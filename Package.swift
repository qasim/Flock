// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Flock",
    platforms: [.macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8)],
    products: [
        .library(name: "Flock", targets: ["Flock"]),
    ],
    dependencies: [
        // Source Dependencies
        .package(url: "https://github.com/apple/swift-algorithms", exact: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log", exact: "1.4.4"),

        // Plugins
        .package(url: "https://github.com/themomax/swift-docc-plugin", branch: "add-extended-types-flag"),
    ],
    targets: [
        .target(
            name: "Flock",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "FlockTests",
            dependencies: ["Flock"],
            path: "Tests"
        ),
    ]
)
