// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CheckPhone",
    defaultLocalization: "en",
    platforms: [.iOS("13.0")],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CheckPhone",
            targets: ["CheckPhone"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
//         .package(url: "https://github.com/kirualex/KAPinField", from: "5.0.1")
        .package(name: "Firebase",
                   url: "https://github.com/firebase/firebase-ios-sdk.git",
                   .branch("6.34-spm-beta")),
        
        .package(url: "https://github.com/jerometonnelier/KCoordinatorKit", from: "1.0.1"),
        .package(url: "https://github.com/jerometonnelier/KExtensions", from: "1.0.0"),
        .package(url: "https://github.com/jerometonnelier/ActionButton", from: "1.0.0"),
        .package(url: "https://github.com/jerometonnelier/ATAConfiguration", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CheckPhone",
            dependencies: [.product(name: "FirebaseAuth", package: "Firebase"), "KCoordinatorKit", "ActionButton", "ATAConfiguration"])
    ]
)