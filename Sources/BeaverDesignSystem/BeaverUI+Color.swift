import SwiftUI

extension BeaverUI {
    /// 흰색부터 검정까지의 회색과 주요 강조색을 밝기별로 모아 둡니다.
    public enum ColorPrimitive {
        public enum Grayscale {
            public static let _0 = Color(beaverHex: 0xFFFFFF)
            public static let _25 = Color(beaverHex: 0xF9F9F9)
            public static let _50 = Color(beaverHex: 0xF3F3F3)
            public static let _100 = Color(beaverHex: 0xE7E7E7)
            public static let _200 = Color(beaverHex: 0xDBDBDB)
            public static let _250 = Color(beaverHex: 0xD9D9D9)
            public static let _300 = Color(beaverHex: 0xB6B6B6)
            public static let _400 = Color(beaverHex: 0x999999)
            public static let _500 = Color(beaverHex: 0x777777)
            public static let _600 = Color(beaverHex: 0x555555)
            public static let _700 = Color(beaverHex: 0x333333)
            public static let _800 = Color(beaverHex: 0x2B2B2B)
            public static let _900 = Color(beaverHex: 0x242424)
            public static let _1000 = Color(beaverHex: 0x1D1D1D)
            public static let _1100 = Color(beaverHex: 0x121212)
            public static let black = Color(beaverHex: 0x000000)
        }

        public enum Primary {
            public static let _100 = Color(beaverHex: 0xF7FDCE)
            public static let _200 = Color(beaverHex: 0xEEFA9E)
            public static let _300 = Color(beaverHex: 0xE6F86D)
            public static let _500 = Color(beaverHex: 0xDDF53C)
            public static let _600 = Color(beaverHex: 0xC5E300)
            public static let _700 = Color(beaverHex: 0xBBCE3A)
            public static let _800 = Color(beaverHex: 0x99A738)
            public static let _900 = Color(beaverHex: 0x778137)
        }
    }

    /// 글자, 버튼, 입력 칸처럼 화면에서 맡은 역할에 따라 색을 고릅니다.
    public enum ColorToken {
        private typealias Gray = ColorPrimitive.Grayscale
        private typealias Primary = ColorPrimitive.Primary

        public static let neutralDark = Gray._1100
        public static let neutralPrimary = Gray._25
        public static let neutralSecondary = Gray._50
        public static let neutralTertiary = Gray._250
        public static let primaryLight = Primary._500
        public static let primaryDark = Primary._600
        public static let glassBackground = Gray._400.opacity(0.17)
        public static let textAvailable = Color(beaverHex: 0x34C759)
        public static let textUnavailable = Color(beaverHex: 0xFF383C)

        public enum RouteBar {
            public static let background = Gray._500
            public static let walkIconText = Gray._200
            public static let elevatorIconText = Gray._0
            public static let walkIconFill = Gray._600
            public static let walkIconStroke = Gray._700
            public static let walkGuideText = Gray._300
            public static let elevatorGuideText = Color(beaverHex: 0x005207)
        }

        public enum Tabbar {
            public static let pressedBackground = ColorToken.neutralDark
            public static let darkOverlay = Gray.black
        }

        public enum BookDetails {
            public static let background = Gray._900.opacity(0.8)
            public static let textPlace = Gray._100
            public static let textDistance = Gray._200
            public static let textAuthor = ColorToken.neutralTertiary
            public static let textStory = Gray._300
        }

        public enum MapIndicator {
            public static let text = ColorToken.neutralTertiary
        }

        public enum Button {
            public static let primaryBackground = ColorToken.primaryLight
            public static let primaryText = Gray._800
            public static let primaryBacking = Gray._0
            public static let neutralBackground = Gray._700
            public static let neutralText = ColorToken.neutralPrimary
            public static let neutralBacking = ColorToken.neutralSecondary
            public static let neutralShadow = Gray._400.opacity(0.17)
            public static let disabledBackground = Gray._700
            public static let disabledText = Gray._500
            public static let effectDark = Gray._900
            public static let effectLight = Gray._100
        }

        public enum BookSelection {
            public static let itemBackground = Gray._800
            public static let itemTextAuthor = ColorToken.neutralTertiary
            public static let itemBorder = Gray._600
            public static let checkboxItemBorder = Gray._300
        }

        public enum Chip {
            public static let neutralBackground = Gray._900
        }

        public enum BookSticker {
            public static let bottomColor = Color(beaverHex: 0x4D71FF)
            public static let background = Gray._200
            public static let textTop = Gray.black
            public static let textMiddle = Gray._700
            public static let textLarge = Gray._0
        }

        public enum Pin {
            public static let startBackgroundFill = Color(beaverHex: 0x08C66A)
            public static let startStroke = Color(beaverHex: 0x087F4A)
            public static let endBackgroundFill = Color(beaverHex: 0xC83434)
            public static let endStroke = Color(beaverHex: 0x7D2121)
            public static let text = Gray._0
        }

        public static let recommendationBackground = Primary._600.opacity(0.6)

        public static let accent = Color(red: 0.88, green: 0.95, blue: 0.19)

        public enum Field {
            public static let background = Gray._900
            public static let caption = Gray._500
            public static let actionTint = Gray._700
            public static let disabledBackground = Color(beaverHex: 0x161616)
            public static let disabledText = Gray._400
        }

        public static let fillsSecondary = Color(uiColor: .secondarySystemFill)
    }
}

private extension Color {
    init(beaverHex hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
