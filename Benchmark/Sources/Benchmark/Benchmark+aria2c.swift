import CollectionsBenchmark
import Foundation
import TSCBasic

extension Benchmark {
    mutating func addAria2cTasks() {
        add(
          title: "aria2c, connections=1",
          input: DownloadTestFile.self
        ) { input in
            return { timer in
                timer.measure {
                    try! Process.popen(arguments: [
                        ".build/release/support",
                        "--engine", "aria2c",
                        input.url
                    ])
                }
            }
        }

        let activeProcessorCount = ProcessInfo.processInfo.activeProcessorCount
        add(
          title: "aria2c, connections=\(activeProcessorCount)",
          input: DownloadTestFile.self
        ) { input in
            return { timer in
                timer.measure {
                    try! Process.popen(arguments: [
                        ".build/release/support",
                        "--engine", "aria2c",
                        "--connections", "\(activeProcessorCount)",
                        input.url
                    ])
                }
            }
        }
    }
}
