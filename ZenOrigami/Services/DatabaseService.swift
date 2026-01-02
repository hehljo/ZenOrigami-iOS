import Foundation
import Supabase

/// Database service for Supabase persistence
/// Handles game state loading, saving, and synchronization
actor DatabaseService {
    private let supabase: SupabaseClient

    init(supabaseURL: String, supabaseKey: String) {
        guard let url = URL(string: supabaseURL) else {
            fatalError("Invalid Supabase URL: \(supabaseURL)")
        }
        self.supabase = SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseKey
        )
    }

    // MARK: - Game State Operations

    /// Load game state from database
    /// - Parameter userId: User ID
    /// - Returns: Game state if found, nil otherwise
    func loadGameState(userId: UUID) async throws -> GameState? {
        do {
            let response = try await supabase
                .from("game_state")
                .select()
                .eq("user_id", value: userId.uuidString)
                .single()
                .execute()

            let dto = try JSONDecoder().decode(GameStateDTO.self, from: response.data)
            let gameState = GameState.fromDTO(dto)

            print("[DB] ✅ Loaded game state from database")
            return gameState
        } catch {
            print("[DB] ⚠️ Failed to load game state: \(error.localizedDescription)")
            return nil
        }
    }

    /// Save game state to database
    /// - Parameters:
    ///   - userId: User ID
    ///   - gameState: Current game state
    func saveGameState(userId: UUID, gameState: GameState) async throws {
        var dto = gameState.toDTO(userId: userId)

        do {
            // Upsert (insert or update)
            try await supabase
                .from("game_state")
                .upsert(dto)
                .execute()

            print("[DB] ✅ Saved game state to database")
        } catch {
            print("[DB] ❌ Failed to save game state: \(error.localizedDescription)")
            throw error
        }
    }

    /// Delete user's game state
    /// - Parameter userId: User ID
    func deleteGameState(userId: UUID) async throws {
        try await supabase
            .from("game_state")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()

        print("[DB] ✅ Deleted game state from database")
    }

    // MARK: - Profile Operations

    /// Get user profile
    /// - Parameter userId: User ID
    /// - Returns: User profile
    func getProfile(userId: UUID) async throws -> UserProfile? {
        let response = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()

        return try JSONDecoder().decode(UserProfile.self, from: response.data)
    }

    /// Update user profile
    /// - Parameters:
    ///   - userId: User ID
    ///   - username: New username
    ///   - avatarUrl: New avatar URL
    func updateProfile(userId: UUID, username: String?, avatarUrl: String?) async throws {
        var updates: [String: Any] = ["id": userId.uuidString]
        if let username = username {
            updates["username"] = username
        }
        if let avatarUrl = avatarUrl {
            updates["avatar_url"] = avatarUrl
        }

        try await supabase
            .from("profiles")
            .update(updates)
            .eq("id", value: userId.uuidString)
            .execute()

        print("[DB] ✅ Updated user profile")
    }
}

// MARK: - Supporting Types

struct UserProfile: Codable {
    let id: UUID
    let username: String?
    let avatarUrl: String?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
