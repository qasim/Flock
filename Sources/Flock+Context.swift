import Foundation
import Logging

extension Flock {
    public struct Context {
        let fileManager: FileManager
        var log: Logger
        let session: URLSession

        private static var isLoggingSystemBootstrapped: Bool = false

        /// Creates a structure which provides an outside context (configuration, dependencies, etc.) for inside
        /// methods to use.
        ///
        /// - Parameters:
        ///     - fileManager: the `FileManager` instance to use. The default is `FileManager.default`.
        ///     - logLevel:    the minimum log level required for printing messages to standard output. The default is
        ///                    `Logger.Level.critical`.
        ///     - session:     the `URLSession` instance to use. The default is `URLSession.shared`.
        public init(
            fileManager: FileManager = .default,
            logLevel: Logger.Level = .critical,
            session: URLSession = .shared
        ) {
            self.fileManager = fileManager

            if !Self.isLoggingSystemBootstrapped {
                Self.isLoggingSystemBootstrapped = true
                LoggingSystem.bootstrap(StreamLogHandler.standardOutput)
            }
            self.log = Logger(label: "Flock")
            self.log.logLevel = logLevel
            self.log.debug("Logger initialized")

            self.session = session
        }
    }
}
