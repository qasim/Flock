import Foundation
import Logging

extension Flock {
    /// A structure containing configuration and dependencies for Flock to reference.
    struct Context {
        let fileManager: FileManager
        var log: Logger
        let session: URLSession

        private static var isLoggingSystemBootstrapped: Bool = false

        /// - Parameters:
        ///     - fileManager: The `FileManager` instance to use. The default is `.default`.
        ///     - logLevel:    The minimum log level required for printing messages to standard output. The default is
        ///                    `.critical`.
        ///     - session:     The `URLSession` instance to use. The default is `.shared`.
        init(
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
