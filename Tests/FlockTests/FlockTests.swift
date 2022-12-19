import XCTest
@testable import Flock

final class FlockTests: XCTestCase {
    func testExample() async throws {
        let url = URL(string: "http://212.183.159.230/100MB.zip")!

        _ = try await URLSession.shared.flock(
            from: url,
            numberOfConnections: 8,
            minimumConnectionLength: 1,
            isDebug: true
        )
    }
}
