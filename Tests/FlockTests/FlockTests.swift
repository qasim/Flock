import Foundation
import XCTest
@testable import Flock

final class FlockTests: XCTestCase {
    func testResultIsEqualToRegularDownload() async throws {
        let url = URL(string: "http://212.183.159.230/10MB.zip")!

        let regularDownload = try await URLSession.shared.download(from: url).0
        let flockedDownload = try await URLSession.shared.flock(from: url, minimumConnectionSize: 2_097_152).0

        XCTAssert(
            FileManager.default.contentsEqual(
                atPath: regularDownload.path(),
                andPath: flockedDownload.path()
            )
        )
    }
}
