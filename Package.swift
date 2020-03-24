// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Spark QA Helper",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "sparkHelper", targets: ["Spark QA Helper"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Spark QA Helper",
            dependencies: ["ArgumentParser"]),
    ]
)
