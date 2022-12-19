import Foundation

extension URLSession {
    enum FlockError: Swift.Error {
        case failedToCreateOutputStream(URL)
    }

    func singleConnectionDownload(
        from remoteSourceRequest: URLRequest,
        bufferSize: Int = 65_536
    ) async throws -> (URL, URLResponse) {
        let (asyncBytes, response) = try await bytes(for: remoteSourceRequest)

        let destinationURL = FileManager.default.temporaryFile
        guard let destinationStream = OutputStream(url: destinationURL, append: false) else {
            throw FlockError.failedToCreateOutputStream(destinationURL)
        }

        destinationStream.open()

        var buffer = Data()
        buffer.reserveCapacity(bufferSize)

        for try await byte in asyncBytes {
            buffer.append(byte)
            if buffer.count == bufferSize {
                try destinationStream.write(buffer)
                buffer.removeAll(keepingCapacity: true)
            }
        }
        if !buffer.isEmpty {
            try destinationStream.write(buffer)
        }

        destinationStream.close()

        return (destinationURL, response)
    }
}
