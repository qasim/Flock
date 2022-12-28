import Foundation

extension URLSession {
    func download(
        from request: URLRequest,
        _ asyncBytes: URLSession.AsyncBytes,
        to file: URL,
        at offset: Int = 0,
        until limit: Int? = nil,
        bufferSize: Int,
        progress: Flock.Progress? = nil
    ) async throws {
        let destinationHandle = try FileHandle(forWritingTo: file)
        if offset > 0 {
            try destinationHandle.seek(toOffset: UInt64(offset))
        }

        var buffer = [UInt8]()
        buffer.reserveCapacity(bufferSize)

        var bytesProcessed: Int = 0

        for try await byte in asyncBytes {
            buffer.append(byte)
            bytesProcessed += 1
            if let limit, bytesProcessed == limit {
                break
            } else if buffer.count == bufferSize {
                try destinationHandle.write(contentsOf: buffer)
                buffer.removeAll(keepingCapacity: true)
                await progress?.add(bytesReceived: bufferSize, from: request)
            }
        }

        if !buffer.isEmpty {
            try destinationHandle.write(contentsOf: buffer)
            let bufferCount = buffer.count
            await progress?.add(bytesReceived: bufferCount, from: request)
        }

        try? destinationHandle.close()
    }

    func download(
        from request: URLRequest,
        to file: URL,
        at offset: Int = 0,
        bufferSize: Int,
        progress: Flock.Progress? = nil
    ) async throws {
        let (asyncBytes, _) = try await bytes(for: request)
        try await download(from: request, asyncBytes, to: file, at: offset, bufferSize: bufferSize, progress: progress)
    }
}
