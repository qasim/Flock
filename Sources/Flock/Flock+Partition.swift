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
            self.localDestination = URL(string: "TODO")!
        }

        func download() async {
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
