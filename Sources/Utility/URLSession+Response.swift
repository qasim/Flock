import Foundation

extension URLSession {
    func response(from request: URLRequest) async throws -> HTTPURLResponse {
<<<<<<< Updated upstream
        try await bytes(for: request).1 as! HTTPURLResponse
    }
=======
        if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
            return try await responseUsingAsyncBytes(from: request)
        } else {
            return try await responseUsingDataTask(from: request)
        }
    }

    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    func responseUsingAsyncBytes(from request: URLRequest) async throws -> HTTPURLResponse {
        try await bytes(for: request).1 as! HTTPURLResponse
    }

    func responseUsingDataTask(from request: URLRequest) async throws -> HTTPURLResponse {
        try await withCheckedThrowingContinuation { continuation in
            dataTask(with: request) { _, response, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let response {
                    continuation.resume(returning: response as! HTTPURLResponse)
                }
            }
            .resume()
        }
    }
>>>>>>> Stashed changes
}
