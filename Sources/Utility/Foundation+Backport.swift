import Foundation

extension URL {
    func appendingBackported(component: String) -> URL {
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
            return appending(component: component)
        } else {
            return appendingPathComponent(component)
        }
    }
    
    var pathBackported: String {
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
            return path()
        } else {
            return path
        }
    }
}
