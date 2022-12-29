import Foundation
import XCTest
@testable import Flock

final class FlockValidationTests: XCTestCase {
    func testMultiConnectionDownloadIsEqualToRegularDownload() async throws {
        let url = URL(string: "http://212.183.159.230/5MB.zip")!

        let regularDownload = try await URLSession.shared.download(from: url).0
        let flockedDownload = try await URLSession.shared.flock(
            from: url,
            numberOfConnections: 5,
            minimumConnectionSize: 1
        ).0

        XCTAssert(
            FileManager.default.contentsEqual(
                atPath: regularDownload.pathBackported,
                andPath: flockedDownload.pathBackported
            )
        )

        try? FileManager.default.removeItem(at: regularDownload)
        try? FileManager.default.removeItem(at: flockedDownload)
    }

    func testSingleConnectionDownloadIsEqualToRegularDownload() async throws {
        let url = URL(string: "http://212.183.159.230/5MB.zip")!

        let regularDownload = try await URLSession.shared.download(from: url).0
        let flockedDownload = try await URLSession.shared.flock(
            from: url,
            numberOfConnections: 1,
            minimumConnectionSize: 1
        ).0

        XCTAssert(
            FileManager.default.contentsEqual(
                atPath: regularDownload.pathBackported,
                andPath: flockedDownload.pathBackported
            )
        )

        try? FileManager.default.removeItem(at: regularDownload)
        try? FileManager.default.removeItem(at: flockedDownload)
    }
}
