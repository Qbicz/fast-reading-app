// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FastReadingApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FastReadingApp",
            targets: ["FastReadingApp"]),
    ],
    targets: [
        .target(
            name: "FastReadingApp",
            dependencies: ["FastReadingCore"],
            path: "FastReadingApp/FastReadingApp"
        ),
        .systemLibrary(
            name: "FastReadingCore",
            path: "FastReadingCore"
        ),
    ]
)
