import Foundation

class Flock {
    let context: Context
    let remoteSource: URL
    let connectionCount: Int
    let minimumConnectionLength: Int

    init(
        context: Context,
        remoteSource: URL,
        numberOfConnections connectionCount: Int,
        minimumConnectionLength: Int
    ) {
        self.context = context
        self.remoteSource = remoteSource
        self.connectionCount = connectionCount
        self.minimumConnectionLength = minimumConnectionLength
    }

    func download() async throws -> URL {
        let request = URLRequest(url: remoteSource)
        let response = try await context.session.bytes(forHTTP: request).1

        guard response.value(forHTTPHeaderField: "Accept-Ranges") == "bytes" else {
            throw Error.rangeHeaderUnsupported(remoteSource)
        }

        let contentLength = Int(response.value(forHTTPHeaderField: "Content-Length") ?? "") ?? 0
        let byteRanges = contentLength.ranges(
            whenSplitUpTo: connectionCount,
            minimumPartitionLength: minimumConnectionLength
        )
        print(byteRanges)

        let localDirectory = context.fileManager.temporaryDirectory.appending(
            component: remoteSource.absoluteString,
            directoryHint: .isDirectory
        )
        //try context.fileManager.createDirectory(at: localDirectory)

        let partitions = byteRanges.map { range in
            Partition(
                context: context,
                remoteSource: remoteSource,
                byteRange: range,
                localDestination: localDirectory.appending(component: "")
            )
        }

        // TODO: Fetch all partitions
        await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for partition in partitions {
                taskGroup.addTask {
                    var request = URLRequest(url: partition.remoteSource)
                    request.setValue(
                        "bytes=\(partition.byteRange.lowerBound)-\(partition.byteRange.upperBound)",
                        forHTTPHeaderField: "Range"
                    )

                    print("\(request.value(forHTTPHeaderField: "Range")!): Starting")
                    let (bytes, _) = try await partition.context.session.bytes(forHTTP: request)

                    print("\(request.value(forHTTPHeaderField: "Range")!): Downloading")
                    for try await _ in bytes {
                        // Read all data
                    }

                    print("\(request.value(forHTTPHeaderField: "Range")!): Finished")
                }
            }
        }

        // TODO: Merge partitions into single file
        // TODO: Return the single file's URL

        return localDirectory
    }
}
