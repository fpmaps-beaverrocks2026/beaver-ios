import Foundation

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

    // The amenity clustering distance is measured at building scale.
    func distanceMeters(to other: Self) -> Double {
        let metersPerLatitude = 111_320.0
        let metersPerLongitude = metersPerLatitude * cos((latitude + other.latitude) / 2 * .pi / 180)
        return hypot((latitude - other.latitude) * metersPerLatitude,
                     (longitude - other.longitude) * metersPerLongitude)
    }
}

public enum IndoorMapGeometry: Hashable, Sendable {
    case point(IndoorMapCoordinate)
    case lineString([IndoorMapCoordinate])
    /// The first ring is the exterior. Subsequent rings are holes.
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
