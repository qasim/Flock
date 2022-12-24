import Foundation
import XCTest
@testable import Flock

final class FileManagerMergeTests: XCTestCase {
    func testFilesMergedCorrectly() async throws {
        let partitions = [
            try FileManager.default.flockTemporaryFile(),
            try FileManager.default.flockTemporaryFile(),
            try FileManager.default.flockTemporaryFile(),
        ]

        for (index, partition) in partitions.enumerated() {
            try "\(index)".write(to: partition, atomically: false, encoding: .utf8)
        }

        let destination = try FileManager.default.flockTemporaryFile()
        try FileManager.default.merge(partitions, to: destination)

        XCTAssertEqual(
            try String(contentsOf: destination, encoding: .utf8),
            "012"
        )

        for partition in partitions {
            try? FileManager.default.removeItem(at: partition)
        }
        try? FileManager.default.removeItem(at: destination)
    }
}
