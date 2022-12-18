import Foundation

class Flock {
    let context: Context
    let remoteSourceRequest: URLRequest
    let connectionCount: Int
    let minimumConnectionLength: Int

    init(
        context: Context,
        remoteSourceRequest: URLRequest,
        numberOfConnections connectionCount: Int,
        minimumConnectionLength: Int
    ) {
        self.context = context
        self.remoteSourceRequest = remoteSourceRequest
        self.connectionCount = connectionCount
        self.minimumConnectionLength = minimumConnectionLength
    }

    func download() async throws -> (URL, URLResponse) {
        let response = try await context.session.bytes(for: remoteSourceRequest).1 as! HTTPURLResponse

        guard response.value(forHTTPHeaderField: "Accept-Ranges") == "bytes" else {
            // Range header unsupported, fallback to single-connection download
            return try await context.session.download(for: remoteSourceRequest)
        }

        let contentLength = Int(response.value(forHTTPHeaderField: "Content-Length") ?? "") ?? 0
        let byteRanges = contentLength.ranges(
            whenSplitUpTo: connectionCount,
            minimumPartitionLength: minimumConnectionLength
        )

        guard byteRanges.count > 1 else {
            // Only 1 connection needed, fallback to single-connection download
            return try await context.session.download(for: remoteSourceRequest)
        }

        let partitions = byteRanges.map { byteRange in
            Partition(
                context: context,
                remoteSourceRequest: remoteSourceRequest,
                byteRange: byteRange
            )
        }

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

        print(partitionResults)

        // TODO: Merge partitions into single file
        // TODO: Return the single file's URL

        return (partitionResults.first!.1, response)
    }
}
