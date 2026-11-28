import CoreGraphics

extension BeaverUI {
    /// 글자, 버튼과 화면 가장자리 사이의 간격을 한곳에서 고릅니다.
    ///
    /// 화면 가장자리나 항목 사이를 띄울 때 같은 값을 골라 씁니다.
    ///
    /// ```swift
    /// Text("전시장 안내")
    ///     .padding(.horizontal, BeaverUI.Spacing._16)
    /// ```
    public enum Spacing {
        public static let _4: CGFloat = 4
        public static let _8: CGFloat = 8
        public static let _10: CGFloat = 10
        public static let _12: CGFloat = 12
        public static let _16: CGFloat = 16
        public static let _20: CGFloat = 20
        public static let _24: CGFloat = 24
    }
}
