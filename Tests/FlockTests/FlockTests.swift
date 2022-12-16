import XCTest
@testable import Flock

final class FlockTests: XCTestCase {
    func testExample() async throws {
        let url = URL(string: "https://speed.hetzner.de/100MB.bin")!
        _ = try await URLSession.shared.flock(to: url, numberOfConnections: 8, minimumConnectionLength: 1)
    }
}
