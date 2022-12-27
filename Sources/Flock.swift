import Foundation
import Logging

private var isLoggingSystemBootstrapped: Bool = false

/// An object that coordinates the partitioning and concurrent downloading of a file.
final class Flock {
    let request: URLRequest
    let connectionCount: Int
    let minimumConnectionSize: Int
    let progress: Progress
    let log: Logger
    let session: URLSession

    init(
        request: URLRequest,
        numberOfConnections connectionCount: Int,
        minimumConnectionSize: Int,
        progressDelegate: FlockProgressDelegate?,
        logLevel: Logger.Level,
        session: URLSession
    ) {
        precondition(request.url != nil, "request must have an URL.")

        self.request = request
        self.connectionCount = connectionCount
        self.minimumConnectionSize = minimumConnectionSize
        self.progress = Progress(delegate: SendableFlockProgressDelegate(progressDelegate))

        if !isLoggingSystemBootstrapped {
            LoggingSystem.bootstrap(StreamLogHandler.standardOutput)
            isLoggingSystemBootstrapped = true
        }
        var log = Logger(label: "Flock")
        log.logLevel = logLevel
        log[metadataKey: "url"] = "\(request.url!)"
        log.debug("Logger initialized")
        self.log = log

        self.session = session
    }

    func download() async throws -> (URL, URLResponse) {
        let file = try FileManager.default.flockTemporaryFile()

        log.debug("Fetching headers")
        var headRequest = request
        headRequest.httpMethod = "HEAD"
        let headResponse: HTTPURLResponse
        do {
            headResponse = try await session.response(from: headRequest)
        } catch {
            log.warning(
                "Headers fetch failed, falling back to single-connection download",
                metadata: ["error": "\(error)"]
            )
            return (file, try await session.download(from: request, to: file, progress: progress))
        }

        guard let contentLength = Int(headResponse.value(forHTTPHeaderField: "Content-Length") ?? "") ?? nil else {
            log.debug("Content-Length header unavailable, falling back to single-connection download")
            return (file, try await session.download(from: request, to: file, progress: progress))
        }

        await progress.set(totalBytesExpected: contentLength)

        guard contentLength > 0 else {
            log.debug("Content length less than 1, falling back to single-connection download")
            return (file, try await session.download(from: request, to: file, progress: progress))
        }

        guard headResponse.value(forHTTPHeaderField: "Accept-Ranges") == "bytes" else {
            log.debug("Range header unsupported, falling back to single-connection download")
            return (file, try await session.download(from: request, to: file, progress: progress))
        }

        let byteRanges = contentLength.ranges(
            whenSplitUpTo: connectionCount,
            minimumPartitionSize: minimumConnectionSize
        )

        guard byteRanges.count > 1 else {
            log.debug("Partitioning produced only 1 range, falling back to single-connection download")
            return (file, try await session.download(from: request, to: file, progress: progress))
        }

        log.debug("Downloading partitions")
        try await withThrowingTaskGroup(
            of: Void.self,
            returning: Void.self
        ) { taskGroup in
            for byteRange in byteRanges {
                taskGroup.addTask { [self] in
                    var request = request
                    request.setValue(
                        "bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)",
                        forHTTPHeaderField: "Range"
                    )

                    try await session.download(from: request, to: file, at: byteRange.lowerBound, progress: progress)
                }
            }

            while try await taskGroup.next() != nil {
                // Continue
            }
        }

        return (file, headResponse)
    }
}
