// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "MMMCommonCore",
    platforms: [
        .iOS(.v11),
        .watchOS(.v5),
        .macOS(.v10_10),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "MMMCommonCore",
            targets: ["MMMCommonCore"]
		)
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MMMCommonCoreObjC",
            dependencies: [],
            path: "Sources/MMMCommonCoreObjC"
		),
        .target(
            name: "MMMCommonCore",
            dependencies: ["MMMCommonCoreObjC"],
            path: "Sources/MMMCommonCore"
		),
        .testTarget(
            name: "MMMCommonCoreTests",
            dependencies: ["MMMCommonCore"],
            path: "Tests"
		)
    ]
)

