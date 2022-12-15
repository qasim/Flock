// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Flock",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "Flock",
            targets: [
                "Flock",
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-algorithms",
            exact: "1.0.0"
        ),
    ],
    targets: [
        .target(
            name: "Flock",
            dependencies: [
                .product(
                    name: "Algorithms",
                    package: "swift-algorithms"
                ),
            ]
        ),
        .testTarget(
            name: "FlockTests",
            dependencies: [
                "Flock",
            ]
        ),
    ]
)
