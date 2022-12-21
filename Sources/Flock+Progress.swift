import Foundation

extension Flock {
    actor Progress {
        var totalBytesReceived: Int = 0
        let totalBytesExpected: Int

        weak var delegate: FlockProgressDelegate?

        init(totalBytesExpected: Int, delegate: FlockProgressDelegate?) {
            self.totalBytesExpected = totalBytesExpected
            self.delegate = delegate
        }

        func add(_ bytesReceived: Int, from remoteSourceRequest: URLRequest) {
            totalBytesReceived += bytesReceived
            delegate?.request(
                remoteSourceRequest,
                didRecieveBytes: bytesReceived,
                totalBytesReceived: totalBytesReceived,
                totalBytesExpected: totalBytesExpected
            )
        }
    }
}

/// A protocol that defines methods that Flock instances call on their delegates to handle progress reporting.
public protocol FlockProgressDelegate: AnyObject {
    func request(
        _ request: URLRequest,
        didRecieveBytes bytesReceived: Int,
        totalBytesReceived: Int,
        totalBytesExpected: Int
    )
}
