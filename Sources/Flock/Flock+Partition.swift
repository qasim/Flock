import Foundation

extension Flock {
    class Partition {
        let context: Context

        let remoteSource: URL
        let byteRange: ClosedRange<Int>
        let localDestination: URL

        var bytesDownloaded: Int = 0
        var bytesSavedToDisk: Int = 0

        init(
            context: Context,
            remoteSource: URL,
            byteRange: ClosedRange<Int>,
            localDestination: URL
        ) {
            self.context = context
            self.remoteSource = remoteSource
            self.byteRange = byteRange
            self.localDestination = localDestination
        }

        func download() async throws {
            context.fileManager.createFile(atPath: localDestination.path(), contents: nil)

            var request = URLRequest(url: remoteSource)
            request.setValue(
                "bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)",
                forHTTPHeaderField: "Range"
            )

            print("\(request.value(forHTTPHeaderField: "Range")!): Starting")
            let (bytes, _) = try await context.session.bytes(forHTTP: request)

            print("\(request.value(forHTTPHeaderField: "Range")!): Downloading")
            for try await byte in bytes {
                try write(Data([byte]))
            }

            try finishWriting()
            print("\(request.value(forHTTPHeaderField: "Range")!): Finished")
        }

        // MARK: Writing

        private var writingHandle: FileHandle?

        func write(_ data: Data) throws {
            if writingHandle == nil {
                writingHandle = try FileHandle(forWritingTo: localDestination)
            }
            try writingHandle?.write(contentsOf: data)
        }

        func finishWriting() throws {
            try writingHandle?.close()
            writingHandle = nil
        }
    }
}
