# Flock

Flock is a Swift package for rapidly downloading a file through multiple connections in parallel.

## Installation

Flock can be included in your project via [Swift Package Manager](https://www.swift.org/package-manager/). Add the following line to the dependencies in your `Package.swift` file:

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

Flock extends `URLSession` with 2 methods for your convenience, with reasonable defaults:

- [`flock(from remoteSource: URL)`](https://github.com/qasim/Flock/blob/main/Sources/URLSession%2BFlock.swift#L4-L26)
- [`flock(from remoteSourceRequest: URLRequest)`](https://github.com/qasim/Flock/blob/main/Sources/URLSession%2BFlock.swift#L36-L58)

For example, to download a file using as many connections as your machine has [active processors](https://developer.apple.com/documentation/foundation/processinfo/1408184-activeprocessorcount):

```swift
try await URLSession.shared.flock(from: URL(string: "http://212.183.159.230/1GB.zip")!)
```

To track progress of your download as it transfers, pass a [`FlockProgressDelegate`](https://github.com/qasim/Flock/blob/main/Sources/Flock%2BProgress.swift#L27-L35):

```swift
class ExampleProgressDelegate: FlockProgressDelegate {
    func request(_ request: URLRequest, didRecieveBytes bytesReceived: Int, totalBytesReceived: Int, totalBytesExpected: Int) {
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

## Benchmarks

TODO

## Contributing

TODO
