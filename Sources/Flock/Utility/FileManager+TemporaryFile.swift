import Foundation

extension FileManager {
    var flockTemporaryFile: URL {
        temporaryDirectory.appending(components: "Flock_\(UUID().uuidString).tmp")
    }
}
