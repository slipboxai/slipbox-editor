// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "SlipboxEditorExamples",
    platforms: [
        .macOS("26"),
        .iOS("26"),
    ],
    products: [
        .executable(
            name: "SlipboxEditorDemo",
            targets: ["SlipboxEditorDemo"]
        )
    ],
    dependencies: [
        .package(path: "..")
    ],
    targets: [
        .executableTarget(
            name: "SlipboxEditorDemo",
            dependencies: [
                .product(name: "SlipboxEditor", package: "slipbox-editor")
            ],
            path: "SlipboxEditorDemo"
        )
    ]
)
