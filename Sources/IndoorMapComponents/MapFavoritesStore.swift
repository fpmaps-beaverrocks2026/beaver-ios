import Foundation
import Observation

/// 어떤 항목을 찜했는지 기기에 저장합니다. 앱을 다시 열면 이전에 저장한 찜 목록을 불러옵니다.
@MainActor
@Observable
public final class MapFavoritesStore {
    public private(set) var favoriteIDs: Set<String>

    private let defaults: UserDefaults
    private let storageKey: String

    /// 같은 찜 목록을 여러 화면에서 보여 주려면 한 번만 만들고 함께 사용합니다.
    public init(storageKey: String, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.storageKey = storageKey
        favoriteIDs = Set(defaults.stringArray(forKey: storageKey) ?? [])
    }

    /// 지정한 항목을 찜 목록에 넣거나 목록에서 뺍니다.
    public func setFavorite(_ isFavorite: Bool, for id: String) {
        if isFavorite {
            guard favoriteIDs.insert(id).inserted else { return }
        } else {
            guard favoriteIDs.remove(id) != nil else { return }
        }
        defaults.set(favoriteIDs.sorted(), forKey: storageKey)
    }

    /// 이미 찜했다면 빼고, 찜하지 않았다면 넣습니다. 바뀐 뒤의 찜 여부를 돌려줍니다.
    @discardableResult
    public func toggle(_ id: String) -> Bool {
        let isFavorite = !favoriteIDs.contains(id)
        setFavorite(isFavorite, for: id)
        return isFavorite
    }
}
