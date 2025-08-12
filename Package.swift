// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BCryptSwift",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v5)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "BCryptSwift",
            targets: ["BCryptSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // BCryptSwift has no external dependencies
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BCryptSwift",
            dependencies: [],
            path: "BCryptSwift/Classes",
            exclude: [],
            sources: nil,
            publicHeadersPath: nil,
            cSettings: nil,
            cxxSettings: nil,
            swiftSettings: [
                .define("SWIFT_PACKAGE")
            ],
            linkerSettings: nil),
        .testTarget(
            name: "BCryptSwiftTests",
            dependencies: ["BCryptSwift"],
            path: "Example/Tests",
            exclude: ["Info.plist", "Tests.swift"],
            sources: nil,
            cSettings: nil,
            cxxSettings: nil,
            swiftSettings: nil,
            linkerSettings: nil),
    ],
    swiftLanguageVersions: [.v5],
    cLanguageStandard: nil,
    cxxLanguageStandard: nil
)