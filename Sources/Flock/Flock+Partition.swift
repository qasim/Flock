import Foundation

extension Flock {
    class Partition {
        private var context: Context
        
        let remoteSourceRequest: URLRequest
        let byteRange: ClosedRange<Int>

        init(
            context: Context,
            remoteSourceRequest: URLRequest,
            byteRange: ClosedRange<Int>
        ) {
            self.context = context
            self.context.log[metadataKey: "partitionByteRange"] = "\(byteRange)"

            self.remoteSourceRequest = remoteSourceRequest
            self.byteRange = byteRange
        }

        func download() async throws -> (URL, URLResponse) {
            var request = remoteSourceRequest
            request.setValue(
                "bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)",
                forHTTPHeaderField: "Range"
            )

            context.log.debug("Download starting")
            let (url, response) = try await context.session.download(for: request)

            context.log.debug("Download completed", metadata: ["partitionDestination": "\(url)"])
            return (url, response)
        }
    }
}
