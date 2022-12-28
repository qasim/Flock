import CollectionsBenchmark
import Foundation
import TSCBasic

precondition(
    FileManager.default.fileExists(atPath: "\(FileManager.default.currentDirectoryPath)/.build/release/support"),
    "support binary missing, run `swift build -c release` first."
)

var benchmark = Benchmark(title: "Flock.Benchmark")

benchmark.registerInputGenerator(for: RemoteTestFile.self, RemoteTestFile.of)
benchmark.registerInputGenerator(for: LocalTestFile.self, LocalTestFile.of)

if Process.findExecutable("aria2c") != nil {
    benchmark.addAria2cTasks()
}
if Process.findExecutable("curl") != nil {
    benchmark.addCurlTasks()
}
benchmark.addFlockTasks()
benchmark.addURLSessionDownloadTasks()

benchmark.main()
