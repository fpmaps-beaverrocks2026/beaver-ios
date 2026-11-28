import SwiftUI

/// 화면 아래에서 접거나 펼칠 수 있는 창입니다.
/// 손잡이를 누르거나 위아래로 밀면 높이가 바뀝니다. 창 밖의 화면도 계속 사용할 수 있습니다.
///
/// 화면에 `@State private var isExpanded = false`를 두고 아래쪽에 창을 겹쳐 놓습니다.
/// 예제의 `map`은 창 뒤에 보일 지도 화면입니다.
///
/// ```swift
/// map.overlay(alignment: .bottom) {
///     BottomSheet(isExpanded: $isExpanded, collapsedHeight: 100, expandedHeight: 300) {
///         Text("층별 시설을 둘러보세요.")
///     }
/// }
/// ```
public struct BottomSheet<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding private var isExpanded: Bool
    private let collapsedHeight: CGFloat
    private let expandedHeight: CGFloat
    private let bottomInset: CGFloat
    private let accessibilityIdentifier: String
    private let content: () -> Content

    /// 접었을 때와 펼쳤을 때의 높이에는 손잡이 공간을 포함합니다.
    /// 창이 화면 맨 아래까지 닿는다면 홈 표시줄을 위한 여백은 따로 넘깁니다.
    public init(
        isExpanded: Binding<Bool>,
        collapsedHeight: CGFloat,
        expandedHeight: CGFloat,
        bottomInset: CGFloat = 0,
        accessibilityIdentifier: String = "bottom-sheet",
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isExpanded = isExpanded
        self.collapsedHeight = collapsedHeight
        self.expandedHeight = expandedHeight
        self.bottomInset = bottomInset
        self.accessibilityIdentifier = accessibilityIdentifier
        self.content = content
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: 28)
        let inset = max(0, bottomInset)
        VStack(spacing: 0) {
            Button { setExpanded(!isExpanded) } label: {
                Capsule().fill(.white.opacity(0.3))
                    .frame(width: 57, height: 4)
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isExpanded ? "시트 접기" : "시트 펼치기")
            .accessibilityIdentifier("\(accessibilityIdentifier)-toggle")
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(.bottom, inset)
        .frame(maxWidth: .infinity)
        .frame(height: max(24, isExpanded ? max(collapsedHeight, expandedHeight) : collapsedHeight) + inset)
        .clipShape(shape)
        .glassEffect(.regular.tint(.black.opacity(0.45)), in: shape)
        .contentShape(.rect)
        .simultaneousGesture(DragGesture(minimumDistance: 12).onEnded { value in
            guard abs(value.translation.height) > abs(value.translation.width) else { return }
            let travel = value.predictedEndTranslation.height
            if abs(travel) > 24 { setExpanded(travel < 0) }
        })
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    private func setExpanded(_ expanded: Bool) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) { isExpanded = expanded }
    }
}
