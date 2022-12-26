// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Flock.Benchmark",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "benchmark", targets: ["Benchmark"]),
        .executable(name: "support", targets: ["Support"]),
    ],
    dependencies: [
        .package(name: "Flock", path: ".."),
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.2.0"),
        .package(url: "https://github.com/qasim/swift-collections-benchmark", branch: "main"),
        .package(url: "https://github.com/apple/swift-tools-support-core", exact: "0.4.0"),
    ],
    targets: [
        .executableTarget(
            name: "Benchmark",
            dependencies: [
                .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
                .product(name: "TSCBasic", package: "swift-tools-support-core"),
            ]
        ),
        .executableTarget(
            name: "Support",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Flock",
                .product(name: "TSCBasic", package: "swift-tools-support-core"),
            ]
        ),
    ]
)
