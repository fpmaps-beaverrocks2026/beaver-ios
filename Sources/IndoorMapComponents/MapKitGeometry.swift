import MapKit

extension IndoorMapCoordinate {
    /// 위도와 경도를 화면의 지도가 읽을 수 있는 형태로 바꿉니다.
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// 실내 지도에서 읽은 선과 영역을 화면에 그릴 수 있는 형태로 바꿉니다.
///
/// `IndoorMapView`가 층을 그릴 때 이 부분을 자동으로 씁니다.
/// 그릴 모양은 `IndoorMapGeometry`로 만들어 `IndoorMap`에 담습니다.
enum MapKitGeometry {
    static func overlays(for geometry: IndoorMapGeometry) -> [any MKOverlay] {
        switch geometry {
        case .point: return []
        case .lineString(let points):
            guard points.count >= 2, points.allSatisfy(\.isValid) else { return [] }
            return [MKPolyline(coordinates: points.map(\.clCoordinate), count: points.count)]
        case .polygon(let rings):
            return polygon(rings).map { [$0] } ?? []
        case .multiPolygon(let polygons):
            return polygons.compactMap { polygon($0) }
        }
    }

    /// 지도 모양에 속한 모든 점을 담는 사각형으로 화면에 보여 줄 범위를 정합니다.
    static func mapRect(for geometry: IndoorMapGeometry) -> MKMapRect {
        geometry.coordinates.reduce(MKMapRect.null) { rect, coordinate in
            guard coordinate.isValid else { return rect }
            let point = MKMapPoint(coordinate.clCoordinate)
            return rect.union(MKMapRect(x: point.x, y: point.y, width: 0.1, height: 0.1))
        }
    }

    private static func polygon(_ rings: [[IndoorMapCoordinate]]) -> MKPolygon? {
        guard let outer = rings.first, rings.allSatisfy({ $0.count >= 3 && $0.allSatisfy(\.isValid) })
        else { return nil }
        let holes = rings.dropFirst().map {
            MKPolygon(coordinates: $0.map(\.clCoordinate), count: $0.count)
        }
        return MKPolygon(coordinates: outer.map(\.clCoordinate), count: outer.count, interiorPolygons: holes)
    }
}
