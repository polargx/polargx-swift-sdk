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
        // Main SDK - XCFramework
        .binaryTarget(
            name: "PolarGX",
            path: "XCFrameworks/PolarGX.xcframework"
        ),
        // NotificationServiceExtension SDK - XCFramework
        .binaryTarget(
            name: "PolarGX_NotificationServiceExtension",
            path: "XCFrameworks/PolarGX_NotificationServiceExtension.xcframework"
        )
    ],
    swiftLanguageVersions: [.v5]
)