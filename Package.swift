// swift-tools-version: 6.2
import PackageDescription

/// 실내 지도와 화면 아래에서 열리는 창을 다른 iPhone·iPad 앱에서 가져다 쓸 수 있게 묶습니다.
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
