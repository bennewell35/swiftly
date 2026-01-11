// swift-tools-version: 5.9
// TEACHING: Swift Package Manager
// Package.swift is the manifest for Swift Package Manager (SPM).
// SPM is Swift's built-in dependency manager (like npm for Node.js).

import PackageDescription

let package = Package(
    name: "SwiftExperiment",

    // TEACHING: Platform Requirements
    // Specify minimum OS versions. This affects which APIs are available.
    // iOS 17+ gives us the latest SwiftUI features.
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],

    // TEACHING: Products
    // What this package produces. For an app, we don't need to define products
    // as Xcode handles the app target. This would matter for libraries.
    products: [
        // If this were a library:
        // .library(name: "SwiftExperiment", targets: ["SwiftExperiment"])
    ],

    // TEACHING: Dependencies
    // External packages we depend on. These are fetched from Git URLs.
    // Amplify packages provide AWS integration.
    dependencies: [
        // AWS Amplify for iOS
        // Provides: Auth (Cognito), API (AppSync/REST), DataStore, Storage (S3)
        .package(
            url: "https://github.com/aws-amplify/amplify-swift.git",
            from: "2.0.0"
        ),

        // Note: For production, you might also add:
        // - KeychainAccess for secure storage
        // - Swift Argument Parser for CLI tools
    ],

    // TEACHING: Targets
    // Build targets for the package. Each target can have its own dependencies.
    targets: [
        .executableTarget(
            name: "SwiftExperiment",
            dependencies: [
                // TEACHING: Product Dependencies
                // Amplify is modular - import only what you need.
                // This reduces app size and build time.
                .product(name: "Amplify", package: "amplify-swift"),
                .product(name: "AWSCognitoAuthPlugin", package: "amplify-swift"),
                .product(name: "AWSAPIPlugin", package: "amplify-swift"),
            ],
            path: "Sources"
        ),

        // TEACHING: Test Target
        // Unit tests live in a separate target.
        // They can import the main target for testing.
        .testTarget(
            name: "SwiftExperimentTests",
            dependencies: ["SwiftExperiment"],
            path: "Tests"
        )
    ]
)
