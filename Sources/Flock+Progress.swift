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
                didReceiveBytes: bytesReceived,
                totalBytesReceived: totalBytesReceived,
                totalBytesExpected: totalBytesExpected
            )
        }
    }
}

/// A protocol that defines methods that a ``Flock/Flock`` instance calls on their delegate to handle progress
/// reporting.
public protocol FlockProgressDelegate: AnyObject {
    func request(
        _ request: URLRequest,
        didReceiveBytes bytesReceived: Int,
        totalBytesReceived: Int,
        totalBytesExpected: Int
    )
}
