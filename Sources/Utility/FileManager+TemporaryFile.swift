import Foundation

extension FileManager {
    enum FlockError: Swift.Error {
        case failedToCreateFile(URL)
    }

    func flockTemporaryFile(creatingFile: Bool = true) throws -> URL {
        let component = "Flock_\(UUID().uuidString).tmp"
        let url = temporaryDirectory.appendingBackported(component: component)

<<<<<<< Updated upstream
        guard createFile(atPath: url.pathBackported, contents: nil) else {
            throw FlockError.failedToCreateFile(url)
=======
        if creatingFile {
            guard createFile(atPath: url.pathBackported, contents: nil) else {
                throw FlockError.failedToCreateFile(url)
            }
>>>>>>> Stashed changes
        }

        return url
    }
}
