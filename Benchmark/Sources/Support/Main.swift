import ArgumentParser
import Flock
import Foundation
import TSCBasic

@main
struct Main: AsyncParsableCommand {
    enum Engine: String, ExpressibleByArgument {
        case aria2c
        case curl
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
        switch engine {
        case .aria2c:
            let directory = FileManager.default.temporaryDirectory.path()
            let output = "aria2c_\(UUID().uuidString).tmp"
            let process = "\(ProcessInfo.processInfo.processIdentifier)"
            try Process.popen(arguments: [
                "aria2c",
                "--split", "\(connections)",
                "--max-connection-per-server", "\(connections)",
                "--min-split-size", "1048576", // minimum possible split
                "--dir", directory,
                "--out", output,
                "--stop-with-process", process,
                url,
            ])

        case .curl:
            precondition(connections == 1, "multiple connections not supported.")
            let output = FileManager.default.temporaryDirectory.appending(
                component: "curl_\(UUID().uuidString).tmp"
            ).path()
            try Process.popen(arguments: [
                "curl",
                "--output", output,
                url,
            ])

        case .flock:
            _ = try await URLSession.shared.flock(
                from: URL(string: url)!,
                numberOfConnections: connections,
                minimumConnectionSize: 1
            )

        case .urlSessionDownload:
            precondition(connections == 1, "multiple connections not supported.")
            _ = try await URLSession.shared.download(from: URL(string: url)!)
        }
    }
}
