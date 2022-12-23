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

        func add(_ bytesReceived: Int, from request: URLRequest) {
            totalBytesReceived += bytesReceived
            delegate?.request(
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
        totalBytesExpected: Int
    )
}
