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

    enum Verbosity: EnumerableFlag {
        case quiet
        case verbose

        static func name(for value: Verbosity) -> NameSpecification {
            NameSpecification([.short, .long])
        }

        static func help(for value: Verbosity) -> ArgumentHelp? {
            switch value {
            case .quiet: return "Skip progress reporting."
            case .verbose: return "Print verbose logs."
            }
        }
    }

    @Flag
    var verbosity: Verbosity?

    mutating func run() async throws {
        if verbosity != .quiet {
            print("Preparing")
        }

        let prefix = verbosity == nil ? "\u{1B}[1A\u{1B}[K" : ""

        let (url, _) = try await URLSession.shared.flock(
            from: URL(string: url)!,
            numberOfConnections: connectionCount,
            minimumConnectionSize: minimumConnectionSize,
            progressDelegate: verbosity != .quiet ? ProgressDelegate(prefix) : nil,
            isVerbose: verbosity == .verbose
        )

        print("\(prefix)\(url.path)")
    }
}

class ProgressDelegate: FlockProgressDelegate {
    let prefix: String

    init(_ prefix: String) {
        self.prefix = prefix
    }

    func request(_ request: URLRequest, didReceiveBytes bytesReceived: Int, totalBytesReceived: Int, totalBytesExpected: Int) {
        print("\(prefix)Downloading: \(totalBytesReceived) / \(totalBytesExpected)")
    }
}
