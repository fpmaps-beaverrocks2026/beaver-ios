import Foundation

/// 한 폴더에 모인 실내 지도 파일을 읽어 앱에서 쓸 수 있는 지도를 만듭니다.
public struct IMDFMapLoader: Sendable {
    private static let requiredFiles = ["venue", "level", "footprint", "unit", "fixture", "opening"]
    private static let optionalFiles = ["amenity", "section"]

    public init() {}

    /// 압축을 푼 실내 지도 폴더를 넘깁니다. 지도 파일은 1.0.0 버전이어야 합니다.
    /// 꼭 필요한 파일이 없거나 파일을 읽을 수 없으면 어떤 파일에서 문제가 생겼는지 알려 줍니다.
    ///
    /// 화면이 열릴 때 지도 폴더의 주소를 넘겨 읽습니다. 아래의 `mapFolder`는 지도 파일들이 들어 있는 폴더입니다.
    /// 읽은 `map`을 `IndoorMapView`에 전달합니다.
    ///
    /// ```swift
    /// let map = try await IMDFMapLoader().load(directory: mapFolder)
    /// ```
    @concurrent
    public func load(directory: URL) async throws -> IndoorMap {
        try Task.checkCancellation()
        let manifest: IMDFManifestDTO = try decode("manifest.json", in: directory)
        guard manifest.version == "1.0.0" else {
            throw IndoorMapLoadError.invalidData(
                file: "manifest.json", reason: "지원하지 않는 IMDF 버전입니다: \(manifest.version)"
            )
        }

        var collections: [String: IMDFFeatureCollectionDTO] = [:]
        for kind in Self.requiredFiles {
            try Task.checkCancellation()
            collections[kind] = try decode("\(kind).geojson", in: directory)
        }
        for kind in Self.optionalFiles {
            try Task.checkCancellation()
            do {
                collections[kind] = try decode("\(kind).geojson", in: directory)
            } catch IndoorMapLoadError.missingResource {
                continue
            }
        }
        return try IMDFMapper().map(collections: collections)
    }

    private func decode<T: Decodable>(_ file: String, in directory: URL) throws -> T {
        let url = directory.appendingPathComponent(file)
        do {
            return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
            throw IndoorMapLoadError.missingResource(file)
        } catch {
            throw IndoorMapLoadError.invalidData(file: file, reason: error.localizedDescription)
        }
    }
}
