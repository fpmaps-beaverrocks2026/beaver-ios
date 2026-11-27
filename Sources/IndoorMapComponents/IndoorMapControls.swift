import SwiftUI

/// 층 버튼을 보여 주고, 누른 층의 지도가 열리도록 선택을 바꿉니다.
public struct IndoorMapFloorPicker: View {
    private let floors: [IndoorMapFloor]
    private let defaultFloorID: UUID?
    @Binding private var selection: UUID?

    /// 층 목록과 지도에서 사용하는 선택 값을 넘깁니다. 선택한 층이 없으면 목록의 첫 층을 보여 줍니다.
    public init(floors: [IndoorMapFloor], selection: Binding<UUID?>) {
        self.floors = floors.sorted { $0.ordinal > $1.ordinal }
        self.defaultFloorID = floors.first?.id
        self._selection = selection
    }

    public var body: some View {
        if !floors.isEmpty {
            ViewThatFits(in: .vertical) {
                VStack(spacing: 0) { buttons }
                HStack(spacing: 0) { buttons }
            }
            .clipShape(.rect(cornerRadius: 12))
            .glassEffect(.regular, in: .rect(cornerRadius: 12))
        }
    }

    private var buttons: some View {
        let selectedID = floors.first { $0.id == selection }?.id ?? defaultFloorID
        return ForEach(floors) { floor in
            let isSelected = selectedID == floor.id
            Button { selection = floor.id } label: {
                Text(floor.name)
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal, 6)
                    .frame(minWidth: 61, minHeight: 44)
                    .foregroundStyle(isSelected ? .black : .white)
                    .background(isSelected ? Color(red: 221.0 / 255, green: 245.0 / 255, blue: 60.0 / 255) : .clear)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(floor.name) 지도 보기")
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        }
    }
}

/// 화장실이나 카페 같은 편의시설 표시를 켜고 끄는 버튼입니다.
public struct IndoorMapAmenitiesToggle: View {
    @Binding private var showsAmenities: Bool

    public init(showsAmenities: Binding<Bool>) {
        self._showsAmenities = showsAmenities
    }

    public var body: some View {
        Button { showsAmenities.toggle() } label: {
            Text("편의시설")
                .font(.caption2.weight(showsAmenities ? .bold : .regular))
                .padding(.horizontal, 8)
                .frame(minWidth: 61, minHeight: 44)
                .foregroundStyle(showsAmenities
                    ? Color(red: 221.0 / 255, green: 245.0 / 255, blue: 60.0 / 255) : .white)
                .glassEffect(.regular, in: .rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityValue(showsAmenities ? "전체 시설 표시 중" : "기본 아이콘만 표시 중")
    }
}
