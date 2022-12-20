import Foundation

extension URLSession {
    public func flock(
        from remoteSource: URL,
        numberOfConnections connectionCount: Int = 8,
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

    public func flock(
        from remoteSourceRequest: URLRequest,
        numberOfConnections connectionCount: Int = 8,
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
