// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DatePicker",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(name: "DatePicker", targets: ["DatePicker"]),
    ],
    targets: [
        .target(name: "DatePicker", path: "Sources"),
        .testTarget(name: "DatePickerTests", dependencies: ["DatePicker"]),
    ]
)
