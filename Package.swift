// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Auth0",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_11),
        .watchOS(.v2),
        .tvOS(.v9),
    ],
    products: [
        .library(
            name: "Auth0",
            targets: [
                "Auth0"
            ]
        ),
    ],
    dependencies: [
        .package(name: "JWTDecode", url: "https://github.com/auth0/JWTDecode.swift", from: "2.4.1"),
        .package(url: "https://github.com/auth0/SimpleKeychain", from: "0.11.1"),
//        .package(url: "https://github.com/Quick/Quick", .upToNextMajor(from: "2.0.0")),
//        .package(url: "https://github.com/Quick/Nimble", from: "8.1.0"),
//        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", from: "9.0.0"),
    ],
    targets: [
        .target(
            name: "Auth0",
            dependencies: [
                "Auth0ObjC",
                "SimpleKeychain",
                "JWTDecode",
            ]
        ),
        .target(
            name: "Auth0ObjC",
            dependencies: [
            ],
            publicHeadersPath: "."
        ),
//        .testTarget(
//            name: "Auth0Tests",
//            dependencies: [
//                "Auth0",
//                "Quick",
//                "Nimble",
//                "OHHTTPStubs",
//                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")
//            ]
//        ),
    ]
)
