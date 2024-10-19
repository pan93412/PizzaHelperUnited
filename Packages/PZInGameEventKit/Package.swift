// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PZInGameEventKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14), .watchOS(.v10), .macCatalyst(.v17), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PZInGameEventKit",
            targets: ["PZInGameEventKit"]
        ),
    ],
    dependencies: [
        .package(path: "../PZKit"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PZInGameEventKit",
            dependencies: [
                .product(name: "PZBaseKit", package: "PZKit"),
            ],
            resources: [
                .process("Resources/"),
            ]
        ),
        .testTarget(
            name: "PZInGameEventKitTests",
            dependencies: ["PZInGameEventKit"]
        ),
    ]
)