// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "MMMCommonCore",
    platforms: [
        .iOS(.v11)
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

