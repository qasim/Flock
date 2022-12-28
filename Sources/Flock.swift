import Foundation
import Logging

private var isLoggingSystemBootstrapped: Bool = false

/// An object that coordinates the partitioning and concurrent downloading of a file.
final class Flock {
    let request: URLRequest
    let connectionCount: Int
    let minimumConnectionSize: Int
    let bufferSize: Int
    let progress: Progress
    let log: Logger
    let session: URLSession

    init(
        request: URLRequest,
        numberOfConnections connectionCount: Int,
        minimumConnectionSize: Int,
        bufferSize: Int,
        progressDelegate: FlockProgressDelegate?,
        logLevel: Logger.Level,
        session: URLSession
    ) {
        precondition(request.url != nil, "request must have an URL.")

        self.request = request
        self.connectionCount = connectionCount
        self.minimumConnectionSize = minimumConnectionSize
        self.bufferSize = bufferSize
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
        let (asyncBytes, response) = try await session.bytes(for: request) as! (URLSession.AsyncBytes, HTTPURLResponse)

        guard let contentLength = Int(response.value(forHTTPHeaderField: "Content-Length") ?? "") ?? nil else {
            log.debug("Content-Length header unavailable, downloading initial request")
            try await session.download(from: request, asyncBytes, to: file, bufferSize: bufferSize, progress: progress)
            return (file, response)
        }

        await progress.set(totalBytesExpected: contentLength)

        guard contentLength > 0 else {
            log.debug("Content length less than 1, downloading initial request")
            try await session.download(from: request, asyncBytes, to: file, bufferSize: bufferSize, progress: progress)
            return (file, response)
        }

        guard response.value(forHTTPHeaderField: "Accept-Ranges") == "bytes" else {
            log.debug("Range header unsupported, downloading initial request")
            try await session.download(from: request, asyncBytes, to: file, bufferSize: bufferSize, progress: progress)
            return (file, response)
        }

        let byteRanges = contentLength.ranges(
            whenSplitUpTo: connectionCount,
            minimumPartitionSize: minimumConnectionSize
        )

        guard byteRanges.count > 1 else {
            log.debug("Partitioning produced only 1 range, downloading initial request")
            try await session.download(from: request, asyncBytes, to: file, bufferSize: bufferSize, progress: progress)
            return (file, response)
        }

        log.debug("Downloading partitions")
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask { [self] in
                log.debug("Downloading", metadata: ["byteRange": "\(byteRanges[0])"])
                try await session.download(
                    from: request, asyncBytes,
                    to: file,
                    until: byteRanges[0].upperBound + 1,
                    bufferSize: bufferSize,
                    progress: progress
                )
            }

            for byteRange in byteRanges[1...] {
                taskGroup.addTask { [self] in
                    var request = request
                    request.setValue(
                        "bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)",
                        forHTTPHeaderField: "Range"
                    )

                    log.debug("Downloading", metadata: ["byteRange": "\(byteRange)"])
                    try await session.download(
                        from: request,
                        to: file,
                        at: byteRange.lowerBound,
                        bufferSize: bufferSize,
                        progress: progress
                    )
                }
            }

            while try await taskGroup.next() != nil {
                // Continue
            }
        }

        return (file, response)
    }
}
