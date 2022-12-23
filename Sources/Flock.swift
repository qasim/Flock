import Foundation
import Logging

/// An object that coordinates the partitioning and concurrent downloading of a file.
public final class Flock {
    var context: Context
    let request: URLRequest
    let connectionCount: Int
    let minimumConnectionSize: Int

    /// The delegate assigned when this object was created.
    public private(set) weak var progressDelegate: FlockProgressDelegate?

    var progress: Progress?

    /// - Parameters:
    ///     - context:               A structure containing configuration and dependencies for Flock to reference.
    ///     - request:               The request to download.
    ///     - connectionCount:       The maximum number of connections to create in parallel.
    ///     - minimumConnectionSize: The minimum size, in bytes, for each connection.
    ///     - progressDelegate:      A delegate that receives progress updates for the download.
    public init(
        context: Context,
        request: URLRequest,
        numberOfConnections connectionCount: Int,
        minimumConnectionSize: Int,
        progressDelegate: FlockProgressDelegate?
    ) {
        precondition(request.url != nil, "request must have an URL.")

        self.context = context
        self.context.log[metadataKey: "url"] = "\(request.url!)"

        self.request = request
        self.connectionCount = connectionCount
        self.minimumConnectionSize = minimumConnectionSize
        self.progressDelegate = progressDelegate
    }

    /// Downloads the file.
    ///
    /// If the `URL` supports the `Range` HTTP header, the file will be partitioned and downloaded using multiple
    /// concurrent connections based on the given parameters.
    ///
    /// - Returns: An asynchronously-delivered tuple that contains the location of the downloaded file as an `URL`, and
    ///            an `URLResponse`.
    public func download() async throws -> (URL, URLResponse) {
        var headRequest = request
        headRequest.httpMethod = "HEAD"

        context.log.debug("Fetching headers")
        let headResponse = try await context.session.bytes(for: headRequest).1 as! HTTPURLResponse

        let contentLength = Int(headResponse.value(forHTTPHeaderField: "Content-Length") ?? "") ?? 0

        if contentLength > 0 {
            progress = Progress(totalBytesExpected: contentLength, delegate: progressDelegate)
        }

        guard headResponse.value(forHTTPHeaderField: "Accept-Ranges") == "bytes" else {
            context.log.debug("Range header unsupported, falling back to single-connection download")
            return try await context.session.singleConnectionDownload(
                from: request,
                using: context.fileManager,
                progress: progress
            )
        }

        let byteRanges = contentLength.ranges(
            whenSplitUpTo: connectionCount,
            minimumPartitionSize: minimumConnectionSize
        )

        guard byteRanges.count > 1 else {
            context.log.debug("Partitioning produced only 1 range, falling back to single-connection download")
            return try await context.session.singleConnectionDownload(
                from: request,
                using: context.fileManager,
                progress: progress
            )
        }

        let partitions = byteRanges.map { byteRange in
            Partition(
                context: context,
                request: request,
                byteRange: byteRange,
                progress: progress
            )
        }

        context.log.debug("Downloading partitions")
        let partitionResults = try await withThrowingTaskGroup(
            of: (Partition, URL).self,
            returning: [(Partition, URL)].self
        ) { taskGroup in
            for partition in partitions {
                taskGroup.addTask {
                    return (partition, try await partition.download().0)
                }
            }

            var result: [(Partition, URL)] = []
            while let (partition, url) = try await taskGroup.next() {
                result.append((partition, url))
            }

            return result
        }

        let destinationURL = context.fileManager.flockTemporaryFile
        context.log[metadataKey: "destination"] = "\(destinationURL)"

        context.log.debug("Merging partitions")
        try context.fileManager.merge(
            partitionResults
                .sorted { lhs, rhs in
                    lhs.0.byteRange.upperBound < rhs.0.byteRange.lowerBound
                }
                .map(\.1),
            to: destinationURL
        )

        defer {
            context.log.debug("Deleting partitions")
            for (_, partitionURL) in partitionResults {
                do {
                    try context.fileManager.removeItem(at: partitionURL)
                } catch {
                    context.log.warning(
                        "Failed to delete partition",
                        metadata: ["url": "\(partitionURL)", "error": "\(error)"]
                    )
                }
            }
        }

        return (destinationURL, headResponse)
    }
}
