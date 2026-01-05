@preconcurrency import Foundation
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

            // Extract data before Task.detached (response is non-Sendable)
            let responseData = response.data

            let dto = try await Task.detached { @Sendable in
                let decoder = JSONDecoder()
                return try decoder.decode(GameStateDTO.self, from: responseData)
            }.value
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
        let dto = gameState.toDTO(userId: userId)

        do {
            // Upsert (GameStateDTO now has nonisolated Codable - Swift 6 compliant)
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

        // Extract data before Task.detached (response is non-Sendable)
        let responseData = response.data

        return try await Task.detached { @Sendable in
            let decoder = JSONDecoder()
            return try decoder.decode(UserProfile.self, from: responseData)
        }.value
    }

    /// Update user profile
    /// - Parameters:
    ///   - userId: User ID
    ///   - username: New username
    ///   - avatarUrl: New avatar URL
    func updateProfile(userId: UUID, username: String?, avatarUrl: String?) async throws {
        struct ProfileUpdate: Codable {
            let id: String
            let username: String?
            let avatarUrl: String?

            enum CodingKeys: String, CodingKey {
                case id
                case username
                case avatarUrl = "avatar_url"
            }
        }

        let update = ProfileUpdate(
            id: userId.uuidString,
            username: username,
            avatarUrl: avatarUrl
        )

        try await supabase
            .from("profiles")
            .update(update)
            .eq("id", value: userId.uuidString)
            .execute()

        print("[DB] ✅ Updated user profile")
    }
}

// MARK: - Supporting Types

struct UserProfile: @unchecked Sendable {
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

    // MARK: - Nonisolated Codable Conformance (Swift 6 Fix)

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(avatarUrl, forKey: .avatarUrl)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

// MARK: - Codable Conformance
extension UserProfile: Codable {}
