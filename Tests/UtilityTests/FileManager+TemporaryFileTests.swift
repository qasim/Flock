import Foundation
import XCTest
@testable import Flock

final class FileManagerTemporaryFileTests: XCTestCase {
    func testFileDirectoryIsCorrect() async throws {
        let file = try FileManager.default.flockTemporaryFile()

        XCTAssertEqual(file.pathComponents.dropLast(), FileManager.default.temporaryDirectory.pathComponents)
        XCTAssert(file.pathComponents.last!.hasSuffix(".tmp"))

        try? FileManager.default.removeItem(at: file)
    }

    func testFileNameIsCorrect() async throws {
        let file = try FileManager.default.flockTemporaryFile()

        XCTAssert(file.pathComponents.last!.hasPrefix("Flock_"))
        XCTAssert(file.pathComponents.last!.hasSuffix(".tmp"))

        try? FileManager.default.removeItem(at: file)
    }
}
