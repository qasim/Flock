import Foundation

extension OutputStream {
    enum FlockError: Swift.Error {
        case failedToWriteBytes
    }

    func write(_ data: Data) throws {
        var remaining = data[...]
        while !remaining.isEmpty {
            let bytesWritten = remaining.withUnsafeBytes { buffer in
                self.write(
                    buffer.baseAddress!.assumingMemoryBound(to: UInt8.self),
                    maxLength: buffer.count
                )
            }

            guard bytesWritten >= 0 else {
                throw FlockError.failedToWriteBytes
            }

            remaining = remaining.dropFirst(bytesWritten)
        }
    }
}
