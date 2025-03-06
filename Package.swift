// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftAwsNuggets",
    platforms: [
         .macOS(.v10_15), // Set the minimum deployment target to macOS 10.15
         .iOS(.v13)
     ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftAwsNuggets",
            targets: ["SwiftAwsNuggets"]),
    ],
    dependencies: [
            // Add the aws-sdk-swift dependency
            .package(url: "https://github.com/awslabs/aws-sdk-swift.git", "1.2.32"..<"2.0.0")
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftAwsNuggets",
            dependencies: [
                .product(name: "AWSClientRuntime", package: "aws-sdk-swift"),
                .product(name: "AWSCognitoIdentity", package: "aws-sdk-swift")
            ],
            path: "Sources/SwiftAwsNuggets",
            sources: ["AwsAccessor.swift", "AwsV4Signer.swift"]
        ),
        .testTarget(
            name: "SwiftAwsNuggetsTests",
            dependencies: [
                "SwiftAwsNuggets",
                .product(name: "AWSClientRuntime", package: "aws-sdk-swift"),
                .product(name: "AWSCognitoIdentity", package: "aws-sdk-swift")
            ]
        ),
    ]
)
