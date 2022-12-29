import CollectionsBenchmark
import Foundation
import TSCBasic

extension Benchmark {
    mutating func addURLSessionDownloadTasks() {
        addFileSizeTasks()
    }
}

// MARK: - File Size

extension Benchmark {
    private mutating func addFileSizeTasks() {
        addSimple(
            title: "local, fileSize=x, URLSession.download",
            input: LocalTestFile.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "curl",
                input.url,
            ])
        }

        addSimple(
            title: "remote, fileSize=x, URLSession.download",
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
