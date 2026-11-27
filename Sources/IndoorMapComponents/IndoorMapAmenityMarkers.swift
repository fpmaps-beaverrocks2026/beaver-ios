import Foundation

nonisolated enum IndoorMapAmenityMarkers {
    static func amenities(on map: IndoorMap) -> [IndoorMapMarker] {
        let markers: [(marker: IndoorMapMarker, mergeCategory: String?)] = map.features.compactMap { feature in
            guard let floor = feature.floorID, let kind = amenityKind(feature),
                  let coordinate = anchor(for: feature.geometry) else { return nil }
            let fallback: String = switch kind {
            case .stairs: "계단"
            case .elevator: "엘리베이터"
            case .toilet: "화장실"
            case .shop: "편의점"
            case .printer: "프린터·복사기"
            case .media: "영상 자료실"
            case .cafe: "카페"
            case .plora: "Plora"
            case .conferenceRoom: "미팅룸"
            case .gamingRoom: "게임룸"
            case .groupStudyRoom: feature.category?.lowercased() == "classroom" ? "강의실" : "그룹 스터디룸"
            case .relaxZone: feature.category?.lowercased() == "lounge" ? "휴게실" : "릴렉스존"
            case .waterDispenser: "정수기"
            case .entranceDesk: "출입구 데스크"
            case .circulationDesk: "대출 데스크"
            case .computer: "PC 존"
            case .nursingRoom: "수유실"
            default: "기타 시설"
            }
            let marker = IndoorMapMarker(id: "amenity-\(feature.kind.rawValue)-\(feature.sourceID)", kind: kind,
                floorID: floor, coordinate: coordinate, title: feature.name ?? fallback)
            return (marker, mergeCategory(for: feature))
        }.sorted { $0.marker.id < $1.marker.id }
        return merging(markers)
    }

    /// 나란히 놓인 엘리베이터처럼 같은 IMDF 분류의 점 시설만 합친다.
    /// 방(unit) 마커와 분류가 다른 시설(남자·여자·장애인 화장실 등)은 각자 자리에 남긴다.
    private static func mergeCategory(for feature: IndoorMapElement) -> String? {
        guard feature.kind == .amenity, case .point = feature.geometry,
              let category = feature.category?.lowercased(), !category.isEmpty else { return nil }
        return category
    }

    private static let overlapMeters = 6.0

    private static func isPlainer(_ lhs: String, _ rhs: String) -> Bool {
        let leftHasNote = lhs.contains("(")
        let rightHasNote = rhs.contains("(")
        if leftHasNote != rightHasNote { return rightHasNote }
        if lhs.count != rhs.count { return lhs.count < rhs.count }
        return lhs < rhs
    }

    private static func merging(_ markers: [(marker: IndoorMapMarker, mergeCategory: String?)]) -> [IndoorMapMarker] {
        var clusters: [(category: String?, markers: [IndoorMapMarker])] = []
        for (marker, category) in markers {
            let index = category == nil ? nil : clusters.firstIndex { cluster in
                guard cluster.category == category, let first = cluster.markers.first,
                      first.floorID == marker.floorID else { return false }
                return cluster.markers.contains {
                    $0.coordinate.distanceMeters(to: marker.coordinate) <= overlapMeters
                }
            }
            if let index {
                clusters[index].markers.append(marker)
            } else {
                clusters.append((category, [marker]))
            }
        }
        return clusters.map(\.markers).map { cluster in
            guard cluster.count > 1, var representative = cluster.first else { return cluster[0] }
            representative.title = cluster.map(\.title).min(by: isPlainer) ?? representative.title
            representative.coordinate = IndoorMapCoordinate(
                latitude: cluster.map(\.coordinate.latitude).reduce(0, +) / Double(cluster.count),
                longitude: cluster.map(\.coordinate.longitude).reduce(0, +) / Double(cluster.count))
            return representative
        }.sorted { $0.id < $1.id }
    }

    private static func ownedKind(forCategory category: String) -> IndoorMapMarker.Kind? {
        if category == "stairs" || category == "stairway" { return .stairs }
        if category == "elevator" { return .elevator }
        if category.hasPrefix("restroom") || category == "toilets" { return .toilet }
        if category == "drinkingfountain" { return .waterDispenser }
        if category == "mothersroom" { return .nursingRoom }
        if category == "information" { return .entranceDesk }
        if category == "reception.desk" { return .circulationDesk }
        return nil
    }

    private static func amenityKind(_ feature: IndoorMapElement) -> IndoorMapMarker.Kind? {
        guard feature.kind == .unit || feature.kind == .amenity || feature.kind == .fixture else { return nil }
        let category = feature.category?.lowercased() ?? ""
        let name = feature.name?.lowercased() ?? ""
        let compactName = name.filter { !$0.isWhitespace }
        if let owned = Self.ownedKind(forCategory: category) {
            return feature.kind == .amenity ? owned : nil
        }
        if compactName.contains("plora") || compactName.contains("플로라") { return .plora }
        if compactName.contains("pc존") || compactName.contains("pczone") { return .computer }
        if name.contains("편의점") || name.contains("convenience") || name.contains("gs25") { return .shop }
        if name.contains("프린터") || name.contains("복사기") || name.contains("printer") || name.contains("copier") {
            return .printer
        }
        if compactName.contains("dvd") || compactName.contains("미디어") || compactName.contains("mediaroom") {
            return .media
        }
        if compactName.contains("fun&play") || compactName.contains("funandplay")
            || compactName.contains("게임룸") || compactName.contains("gamingroom")
            || compactName.contains("gameroom") { return .gamingRoom }
        if compactName.contains("그룹스터디룸") || compactName.contains("groupstudyroom")
            || compactName.hasPrefix("gsr") || compactName.contains("토의실")
            || compactName.contains("회의실") || compactName.contains("미팅룸")
            || compactName.contains("meetingroom") || compactName.contains("conferenceroom")
            || compactName.contains("콜라보") || compactName.contains("collaboration")
            || compactName.contains("postech1986") || compactName.contains("isss")
            || compactName.contains("국제협력팀") || compactName.contains("internationalrelations") {
            return .groupStudyRoom
        }
        if category == "classroom" || compactName.contains("강의실")
            || compactName.contains("컨퍼런스홀") || compactName.contains("conferencehall")
            || compactName.contains("스튜디오") || compactName.contains("studio") { return .conferenceRoom }
        if compactName.contains("니어미") || compactName.contains("nearme")
            || compactName.contains("카페") || compactName.contains("cafe") { return .cafe }
        if category == "lounge" || compactName.contains("휴게실") || compactName.contains("열람석")
            || compactName.contains("relaxzone") || compactName.contains("릴렉스존") { return .relaxZone }
        if compactName.contains("welcomecenter") || compactName.contains("웰컴센터")
            || compactName.contains("입학팀") || compactName.contains("admissions") { return .entranceDesk }
        if category == "coinlocker" { return nil }
        if feature.kind == .amenity || ["foodservice", "recreation"].contains(category)
            || (category == "room" && !name.isEmpty) { return .other }
        return nil
    }

    private static func anchor(for geometry: IndoorMapGeometry) -> IndoorMapCoordinate? {
        if case .point(let coordinate) = geometry { return coordinate.isValid ? coordinate : nil }
        let points = geometry.coordinates.filter(\.isValid)
        guard let first = points.first else { return nil }
        var south = first.latitude, north = first.latitude
        var west = first.longitude, east = first.longitude
        for point in points.dropFirst() {
            south = min(south, point.latitude)
            north = max(north, point.latitude)
            west = min(west, point.longitude)
            east = max(east, point.longitude)
        }
        for y in [0.5, 0.25, 0.75, 0.125, 0.875] {
            for x in [0.5, 0.25, 0.75, 0.125, 0.875] {
                let point = IndoorMapCoordinate(latitude: south + (north - south) * y,
                                                longitude: west + (east - west) * x)
                if geometry.contains(point) { return point }
            }
        }
        return geometry.contains(first) ? first : nil
    }
}
