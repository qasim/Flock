import Foundation

extension FileManager {
    func merge(_ partitionSources: [URL], to destination: URL, chunkSize: Int = 67_108_864) throws {
        createFile(atPath: destination.path(), contents: nil)
        let destinationHandle = try FileHandle(forWritingTo: destination)
        for source in partitionSources {
            let sourceHandle = try FileHandle(forReadingFrom: source)
            while let data = try sourceHandle.read(upToCount: chunkSize), !data.isEmpty {
                try destinationHandle.write(contentsOf: data)
            }
            try sourceHandle.close()
        }
        try destinationHandle.close()
    }
}
