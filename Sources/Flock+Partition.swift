import Foundation
import Logging

extension Flock {
    final class Partition: Sendable {
        let request: URLRequest
        let byteRange: ClosedRange<Int>
        let progress: Progress?
        let log: Logger
        let session: URLSession

        init(
            request: URLRequest,
            byteRange: ClosedRange<Int>,
            progress: Progress?,
            log: Logger,
            session: URLSession
        ) {
            self.request = request
            self.byteRange = byteRange
            self.progress = progress

            var log = log
            log[metadataKey: "partitionByteRange"] = "\(byteRange)"
            self.log = log

            self.session = session
        }

        func download() async throws -> (URL, URLResponse) {
            var request = request
            request.setValue(
                "bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)",
                forHTTPHeaderField: "Range"
            )

            log.debug("Downloading")
            return try await session.singleConnectionDownload(from: request, progress: progress)
        }
    }
}
