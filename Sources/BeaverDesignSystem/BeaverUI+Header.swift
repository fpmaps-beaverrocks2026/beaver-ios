import SwiftUI

extension BeaverUI {
    /// 화면 위쪽에 제목, 필요한 경우에만 보이는 설명, 닫기 버튼을 놓습니다.
    ///
    /// 화면 맨 위에 놓고, 닫기 버튼을 눌렀을 때 실행할 동작을 넘깁니다. 설명은 필요할 때 넣습니다.
    ///
    /// ```swift
    /// BeaverUI.DismissibleHeader(
    ///     title: "전시장 안내",
    ///     subtitle: "층별 시설을 둘러보세요.",
    ///     onClose: closeGuide
    /// )
    /// ```
    public struct DismissibleHeader: View {
        private let title: String
        private let subtitle: String?
        private let closeLabel: String
        private let onClose: () -> Void

        public init(
            title: String,
            subtitle: String? = nil,
            closeLabel: String = "닫기",
            onClose: @escaping () -> Void
        ) {
            self.title = title
            self.subtitle = subtitle
            self.closeLabel = closeLabel
            self.onClose = onClose
        }

        public var body: some View {
            HStack(alignment: .top, spacing: Spacing._16) {
                VStack(alignment: .leading, spacing: Spacing._4) {
                    Text(title)
                        .beaverTypography(.title1)
                        .accessibilityAddTraits(.isHeader)
                    if let subtitle {
                        Text(subtitle)
                            .beaverTypography(.title1)
                            .foregroundStyle(.secondary)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

                GlassIconButton(closeLabel, systemImage: "xmark", symbolSize: 17, action: onClose)
            }
            .padding([.horizontal, .top], Spacing._20)
        }
    }

    /// 지도처럼 그림이 있는 화면 위에서 제목을 읽기 편하게 위쪽 배경을 흐리게 합니다.
    ///
    /// 제목 뒤에 배경으로 넣고, 흐리게 만들 높이를 넘깁니다.
    ///
    /// ```swift
    /// Text("전시장 안내")
    ///     .frame(maxWidth: .infinity, alignment: .leading)
    ///     .background(alignment: .top) {
    ///         BeaverUI.HeaderBackground(height: 160)
    ///     }
    /// ```
    public struct HeaderBackground: View {
        @Environment(\.colorScheme) private var colorScheme
        private let height: CGFloat

        public init(height: CGFloat = 361) {
            self.height = height
        }

        public var body: some View {
            let shade = colorScheme == .dark ? ColorToken.neutralDark : .white
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .mask {
                        LinearGradient(
                            stops: [
                                .init(color: .white, location: 0),
                                .init(color: .white, location: 0.25),
                                .init(color: .clear, location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }

                LinearGradient(
                    stops: [
                        .init(color: shade, location: 0),
                        .init(color: shade, location: 0.65),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(0.3)
            }
            .frame(height: height)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}
