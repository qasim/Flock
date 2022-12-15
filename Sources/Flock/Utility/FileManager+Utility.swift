import Foundation

extension FileManager {
    func createDirectory(
        at url: URL,
        creatingIntermediates createIntermediates: Bool = false,
        attributes: [FileAttributeKey: Any]? = nil
    ) throws {
        try createDirectory(at: url, withIntermediateDirectories: createIntermediates, attributes: attributes)
    }
}
