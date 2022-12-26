import CollectionsBenchmark
import Foundation
import TSCBasic

extension Benchmark {
    mutating func addFlockTasks() {
        let activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount

        add(
          title: "Flock, connections=1",
          input: DownloadTestFile.self
        ) { input in
            return { timer in
                timer.measure {
                    try! Process.popen(arguments: [
                        ".build/release/support",
                        "--engine", "flock",
                        input.url
                    ])
                }
            }
        }

        add(
          title: "Flock, connections=\(activeProcessorCount)",
          input: DownloadTestFile.self
        ) { input in
            return { timer in
                timer.measure {
                    try! Process.popen(arguments: [
                        ".build/release/support",
                        "--engine", "flock",
                        "--connections", "\(activeProcessorCount)",
                        input.url
                    ])
                }
            }
        }
    }
}
