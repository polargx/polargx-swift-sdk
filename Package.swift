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
        .library(
            name: "PolarGX_NotificationServiceExtension",
            targets: ["PolarGX_NotificationServiceExtension"]),
    ],
    dependencies: [],
    targets: [
        // Main SDK (includes shared Core)
        .target(
            name: "PolarGX",
            dependencies: [],
            path: "PolarGX-SDK",
            exclude: ["PolarGX.xcodeproj", "PolarGX-NotificationServiceExtension"],
            sources: ["Classes", "Core"]
        ),
        // NotificationServiceExtension SDK (includes shared Core)
        .target(
            name: "PolarGX_NotificationServiceExtension",
            dependencies: [],
            path: "PolarGX-SDK",
            exclude: ["PolarGX.xcodeproj", "Classes"],
            sources: ["PolarGX-NotificationServiceExtension", "Core"]
        )
    ],
    swiftLanguageVersions: [.v5]
)