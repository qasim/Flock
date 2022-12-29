import Foundation

extension URLSession {
    typealias AsyncResume = @Sendable (_ limit: Int?) async throws -> Void

    func download(
        from request: URLRequest,
        to file: URL,
        at offset: Int = 0,
        until limit: Int? = nil,
        progress: Flock.Progress? = nil
    ) async throws -> (AsyncResume, HTTPURLResponse) {
        try await Download(
            session: self,
            request: request,
            file: file,
            offset: offset,
            limit: limit,
            progress: progress
        )
        .start()
    }
}

private final class Download: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    let session: URLSession
    let request: URLRequest
    let fileHandle: FileHandle
    var limit: Int?
    let progress: Flock.Progress?

    private var responseContinuation: CheckedContinuation<(URLSession.AsyncResume, HTTPURLResponse), any Error>?
    private var downloadContinuation: CheckedContinuation<Void, any Error>?

    private var bytesReceived: Int = 0

    init(
        session: URLSession,
        request: URLRequest,
        file: URL,
        offset: Int,
        limit: Int?,
        progress: Flock.Progress?
    ) throws {
        self.session = session
        self.request = request
        self.fileHandle = try FileHandle(forWritingTo: file)
        try self.fileHandle.seek(toOffset: UInt64(offset))
        self.limit = limit
        self.progress = progress
    }

    func start() async throws -> (URLSession.AsyncResume, HTTPURLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            self.responseContinuation = continuation
            let dataTask = session.dataTask(with: request)
            dataTask.delegate = self
            dataTask.resume()
        }
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        responseContinuation?.resume(
            returning: (
                { [self] limit in
                    self.limit = limit
                    completionHandler(.allow)
                    try await withCheckedThrowingContinuation { continuation in
                        downloadContinuation = continuation
                    }
                },
                response as! HTTPURLResponse
            )
        )
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        do {
            if let limit, bytesReceived + data.count >= limit {
                dataTask.cancel()
                let finalData = data[..<(limit - bytesReceived)]
                try fileHandle.write(contentsOf: finalData)
                Task {
                    await progress?.add(bytesReceived: finalData.count, from: request)
                }
            } else {
                try fileHandle.write(contentsOf: data)
                bytesReceived += data.count
                Task {
                    await progress?.add(bytesReceived: data.count, from: request)
                }
            }
        } catch {
            downloadContinuation?.resume(throwing: error)
            downloadContinuation = nil
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error, (error as NSError).code != NSURLErrorCancelled {
            downloadContinuation?.resume(throwing: error)
        } else {
            downloadContinuation?.resume()
        }
        downloadContinuation = nil
    }
}
