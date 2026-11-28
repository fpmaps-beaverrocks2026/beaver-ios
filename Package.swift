// swift-tools-version: 6.2
import PackageDescription

/// 실내 지도, 화면 아래에서 열리는 창, 공용 화면 꾸밈을 다른 iPhone·iPad 앱에서 가져다 쓸 수 있게 묶습니다.
///
/// Xcode에서 이 폴더를 패키지로 추가한 뒤 앱에서 쓸 제품을 고릅니다.
/// 지도는 `IndoorMapComponents`, 아래쪽 창은 `BottomSheetComponents`, 공용 화면 꾸밈은 `BeaverDesignSystem`입니다.
let package = Package(
    name: "BeaverComponents",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "IndoorMapComponents", targets: ["IndoorMapComponents"]),
        .library(name: "BottomSheetComponents", targets: ["BottomSheetComponents"]),
        .library(name: "BeaverDesignSystem", targets: ["BeaverDesignSystem"]),
    ],
    targets: [
        .target(name: "IndoorMapComponents", resources: [.process("Resources")]),
        .target(name: "BottomSheetComponents"),
        .target(name: "BeaverDesignSystem"),
    ]
)
