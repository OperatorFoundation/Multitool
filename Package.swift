// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Multitool",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .executable(
            name: "Multitool",
            targets: ["Multitool"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        
        .package(url: "https://github.com/OperatorFoundation/Gardener", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/KeychainTypes", from: "1.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "Multitool",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),

                "Gardener",
                "KeychainTypes",
            ],
            resources: [.copy("Templates/NOMNIConfig.txt"), .copy("Templates/Package.txt")]
        ),
        .testTarget(
            name: "MultitoolTests",
            dependencies: ["Multitool"]),
    ],
    swiftLanguageVersions: [.v5]
)
