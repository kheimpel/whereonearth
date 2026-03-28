// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WhereOnEarth",
    platforms: [
        .watchOS(.v11)
    ],
    targets: [
        .executableTarget(
            name: "WhereOnEarth",
            path: "WhereOnEarth",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "WhereOnEarthTests",
            dependencies: ["WhereOnEarth"],
            path: "WhereOnEarthTests"
        ),
    ]
)
