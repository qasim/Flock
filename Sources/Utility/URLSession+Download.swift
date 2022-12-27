import Foundation

extension URLSession {
    func download(
        from request: URLRequest,
        _ asyncBytes: URLSession.AsyncBytes,
        to file: URL,
        at offset: Int = 0,
        until limit: Int? = nil,
        bufferSize: Int = 65_536,
        progress: Flock.Progress? = nil
    ) async throws {
        let destinationHandle = try FileHandle(forWritingTo: file)
        if offset > 0 {
            try destinationHandle.seek(toOffset: UInt64(offset))
        }

        var buffer = Data()
        buffer.reserveCapacity(bufferSize)

        var totalBytesReceived = 0

        for try await byte in asyncBytes {
            buffer.append(byte)
            totalBytesReceived += 1
            if let limit, totalBytesReceived == limit {
                try destinationHandle.write(contentsOf: buffer)
                await progress?.add(bytesReceived: buffer.count, from: request)
                //asyncBytes.task.cancel()
                try? destinationHandle.close()
                return
            } else if totalBytesReceived % bufferSize == 0 {
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
        bufferSize: Int = 65_536,
        progress: Flock.Progress? = nil
    ) async throws {
        let (asyncBytes, _) = try await bytes(for: request)
        try await download(from: request, asyncBytes, to: file, at: offset, bufferSize: bufferSize, progress: progress)
    }
}
