import CoreGraphics

extension BeaverUI {
    /// 버튼, 입력 칸과 아래쪽 창의 모서리를 둥글게 할 때 쓰는 값입니다.
    ///
    /// 배경 모서리를 둥글게 만들 때, 어떤 부분을 꾸미는지에 맞춰 값을 고릅니다.
    ///
    /// ```swift
    /// Text("운영 시간")
    ///     .padding()
    ///     .background(.thinMaterial, in: .rect(cornerRadius: BeaverUI.Radius.bottomSheet))
    /// ```
    public enum Radius {
        public static let _0: CGFloat = 0
        public static let bookCover: CGFloat = 8
        public static let floorAmenitiesToggle: CGFloat = 12
        public static let mapActionButton: CGFloat = 12
        public static let shelfChip: CGFloat = 20
        public static let bookSearch: CGFloat = 20
        public static let selectionField: CGFloat = 20
        public static let bottomSheet: CGFloat = 28
        public static let onboardingChip: CGFloat = 30
        public static let button: CGFloat = 1000
        public static let iconButton: CGFloat = 1000
    }
}
