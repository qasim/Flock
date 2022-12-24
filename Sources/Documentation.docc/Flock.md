# ``Flock``

Rapid file download using concurrent connections

## Overview

Flock is a Swift package which provides methods for downloading a file from multiple connections, by taking advantage of the [`Range`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Range) HTTP header and [structured concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html#ID642).

The objective is to speed up downloads by maximizing core usage and download bandwidth.

## Usage

Flock [extends `URLSession`](/documentation/flock/foundation/urlsession) for your convenience, with reasonable defaults.

For example, to download a file using up to as many connections as there are [active processors](https://developer.apple.com/documentation/foundation/processinfo/1408184-activeprocessorcount):

```swift
try await URLSession.shared.flock(from: URL(string: "http://212.183.159.230/1GB.zip")!)
```

To track progress of your download as it transfers, pass a [`FlockProgressDelegate`](/documentation/flock/flockprogressdelegate):

```swift
class ExampleProgressDelegate: FlockProgressDelegate {
    func request(_ request: URLRequest, didReceiveBytes bytesReceived: Int, totalBytesReceived: Int, totalBytesExpected: Int?) {
        print("\(totalBytesReceived) bytes downloaded")
    }
}
```
```swift
try await URLSession.shared.flock(
    from: URL(string: "http://212.183.159.230/1GB.zip")!, 
    progressDelegate: ExampleProgressDelegate()
)
```
