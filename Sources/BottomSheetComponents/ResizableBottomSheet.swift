import SwiftUI

/// A bottom overlay with interactive resizing, an optional collapsed accessory and fixed actions.
public struct ResizableBottomSheet<Content: View, Actions: View, Accessory: View, ExpandedBackground: View>: View {
    @Binding private var presentation: BottomSheetPresentation
    private let availableSize: CGSize
    private let safeAreaInsets: EdgeInsets
    private let topBarHeight: CGFloat
    private let collapsedHeight: CGFloat
    private let expandedBottomPadding: CGFloat
    private let expandedTopInset: CGFloat?
    private let identifier: String
    private let onCoveredHeightChange: (CGFloat) -> Void
    private let accessory: () -> Accessory
    private let content: () -> Content
    private let actions: () -> Actions
    private let expandedBackground: () -> ExpandedBackground

    @State private var actionsHeight: CGFloat = 50
    @State private var renderedHeight: CGFloat = 0

    /// The available size includes the safe area insets supplied here.
    public init(
        presentation: Binding<BottomSheetPresentation>,
        availableSize: CGSize,
        safeAreaInsets: EdgeInsets = .init(),
        topBarHeight: CGFloat = 0,
        collapsedHeight: CGFloat = 376,
        expandedBottomPadding: CGFloat = 16,
        expandedTopInset: CGFloat? = nil,
        accessibilityIdentifier: String = "resizable-bottom-sheet",
        onCoveredHeightChange: @escaping (CGFloat) -> Void = { _ in },
        @ViewBuilder accessory: @escaping () -> Accessory = { EmptyView() },
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder expandedBackground: @escaping () -> ExpandedBackground
    ) {
        self._presentation = presentation
        self.availableSize = availableSize
        self.safeAreaInsets = safeAreaInsets
        self.topBarHeight = topBarHeight
        self.collapsedHeight = max(1, collapsedHeight)
        self.expandedBottomPadding = expandedBottomPadding
        self.expandedTopInset = expandedTopInset
        self.identifier = accessibilityIdentifier
        self.onCoveredHeightChange = onCoveredHeightChange
        self.accessory = accessory
        self.content = content
        self.actions = actions
        self.expandedBackground = expandedBackground
    }

    private var progress: CGFloat { presentation.expansionProgress }
    private var topInset: CGFloat { expandedTopInset ?? safeAreaInsets.top + topBarHeight + 16 }
    private var maximumPanelHeight: CGFloat {
        max(1, availableSize.height - topInset - actionsHeight - 12 - expandedBottomPadding - safeAreaInsets.bottom)
    }

    public var body: some View {
        VStack(spacing: 12) {
            if !presentation.showsExpandedContent, Accessory.self != EmptyView.self {
                accessory()
                    .padding(.bottom, 1)
                    .padding(.leading, 16 + safeAreaInsets.leading)
                    .padding(.trailing, 16 + safeAreaInsets.trailing)
            }
            ResizableBottomSheetPanel(
                presentation: $presentation,
                collapsedHeight: collapsedHeight,
                maximumHeight: maximumPanelHeight,
                identifier: "\(identifier).panel"
            ) {
                content()
                    .padding(.leading, safeAreaInsets.leading * progress)
                    .padding(.trailing, safeAreaInsets.trailing * progress)
            }
            .padding(.leading, (16 + safeAreaInsets.leading) * (1 - progress))
            .padding(.trailing, (16 + safeAreaInsets.trailing) * (1 - progress))
            .padding(.top, topInset * progress)
            actions()
                .padding(.leading, 16 + safeAreaInsets.leading)
                .padding(.trailing, 16 + safeAreaInsets.trailing)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { actionsHeight = $0 }
        }
        .padding(.bottom, 16 + (expandedBottomPadding - 16) * progress + safeAreaInsets.bottom)
        .frame(width: availableSize.width)
        .background { expandedBackground().opacity(progress) }
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
            renderedHeight = max(0, height - safeAreaInsets.bottom)
            if !presentation.showsExpandedContent { onCoveredHeightChange(renderedHeight) }
        }
        .onChange(of: presentation.showsExpandedContent) { _, showsExpandedContent in
            if !showsExpandedContent { onCoveredHeightChange(renderedHeight) }
        }
    }
}
