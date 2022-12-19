import Foundation

extension Flock {
    class Partition {
        var context: Context
        
        let remoteSourceRequest: URLRequest
        let byteRange: ClosedRange<Int>
        let progress: Progress?

        init(
            context: Context,
            remoteSourceRequest: URLRequest,
            byteRange: ClosedRange<Int>,
            progress: Progress?
        ) {
            self.context = context
            self.context.log[metadataKey: "partitionByteRange"] = "\(byteRange)"

            self.remoteSourceRequest = remoteSourceRequest
            self.byteRange = byteRange
            self.progress = progress
        }

        func download() async throws -> (URL, URLResponse) {
            var request = remoteSourceRequest
            request.setValue(
                "bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)",
                forHTTPHeaderField: "Range"
            )

            context.log.debug("Downloading")
            return try await context.session.singleConnectionDownload(from: request, progress: progress)
        }
    }
}
