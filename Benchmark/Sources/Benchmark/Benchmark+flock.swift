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
        addLocalFileSizeTasks()
        addRemoteFileSizeTasks()
    }

    mutating func addLocalFileSizeTasks() {
        addSimple(
            title: "local, fileSize=x, connections=1, Flock",
            input: LocalTestFile.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "flock",
                input.url,
            ])
        }

        let activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount
        addSimple(
            title: "local, fileSize=x, connections=\(activeProcessorCount), Flock",
            input: LocalTestFile.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "flock",
                "--connections", "\(activeProcessorCount)",
                input.url,
            ])
        }
    }

    mutating func addRemoteFileSizeTasks() {
        addSimple(
            title: "remote, fileSize=x, connections=1, Flock",
            input: RemoteTestFile.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "flock",
                input.url,
            ])
        }

        let activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount
        addSimple(
            title: "remote, fileSize=x, connections=\(activeProcessorCount), Flock",
            input: RemoteTestFile.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "flock",
                "--connections", "\(activeProcessorCount)",
                input.url,
            ])
        }
    }
}

// MARK: - Connection Count

private extension Benchmark {
    mutating func addConnectionCountTasks() {
        addSimple(
            title: "local, connections=x, fileSize=128M, Flock",
            input: Int.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "flock",
                "--connections", "\(input)",
                LocalTestFile.of(134217728).url,
            ])
        }

        addSimple(
            title: "remote, connections=x, fileSize=100M, Flock",
            input: Int.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "flock",
                "--connections", "\(input)",
                RemoteTestFile.of100MB.url,
            ])
        }
    }
}
