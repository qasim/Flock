import Foundation

extension URLSession {
    @discardableResult
    func download(
        from request: URLRequest,
        to file: URL,
        at offset: Int = 0,
        bufferSize: Int = 65_536,
        progress: Flock.Progress? = nil
    ) async throws -> URLResponse {
        let (asyncBytes, response) = try await bytes(for: request)

        let destinationHandle = try FileHandle(forWritingTo: file)
        try destinationHandle.seek(toOffset: UInt64(offset))

        var buffer = Data()
        buffer.reserveCapacity(bufferSize)

        for try await byte in asyncBytes {
            buffer.append(byte)
            if buffer.count == bufferSize {
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

        defer {
            try? destinationHandle.close()
        }

        return response
    }
}
