import CollectionsBenchmark
import Foundation
import TSCBasic

extension Benchmark {
    mutating func addURLSessionDownloadTasks() {
        add(
          title: "URLSession.download",
          input: DownloadTestFile.self
        ) { input in
            return { timer in
                timer.measure {
                    try! Process.popen(arguments: [
                        ".build/release/support",
                        "--engine", "urlSessionDownload",
                        input.url
                    ])
                }
            }
        }
    }
}
