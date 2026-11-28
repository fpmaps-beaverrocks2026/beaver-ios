import SwiftUI
import UIKit

extension BeaverUI {
    /// 앱에 등록된 글꼴을 찾아 쓸 때 쓰는 이름입니다.
    public enum FontFamily {
        public static let pretendard = "Pretendard"
    }

    /// 같은 글자 크기에서 굵기를 고를 때 씁니다.
    public enum FontStyle: String, CaseIterable, Sendable {
        case regular = "Regular"
        case medium = "Medium"
        case semibold = "SemiBold"
        case bold = "Bold"

        var systemWeight: UIFont.Weight {
            switch self {
            case .regular: .regular
            case .medium: .medium
            case .semibold: .semibold
            case .bold: .bold
            }
        }
    }

    /// 글자의 기본 크기입니다.
    public enum FontSize {
        public static let _32: CGFloat = 32
        public static let _24: CGFloat = 24
        public static let _20: CGFloat = 20
        public static let _18: CGFloat = 18
        public static let _16: CGFloat = 16
        public static let _14: CGFloat = 14
        public static let _12: CGFloat = 12
    }

    /// 글자 한 줄이 차지하는 높이입니다.
    public enum LineHeight {
        public static let _32: CGFloat = 45
        public static let _28: CGFloat = 39.2
        public static let _24: CGFloat = 34
        public static let _20: CGFloat = 28
        public static let _18: CGFloat = 25
        public static let _16: CGFloat = 22.4
        public static let _14: CGFloat = 19.6
        public static let _12: CGFloat = 16.8
    }

    /// 이웃한 글자 사이의 간격을 얼마나 좁힐지 정합니다.
    public enum LetterSpacing {
        public static let _32: CGFloat = -0.64
        public static let _28: CGFloat = -0.56
        public static let _24: CGFloat = -0.48
        public static let _20: CGFloat = -0.4
        public static let _18: CGFloat = -0.36
        public static let _16: CGFloat = -0.32
        public static let _14: CGFloat = -0.28
        public static let _12: CGFloat = -0.24
    }

    public enum SystemFont {
        /// 버튼 글자에 iOS 기본 글꼴을 쓰고, 기기의 글자 크기 설정을 따릅니다.
        public static let button = Font.system(.body, design: .default, weight: .medium)
    }

    /// 제목, 본문과 작은 설명에 쓰는 글자 크기, 굵기, 줄 간격과 글자 간격을 모아 둡니다.
    /// 앱에 Pretendard가 등록되어 있으면 그 글꼴을 쓰고, 없으면 iOS 기본 글꼴을 씁니다.
    public struct Typography: Sendable {
        /// 기기의 글자 크기 설정을 따를지 정합니다.
        public enum Scaling: Sendable {
            case dynamic
            case fixed
        }

        public let style: FontStyle
        public let size: CGFloat
        public let lineHeight: CGFloat
        public let letterSpacing: CGFloat
        public let relativeTo: UIFont.TextStyle

        public var fontName: String { "\(FontFamily.pretendard)-\(style.rawValue)" }

        public static let largeTitle = Self(style: .semibold, size: FontSize._32,
            lineHeight: LineHeight._32, letterSpacing: LetterSpacing._32, relativeTo: .largeTitle)
        public static let title1 = Self(style: .semibold, size: FontSize._24,
            lineHeight: LineHeight._24, letterSpacing: LetterSpacing._24, relativeTo: .title1)
        public static let title2 = Self(style: .semibold, size: FontSize._20,
            lineHeight: LineHeight._20, letterSpacing: LetterSpacing._20, relativeTo: .title2)
        public static let bookTitle = Self(style: .semibold, size: FontSize._18,
            lineHeight: LineHeight._18, letterSpacing: LetterSpacing._18, relativeTo: .headline)
        public static let body1 = Self(style: .medium, size: FontSize._18,
            lineHeight: LineHeight._18, letterSpacing: LetterSpacing._18, relativeTo: .body)
        public static let body2 = Self(style: .medium, size: FontSize._16,
            lineHeight: LineHeight._16, letterSpacing: LetterSpacing._16, relativeTo: .body)
        public static let caption1 = Self(style: .regular, size: FontSize._14,
            lineHeight: LineHeight._14, letterSpacing: LetterSpacing._14, relativeTo: .footnote)
        public static let caption2 = Self(style: .regular, size: FontSize._12,
            lineHeight: LineHeight._12, letterSpacing: LetterSpacing._12, relativeTo: .caption1)

