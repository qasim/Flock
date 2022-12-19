import Foundation
import Logging

public final class Flock {
    var context: Context
    let remoteSourceRequest: URLRequest
    let connectionCount: Int
    let minimumConnectionSize: Int

    public weak var progressDelegate: FlockProgressDelegate?
    var progress: Progress?

    public init(
        context: Context,
        remoteSourceRequest: URLRequest,
        numberOfConnections connectionCount: Int,
        minimumConnectionSize: Int,
        progressDelegate: FlockProgressDelegate?
    ) {
        precondition(remoteSourceRequest.url != nil, "request must have an URL.")

        self.context = context
        self.context.log[metadataKey: "source"] = "\(remoteSourceRequest.url!)"

        self.remoteSourceRequest = remoteSourceRequest
        self.connectionCount = connectionCount
        self.minimumConnectionSize = minimumConnectionSize
        self.progressDelegate = progressDelegate
    }

    public func download() async throws -> (URL, URLResponse) {
        var headRequest = remoteSourceRequest
        headRequest.httpMethod = "HEAD"

        context.log.debug("Fetching headers")
        let headResponse = try await context.session.bytes(for: headRequest).1 as! HTTPURLResponse

        let contentLength = Int(headResponse.value(forHTTPHeaderField: "Content-Length") ?? "") ?? 0

        if contentLength > 0 {
            progress = Progress(totalBytesExpected: contentLength, delegate: progressDelegate)
        }

        guard headResponse.value(forHTTPHeaderField: "Accept-Ranges") == "bytes" else {
            context.log.debug("Range header unsupported, falling back to single-connection download")
            return try await context.session.singleConnectionDownload(from: remoteSourceRequest, progress: progress)
        }

        let byteRanges = contentLength.ranges(
            whenSplitUpTo: connectionCount,
            minimumPartitionSize: minimumConnectionSize
        )

        guard byteRanges.count > 1 else {
            context.log.debug("Partitioning produced only 1 range, falling back to single-connection download")
            return try await context.session.singleConnectionDownload(from: remoteSourceRequest, progress: progress)
        }

        let partitions = byteRanges.map { byteRange in
            Partition(
                context: context,
                remoteSourceRequest: remoteSourceRequest,
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

        let destinationURL = context.fileManager.temporaryFile
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
                    context.log.warning("Failed to delete partition", metadata: ["url": "\(partitionURL)", "error": "\(error)"])
                }
            }
        }

        return (destinationURL, headResponse)
    }
}
