import Foundation

extension URLSession {
    public func flock(
        from remoteSource: URL,
        numberOfConnections connectionCount: Int = 8,
        minimumConnectionLength: Int = 16_777_216
    ) async throws -> (URL, URLResponse) {
        try await
            Flock(
                context: .init(
                    session: self,
                    fileManager: FileManager.default
                ),
                remoteSourceRequest: URLRequest(url: remoteSource),
                numberOfConnections: connectionCount,
                minimumConnectionLength: minimumConnectionLength
            )
            .download()
    }

    public func flock(
        from remoteSourceRequest: URLRequest,
        numberOfConnections connectionCount: Int = 8,
        minimumConnectionLength: Int = 16_777_216
    ) async throws -> (URL, URLResponse) {
        try await
            Flock(
                context: .init(
                    session: self,
                    fileManager: FileManager.default
                ),
                remoteSourceRequest: remoteSourceRequest,
                numberOfConnections: connectionCount,
                minimumConnectionLength: minimumConnectionLength
            )
            .download()
    }
}
