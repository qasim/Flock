import ArgumentParser
import Flock
import Foundation
import TSCBasic

@main
struct Main: AsyncParsableCommand {
    enum Engine: String, ExpressibleByArgument {
        case flock
        case urlSessionDownload
    }

    @Option
    var engine: Engine

    @Option
    var connections: Int = 1

    @Argument
    var url: String

    func run() async throws {
        let url = URL(string: url)!
        switch engine {
        case .flock:
            _ = try await URLSession.shared.flock(
                from: url,
                numberOfConnections: connections,
                minimumConnectionSize: 1
            )

        case .urlSessionDownload:
            precondition(connections == 1, "multiple connections not supported.")
            _ = try await URLSession.shared.download(from: url)
        }
    }
}
