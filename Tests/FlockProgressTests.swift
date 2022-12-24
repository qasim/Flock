import Foundation
import XCTest
@testable import Flock

final class FlockProgressTests: XCTestCase {
    func testProgress() async throws {
        let url = URL(string: "http://212.183.159.230/5MB.zip")!

        let testProgressDelegate = TestProgressDelegate()
        let flockedDownload = try await URLSession.shared.flock(
            from: url,
            numberOfConnections: 5,
            minimumConnectionSize: 1,
            progressDelegate: testProgressDelegate
        ).0

        defer {
            try? FileManager.default.removeItem(at: flockedDownload)
        }

        XCTAssertEqual(testProgressDelegate.numberOfCalls, 80)
        XCTAssertEqual(testProgressDelegate.totalBytesReceived, testProgressDelegate.totalBytesExpected)
    }
}

private class TestProgressDelegate: FlockProgressDelegate {
    var numberOfCalls: Int = 0
    var totalBytesReceived: Int!
    var totalBytesExpected: Int?

    func request(
        _ request: URLRequest,
        didReceiveBytes bytesReceived: Int,
        totalBytesReceived: Int,
        totalBytesExpected: Int?
    ) {
        numberOfCalls += 1
        self.totalBytesReceived = totalBytesReceived
        self.totalBytesExpected = totalBytesExpected
    }
}
