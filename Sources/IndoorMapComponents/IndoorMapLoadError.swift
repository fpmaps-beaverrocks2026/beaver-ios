import Foundation

/// 필요한 지도 파일이 없거나 내용을 읽을 수 없을 때 어떤 파일에서 문제가 생겼는지 알려 줍니다.
///
/// 지도를 읽는 중 문제가 생기면 아래처럼 설명을 받아 화면에 보여 줄 수 있습니다.
///
/// ```swift
/// do {
///     map = try await IMDFMapLoader().load(directory: mapFolder)
/// } catch let error as IndoorMapLoadError {
///     message = error.localizedDescription
/// } catch {
///     message = "지도를 불러오지 못했어요."
/// }
/// ```
public enum IndoorMapLoadError: LocalizedError {
    case missingResource(String)
    case invalidData(file: String, reason: String)

    public var errorDescription: String? {
        switch self {
        case .missingResource(let path):
            "지도 리소스를 찾을 수 없습니다: \(path)"
        case .invalidData(let file, let reason):
            "지도 데이터를 읽을 수 없습니다 (\(file)): \(reason)"
        }
    }
}
