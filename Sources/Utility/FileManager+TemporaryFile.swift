import Foundation

extension FileManager {
    enum FlockError: Swift.Error {
        case failedToCreateFile(URL)
    }

    func flockTemporaryFile() throws -> URL {
        let component = "Flock_\(UUID().uuidString).tmp"
        let url = temporaryDirectory.appendingBackported(component: component)

        guard createFile(atPath: url.pathBackported, contents: nil) else {
            throw FlockError.failedToCreateFile(url)
        }

        return url
    }
}
