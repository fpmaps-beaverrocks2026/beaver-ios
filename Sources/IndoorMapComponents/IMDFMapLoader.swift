import Foundation

public struct IMDFMapLoader: Sendable {
    private static let requiredFiles = ["venue", "level", "footprint", "unit", "fixture", "opening"]
    private static let optionalFiles = ["amenity", "section"]

    public init() {}

    /// Reads an unpacked IMDF 1.0.0 directory on a concurrent executor.
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
