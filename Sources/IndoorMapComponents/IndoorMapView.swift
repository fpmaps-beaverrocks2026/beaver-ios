import MapKit
import SwiftUI

@MainActor
public struct IndoorMapView: View {
    private let map: IndoorMap
    private let floorID: UUID?
    private let markers: [IndoorMapMarker]
    private let showsAmenities: Bool
    private let hiddenFavoriteMarkerIDs: Set<String>
    private let viewportInsets: UIEdgeInsets
    private let onSelectFavorite: (IndoorMapMarker) -> Void

    public init(
        map: IndoorMap,
        floorID: UUID? = nil,
        markers: [IndoorMapMarker],
        showsAmenities: Bool = false,
        hiddenFavoriteMarkerIDs: Set<String> = [],
        viewportInsets: UIEdgeInsets = .zero,
        onSelectFavorite: @escaping (IndoorMapMarker) -> Void = { _ in }
    ) {
        self.map = map
        self.floorID = floorID
        self.markers = markers
        self.showsAmenities = showsAmenities
        self.hiddenFavoriteMarkerIDs = hiddenFavoriteMarkerIDs
        self.viewportInsets = viewportInsets
        self.onSelectFavorite = onSelectFavorite
    }

    public var body: some View {
        let floor = map.floors.first { $0.id == floorID } ?? map.floors.first
        let visibleMarkers = markers.filter { marker in
            marker.floorID == floor?.id && marker.coordinate.isValid
                && (showsAmenities || marker.kind.isAlwaysVisible)
                && (marker.kind != .favorite || !hiddenFavoriteMarkerIDs.contains(marker.id))
        }
        MapSurface(map: map, floor: floor, markers: visibleMarkers,
                   viewportInsets: viewportInsets, onSelectFavorite: onSelectFavorite)
    }
}

private struct MapSurface: UIViewRepresentable {
    let map: IndoorMap
    let floor: IndoorMapFloor?
    let markers: [IndoorMapMarker]
    let viewportInsets: UIEdgeInsets
    let onSelectFavorite: (IndoorMapMarker) -> Void

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> LayoutMapView {
        let view = LayoutMapView()
        view.delegate = context.coordinator
        view.onLayout = { [weak coordinator = context.coordinator] view in coordinator?.fitCamera(in: view) }
        view.overrideUserInterfaceStyle = .dark
        let configuration = MKStandardMapConfiguration(elevationStyle: .flat)
        configuration.pointOfInterestFilter = .excludingAll
        view.preferredConfiguration = configuration
        view.showsCompass = false
        view.showsScale = false
        view.accessibilityIdentifier = "indoor-map"
        return view
    }

    func updateUIView(_ view: LayoutMapView, context: Context) {
        context.coordinator.update(self, in: view)
    }

    static func dismantleUIView(_ view: LayoutMapView, coordinator: Coordinator) {
        view.delegate = nil
        view.onLayout = nil
    }

    @MainActor
    final class Coordinator: NSObject, MKMapViewDelegate {
        private let annotations = IndoorMapAnnotationController()
        private var renderedMap: IndoorMap?
        private var renderedFloorID: UUID?
        private var viewportInsets = UIEdgeInsets.zero
        private var pendingCameraRect: MKMapRect?
        private var styles: [ObjectIdentifier: IndoorOverlayStyle] = [:]
        private var onSelectFavorite: ((IndoorMapMarker) -> Void)?

        func update(_ surface: MapSurface, in view: LayoutMapView) {
            onSelectFavorite = surface.onSelectFavorite
            viewportInsets = surface.viewportInsets
            if renderedMap != surface.map || renderedFloorID != surface.floor?.id {
                render(surface, in: view)
                renderedMap = surface.map
                renderedFloorID = surface.floor?.id
                pendingCameraRect = surface.floor.map { MapKitGeometry.mapRect(for: $0.geometry) }
                    ?? MapKitGeometry.mapRect(for: surface.map.venue.geometry)
                view.setNeedsLayout()
            }
            annotations.update(surface.markers, in: view)
        }

        private func render(_ surface: MapSurface, in view: MKMapView) {
            view.removeOverlays(view.overlays)
            styles.removeAll()
            guard let floor = surface.floor else { return }

            func style(for feature: IndoorMapElement?) -> IndoorOverlayStyle {
                var style = IndoorOverlayStyle(fillColor: UIColor(white: 0.23, alpha: 1), lineWidth: 0.8)
                if feature?.kind == .fixture { style.fillColor = UIColor(white: 0.09, alpha: 1) }
                IndoorMapPalette.apply(to: &style, feature: feature)
                return style
            }

            var batcher = IndoorOverlayBatcher()
            batcher.append(floor.geometry, style: style(for: nil))
            let features = surface.map.features.filter { $0.floorID == floor.id }
            let kinds: [IndoorMapElement.Kind] = [.unit, .section, .fixture, .opening]
            for kind in kinds {
                for feature in features where feature.kind == kind {
                    batcher.append(feature.geometry, style: style(for: feature))
                }
            }
            let batches = batcher.finish()
            for batch in batches {
                styles[ObjectIdentifier(batch.overlay)] = batch.style
            }
            view.addOverlays(batches.map(\.overlay), level: .aboveRoads)
        }

        func fitCamera(in view: MKMapView) {
            guard let rect = pendingCameraRect, !rect.isNull, !view.bounds.isEmpty else { return }
            let padding = UIEdgeInsets(
                top: 24 + max(0, viewportInsets.top), left: 24 + max(0, viewportInsets.left),
                bottom: 24 + max(0, viewportInsets.bottom), right: 24 + max(0, viewportInsets.right)
            )
            let fits = padding.left + padding.right < view.bounds.width
                && padding.top + padding.bottom < view.bounds.height
            pendingCameraRect = nil
            let center = MKMapPoint(x: rect.midX, y: rect.midY).coordinate
            let minimumSpan = 12 * MKMapPointsPerMeterAtLatitude(center.latitude)
            let focus = rect.insetBy(dx: -max(0, minimumSpan - rect.width) / 2,
                                     dy: -max(0, minimumSpan - rect.height) / 2)
            view.setVisibleMapRect(focus, edgePadding: fits ? padding : .zero, animated: false)
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
            let renderer: MKOverlayPathRenderer
            switch overlay {
            case let polygon as MKPolygon: renderer = MKPolygonRenderer(polygon: polygon)
            case let polygons as MKMultiPolygon: renderer = MKMultiPolygonRenderer(multiPolygon: polygons)
            case let line as MKPolyline: renderer = MKPolylineRenderer(polyline: line)
            case let lines as MKMultiPolyline: renderer = MKMultiPolylineRenderer(multiPolyline: lines)
            default: return MKOverlayRenderer(overlay: overlay)
            }
            styles[ObjectIdentifier(overlay)]?.apply(to: renderer)
            return renderer
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? IndoorMapPointAnnotation else { return nil }
            let reuseID = IndoorMapAnnotationView.reuseID
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? IndoorMapAnnotationView
                ?? IndoorMapAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            let activate: (() -> Void)? = annotation.marker.kind == .favorite
                ? { [weak self] in self?.onSelectFavorite?(annotation.marker) }
                : nil
            view.configure(annotation, onActivate: activate)
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? IndoorMapPointAnnotation,
                  annotation.marker.kind == .favorite else { return }
            mapView.deselectAnnotation(annotation, animated: false)
            onSelectFavorite?(annotation.marker)
        }
    }
}

private final class LayoutMapView: MKMapView {
    var onLayout: ((MKMapView) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?(self)
    }
}
