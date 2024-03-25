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
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.15.1"),
        
        .package(url: "https://github.com/OperatorFoundation/Gardener", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Ghostwriter", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/OmniLanguage", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Time", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/TransmissionAsync", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "Multitool",
            dependencies: [
                "Gardener",
                "Ghostwriter",
                "Stencil",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            resources: [
                .copy("Templates/Transport.txt"),
                .copy("Templates/NOMNIConfig.txt"),
                .copy("Templates/NOMNIController.txt"),
                .copy("Templates/NOMNIError.txt"),
                .copy("Templates/Package.txt"),
                .copy("Templates/Toneburst.txt")]
        ),
        
        .testTarget(name: "MultitoolTests",dependencies: [
            "Multitool",
            "OmniLanguage",
            "Time",
            .product(name: "OmniCompiler", package: "OmniLanguage")
        ]),
    ],
    swiftLanguageVersions: [.v5]
)
