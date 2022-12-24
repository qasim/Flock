import Foundation
import Logging

private var isLoggingSystemBootstrapped: Bool = false

/// An object that coordinates the partitioning and concurrent downloading of a file.
final class Flock {
    let request: URLRequest
    let connectionCount: Int
    let minimumConnectionSize: Int
    weak var progressDelegate: FlockProgressDelegate?
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
        self.progressDelegate = progressDelegate

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
        var headRequest = request
        headRequest.httpMethod = "HEAD"

        log.debug("Fetching headers")
        let headResponse = try await session.bytes(for: headRequest).1 as! HTTPURLResponse

        let contentLength = Int(headResponse.value(forHTTPHeaderField: "Content-Length") ?? "") ?? 0

        let progress = Progress(
            totalBytesExpected: contentLength,
            delegate: SendableFlockProgressDelegate(progressDelegate)
        )

        guard contentLength > 0 else {
            log.debug("Content length unavailable, falling back to single-connection download")
            return try await session.singleConnectionDownload(from: request, progress: progress)
        }

        guard headResponse.value(forHTTPHeaderField: "Accept-Ranges") == "bytes" else {
            log.debug("Range header unsupported, falling back to single-connection download")
            return try await session.singleConnectionDownload(from: request, progress: progress)
        }

        let byteRanges = contentLength.ranges(
            whenSplitUpTo: connectionCount,
            minimumPartitionSize: minimumConnectionSize
        )

        guard byteRanges.count > 1 else {
            log.debug("Partitioning produced only 1 range, falling back to single-connection download")
            return try await session.singleConnectionDownload(from: request, progress: progress)
        }

        let partitions = byteRanges.map { byteRange in
            Partition(
                request: request,
                byteRange: byteRange,
                progress: progress,
                log: log,
                session: session
            )
        }

        log.debug("Downloading partitions")
        let partitionResults = try await withThrowingTaskGroup(
            of: (Partition, URL).self,
            returning: [(Partition, URL)].self
        ) { taskGroup in
            for partition in partitions {
                taskGroup.addTask {
                    return (partition, try await partition.download().0)
                }
            }

            var result: [(Partition, URL)] = []
            while let (partition, url) = try await taskGroup.next() {
                result.append((partition, url))
            }

            return result
        }

        let destinationURL = try FileManager.default.flockTemporaryFile()

        log.debug("Merging partitions", metadata: ["destination": "\(destinationURL.backportedPath)"])
        try FileManager.default.merge(
            partitionResults
                .sorted { lhs, rhs in
                    lhs.0.byteRange.upperBound < rhs.0.byteRange.lowerBound
                }
                .map(\.1),
            to: destinationURL
        )

        defer {
            log.debug("Deleting partitions")
            for (_, partitionURL) in partitionResults {
                do {
                    try FileManager.default.removeItem(at: partitionURL)
                } catch {
                    log.warning(
                        "Failed to delete partition",
                        metadata: ["location": "\(partitionURL.backportedPath)", "error": "\(error)"]
                    )
                }
            }
        }

        return (destinationURL, headResponse)
    }
}
