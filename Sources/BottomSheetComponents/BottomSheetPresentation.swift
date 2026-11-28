import Foundation

/// 화면 아래의 창이 열려 있는지, 움직이는 중인지, 얼마나 펼쳐졌는지 기억합니다.
///
/// 아래 값을 화면에 두고 `ResizableBottomSheet`의 `presentation`에 `$presentation`을 넘깁니다.
/// 창 안의 목록을 위아래로 넘길 수 있다면 맨 위가 보이는지 `presentation.isContentAtTop`에 기록합니다.
///
/// ```swift
/// @State private var presentation = BottomSheetPresentation()
/// ```
public struct BottomSheetPresentation: Equatable, Sendable {
    public var isExpanded: Bool
    /// 안쪽 목록의 맨 위가 보이는지 기록합니다. 맨 위에서 아래로 밀면 창을 접을 수 있습니다.
    public var isContentAtTop = true
    public internal(set) var isMoving = false
    var dragProgress: CGFloat?

    public init(isExpanded: Bool = false) {
        self.isExpanded = isExpanded
    }

    /// 창이 열려 있거나 움직이는 동안 펼친 내용을 보여 줍니다.
    public var showsExpandedContent: Bool { isExpanded || isMoving }

    /// 접힌 높이는 0, 펼친 높이는 1입니다. 움직이는 동안에는 그 사이 값을 사용합니다.
    public var expansionProgress: CGFloat { dragProgress ?? (isExpanded ? 1 : 0) }

    func canBeginDrag(translation: CGSize) -> Bool {
        guard abs(translation.height) > abs(translation.width) else { return false }
        return !isExpanded || (translation.height > 0 && isContentAtTop)
    }

    /// 손가락을 얼마나 멀리, 얼마나 빠르게 밀었는지 보고 창을 접을지 펼칠지 정합니다.
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
