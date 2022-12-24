# Flock

> Rapid file download using concurrent connections

## Overview

Flock is a Swift package which provides methods for downloading a file from multiple connections, by taking advantage of the [`Range`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Range) HTTP header and [structured concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html#ID642).

The objective is to speed up downloads by maximizing core usage and download bandwidth.

## Installation

Flock can be included in your project via [Swift Package Manager](https://www.swift.org/package-manager). Add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/qasim/Flock", exact: "0.1.0"),
```

Then, include `Flock` as a dependency for the target which requires it:

```swift
.target(
    name: "<target>",
    dependencies: [
        "Flock",
    ]
),
```

Finally, add `import Flock` to your source code.

## Usage

Flock [extends `URLSession`](https://flock.qas.im/documentation/flock/foundation/urlsession) for your convenience, with reasonable defaults.

For example, to download a file using up to as many connections as there are [active processors](https://developer.apple.com/documentation/foundation/processinfo/1408184-activeprocessorcount):

```swift
try await URLSession.shared.flock(from: URL(string: "http://212.183.159.230/1GB.zip")!)
```

To track progress of your download as it transfers, pass a [`FlockProgressDelegate`](https://flock.qas.im/documentation/flock/flockprogressdelegate):

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

For more details, have a look at the [Flock API reference](https://flock.qas.im).

## Benchmarks

TODO

## Contributing

TODO

## Disclaimer

TODO
