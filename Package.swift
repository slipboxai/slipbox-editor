// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "slipbox-editor",
    platforms: [
        .macOS("15.4"),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "SlipboxEditor",
            targets: ["SlipboxEditor"]
        )
    ],
    dependencies: [
        // No external dependencies - self-contained package
    ],
    targets: [
        .target(
            name: "SlipboxEditor",
            dependencies: [],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "SlipboxEditorTests",
            dependencies: ["SlipboxEditor"]
        ),
    ]
)
