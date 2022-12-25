import Foundation

extension URLSession {
    func singleConnectionDownload(
        from request: URLRequest,
        bufferSize: Int = 65_536,
        progress: Flock.Progress? = nil
    ) async throws -> (URL, URLResponse) {
        if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
            return try await singleConnectionDownloadUsingAsyncBytes(
                from: request,
                bufferSize: bufferSize,
                progress: progress
            )
        } else {
            return try await singleConnectionDownloadUsingDownloadTask(
                from: request,
                bufferSize: bufferSize,
                progress: progress
            )
        }
    }

    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    private func singleConnectionDownloadUsingAsyncBytes(
        from request: URLRequest,
        bufferSize: Int,
        progress: Flock.Progress?
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

    private func singleConnectionDownloadUsingDownloadTask(
        from request: URLRequest,
        bufferSize: Int,
        progress: Flock.Progress?
    ) async throws -> (URL, URLResponse) {
        var observation: NSKeyValueObservation?

        let result: (URL, URLResponse) = try await withCheckedThrowingContinuation { continuation in
            let task = downloadTask(with: request) { url, response, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let url, let response {
                    do {
                        // Copying file into our control, since the original file will be deleted once this completion
                        // handler returns
                        let destinationURL = try FileManager.default.flockTemporaryFile(creatingFile: false)
                        try FileManager.default.moveItem(at: url, to: destinationURL)

                        continuation.resume(returning: (destinationURL, response))
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }

            observation = task.observe(\.countOfBytesReceived) { task, _ in
                Task {
                    await progress?.set(totalBytesReceived: Int(task.countOfBytesReceived), from: request)
                }
            }

            task.resume()
        }

        defer {
            observation?.invalidate()
        }

        return result
    }
}
