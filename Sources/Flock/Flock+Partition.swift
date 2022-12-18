import Foundation

extension Flock {
    class Partition {
        private let context: Context
        
        let remoteSourceRequest: URLRequest
        let byteRange: ClosedRange<Int>

        init(
            context: Context,
            remoteSourceRequest: URLRequest,
            byteRange: ClosedRange<Int>
        ) {
            self.context = context
            self.remoteSourceRequest = remoteSourceRequest
            self.byteRange = byteRange
        }

        func download() async throws -> (URL, URLResponse) {
            var request = remoteSourceRequest
            request.setValue(
                "bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)",
                forHTTPHeaderField: "Range"
            )

            print("\(request.value(forHTTPHeaderField: "Range")!): Downloading")
            let (url, response) = try await context.session.download(for: request)

            print("\(byteRange): \(url.absoluteString)")

            print("\(request.value(forHTTPHeaderField: "Range")!): Finished")

            return (url, response)
        }
    }
}
