import Foundation

/// Local storage service using UserDefaults + iCloud (NSUbiquitousKeyValueStore)
/// No Supabase required - perfect for offline-first apps
actor LocalStorageService {
    private let userDefaults = UserDefaults.standard
    private let iCloudStore = NSUbiquitousKeyValueStore.default
    private let gameStateKey = "zenOrigamiGameState"

    // MARK: - Game State Operations

    /// Load game state from local storage (UserDefaults or iCloud)
    /// - Returns: Game state if found, nil otherwise
    func loadGameState() async -> GameState? {
        // Try iCloud first (for cross-device sync)
        if let iCloudData = iCloudStore.data(forKey: gameStateKey),
           let state = try? JSONDecoder().decode(GameState.self, from: iCloudData) {
            print("[LocalStorage] ✅ Loaded from iCloud")
            return state
        }

        // Fallback to UserDefaults
        if let data = userDefaults.data(forKey: gameStateKey),
           let state = try? JSONDecoder().decode(GameState.self, from: data) {
            print("[LocalStorage] ✅ Loaded from UserDefaults")
            return state
        }

        print("[LocalStorage] ⚠️ No saved game state found")
        return nil
    }

    /// Save game state to local storage (both UserDefaults and iCloud)
    /// - Parameter gameState: Current game state
    func saveGameState(_ gameState: GameState) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(gameState)

        // Save to UserDefaults (instant, local)
        userDefaults.set(data, forKey: gameStateKey)

        // Save to iCloud (syncs across devices)
        iCloudStore.set(data, forKey: gameStateKey)
        iCloudStore.synchronize()

        print("[LocalStorage] ✅ Saved game state (UserDefaults + iCloud)")
    }

    /// Delete all game data
    func deleteGameState() async {
        userDefaults.removeObject(forKey: gameStateKey)
        iCloudStore.removeObject(forKey: gameStateKey)
        iCloudStore.synchronize()

        print("[LocalStorage] ✅ Deleted all game data")
    }

    // MARK: - iCloud Sync Status

    /// Check if iCloud is available
    var isICloudAvailable: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    /// Listen for iCloud changes (call this in your app)
    func observeICloudChanges(onChange: @escaping () -> Void) {
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: iCloudStore,
            queue: .main
        ) { _ in
            onChange()
        }
    }
}
