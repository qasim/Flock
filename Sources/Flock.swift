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

        log.debug("Preparing initial request")
        let (asyncResume, response) = try await session.download(from: request, to: file, progress: progress)

        guard let contentLength = Int(response.value(forHTTPHeaderField: "Content-Length") ?? "") ?? nil else {
            log.debug("Content-Length header unavailable, downloading initial request")
            try await asyncResume(nil)
            return (file, response)
        }

        await progress.set(totalBytesExpected: contentLength)

        guard contentLength > 0 else {
            log.debug("Content length less than 1, downloading initial request")
            try await asyncResume(nil)
            return (file, response)
        }

        guard response.value(forHTTPHeaderField: "Accept-Ranges") == "bytes" else {
            log.debug("Range header unsupported, downloading initial request")
            try await asyncResume(nil)
            return (file, response)
        }

        let byteRanges = contentLength.ranges(
            whenSplitUpTo: connectionCount,
            minimumPartitionSize: minimumConnectionSize
        )

        guard byteRanges.count > 1 else {
            log.debug("Partitioning produced only 1 range, downloading initial request")
            try await asyncResume(nil)
            return (file, response)
        }

        log.debug("Downloading partitions")
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask { [log] in
                log.debug("Downloading", metadata: ["byteRange": "\(byteRanges[0])"])
                try await asyncResume(byteRanges[0].upperBound + 1)
            }

            for byteRange in byteRanges[1...] {
                taskGroup.addTask { [request, log, session, progress] in
                    var request = request
                    request.setValue(
                        "bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)",
                        forHTTPHeaderField: "Range"
                    )

                    log.debug("Downloading", metadata: ["byteRange": "\(byteRange)"])
                    let (asyncResume, _) = try await session.download(from: request, to: file, at: byteRange.lowerBound, progress: progress)
                    try await asyncResume(nil)
                }
            }

            while try await taskGroup.next() != nil {
                // Continue
            }
        }

        return (file, response)
    }
}
