import Foundation

extension Flock {
    enum Error: LocalizedError {
        case rangeHeaderUnsupported(_ remoteSource: URL)

        var errorDescription: String? {
            switch self {
            case .rangeHeaderUnsupported(let remoteSource):
                return "The resource at \(remoteSource.absoluteString) does not support the 'Range' request header"
            }
        }
    }
}
