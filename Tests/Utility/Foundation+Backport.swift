@testable import Flock
import Foundation

extension URLSession {
    func downloadBackported(from url: URL) async throws -> (URL, URLResponse) {
        if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
            return try await download(from: url)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                downloadTask(with: url) { url, response, error in
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
                .resume()
            }
        }
    }
}
