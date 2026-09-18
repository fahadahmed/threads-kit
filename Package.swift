// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThreadsKit",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "ThreadsTokens", targets: ["ThreadsTokens"])
    ],
    targets: [
        .target(name: "ThreadsTokens", resources: [.process("Resources")]),
        .testTarget(name: "ThreadsTokensTests", dependencies: ["ThreadsTokens"])
    ]
)
