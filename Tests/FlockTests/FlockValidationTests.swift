import Foundation
import XCTest
@testable import Flock

final class FlockValidationTests: XCTestCase {
    func testResultIsEqualToRegularDownload() async throws {
        let url = URL(string: "http://212.183.159.230/5MB.zip")!

        let regularDownload = try await URLSession.shared.download(from: url).0
        let flockedDownload = try await URLSession.shared.flock(
            from: url,
            numberOfConnections: 5,
            minimumConnectionSize: 1
        ).0

        defer {
            try? FileManager.default.removeItem(at: regularDownload)
            try? FileManager.default.removeItem(at: flockedDownload)
        }

        XCTAssert(
            FileManager.default.contentsEqual(
                atPath: regularDownload.path(),
                andPath: flockedDownload.path()
            )
        )
    }
}
