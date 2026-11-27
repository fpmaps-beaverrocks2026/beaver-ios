// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "BeaverComponents",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "IndoorMapComponents", targets: ["IndoorMapComponents"]),
        .library(name: "BottomSheetComponents", targets: ["BottomSheetComponents"]),
    ],
    targets: [
        .target(name: "IndoorMapComponents", resources: [.process("Resources")]),
        .target(name: "BottomSheetComponents"),
    ]
)
