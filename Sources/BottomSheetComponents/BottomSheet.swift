import SwiftUI

/// A two-height, nonmodal sheet intended for a bottom-aligned overlay.
public struct BottomSheet<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding private var isExpanded: Bool
    private let collapsedHeight: CGFloat
    private let expandedHeight: CGFloat
    private let bottomInset: CGFloat
    private let accessibilityIdentifier: String
    private let content: () -> Content

    /// Heights include the grabber. Supply the bottom safe area separately if the host extends under it.
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
