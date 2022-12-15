import Algorithms

extension Int {
    func ranges(
        whenSplitUpTo numberOfPartitions: Int,
        minimumPartitionLength: Int = 1
    ) -> [ClosedRange<Int>] {
        precondition(self > 0, "values less than 1 cannot be partitioned.")
        precondition(numberOfPartitions > 0, "values cannot be partitioned less than 1 time.")
        precondition(minimumPartitionLength > 0, "partitions cannot be smaller than 1.")

        let partitionLength = self / numberOfPartitions
        if partitionLength < minimumPartitionLength {
            return [0...self - 1]
        }

        let boundaries = Array(
            stride(
                from: 0,
                to: partitionLength * numberOfPartitions,
                by: partitionLength
            )
        ) + [self]

        return boundaries.adjacentPairs().map { start, end in
            if start == 0 {
                return 0...end - 1
            } else {
                return start...end - 1
            }
        }
    }
}
