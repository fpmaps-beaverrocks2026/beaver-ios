import MapKit
import UIKit

/// 지도에 그릴 모양의 안쪽 색, 테두리 색과 선 굵기를 담습니다.
struct IndoorOverlayStyle: Hashable {
    var fillColor: UIColor?
    var strokeColor: UIColor?
    var lineWidth: CGFloat = 0

    func apply(to renderer: MKOverlayPathRenderer) {
        renderer.fillColor = fillColor
        renderer.strokeColor = strokeColor
        renderer.lineWidth = lineWidth
    }
}

/// 같은 색과 선 굵기로 이어서 그릴 모양을 한 번에 그릴 수 있게 묶습니다.
/// 지도에 올릴 묶음의 수가 줄어 층을 더 빠르게 보여 줄 수 있습니다.
struct IndoorOverlayBatcher {
    private var batches: [(overlay: any MKOverlay, style: IndoorOverlayStyle)] = []
    private var currentStyle: IndoorOverlayStyle?
    private var polygons: [MKPolygon] = []
    private var polylines: [MKPolyline] = []

    mutating func append(_ geometry: IndoorMapGeometry, style: IndoorOverlayStyle) {
        let overlays = MapKitGeometry.overlays(for: geometry)
        guard !overlays.isEmpty else { return }
        if style != currentStyle {
            flush()
            currentStyle = style
        }
        for overlay in overlays {
            if let polygon = overlay as? MKPolygon {
                polygons.append(polygon)
            } else if let polyline = overlay as? MKPolyline {
                polylines.append(polyline)
            }
        }
    }

    mutating func finish() -> [(overlay: any MKOverlay, style: IndoorOverlayStyle)] {
        flush()
        return batches
    }

    private mutating func flush() {
        guard let currentStyle else { return }
        if !polygons.isEmpty {
            batches.append((polygons.count == 1 ? polygons[0] : MKMultiPolygon(polygons), currentStyle))
        }
        if !polylines.isEmpty {
            batches.append((polylines.count == 1 ? polylines[0] : MKMultiPolyline(polylines), currentStyle))
        }
        polygons.removeAll(keepingCapacity: true)
        polylines.removeAll(keepingCapacity: true)
    }
}
