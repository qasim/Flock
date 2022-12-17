import Foundation

extension Flock {
    class Partition {
        private let context: Context
        
        let remoteSource: URL
        let byteRange: ClosedRange<Int>

        init(
            context: Context,
            remoteSource: URL,
            byteRange: ClosedRange<Int>
        ) {
            self.context = context
            self.remoteSource = remoteSource
            self.byteRange = byteRange
        }

        func download() async throws -> (URL, URLResponse) {
            var request = URLRequest(url: remoteSource)
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
