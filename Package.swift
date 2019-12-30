// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "AutoComposerKit",
    platforms: [
        // Relevant platforms.
        .iOS(.v13), .macOS(.v10_15), .tvOS(.v13)
    ],
    products: [
        .library(name: "AutoComposerKit", targets: ["AutoComposerKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apparata/MIDISequencer.git", from: "0.1.0")
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
        .testTarget(
            name: "AutoComposerKitTests",
            dependencies: [
                "AutoComposerKit",
                "MIDISequencer"
            ]),
    ]
)
