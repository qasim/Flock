// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Flock.CLI",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "flock", targets: ["CLI"]),
    ],
    dependencies: [
        .package(name: "Flock", path: ".."),
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.2.0")
    ],
    targets: [
        .executableTarget(
            name: "CLI",
            dependencies: [
                "Flock",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources"
        ),
    ]
)
