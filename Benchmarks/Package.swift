// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Flock.Benchmarks",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "benchmarks", targets: ["Benchmarks"]),
    ],
    dependencies: [
        .package(name: "Flock", path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "Benchmarks",
            dependencies: ["Flock"],
            path: "Sources"
        ),
    ]
)
