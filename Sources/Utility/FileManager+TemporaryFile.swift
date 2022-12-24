import Foundation

extension FileManager {
    enum FlockError: Swift.Error {
        case failedToCreateFile(URL)
    }

    func flockTemporaryFile() throws -> URL {
        let component = "Flock_\(UUID().uuidString).tmp"

        let url: URL
        if #available(macOS 13.0, *) {
            url = temporaryDirectory.appending(component: component)
        } else {
            url = temporaryDirectory.appendingPathComponent(component)
        }

        guard createFile(atPath: url.backportedPath, contents: nil) else {
            throw FlockError.failedToCreateFile(url)
        }

        return url
    }
}
