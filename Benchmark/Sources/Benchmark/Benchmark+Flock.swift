import CollectionsBenchmark
import Foundation
import TSCBasic

extension Benchmark {
    mutating func addFlockTasks() {
        addFileSizeTasks()
        addConnectionCountTasks()
    }
}

// MARK: - File Size

private extension Benchmark {
    mutating func addFileSizeTasks() {
        addSimple(
            title: "fileSize=x, connections=1, Flock",
            input: Int.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "flock",
                "\(BENCHMARK_SERVER)/\(input)",
            ])
        }

        addSimple(
            title: "fileSize=x, connections=8, Flock",
            input: Int.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "flock",
                "--connections", "8",
                "\(BENCHMARK_SERVER)/\(input)",
            ])
        }
    }
}

// MARK: - Connection Count

private extension Benchmark {
    mutating func addConnectionCountTasks() {
        addSimple(
            title: "connections=x, fileSize=128M, Flock",
            input: Int.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "flock",
                "--connections", "\(input)",
                "\(BENCHMARK_SERVER)/134217728",
            ])
        }
    }
}
