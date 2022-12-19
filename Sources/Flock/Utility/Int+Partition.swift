import Algorithms

extension Int {
    func ranges(
        whenSplitUpTo maximumNumberOfPartitions: Int,
        minimumPartitionSize: Int = 1
    ) -> [ClosedRange<Int>] {
        precondition(self > 0, "values less than 1 cannot be partitioned.")
        precondition(maximumNumberOfPartitions > 0, "values cannot be partitioned less than 1 time.")
        precondition(minimumPartitionSize > 0, "partitions cannot be smaller than 1.")

        var numberOfPartitions = self / minimumPartitionSize
        if numberOfPartitions > maximumNumberOfPartitions {
            numberOfPartitions = maximumNumberOfPartitions
        }

        let partitionLength = self / numberOfPartitions
        if partitionLength < minimumPartitionSize {
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
