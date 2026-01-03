import Foundation

/// Local storage service using ONLY UserDefaults (no iCloud)
/// Perfect for single-device offline gaming or when iCloud capability is not available
///
/// USAGE: Ersetze LocalStorageService.swift mit dieser Datei wenn du kein iCloud willst
actor LocalStorageService {
    private let userDefaults = UserDefaults.standard
    private let gameStateKey = "zenOrigamiGameState"

    // MARK: - Game State Operations

    /// Load game state from UserDefaults
    /// - Returns: Game state if found, nil otherwise
    func loadGameState() async -> GameState? {
        if let data = userDefaults.data(forKey: gameStateKey),
           let state = try? JSONDecoder().decode(GameState.self, from: data) {
            print("[LocalStorage] ✅ Loaded from UserDefaults")
            return state
        }

        print("[LocalStorage] ⚠️ No saved game state found")
        return nil
    }

    /// Save game state to UserDefaults
    /// - Parameter gameState: Current game state
    func saveGameState(_ gameState: GameState) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(gameState)
        userDefaults.set(data, forKey: gameStateKey)

        print("[LocalStorage] ✅ Saved game state to UserDefaults")
    }

    /// Delete all game data
    func deleteGameState() async {
        userDefaults.removeObject(forKey: gameStateKey)
        print("[LocalStorage] ✅ Deleted all game data")
    }

    // MARK: - Helper Methods

    /// Check if game state exists
    func hasGameState() -> Bool {
        return userDefaults.data(forKey: gameStateKey) != nil
    }

    /// Get last save timestamp
    func getLastSaveDate() -> Date? {
        guard let data = userDefaults.data(forKey: gameStateKey),
              let state = try? JSONDecoder().decode(GameState.self, from: data) else {
            return nil
        }
        return state.updatedAt
    }
}
