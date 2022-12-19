import Foundation

extension FileManager {
    var flockTemporaryFile: URL {
        let component = "Flock_\(UUID().uuidString).tmp"
        if #available(macOS 13.0, *) {
            return temporaryDirectory.appending(component: component)
        } else {
            return temporaryDirectory.appendingPathExtension(component)
        }
    }
}
