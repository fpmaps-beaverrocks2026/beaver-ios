import Foundation

public struct BottomSheetPresentation: Equatable, Sendable {
    public var isExpanded: Bool
    /// Updated by callers that supply scrollable content.
    public var isContentAtTop = true
    public internal(set) var isMoving = false
    var dragProgress: CGFloat?

    public init(isExpanded: Bool = false) {
        self.isExpanded = isExpanded
    }

    public var showsExpandedContent: Bool { isExpanded || isMoving }
    public var expansionProgress: CGFloat { dragProgress ?? (isExpanded ? 1 : 0) }

    func canBeginDrag(translation: CGSize) -> Bool {
        guard abs(translation.height) > abs(translation.width) else { return false }
        return !isExpanded || (translation.height > 0 && isContentAtTop)
    }

    func targetIsExpanded(translation: CGFloat, predictedTranslation: CGFloat) -> Bool {
        if isExpanded {
            return !(translation >= 48 || predictedTranslation >= 80)
        }
        return translation <= -48 || predictedTranslation <= -80
    }

    func progress(height: CGFloat, minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        guard maximum > minimum else { return isExpanded ? 1 : 0 }
        return min(1, max(0, (height - minimum) / (maximum - minimum)))
    }
}
