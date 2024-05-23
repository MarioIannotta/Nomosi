// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Nomosi",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "Nomosi",
            targets: ["Nomosi"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Nomosi",
               path: "Nomosi/Core")
    ]
)

