import Foundation

extension Flock {
    class Partition {
        var context: Context
        
        let sourceRequest: URLRequest
        let byteRange: ClosedRange<Int>
        let progress: Progress?

        init(
            context: Context,
            sourceRequest: URLRequest,
            byteRange: ClosedRange<Int>,
            progress: Progress?
        ) {
            self.context = context
            self.context.log[metadataKey: "partitionByteRange"] = "\(byteRange)"

            self.sourceRequest = sourceRequest
            self.byteRange = byteRange
            self.progress = progress
        }

        func download() async throws -> (URL, URLResponse) {
            var request = sourceRequest
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
