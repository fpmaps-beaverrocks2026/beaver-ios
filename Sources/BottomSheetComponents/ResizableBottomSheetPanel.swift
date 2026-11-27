import SwiftUI

/// 사용자가 손가락을 움직이는 만큼 안쪽 내용이 보이는 높이를 바꿉니다.
/// 손을 떼면 움직인 방향과 거리에 따라 접거나 펼칩니다.
struct ResizableBottomSheetPanel<Content: View>: View {
    @Binding var presentation: BottomSheetPresentation
    let collapsedHeight: CGFloat
    let maximumHeight: CGFloat
    let identifier: String
    @ViewBuilder let content: () -> Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @GestureState private var isGestureActive = false
    @State private var dragHeight: CGFloat?
    @State private var dragStartHeight: CGFloat?
    @State private var dragStartTranslation: CGFloat = 0
    @State private var renderedHeight: CGFloat = 0
    @State private var isSettling = false
    @State private var motionID = UUID()

    private var minimumHeight: CGFloat { min(collapsedHeight, maximumHeight) }
    private var height: CGFloat {
        dragHeight ?? (presentation.isExpanded ? maximumHeight : minimumHeight)
    }
    private var cornerRadius: CGFloat { 28 * (1 - presentation.expansionProgress) }

    var body: some View {
        content()
            .frame(height: height)
            .background {
                Color.clear
                    .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
                    .opacity(1 - presentation.expansionProgress)
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .contentShape(.rect)
            .simultaneousGesture(panelDrag)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { renderedHeight = $0 }
            .onChange(of: isGestureActive) { _, active in
                guard !active else { return }
                let id = motionID
                Task { @MainActor in
                    await Task.yield()
                    guard motionID == id, !isGestureActive,
                          dragStartHeight != nil, !isSettling else { return }
                    settle(expanded: presentation.isExpanded)
                }
            }
            .onDisappear {
                motionID = UUID()
                dragStartHeight = nil
                dragHeight = nil
                renderedHeight = 0
                isSettling = false
                presentation.isMoving = false
                presentation.dragProgress = nil
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(identifier)
            .accessibilityAction(named: Text("시트 펼치기")) { settle(expanded: true) }
            .accessibilityAction(named: Text("시트 접기")) { settle(expanded: false) }
    }

    private var panelDrag: some Gesture {
        DragGesture(minimumDistance: 6, coordinateSpace: .global)
            .updating($isGestureActive) { _, active, _ in active = true }
            .onChanged { value in
                if dragStartHeight == nil {
                    guard presentation.canBeginDrag(translation: value.translation) else { return }
                    motionID = UUID()
                    isSettling = false
                    presentation.isMoving = true
                    dragStartHeight = renderedHeight > 0 ? renderedHeight : height
                    dragStartTranslation = value.translation.height
                }
                guard let start = dragStartHeight else { return }
                let translation = value.translation.height - dragStartTranslation
                dragHeight = min(maximumHeight, max(minimumHeight, start - translation))
                presentation.dragProgress = presentation.progress(
                    height: dragHeight ?? minimumHeight, minimum: minimumHeight, maximum: maximumHeight)
            }
            .onEnded { value in
                guard dragStartHeight != nil else { return }
                settle(expanded: presentation.targetIsExpanded(
                    translation: value.translation.height - dragStartTranslation,
                    predictedTranslation: value.predictedEndTranslation.height - dragStartTranslation))
            }
    }

    /// 손을 뗀 뒤 창을 정해진 높이로 옮깁니다.
    /// 사용자가 기기에서 움직임 줄이기를 켜면 바로 해당 높이로 바꿉니다.
    private func settle(expanded: Bool) {
        let id = UUID()
        motionID = id
        isSettling = true
        presentation.isMoving = true
        dragStartHeight = nil
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.3), completionCriteria: .removed) {
            presentation.isExpanded = expanded
            presentation.dragProgress = nil
            dragHeight = nil
        } completion: {
            guard motionID == id else { return }
            isSettling = false
            presentation.isMoving = false
        }
    }
}
