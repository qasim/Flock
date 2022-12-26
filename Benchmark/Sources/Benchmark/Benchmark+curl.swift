import CollectionsBenchmark
import Foundation
import TSCBasic

extension Benchmark {
    mutating func addCurlTasks() {
        add(
          title: "curl",
          input: DownloadTestFile.self
        ) { input in
            return { timer in
                timer.measure {
                    try! Process.popen(arguments: [
                        ".build/release/support",
                        "--engine", "curl",
                        input.url
                    ])
                }
            }
        }
    }
}
