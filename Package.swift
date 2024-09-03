// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "neo4j-driver-swift",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .executable(name: "Example", targets: ["Example"]),
        
        .library(name: "Neo4J", targets: ["Neo4J"]),
        .library(name: "Bolt", targets: ["Bolt"]),
        .library(name: "PackStream", targets: ["PackStream"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.27.1"),
        .package(url: "https://github.com/apple/swift-nio-extras.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.3"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "Example",
            dependencies: [
                .target(name: "Bolt"),
                .target(name: "Neo4J"),
            ]),
        .target(
            name: "Neo4J",
            dependencies: [
                .target(name: "Bolt"),
                .target(name: "ConnectionPool"),
                .product(name: "Logging", package: "swift-log"),
            ]),
        .target(
            name: "Bolt",
            dependencies: [
                .target(name: "PackStream"),
                .target(name: "ConnectionPool"),
                
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "NIOExtras", package: "swift-nio-extras"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle")
            ]),
        .target(
            name: "ConnectionPool",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Collections", package: "swift-collections"),
            ]),
        .target(
            name: "PackStream",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
            ]),
        .testTarget(
            name: "Neo4JTests",
            dependencies: ["Neo4J"]
        ),
        .testTarget(
            name: "BoltTests",
            dependencies: ["Bolt"]
        ),
        .testTarget(
            name: "PackStreamTests",
            dependencies: ["PackStream"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
