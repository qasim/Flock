import Flock
import Foundation

@main
struct Main {
    static func main() async throws {
        let benchmark = Benchmark<URL> { input, clock in
            try await clock.measure {
                blackhole(try await URLSession.shared.flock(from: input))
            }
        }

        print(try await benchmark.run(on: .remoteTestFile(.of100MB)))
    }
}
