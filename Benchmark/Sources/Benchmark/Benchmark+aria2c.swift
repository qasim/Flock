import CollectionsBenchmark
import Foundation
import TSCBasic

extension Benchmark {
    mutating func addAria2cTasks() {
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
            title: "local, fileSize=x, connections=1, aria2c",
            input: LocalTestFile.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "aria2c",
                input.url,
            ])
        }

        let activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount
        addSimple(
            title: "local, fileSize=x, connections=\(activeProcessorCount), aria2c",
            input: LocalTestFile.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "aria2c",
                "--connections", "\(activeProcessorCount)",
                input.url,
            ])
        }
    }

    mutating func addRemoteFileSizeTasks() {
        addSimple(
            title: "remote, fileSize=x, connections=1, aria2c",
            input: RemoteTestFile.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "aria2c",
                input.url,
            ])
        }

        let activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount
        addSimple(
            title: "remote, fileSize=x, connections=\(activeProcessorCount), aria2c",
            input: RemoteTestFile.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "aria2c",
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
            title: "local, connections=x, fileSize=128M, aria2c",
            input: Int.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "aria2c",
                "--connections", "\(input)",
                LocalTestFile.of(134217728).url,
            ])
        }

        addSimple(
            title: "remote, connections=x, fileSize=100M, aria2c",
            input: Int.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "aria2c",
                "--connections", "\(input)",
                "http://localhost/134217728",
            ])
        }
    }
}
