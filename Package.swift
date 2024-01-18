// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RadoSmallServer",
    products: [
        .library(
            name: "RadoSmallServer",
            targets: ["RadoSmallServer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio", from: "2.12.0")
    ],
    targets: [
        .target(name: "RadoSmallServer", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOHTTP1", package: "swift-nio")
        ]),
        .testTarget(name: "RadoSmallServerTests", dependencies: [
            .target(name: "RadoSmallServer"),
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOHTTP1", package: "swift-nio")
        ])
    ]
)
