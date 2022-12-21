import Foundation

extension URLSession {
    /// Downloads a file from a remote source URL.
    ///
    /// If the source supports the `Range` header, the file will be downloaded
    /// in parallel using multiple connections based on the given parameters.
    ///
    /// - Parameters:
    ///     - remoteSource:          an URL to download.
    ///     - connectionCount:       the maximum number of connections to create in parallel. The default is
    ///                              `ProcessInfo.processInfo.activeProcessorCount`.
    ///     - minimumConnectionSize: the minimum size, in bytes, for each connection. The default is `16777216`,
    ///                              which is equivalent to 16MB.
    ///     - progressDelegate:      a delegate that receives progress updates for the download.
    ///     - isDebug:               whether or not debug logs should be printed to standard output.
    ///
    /// - Returns: an asynchronously-delivered tuple that contains the location of the downloaded file as an URL, and
    ///            an `URLResponse`.
    public func flock(
        from remoteSource: URL,
        numberOfConnections connectionCount: Int = ProcessInfo.processInfo.activeProcessorCount,
        minimumConnectionSize: Int = 16_777_216,
        progressDelegate: FlockProgressDelegate? = nil,
        isDebug: Bool = false
    ) async throws -> (URL, URLResponse) {
        try await flock(
            from: URLRequest(url: remoteSource),
            numberOfConnections: connectionCount,
            minimumConnectionSize: minimumConnectionSize,
            progressDelegate: progressDelegate,
            isDebug: isDebug
        )
    }

    /// Downloads a file from a remote source request.
    ///
    /// If the source supports the `Range` header, the file will be downloaded
    /// in parallel using multiple connections based on the given parameters.
    ///
    /// - Parameters:
    ///     - remoteSourceRequest:   a request to download.
    ///     - connectionCount:       the maximum number of connections to create in parallel. The default is
    ///                              `ProcessInfo.processInfo.activeProcessorCount`.
    ///     - minimumConnectionSize: the minimum size, in bytes, for each connection. The default is `16777216`,
    ///                              which is equivalent to 16MB.
    ///     - progressDelegate:      a delegate that receives progress updates for the download.
    ///     - isDebug:               whether or not debug logs should be printed to standard output.
    ///
    /// - Returns: an asynchronously-delivered tuple that contains the location of the downloaded file as an `URL`, and
    ///            an `URLResponse`.
    public func flock(
        from remoteSourceRequest: URLRequest,
        numberOfConnections connectionCount: Int = ProcessInfo.processInfo.activeProcessorCount,
        minimumConnectionSize: Int = 16_777_216,
        progressDelegate: FlockProgressDelegate? = nil,
        isDebug: Bool = false
    ) async throws -> (URL, URLResponse) {
        try await
            Flock(
                context: .init(
                    logLevel: isDebug ? .trace : .critical,
                    session: self
                ),
                remoteSourceRequest: remoteSourceRequest,
                numberOfConnections: connectionCount,
                minimumConnectionSize: minimumConnectionSize,
                progressDelegate: progressDelegate
            )
            .download()
    }
}
