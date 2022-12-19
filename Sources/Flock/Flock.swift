import Foundation
import Logging

class Flock {
    private var context: Context
    private let remoteSourceRequest: URLRequest
    private let connectionCount: Int
    private let minimumConnectionLength: Int

    init(
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

    func download() async throws -> (URL, URLResponse) {
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
            while let (url, partition) = try await taskGroup.next() {
                result.append((url, partition))
            }

            return result
        }

        // TODO: Merge partitions into single file
        // TODO: Return the single file's URL

        return (partitionResults.first!.1, headResponse)
    }
}
