import Foundation

extension URLSession {
    public func flock(
        to remoteSource: URL,
        numberOfConnections connectionCount: Int = 8,
        minimumConnectionLength: Int = 16_777_216
    ) async throws -> URL {
        try await
            Flock(
                context: .init(
                    session: self,
                    fileManager: FileManager.default
                ),
                remoteSource: remoteSource,
                numberOfConnections: connectionCount,
                minimumConnectionLength: minimumConnectionLength
            )
            .download()
    }
}
