import Foundation
import Logging

extension Flock {
    public struct Context {
        static var isLoggingSystemBootstrapped: Bool = false

        let fileManager: FileManager
        var log: Logger
        let session: URLSession

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
