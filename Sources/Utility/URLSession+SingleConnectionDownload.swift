import Foundation

extension URLSession {
    enum FlockError: Swift.Error {
        case failedToCreateFile(URL)
    }

    func singleConnectionDownload(
        from request: URLRequest,
        using fileManager: FileManager = .default,
        bufferSize: Int = 65_536,
        progress: Flock.Progress?
    ) async throws -> (URL, URLResponse) {
        let (asyncBytes, response) = try await bytes(for: request)

        let destinationURL = fileManager.flockTemporaryFile
        guard fileManager.createFile(atPath: destinationURL.backportedPath, contents: nil) else {
            throw FlockError.failedToCreateFile(destinationURL)
        }
        let destinationHandle = try FileHandle(forWritingTo: destinationURL)

        var buffer = Data()
        buffer.reserveCapacity(bufferSize)

        for try await byte in asyncBytes {
            buffer.append(byte)
            if buffer.count == bufferSize {
                try destinationHandle.write(contentsOf: buffer)
                buffer.removeAll(keepingCapacity: true)
                Task.detached(priority: .utility) {
                    await progress?.add(bufferSize, from: request)
                }
            }
        }
        if !buffer.isEmpty {
            try destinationHandle.write(contentsOf: buffer)
            let bufferCount = buffer.count
            Task.detached(priority: .utility) {
                await progress?.add(bufferCount, from: request)
            }
        }

        defer {
            try? destinationHandle.close()
        }

        return (destinationURL, response)
    }
}
