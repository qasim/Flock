# ``Flock``

Rapid file download using concurrent connections.

## Overview

Flock is a Swift package which provides methods for downloading a single file from multiple connections, by taking advantage of the [`Range`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Range) HTTP header and [Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html).

The objective is to speed up downloads by maximizing core usage and download bandwidth.

## Usage

Flock [extends `URLSession`](/documentation/flock/foundation/urlsession) for your convenience, with reasonable defaults.

For example, to download a file using as many connections as your machine has [active processors](https://developer.apple.com/documentation/foundation/processinfo/1408184-activeprocessorcount):

```swift
try await URLSession.shared.flock(from: URL(string: "http://212.183.159.230/1GB.zip")!)
```

To track progress of your download as it transfers, pass a [`FlockProgressDelegate`](https://github.com/qasim/Flock/blob/main/Sources/Flock%2BProgress.swift#L27-L35):

```swift
class ExampleProgressDelegate: FlockProgressDelegate {
    func request(_ request: URLRequest, didReceiveBytes bytesReceived: Int, totalBytesReceived: Int, totalBytesExpected: Int) {
        // Prints the percentage of the transfer that's been downloaded
        print("\(Double(totalBytesReceived) / Double(totalBytesExpected) * 100)%")
    }
}

// ...

try await URLSession.shared.flock(
    from: URL(string: "http://212.183.159.230/1GB.zip")!, 
    progressDelegate: ExampleProgressDelegate()
)
```