        /// 지도 그림에 들어가는 짧은 길안내 문구의 글자 모양입니다.
        @MainActor
        public static var guidance: Self {
            let size: CGFloat = 8
            let font = UIFont(name: "\(FontFamily.pretendard)-\(FontStyle.semibold.rawValue)", size: size)
                ?? .systemFont(ofSize: size, weight: .semibold)
            return Self(style: .semibold, size: size, lineHeight: font.lineHeight,
                        letterSpacing: 0, relativeTo: .body)
        }

        public static let button = bookTitle
        public static let buttonSmall = body2
        public static let shelfHeading = Self(style: .medium, size: FontSize._20,
            lineHeight: LineHeight._20, letterSpacing: LetterSpacing._20, relativeTo: .title3)

        /// 현재 크기와 간격을 유지하면서 글자 굵기를 바꿉니다.
        public func weight(_ style: FontStyle) -> Self {
            Self(style: style, size: size, lineHeight: lineHeight,
                 letterSpacing: letterSpacing, relativeTo: relativeTo)
        }

        /// 실제 화면에 쓰는 글꼴과 글자·줄 간격을 담습니다.
        public struct Metrics {
            public let font: UIFont
            public let lineHeight: CGFloat
            public let letterSpacing: CGFloat

            public var lineSpacing: CGFloat { max(lineHeight - font.lineHeight, 0) }
            public var halfLeading: CGFloat { lineSpacing / 2 }
        }

        /// 기기의 글자 크기 설정에 맞춰 글자와 간격의 크기를 계산합니다.
        @MainActor
        public func metrics(for dynamicTypeSize: DynamicTypeSize, scaling: Scaling = .dynamic) -> Metrics {
            let baseFont = UIFont(name: fontName, size: size)
                ?? UIFont.systemFont(ofSize: size, weight: style.systemWeight)
            let font: UIFont
            switch scaling {
            case .dynamic:
                let traits = UITraitCollection(preferredContentSizeCategory: dynamicTypeSize.contentSizeCategory)
                font = UIFontMetrics(forTextStyle: relativeTo).scaledFont(for: baseFont, compatibleWith: traits)
            case .fixed:
                font = baseFont
            }
            let scale = font.pointSize / size
            return Metrics(font: font, lineHeight: lineHeight * scale, letterSpacing: letterSpacing * scale)
        }

        /// 글자 스타일에서 글꼴만 꺼내 쓸 때 사용합니다.
        @MainActor
        public func font(for dynamicTypeSize: DynamicTypeSize, scaling: Scaling = .dynamic) -> Font {
            Font(metrics(for: dynamicTypeSize, scaling: scaling).font)
        }
    }
}

extension View {
    /// 제목이나 본문에 글꼴과 줄 간격을 함께 적용합니다.
    ///
    /// 제목, 본문, 설명에 맞는 글자 모양을 고릅니다. 지도 위의 짧은 표시처럼 크기를 유지해야 할 때는 `scaling: .fixed`를 넘깁니다.
    ///
    /// ```swift
    /// Text("전시장 안내").beaverTypography(.title1.weight(.bold))
    /// Text("1층").beaverTypography(.caption2, scaling: .fixed)
    /// ```
    public func beaverTypography(_ typography: BeaverUI.Typography, scaling: BeaverUI.Typography.Scaling = .dynamic) -> some View {
        modifier(TypographyModifier(typography: typography, scaling: scaling))
    }
}

private struct TypographyModifier: ViewModifier {
    let typography: BeaverUI.Typography
    let scaling: BeaverUI.Typography.Scaling
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        let metrics = typography.metrics(for: dynamicTypeSize, scaling: scaling)
        content
            .font(Font(metrics.font))
            .tracking(metrics.letterSpacing)
            .lineSpacing(metrics.lineSpacing)
            .padding(.vertical, metrics.halfLeading)
    }
}

private extension DynamicTypeSize {
    var contentSizeCategory: UIContentSizeCategory {
        switch self {
        case .xSmall: .extraSmall
        case .small: .small
        case .medium: .medium
        case .large: .large
        case .xLarge: .extraLarge
        case .xxLarge: .extraExtraLarge
        case .xxxLarge: .extraExtraExtraLarge
        case .accessibility1: .accessibilityMedium
        case .accessibility2: .accessibilityLarge
        case .accessibility3: .accessibilityExtraLarge
        case .accessibility4: .accessibilityExtraExtraLarge
        case .accessibility5: .accessibilityExtraExtraExtraLarge
        @unknown default: .large
        }
    }
}
