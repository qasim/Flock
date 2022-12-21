import XCTest
@testable import Flock

final class IntPartitionTests: XCTestCase {
    func testSingleCases() {
        XCTAssertEqual(
            1.ranges(whenSplitUpTo: 1),
            [0...0]
        )
        XCTAssertEqual(
            2.ranges(whenSplitUpTo: 1),
            [0...1]
        )
        XCTAssertEqual(
            1.ranges(whenSplitUpTo: 2),
            [0...0]
        )
    }

    func testSmallPartitions() {
        XCTAssertEqual(
            3.ranges(whenSplitUpTo: 3),
            [0...0, 1...1, 2...2]
        )
        XCTAssertEqual(
            3.ranges(whenSplitUpTo: 2),
            [0...0, 1...2]
        )
        XCTAssertEqual(
            3.ranges(whenSplitUpTo: 1),
            [0...2]
        )
    }

    func testLargePartitions() {
        XCTAssertEqual(
            100.ranges(whenSplitUpTo: 3),
            [0...32, 33...65, 66...99]
        )
        XCTAssertEqual(
            100.ranges(whenSplitUpTo: 4),
            [0...24, 25...49, 50...74, 75...99]
        )
        XCTAssertEqual(
            100.ranges(whenSplitUpTo: 1),
            [0...99]
        )
        XCTAssertEqual(
            13471.ranges(whenSplitUpTo: 5),
            [0...2693, 2694...5387, 5388...8081, 8082...10775, 10776...13470]
        )
    }

    func testMinimumPartitionSizes() {
        XCTAssertEqual(
            100.ranges(whenSplitUpTo: 3, minimumPartitionSize: 50),
            [0...49, 50...99]
        )
        XCTAssertEqual(
            100.ranges(whenSplitUpTo: 4, minimumPartitionSize: 25),
            [0...24, 25...49, 50...74, 75...99]
        )
        XCTAssertEqual(
            100.ranges(whenSplitUpTo: 1, minimumPartitionSize: 50),
            [0...99]
        )
    }
}
