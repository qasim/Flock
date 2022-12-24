import Foundation

extension URLSession {
    func singleConnectionDownload(
        from request: URLRequest,
        bufferSize: Int = 65_536,
        progress: Flock.Progress? = nil
    ) async throws -> (URL, URLResponse) {
        let (asyncBytes, response) = try await bytes(for: request)

        let destinationURL = try FileManager.default.flockTemporaryFile()
        let destinationHandle = try FileHandle(forWritingTo: destinationURL)

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

        return (destinationURL, response)
    }
}
