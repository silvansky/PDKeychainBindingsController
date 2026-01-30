// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PDKeychainBindingsController",
    platforms: [.iOS(.v12), .macOS(.v10_13)],
    products: [
        .library(name: "PDKeychainBindingsController", targets: ["PDKeychainBindingsController"])
    ],
    targets: [
        .target(
            name: "PDKeychainBindingsController",
            path: "Sources/PDKeychainBindingsController",
            publicHeadersPath: "include"
        )
    ]
)
