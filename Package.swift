// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Flock",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "Flock", targets: ["Flock"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", exact: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", exact: "1.4.4"),
    ],
    targets: [
        .target(
            name: "Flock",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(
            name: "FlockTests",
            dependencies: ["Flock"]
        ),
    ]
)
