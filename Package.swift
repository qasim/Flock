// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Flock",
    products: [
        .library(
            name: "Flock",
            targets: ["Flock"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Flock",
            dependencies: []
        ),
        .testTarget(
            name: "FlockTests",
            dependencies: ["Flock"]
        ),
    ]
)
