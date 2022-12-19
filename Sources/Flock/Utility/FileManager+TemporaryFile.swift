import Foundation

extension FileManager {
    var temporaryFile: URL {
        temporaryDirectory.appending(components: "Flock_\(UUID().uuidString).tmp")
    }
}
