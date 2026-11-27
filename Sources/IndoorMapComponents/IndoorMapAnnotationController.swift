import MapKit

/// 지도에 새 표시를 추가하고 사라지거나 바뀐 표시를 지웁니다. 그대로인 표시는 남겨 둡니다.
@MainActor
final class IndoorMapAnnotationController {
    private var annotations: [String: IndoorMapPointAnnotation] = [:]

    func update(_ markers: [IndoorMapMarker], in mapView: MKMapView) {
        let next = Dictionary(markers.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let removed = annotations.values.filter { next[$0.marker.id] != $0.marker }
        for annotation in removed {
            annotations.removeValue(forKey: annotation.marker.id)
        }
        let added = next.values.sorted { $0.id < $1.id }.compactMap { marker -> IndoorMapPointAnnotation? in
            guard annotations[marker.id] == nil else { return nil }
            let annotation = IndoorMapPointAnnotation(marker)
            annotations[marker.id] = annotation
            return annotation
        }
        mapView.removeAnnotations(removed)
        mapView.addAnnotations(added)
    }
}

/// 지도 앱이 위치와 이름을 읽을 수 있게 지도 표시 하나를 전달합니다.
final class IndoorMapPointAnnotation: NSObject, MKAnnotation {
    let marker: IndoorMapMarker
    var coordinate: CLLocationCoordinate2D { marker.coordinate.clCoordinate }
    var title: String? { marker.title }
    var subtitle: String? { marker.subtitle }

    init(_ marker: IndoorMapMarker) { self.marker = marker }
}
