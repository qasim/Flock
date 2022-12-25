import Foundation

extension URLSession {
    func response(from request: URLRequest) async throws -> HTTPURLResponse {
        try await bytes(for: request).1 as! HTTPURLResponse
    }
}
