import Foundation

/// 실내 지도 하나를 그리는 데 필요한 장소, 층, 공간과 시설 정보를 모아 둡니다.
///
/// 층과 시설 정보를 이미 가지고 있다면 아래처럼 지도를 만들고 `IndoorMapView`에 넘깁니다.
/// `floorOutline`에는 층의 바깥선을 이루는 위치를 순서대로 넣습니다.
///
/// ```swift
/// let shape = IndoorMapGeometry.polygon([floorOutline])
/// let floor = IndoorMapFloor(id: UUID(), ordinal: 0, name: "1층", geometry: shape)
/// let venue = IndoorMapElement(sourceID: UUID(), kind: .venue, geometry: shape)
/// let map = IndoorMap(venue: venue, floors: [floor], features: [])
/// ```
public struct IndoorMap: Equatable, Sendable {
    public let venue: IndoorMapElement
    public let floors: [IndoorMapFloor]
    public let features: [IndoorMapElement]

    public init(venue: IndoorMapElement, floors: [IndoorMapFloor], features: [IndoorMapElement]) {
        self.venue = venue
        self.floors = floors
        self.features = features
    }
}

/// 층 하나의 이름, 아래층과 위층을 나누는 순서, 지도에 그릴 범위를 담습니다.
public struct IndoorMapFloor: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let ordinal: Int
    public let name: String
    public let geometry: IndoorMapGeometry

    public init(id: UUID, ordinal: Int, name: String, geometry: IndoorMapGeometry) {
        self.id = id
        self.ordinal = ordinal
        self.name = name
        self.geometry = geometry
    }
}

/// 방, 출입구, 편의시설처럼 지도에 표시할 항목 하나입니다.
/// 항목의 종류와 이름, 속한 층, 위치나 모양을 담습니다.
public struct IndoorMapElement: Identifiable, Equatable, Sendable {
    public enum Kind: String, Hashable, Sendable {
        case venue, footprint, unit, section, fixture, opening, amenity
    }

    public struct ID: Hashable, Sendable {
        public let kind: Kind
        public let sourceID: UUID
    }

    public var id: ID { ID(kind: kind, sourceID: sourceID) }
    public let sourceID: UUID
    public let kind: Kind
    public let floorID: UUID?
    public let category: String?
    public let name: String?
    public let geometry: IndoorMapGeometry

    public init(
        sourceID: UUID,
        kind: Kind,
        floorID: UUID? = nil,
        category: String? = nil,
        name: String? = nil,
        geometry: IndoorMapGeometry
    ) {
        self.sourceID = sourceID
        self.kind = kind
        self.floorID = floorID
        self.category = category
        self.name = name
        self.geometry = geometry
    }
}

/// 지도 위 한 지점을 위도와 경도로 나타냅니다.
public struct IndoorMapCoordinate: Hashable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public var isValid: Bool {
        latitude.isFinite && longitude.isFinite
            && (-90...90).contains(latitude) && (-180...180).contains(longitude)
    }

    /// 건물 안의 가까운 두 지점 사이 거리를 미터로 대략 계산합니다.
    func distanceMeters(to other: Self) -> Double {
        let metersPerLatitude = 111_320.0
        let metersPerLongitude = metersPerLatitude * cos((latitude + other.latitude) / 2 * .pi / 180)
        return hypot((latitude - other.latitude) * metersPerLatitude,
                     (longitude - other.longitude) * metersPerLongitude)
    }
}

/// 방의 바깥선이나 시설의 위치를 점, 선, 영역으로 나타냅니다.
public enum IndoorMapGeometry: Hashable, Sendable {
    case point(IndoorMapCoordinate)
    case lineString([IndoorMapCoordinate])
    /// 첫 번째 둘레는 바깥선이고, 나머지는 가운데 비워 둘 부분의 둘레입니다.
    case polygon([[IndoorMapCoordinate]])
    case multiPolygon([[[IndoorMapCoordinate]]])

    var coordinates: [IndoorMapCoordinate] {
        switch self {
        case .point(let point): [point]
        case .lineString(let points): points
        case .polygon(let rings): rings.flatMap { $0 }
        case .multiPolygon(let polygons): polygons.flatMap { $0.flatMap { $0 } }
        }
    }

    func contains(_ point: IndoorMapCoordinate) -> Bool {
        switch self {
        case .polygon(let rings): Self.contains(point, rings: rings)
        case .multiPolygon(let polygons): polygons.contains { Self.contains(point, rings: $0) }
        default: false
        }
    }

    private static func contains(_ point: IndoorMapCoordinate, rings: [[IndoorMapCoordinate]]) -> Bool {
        guard let exterior = rings.first, ringContains(point, ring: exterior) else { return false }
        return !rings.dropFirst().contains { ringContains(point, ring: $0) }
    }

    private static func ringContains(_ point: IndoorMapCoordinate, ring: [IndoorMapCoordinate]) -> Bool {
        guard ring.count >= 3, let last = ring.last, ring.allSatisfy(\.isValid) else { return false }
        var previous = last
        var inside = false
        for current in ring {
            defer { previous = current }
            let cross = (point.longitude - previous.longitude) * (current.latitude - previous.latitude)
                - (point.latitude - previous.latitude) * (current.longitude - previous.longitude)
            let onBounds = (min(previous.longitude, current.longitude)...max(previous.longitude, current.longitude))
                .contains(point.longitude)
                && (min(previous.latitude, current.latitude)...max(previous.latitude, current.latitude))
                .contains(point.latitude)
            if abs(cross) < 1e-14 && onBounds { return true }
            if (previous.latitude > point.latitude) != (current.latitude > point.latitude) {
                let crossing = (current.longitude - previous.longitude) * (point.latitude - previous.latitude)
                    / (current.latitude - previous.latitude) + previous.longitude
                if point.longitude < crossing { inside.toggle() }
            }
        }
        return inside
    }
}
