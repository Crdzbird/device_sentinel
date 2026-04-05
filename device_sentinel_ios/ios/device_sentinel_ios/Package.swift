// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "device_sentinel_ios",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "vol-spotter-ios", targets: ["device_sentinel_ios"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "device_sentinel_ios",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)