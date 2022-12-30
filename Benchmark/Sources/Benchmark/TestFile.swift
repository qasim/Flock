import Foundation

enum RemoteTestFile: Int {
    case of5MB = 5_242_880
    case of10MB = 10_485_760
    case of20MB = 20_971_520
    case of50MB = 52_428_800
    case of100MB = 104_857_600
    case of200MB = 209_715_200
    case of512MB = 536_870_912
    case of1GB = 1_073_741_824
    case of10GB = 10_737_418_240

    static func of(_ sizeInBytes: Int) -> RemoteTestFile {
        let file = self.init(rawValue: sizeInBytes)
        precondition(file != nil, "unsupported size.")
        return file!
    }

    var name: String {
        switch self {
        case .of5MB: return "5MB"
        case .of10MB: return "10MB"
        case .of20MB: return "20MB"
        case .of50MB: return "50MB"
        case .of100MB: return "100MB"
        case .of200MB: return "200MB"
        case .of512MB: return "512MB"
        case .of1GB: return "1GB"
        case .of10GB: return "10GB"
        }
    }

    var url: String {
        "http://212.183.159.230/\(name).zip"
    }
}

struct LocalTestFile {
    let bytes: Int

    static func of(_ sizeInBytes: Int) -> LocalTestFile {
        LocalTestFile(bytes: sizeInBytes)
    }

    var url: String {
        "http://localhost/\(bytes)"
    }
}
