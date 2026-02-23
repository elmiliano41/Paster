// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Paster",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey", from: "0.2.1"),
    ],
    targets: [
        .executableTarget(
            name: "Paster",
            dependencies: [
                "HotKey",
            ],
            path: "Paster",
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
