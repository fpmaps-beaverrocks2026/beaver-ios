import Foundation
import Observation

@MainActor
@Observable
public final class MapFavoritesStore {
    public private(set) var favoriteIDs: Set<String>

    private let defaults: UserDefaults
    private let storageKey: String

    /// Share one store across views that use the same storage key.
    public init(storageKey: String, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.storageKey = storageKey
        favoriteIDs = Set(defaults.stringArray(forKey: storageKey) ?? [])
    }

    public func setFavorite(_ isFavorite: Bool, for id: String) {
        if isFavorite {
            guard favoriteIDs.insert(id).inserted else { return }
        } else {
            guard favoriteIDs.remove(id) != nil else { return }
        }
        defaults.set(favoriteIDs.sorted(), forKey: storageKey)
    }

    @discardableResult
    public func toggle(_ id: String) -> Bool {
        let isFavorite = !favoriteIDs.contains(id)
        setFavorite(isFavorite, for: id)
        return isFavorite
    }
}
