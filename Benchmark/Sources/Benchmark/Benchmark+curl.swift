import CollectionsBenchmark
import Foundation
import TSCBasic

extension Benchmark {
    mutating func addCurlTasks() {
        addFileSizeTasks()
    }
}

// MARK: - File Size

extension Benchmark {
    private mutating func addFileSizeTasks() {
        addSimple(
            title: "local, fileSize=x, curl",
            input: LocalTestFile.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "curl",
                input.url,
            ])
        }

        addSimple(
            title: "remote, fileSize=x, curl",
            input: RemoteTestFile.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "curl",
                input.url,
            ])
        }
    }
}
