// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ProgressiveBlur",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "ProgressiveBlur", targets: ["ProgressiveBlur"])
    ],
    targets: [
        .target(
            name: "ProgressiveBlur",
            resources: [
                .process("Resources"),
                .process("ProgressiveBlur.metal")
            ]
        ),
        .testTarget(
            name: "ProgressiveBlurTests",
            dependencies: ["ProgressiveBlur"]
        )
    ]
)
