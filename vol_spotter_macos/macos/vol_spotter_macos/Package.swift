// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "vol_spotter_macos",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "vol-spotter-macos", targets: ["vol_spotter_macos"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "vol_spotter_macos",
            dependencies: [],
            resources: [
                // TODO: If your plugin requires a privacy manifest
                // (e.g. if it uses any required reason APIs), update the PrivacyInfo.xcprivacy file
                // to describe your plugin's privacy impact, and then uncomment this line.
                // For more information, see:
                // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
                // .process("PrivacyInfo.xcprivacy"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)