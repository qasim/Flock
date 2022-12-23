import Foundation

extension FileManager {
    func merge(_ partitionURLs: [URL], to destinationURL: URL, chunkSize: Int = 67_108_864) throws {
        createFile(atPath: destinationURL.backportedPath, contents: nil)
        let destinationHandle = try FileHandle(forWritingTo: destinationURL)
        for partitionURL in partitionURLs {
            let partitionHandle = try FileHandle(forReadingFrom: partitionURL)
            while let data = try partitionHandle.read(upToCount: chunkSize), !data.isEmpty {
                try destinationHandle.write(contentsOf: data)
            }
            try partitionHandle.close()
        }
        try destinationHandle.close()
    }
}
