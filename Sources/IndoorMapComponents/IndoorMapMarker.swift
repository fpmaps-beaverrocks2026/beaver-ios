import Foundation

/// 지도 위 한 지점에 표시할 시설이나 찜 항목 하나입니다.
/// 표시할 층과 위치, 이름을 담고, 찜 표시에는 그 장소에서 찜한 항목들을 함께 담습니다.
///
/// 시설 표시와 찜 표시를 합쳐 `IndoorMapView`의 `markers`에 넘깁니다.
/// `placements`는 찜할 수 있는 항목들의 위치 목록입니다. `favoriteIDs`에는 이미 찜한 항목의 번호를 넣습니다.
///
/// ```swift
/// let markers = IndoorMapMarker.amenities(in: map)
///     + IndoorMapMarker.favorites(placements, favoriteIDs: favoriteIDs)
/// ```
public struct IndoorMapMarker: Equatable, Identifiable, Sendable {
    /// 표시가 가리키는 대상에 따라 아이콘을 고를 수 있게 종류를 나눕니다.
    public enum Kind: String, CaseIterable, Sendable {
        case favorite, stairs, elevator, toilet, shop, printer, media
        case cafe, plora, conferenceRoom, gamingRoom, groupStudyRoom, relaxZone
        case waterDispenser, entranceDesk, circulationDesk, computer, nursingRoom
        case other

        var isAlwaysVisible: Bool {
            self == .favorite || self == .stairs || self == .elevator
        }

        var systemImage: String {
            switch self {
            case .favorite: "heart.fill"
            case .stairs: "stairs"
            case .elevator: "arrow.up.arrow.down.circle.fill"
            case .toilet: "toilet.fill"
            case .shop: "cart.fill"
            case .printer: "printer.fill"
            case .media: "tv.fill"
            case .cafe: "cup.and.saucer.fill"
            case .plora: "leaf.fill"
            case .conferenceRoom: "person.2.fill"
            case .gamingRoom: "gamecontroller.fill"
            case .groupStudyRoom: "person.3.fill"
            case .relaxZone: "sofa.fill"
            case .waterDispenser: "drop.fill"
            case .entranceDesk: "info.circle.fill"
            case .circulationDesk: "book.closed.fill"
            case .computer: "desktopcomputer"
            case .nursingRoom: "figure.child"
            case .other: "mappin.circle.fill"
            }
        }
    }

    public let id: String
    public let kind: Kind
    public let floorID: UUID
    public var coordinate: IndoorMapCoordinate
    public var title: String
    public var subtitle: String?
    public let favoriteIDs: Set<String>

    public init(
        id: String,
        kind: Kind,
        floorID: UUID,
        coordinate: IndoorMapCoordinate,
        title: String,
        subtitle: String? = nil,
        favoriteIDs: Set<String> = []
    ) {
        self.id = id
        self.kind = kind
        self.floorID = floorID
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.favoriteIDs = favoriteIDs
    }

    /// 지도에 들어 있는 시설을 찾아 층마다 표시할 목록을 만듭니다.
    public static func amenities(in map: IndoorMap) -> [Self] {
        IndoorMapAmenityMarkers.amenities(on: map)
    }

    /// 같은 층의 같은 장소에 있는 찜 항목을 표시 하나로 묶습니다. 같은 항목은 그 장소에서 한 번만 셉니다.
    /// 항목에 가능한 장소가 여러 곳이면 각 장소에 표시할 수 있습니다.
    public static func favorites(
        _ placements: [MapFavoritePlacement],
        favoriteIDs: Set<String>,
        title: (Int) -> String = { "찜한 항목 \($0)개" }
    ) -> [Self] {
        struct Place: Hashable {
            let floorID: UUID
            let id: String
        }

        let validPlacements = placements.filter { favoriteIDs.contains($0.itemID) && $0.coordinate.isValid }
        let groups = Dictionary(grouping: validPlacements) { Place(floorID: $0.floorID, id: $0.placeID) }
        return groups.compactMap { place, group -> Self? in
            guard let first = group.first else { return nil }
            let items = Set(group.map(\.itemID))
            let coordinates = Set(group.map(\.coordinate)).sorted {
                ($0.latitude, $0.longitude) < ($1.latitude, $1.longitude)
            }
            let coordinate = IndoorMapCoordinate(
                latitude: coordinates.map(\.latitude).reduce(0, +) / Double(coordinates.count),
                longitude: coordinates.map(\.longitude).reduce(0, +) / Double(coordinates.count)
            )
            let name = group.lazy.compactMap(\.placeName).first
            let isCandidate = group.contains(where: \.isCandidate)
            let subtitle = if isCandidate { name.map { "\($0) · 위치 후보" } ?? "위치 후보" } else { name }
            return Self(id: "favorite-\(place.floorID.uuidString)-\(place.id)", kind: .favorite,
                        floorID: first.floorID, coordinate: coordinate, title: title(items.count),
                        subtitle: subtitle, favoriteIDs: items)
        }.sorted { $0.id < $1.id }
    }
}

/// 앱이 알려 준 항목의 위치입니다. 항목이 어느 층의 어느 장소에 있는지 담습니다.
///
/// 같은 곳에 있는 항목들에는 같은 `placeID`를 줍니다.
/// 이렇게 만든 위치 목록을 `IndoorMapMarker.favorites(placements, favoriteIDs: favoriteIDs)`에 넘깁니다.
public struct MapFavoritePlacement: Sendable {
    public let itemID: String
    public let placeID: String
    public let floorID: UUID
    public let coordinate: IndoorMapCoordinate
    public let placeName: String?
    /// 정확한 위치를 아직 확정할 수 없는 경우 이 값으로 표시합니다.
    public let isCandidate: Bool

    public init(
        itemID: String,
        placeID: String,
        floorID: UUID,
        coordinate: IndoorMapCoordinate,
        placeName: String? = nil,
        isCandidate: Bool = false
    ) {
        self.itemID = itemID
        self.placeID = placeID
        self.floorID = floorID
        self.coordinate = coordinate
        self.placeName = placeName
        self.isCandidate = isCandidate
    }
}
