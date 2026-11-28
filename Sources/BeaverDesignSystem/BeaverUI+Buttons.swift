import SwiftUI

extension BeaverUI {
    /// 뒤로 가기나 닫기처럼 익숙한 동작을 원 안의 기본 아이콘으로 보여 주는 버튼입니다.
    /// 화면 읽기 기능은 버튼에 넘긴 이름을 읽습니다.
    ///
    /// 버튼 이름, 아이콘 이름, 눌렀을 때 할 일을 차례로 넘깁니다.
    ///
    /// ```swift
    /// BeaverUI.GlassIconButton("뒤로 가기", systemImage: "chevron.left", action: goBack)
    /// ```
    public struct GlassIconButton: View {
        private let title: String
        private let systemImage: String
        private let symbolSize: CGFloat
        private let action: () -> Void

        public init(_ title: String, systemImage: String, symbolSize: CGFloat = 22, action: @escaping () -> Void) {
            self.title = title
            self.systemImage = systemImage
            self.symbolSize = symbolSize
            self.action = action
        }

        public var body: some View {
            Button(action: action) {
                Label(title, systemImage: systemImage)
                    .labelStyle(.iconOnly)
                    .font(.system(size: symbolSize))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .contentShape(.circle)
            }
            .buttonStyle(PressOpacityButtonStyle())
            .glassEffect(.regular.interactive(), in: .circle)
        }
    }

    /// 다음에 하기처럼 크게 강조하지 않아도 되는 동작을 밑줄 있는 글자로 보여 줍니다.
    ///
    /// 보이는 글자와 눌렀을 때 할 일을 넘깁니다.
    ///
    /// ```swift
    /// BeaverUI.UnderlinedButton("다음에 보기", action: showLater)
    /// ```
    public struct UnderlinedButton: View {
        private let title: String
        private let action: () -> Void

        public init(_ title: String, action: @escaping () -> Void) {
            self.title = title
            self.action = action
        }

        public var body: some View {
            Button(action: action) {
                Text(title)
                    .underline()
                    .beaverTypography(.body2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing._4)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(.rect)
            }
            .buttonStyle(PressOpacityButtonStyle())
        }
    }
}

/// 눌렀을 때와 사용할 수 없을 때 버튼을 흐리게 보여 줍니다.
struct PressOpacityButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(isEnabled ? (configuration.isPressed ? 0.7 : 1) : 0.4)
    }
}
