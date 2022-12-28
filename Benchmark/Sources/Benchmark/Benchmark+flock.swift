import CollectionsBenchmark
import Foundation
import TSCBasic

extension Benchmark {
    mutating func addFlockTasks() {
        addFileSizeTasks()
        addConnectionCountTasks()
        addBufferSizeTasks()
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

// MARK: - Buffer Size

extension Benchmark {
    private mutating func addBufferSizeTasks() {
        addLocalBufferSizeTasks()
        addRemoteBufferSizeTasks()
    }

    private mutating func addLocalBufferSizeTasks() {
        addSimple(
            title: "local, bufferSize=x, connections=1, fileSize=128M, Flock",
            input: Int.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "flock",
                "--buffer-size", "\(input)",
                "--connections", "1",
                LocalTestFile.of(134217728).url,
            ])
        }

        let activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount
        addSimple(
            title: "local, bufferSize=x, connections=\(activeProcessorCount), fileSize=128M, Flock",
            input: Int.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "flock",
                "--buffer-size", "\(input)",
                "--connections", "\(activeProcessorCount)",
                LocalTestFile.of(134217728).url,
            ])
        }
    }

    private mutating func addRemoteBufferSizeTasks() {
        addSimple(
            title: "remote, bufferSize=x, connections=1, fileSize=100M, Flock",
            input: Int.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "flock",
                "--buffer-size", "\(input)",
                "--connections", "1",
                RemoteTestFile.of100MB.url,
            ])
        }

        let activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount
        addSimple(
            title: "remote, bufferSize=x, connections=\(activeProcessorCount), fileSize=100M, Flock",
            input: Int.self
        ) { input in
            try! Process.popen(arguments: [
                ".build/release/support",
                "--engine", "flock",
                "--buffer-size", "\(input)",
                "--connections", "\(activeProcessorCount)",
                RemoteTestFile.of100MB.url,
            ])
        }
    }
}
