import Foundation

extension URLSession {
    func bytes(
        forHTTP request: URLRequest,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (URLSession.AsyncBytes, HTTPURLResponse) {
        try await bytes(for: request, delegate: delegate) as! (URLSession.AsyncBytes, HTTPURLResponse)
    }
}
