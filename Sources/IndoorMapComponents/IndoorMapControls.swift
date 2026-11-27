import SwiftUI

public struct IndoorMapFloorPicker: View {
    private let floors: [IndoorMapFloor]
    private let defaultFloorID: UUID?
    @Binding private var selection: UUID?

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
