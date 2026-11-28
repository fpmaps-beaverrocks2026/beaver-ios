import SwiftUI

extension BeaverUI {
    /// 제목과 안내 문구를 읽고 두 가지 선택지 중 하나를 고를 수 있는 카드입니다.
    /// 카드에 넣을 문구와 버튼을 눌렀을 때 할 일은 사용하는 화면에서 정합니다.
    ///
    /// 카드가 보일 자리에 아래 코드를 놓고, 화면에서 준비한 두 가지 동작을 넘깁니다.
    ///
    /// ```swift
    /// BeaverUI.ConfirmationCard(
    ///     title: "알림을 받을까요?",
    ///     message: "운영 시간이 바뀌면 알려 드립니다.",
    ///     cancelTitle: "나중에",
    ///     confirmTitle: "받기",
    ///     onCancel: dismissCard,
    ///     onConfirm: enableNotifications
    /// )
    /// ```
    public struct ConfirmationCard: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let title: String
        private let message: String
        private let cancelTitle: String
        private let confirmTitle: String
        private let onCancel: () -> Void
        private let onConfirm: () -> Void

        public init(
            title: String,
            message: String,
            cancelTitle: String,
            confirmTitle: String,
            onCancel: @escaping () -> Void,
            onConfirm: @escaping () -> Void
        ) {
            self.title = title
            self.message = message
            self.cancelTitle = cancelTitle
            self.confirmTitle = confirmTitle
            self.onCancel = onCancel
            self.onConfirm = onConfirm
        }

        public var body: some View {
            VStack(alignment: .leading, spacing: Spacing._12) {
                Text(title)
                    .beaverTypography(.body1)
                    .accessibilityAddTraits(.isHeader)
                Text(message)
                    .beaverTypography(.caption1)

                let layout = dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(spacing: Spacing._10))
                    : AnyLayout(HStackLayout(spacing: Spacing._10))
                layout {
                    button(cancelTitle, background: Color(white: 0.76), role: .cancel, action: onCancel)
                    button(confirmTitle, background: ColorToken.primaryLight, action: onConfirm)
                }
                .padding(.top, Spacing._8)
            }
            .foregroundStyle(ColorToken.neutralDark)
            .fixedSize(horizontal: false, vertical: true)
            .padding(Spacing._20)
            .frame(maxWidth: 274)
            .background(Color(white: 0.87), in: .rect(cornerRadius: Radius.bottomSheet))
            .shadow(color: .black.opacity(0.25), radius: 20, y: 8)
        }

        private func button(
            _ title: String,
            background: Color,
            role: ButtonRole? = nil,
            action: @escaping () -> Void
        ) -> some View {
            Button(role: role, action: action) {
                Text(title)
                    .beaverTypography(.caption1.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing._8)
                    .padding(.vertical, Spacing._4)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(background, in: .capsule)
            }
            .buttonStyle(PressOpacityButtonStyle())
        }
    }
}
