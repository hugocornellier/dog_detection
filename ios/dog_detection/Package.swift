// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "dog_detection",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "dog-detection", targets: ["dog_detection"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "dog_detection",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
