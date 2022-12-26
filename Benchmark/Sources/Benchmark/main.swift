import CollectionsBenchmark
import Foundation
import TSCBasic

precondition(
    FileManager.default.fileExists(atPath: "\(FileManager.default.currentDirectoryPath)/.build/release/support"),
    "support binary missing, run `swift build -c release` first."
)

var benchmark = Benchmark(title: "Flock.Benchmark")

benchmark.registerInputGenerator(for: DownloadTestFile.self, DownloadTestFile.of)

if Process.findExecutable("aria2c") != nil {
    benchmark.addAria2cTasks()
}
if Process.findExecutable("curl") != nil {
    benchmark.addCurlTasks()
}
benchmark.addFlockTasks()
benchmark.addURLSessionDownloadTasks()

benchmark.main()
