// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Flock.Benchmarks",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "benchmark", targets: ["Benchmarks"]),
    ],
    dependencies: [
        .package(name: "Flock", path: ".."),
        .package(url: "https://github.com/apple/swift-collections-benchmark", exact: "0.0.3"),
    ],
    targets: [
        .executableTarget(
            name: "Benchmarks",
            dependencies: [
                .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
            ],
            path: "Sources"
        ),
    ]
)
