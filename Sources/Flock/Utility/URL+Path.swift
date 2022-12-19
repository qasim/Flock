import Foundation

extension URL {
    var backportedPath: String {
        if #available(macOS 13.0, *) {
            return path()
        } else {
            return path
        }
    }
}
