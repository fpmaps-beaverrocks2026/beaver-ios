import Foundation

public struct IndoorMapMarker: Equatable, Identifiable, Sendable {
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

    public static func amenities(in map: IndoorMap) -> [Self] {
        IndoorMapAmenityMarkers.amenities(on: map)
    }

    /// Groups unique favorite item IDs by place and floor. One item can have several candidate places.
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

/// An item location supplied by the host app. All placements at the same place ID and floor share a marker.
public struct MapFavoritePlacement: Sendable {
    public let itemID: String
    public let placeID: String
    public let floorID: UUID
    public let coordinate: IndoorMapCoordinate
    public let placeName: String?
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
