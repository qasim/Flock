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
            title: "fileSize=x, URLSession.download",
            input: Int.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "urlSessionDownload",
                "\(BENCHMARK_SERVER)/\(input)",
            ])
        }
    }
}
