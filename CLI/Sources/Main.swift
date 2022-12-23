import ArgumentParser
import Flock
import Foundation

@main
struct Main: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "flock",
        abstract: "Rapid file download using concurrent connections."
    )

    @Argument(help: "An URL to download.")
    var remoteSource: String

    @Option(
        name: .shortAndLong,
        help: """
        The maximum number of connections to create in parallel.
        """
    )
    var connectionCount: Int = ProcessInfo.processInfo.activeProcessorCount

    @Option(
        name: .shortAndLong,
        help: "The minimum size, in bytes, for each connection."
    )
    var minimumConnectionSize: Int = 16777216

    @Flag(name: .shortAndLong, help: "Whether or not verbose logs should be printed to standard output.")
    var verbose: Bool = false

    mutating func run() async throws {
        print("TODO")
    }
}
