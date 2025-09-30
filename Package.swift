// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PolarGX",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PolarGX",
            targets: ["PolarGX"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PolarGX",
            dependencies: [],
            path: "PolarGX-SDK",
            exclude: ["PolarGX.xcodeproj"],
            sources: ["Classes"]
        )
    ],
    swiftLanguageVersions: [.v5]
)