import Foundation

extension URLSession {
    /// Downloads a file.
    ///
    /// If the source `URL` supports the `Range` HTTP header, the file will be partitioned and downloaded using
    /// multiple concurrent connections based on the given parameters.
    ///
    /// - Parameters:
    ///     - source:                The `URL` to download.
    ///     - connectionCount:       The maximum number of connections to create in parallel. The default is
    ///                              `ProcessInfo.processInfo.activeProcessorCount`.
    ///     - minimumConnectionSize: The minimum size, in bytes, for each connection. The default is `16777216`,
    ///                              which is equivalent to `16MB`.
    ///     - progressDelegate:      A delegate that receives progress updates for the download.
    ///     - isVerbose:             Whether or not verbose logs should be printed to standard output.
    ///
    /// - Returns: An asynchronously-delivered tuple that contains the location of the downloaded file as an `URL`, and
    ///            an `URLResponse`.
    public func flock(
        from source: URL,
        numberOfConnections connectionCount: Int = ProcessInfo.processInfo.activeProcessorCount,
        minimumConnectionSize: Int = 16_777_216,
        progressDelegate: FlockProgressDelegate? = nil,
        isVerbose: Bool = false
    ) async throws -> (URL, URLResponse) {
        try await flock(
            from: URLRequest(url: source),
            numberOfConnections: connectionCount,
            minimumConnectionSize: minimumConnectionSize,
            progressDelegate: progressDelegate,
            isVerbose: isVerbose
        )
    }

    /// Downloads a file.
    ///
    /// If the source `URL` supports the `Range` HTTP header, the file will be partitioned and downloaded using
    /// multiple concurrent connections based on the given parameters.
    ///
    /// - Parameters:
    ///     - sourceRequest:         The request to download.
    ///     - connectionCount:       The maximum number of connections to create in parallel. The default is
    ///                              `ProcessInfo.processInfo.activeProcessorCount`.
    ///     - minimumConnectionSize: The minimum size, in bytes, for each connection. The default is `16777216`,
    ///                              which is equivalent to `16MB`.
    ///     - progressDelegate:      A delegate that receives progress updates for the download.
    ///     - isVerbose:             Whether or not verbose logs should be printed to standard output.
    ///
    /// - Returns: An asynchronously-delivered tuple that contains the location of the downloaded file as an `URL`, and
    ///            an `URLResponse`.
    public func flock(
        from sourceRequest: URLRequest,
        numberOfConnections connectionCount: Int = ProcessInfo.processInfo.activeProcessorCount,
        minimumConnectionSize: Int = 16_777_216,
        progressDelegate: FlockProgressDelegate? = nil,
        isVerbose: Bool = false
    ) async throws -> (URL, URLResponse) {
        try await
            Flock(
                context: .init(
                    logLevel: isVerbose ? .trace : .critical,
                    session: self
                ),
                sourceRequest: sourceRequest,
                numberOfConnections: connectionCount,
                minimumConnectionSize: minimumConnectionSize,
                progressDelegate: progressDelegate
            )
            .download()
    }
}
