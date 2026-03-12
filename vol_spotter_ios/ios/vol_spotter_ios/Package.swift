// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "vol_spotter_ios",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "vol-spotter-ios", targets: ["vol_spotter_ios"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "vol_spotter_ios",
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