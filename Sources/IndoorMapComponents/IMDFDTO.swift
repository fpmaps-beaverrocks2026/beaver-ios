import Foundation

/// 실내 지도 파일이 어떤 버전으로 저장됐는지 알려 줍니다.
nonisolated struct IMDFManifestDTO: Decodable {
    let version: String
}

/// 같은 종류의 지도 항목을 한 파일에서 읽습니다.
nonisolated struct IMDFFeatureCollectionDTO: Decodable {
    let type: String
    let features: [IMDFFeatureDTO]
}

/// 파일에서 읽은 방, 계단, 화장실 같은 지도 항목 하나입니다.
nonisolated struct IMDFFeatureDTO: Decodable {
    let type: String
    let id: UUID
    let featureType: String
    let properties: IMDFPropertiesDTO
    let geometry: IMDFGeometryDTO?

    enum CodingKeys: String, CodingKey {
        case type, id, properties, geometry
        case featureType = "feature_type"
    }
}

/// 항목이 어느 층과 방에 속하는지, 이름과 종류가 무엇인지 담습니다.
nonisolated struct IMDFPropertiesDTO: Decodable {
    let ordinal: Int?
    let levelID: UUID?
    let unitIDs: [UUID]?
    let name: [String: String]?
    let category: String?

    enum CodingKeys: String, CodingKey {
        case ordinal, name, category
        case levelID = "level_id"
        case unitIDs = "unit_ids"
    }
}

/// 파일에 저장된 위치나 모양을 점, 선, 하나 또는 여러 영역으로 읽습니다.
nonisolated enum IMDFGeometryDTO: Decodable {
    case point([Double])
    case lineString([[Double]])
    case polygon([[[Double]]])
    case multiPolygon([[[[Double]]]])

    private enum CodingKeys: String, CodingKey {
        case type, coordinates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(String.self, forKey: .type) {
        case "Point":
            self = .point(try container.decode([Double].self, forKey: .coordinates))
        case "LineString":
            self = .lineString(try container.decode([[Double]].self, forKey: .coordinates))
        case "Polygon":
            self = .polygon(try container.decode([[[Double]]].self, forKey: .coordinates))
        case "MultiPolygon":
            self = .multiPolygon(try container.decode([[[[Double]]]].self, forKey: .coordinates))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container, debugDescription: "지원하지 않는 지도 geometry 형식"
            )
        }
    }
}
