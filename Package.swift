// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "AutoComposerKit",
    platforms: [
        // Relevant platforms.
        .iOS(.v15), .macOS(.v12), .tvOS(.v15)
    ],
    products: [
        .library(name: "AutoComposerKit", targets: ["AutoComposerKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apparata/MIDISequencer.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "AutoComposerKit",
            dependencies: ["MIDISequencer"],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
                .define("SWIFT_PACKAGE")
            ]),
    ]
)
