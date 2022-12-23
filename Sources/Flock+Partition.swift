import Foundation

extension Flock {
    class Partition {
        var context: Context
        
        let request: URLRequest
        let byteRange: ClosedRange<Int>
        let progress: Progress?

        init(
            context: Context,
            request: URLRequest,
            byteRange: ClosedRange<Int>,
            progress: Progress?
        ) {
            self.context = context
            self.context.log[metadataKey: "partitionByteRange"] = "\(byteRange)"

            self.request = request
            self.byteRange = byteRange
            self.progress = progress
        }

        func download() async throws -> (URL, URLResponse) {
            var request = request
            request.setValue(
                "bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)",
                forHTTPHeaderField: "Range"
            )

            context.log.debug("Downloading")
            return try await context.session.singleConnectionDownload(
                from: request,
                using: context.fileManager,
                progress: progress
            )
        }
    }
}
