import Foundation

enum RemoteTestFile {
    case of100MB

    var url: URL {
        switch self {
        case .of100MB:
            return URL(string: "http://212.183.159.230/100MB.zip")!
        }
    }
}

extension URL {
    static func remoteTestFile(_ file: RemoteTestFile) -> URL {
        file.url
    }
}
