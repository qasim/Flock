import ArgumentParser
import Flock
import Foundation

@main
struct Main: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "flock",
        abstract: "Rapid file download using concurrent connections."
    )

    @Argument(help: "The URL to download.")
    var url: String

    @Option(name: .shortAndLong, help: "The maximum number of connections to create in parallel.")
    var connectionCount: Int = ProcessInfo.processInfo.activeProcessorCount

    @Option(name: .shortAndLong, help: "The minimum size, in bytes, for each connection.")
    var minimumConnectionSize: Int = 16777216

    @Flag(name: .shortAndLong, help: "Whether or not verbose logs should be printed to standard output.")
    var verbose: Bool = false

    mutating func run() async throws {
        print("Preparing")
        let (url, _) = try await URLSession.shared.flock(
            from: URL(string: url)!,
            numberOfConnections: connectionCount,
            minimumConnectionSize: minimumConnectionSize,
            progressDelegate: ProgressDelegate(),
            isVerbose: verbose
        )
        print("\u{1B}[1A\u{1B}[K\(url.path)")
    }
}

class ProgressDelegate: FlockProgressDelegate {
    func request(_ request: URLRequest, didReceiveBytes bytesReceived: Int, totalBytesReceived: Int, totalBytesExpected: Int) {
        print("\u{1B}[1A\u{1B}[KDownloading: \(totalBytesReceived) / \(totalBytesExpected)")
    }
}
