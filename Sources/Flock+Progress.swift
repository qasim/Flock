import Foundation

extension Flock {
    actor Progress {
        var totalBytesReceived: Int = 0
        var totalBytesExpected: Int?
        let delegate: SendableFlockProgressDelegate

        init(delegate: SendableFlockProgressDelegate) {
            self.delegate = delegate
        }

        func set(totalBytesExpected: Int) {
            self.totalBytesExpected = totalBytesExpected
        }

        func add(bytesReceived: Int, from request: URLRequest) {
            totalBytesReceived += bytesReceived
            delegate.request(
                request,
                didReceiveBytes: bytesReceived,
                totalBytesReceived: totalBytesReceived,
                totalBytesExpected: totalBytesExpected
            )
        }
    }
}

/// A protocol that defines methods that Flock internally calls to communicate the progress of a download.
public protocol FlockProgressDelegate: AnyObject {
    /// Called after receiving a new chunk of bytes from a request.
    ///
    /// - Parameters:
    ///     - request:            The request from which the bytes originated from.
    ///     - bytesReceived:      The number of bytes received from the chunk.
    ///     - totalBytesReceived: The total number of bytes received so far.
    ///     - totalBytesExpected: The expected length of the file.
    func request(
        _ request: URLRequest,
        didReceiveBytes bytesReceived: Int,
        totalBytesReceived: Int,
        totalBytesExpected: Int?
    )
}

final class SendableFlockProgressDelegate: FlockProgressDelegate, @unchecked Sendable {
    weak var delegate: FlockProgressDelegate?

    init(_ delegate: FlockProgressDelegate?) {
        self.delegate = delegate
    }

    func request(
        _ request: URLRequest,
        didReceiveBytes bytesReceived: Int,
        totalBytesReceived: Int,
        totalBytesExpected: Int?
    ) {
        delegate?.request(
            request,
            didReceiveBytes: bytesReceived,
            totalBytesReceived: totalBytesReceived,
            totalBytesExpected: totalBytesExpected
        )
    }
}
