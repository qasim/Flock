import Foundation
import Logging

public final class Flock {
    var context: Context
    let remoteSourceRequest: URLRequest
    let connectionCount: Int
    let minimumConnectionLength: Int

    public init(
        context: Context,
        remoteSourceRequest: URLRequest,
        numberOfConnections connectionCount: Int,
        minimumConnectionLength: Int
    ) {
        precondition(remoteSourceRequest.url != nil, "request must have an URL.")

        self.context = context
        self.context.log[metadataKey: "source"] = "\(remoteSourceRequest.url!)"

        self.remoteSourceRequest = remoteSourceRequest
        self.connectionCount = connectionCount
        self.minimumConnectionLength = minimumConnectionLength
    }

    public func download() async throws -> (URL, URLResponse) {
        var headRequest = remoteSourceRequest
        headRequest.httpMethod = "HEAD"

        context.log.debug("Fetching headers")
        let headResponse = try await context.session.bytes(for: headRequest).1 as! HTTPURLResponse

        guard headResponse.value(forHTTPHeaderField: "Accept-Ranges") == "bytes" else {
            context.log.debug("Range header unsupported, falling back to single-connection download")
            return try await context.session.download(for: remoteSourceRequest)
        }

        let contentLength = Int(headResponse.value(forHTTPHeaderField: "Content-Length") ?? "") ?? 0
        let byteRanges = contentLength.ranges(
            whenSplitUpTo: connectionCount,
            minimumPartitionLength: minimumConnectionLength
        )

        guard byteRanges.count > 1 else {
            context.log.debug("Partitioning produced only 1 range, falling back to single-connection download")
            return try await context.session.download(for: remoteSourceRequest)
        }

        let partitions = byteRanges.map { byteRange in
            Partition(
                context: context,
                remoteSourceRequest: remoteSourceRequest,
                byteRange: byteRange
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

        let destinationURL = context.fileManager
            .temporaryDirectory
            .appending(components: "FlockDownload_\(UUID().uuidString).tmp")
        context.log[metadataKey: "destination"] = "\(destinationURL)"

        context.log.debug("Merging partitions into destination")
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
