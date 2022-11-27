import Algorithms

extension Int {
    func slices(whenCutInto numberOfSlices: Int) -> [ClosedRange<Int>] {
        guard numberOfSlices > 0 else {
            return []
        }

        let sliceSize = self / numberOfSlices
        let boundaries = [0] + Array(
            stride(
                from: sliceSize,
                to: sliceSize * numberOfSlices,
                by: sliceSize
            )
        ) + [self]
        return boundaries.adjacentPairs().map { start, end in
            if start == 0 {
                return 0...end
            } else {
                return (start + 1)...end
            }
        }
    }
}
