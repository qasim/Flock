import CollectionsBenchmark
import Foundation
import TSCBasic

let BENCHMARK_SERVER = ProcessInfo.processInfo.environment["FLOCK_BENCHMARK_SERVER"]!

var benchmark = Benchmark(title: "Flock.Benchmark")

benchmark.addFlockTasks()
benchmark.addURLSessionDownloadTasks()

benchmark.main()
