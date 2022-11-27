import Foundation

extension URLSession {
    public func flock(
        _ remoteSource: URL,
        to localDestination: URL,
        numberOfConnections connectionCount: Int = 16,
        memoryLimit: Int = 67_108_864
    ) async throws {
        let request = URLRequest(url: remoteSource)
        let response = try await bytes(forHTTP: request).1

        let metadata = ResponseMetadata(response)
        print(metadata)

        let ranges = metadata.contentLength.slices(whenCutInto: connectionCount)
        print(ranges)

        let requests = ranges.map { range in
            var request = URLRequest(url: remoteSource)
            request.setValue("bytes=\(range.lowerBound)-\(range.upperBound)", forHTTPHeaderField: "Range")
            return request
        }

        await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for request in requests {
                taskGroup.addTask {
                    print("\(request.value(forHTTPHeaderField: "Range")!): Starting")
                    let (bytes, _) = try await self.bytes(forHTTP: request)
                    print("\(request.value(forHTTPHeaderField: "Range")!): Downloading")
                    for try await _ in bytes {
                        // Read all data
                    }
                    print("\(request.value(forHTTPHeaderField: "Range")!): Finished")
                }
            }
        }
    }
}

struct ResponseMetadata {
    enum RangeUnit: String {
        case bytes
        case none
    }
    let acceptRanges: RangeUnit
    let contentLength: Int

    init(_ response: HTTPURLResponse) {
        self.acceptRanges = RangeUnit(rawValue: response.value(forHTTPHeaderField: "Accept-Ranges") ?? "") ?? .none
        self.contentLength = Int(response.value(forHTTPHeaderField: "Content-Length") ?? "") ?? 0
    }
}
