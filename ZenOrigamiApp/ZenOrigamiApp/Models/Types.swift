import Foundation

// MARK: - Currency Types
enum Currency: String, Codable, CaseIterable {
    case drop
    case pearl
    case leaf
}

struct Currencies: Codable, Equatable, Sendable {
    var drop: Int
    var pearl: Int
    var leaf: Int

    static var zero: Currencies {
        Currencies(drop: 0, pearl: 0, leaf: 0)
    }

    nonisolated init(drop: Int = 0, pearl: Int = 0, leaf: Int = 0) {
        self.drop = drop
        self.pearl = pearl
        self.leaf = leaf
    }

    subscript(currency: Currency) -> Int {
        get {
            switch currency {
            case .drop: return drop
            case .pearl: return pearl
            case .leaf: return leaf
            }
        }
        set {
            switch currency {
            case .drop: drop = newValue
            case .pearl: pearl = newValue
            case .leaf: leaf = newValue
            }
        }
    }
}

// MARK: - Upgrade Types
enum UpgradeID: String, Codable, CaseIterable {
    case speed
    case radius
    case rate
    case collector
}

struct UpgradesState: Codable, Equatable, Sendable {
    var speed: Int
    var radius: Int
    var rate: Int
    var collector: Int

    static var initial: UpgradesState {
        UpgradesState(speed: 0, radius: 0, rate: 0, collector: 0)
    }

    subscript(id: UpgradeID) -> Int {
        get {
            switch id {
            case .speed: return speed
            case .radius: return radius
            case .rate: return rate
            case .collector: return collector
            }
        }
        set {
            switch id {
            case .speed: speed = newValue
            case .radius: radius = newValue
            case .rate: rate = newValue
            case .collector: collector = newValue
            }
        }
    }
}

// MARK: - Add-ons & Skins
struct AddOnsState: Codable, Equatable, Sendable {
    var flag: Bool

    static var initial: AddOnsState {
        AddOnsState(flag: false)
    }
}

enum Skin: String, Codable, CaseIterable, Sendable {
    case `default`
    case swanSkin = "swan_skin"
}

struct SkinsState: Codable, Equatable, Sendable {
    var swanSkin: Bool

    static var initial: SkinsState {
        SkinsState(swanSkin: false)
    }

    func isUnlocked(_ skin: Skin) -> Bool {
        switch skin {
        case .default: return true
        case .swanSkin: return swanSkin
        }
    }
}

// MARK: - Companions
enum CompanionType: String, Codable {
    case water
    case air
}

enum CompanionID: String, Codable, CaseIterable {
    case origamiFish = "origami_fish"
    case origamiBird = "origami_bird"
}

struct CompanionsState: Codable, Equatable, Sendable {
    var origamiFish: Bool
    var origamiBird: Bool

    static var initial: CompanionsState {
        CompanionsState(origamiFish: false, origamiBird: false)
    }

    subscript(id: CompanionID) -> Bool {
        get {
            switch id {
            case .origamiFish: return origamiFish
            case .origamiBird: return origamiBird
            }
        }
        set {
            switch id {
            case .origamiFish: origamiFish = newValue
            case .origamiBird: origamiBird = newValue
            }
        }
    }
}

// MARK: - Achievement Types
enum AchievementCategory: String, Codable {
    case collector
    case progression
    case mastery
    case secret
    case prestige
    case seasonal
    case social
}

enum AchievementRarity: String, Codable {
    case common
    case rare
    case epic
    case legendary
    case mythic
}

enum AchievementTier: String, Codable {
    case bronze
    case silver
    case gold
    case platinum
    case diamond
}

struct Achievement: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let target: Int
    let reward: Currencies
    let category: AchievementCategory
    let rarity: AchievementRarity
    let tier: AchievementTier
    let secret: Bool
    let prerequisite: String?
    let points: Int
}

struct AchievementState: Codable, Equatable, Sendable {
    var unlocked: Bool
    var unlockedAt: Date?
    var progress: Int

    static var initial: AchievementState {
        AchievementState(unlocked: false, unlockedAt: nil, progress: 0)
    }
}

// MARK: - Prestige System
struct PrestigeState: Codable, Equatable, Sendable {
    var level: Int
    var zenPoints: Int
    var totalPrestiges: Int

    static var initial: PrestigeState {
        PrestigeState(level: 0, zenPoints: 0, totalPrestiges: 0)
    }
}

// MARK: - Game State
struct GameState: Codable, Equatable, @unchecked Sendable {
    // Currencies
    var currencies: Currencies

    // Upgrades
    var upgrades: UpgradesState
    var addOns: AddOnsState
    var skins: SkinsState
    var companions: CompanionsState
    var activeSkin: Skin

    // Achievements
    var achievements: [String: AchievementState]

    // Statistics
    var totalCollected: Currencies
    var playTime: Int // seconds
    var totalUpgradesPurchased: Int
    var loginStreak: Int // consecutive login days

    // Prestige
    var prestige: PrestigeState

    // Metadata
    var lastVisit: Date
    var createdAt: Date
    var updatedAt: Date

    // Computed properties for convenience
    var prestigeLevel: Int {
        prestige.level
    }

    static var initial: GameState {
        GameState(
            currencies: .zero,
            upgrades: .initial,
            addOns: .initial,
            skins: .initial,
            companions: .initial,
            activeSkin: .default,
            achievements: [:],
            totalCollected: .zero,
            playTime: 0,
            totalUpgradesPurchased: 0,
            loginStreak: 0,
            prestige: .initial,
            lastVisit: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - Database Types (Supabase)
struct GameStateDTO: @unchecked Sendable {
    let id: UUID?
    let userId: UUID

    // Currencies
    let drops: Int
    let pearls: Int
    let leaves: Int

    // Upgrades
    let boatSpeedLevel: Int
    let collectionRadiusLevel: Int
    let dropRateLevel: Int
    let rainCollectorLevel: Int

    // Add-ons & Skins
    let origamiFlag: Bool
    let currentSkin: String
    let unlockedSkins: [String]

    // Companions
    let hasFishCompanion: Bool
    let hasBirdCompanion: Bool

    // Achievements
    let unlockedAchievements: [String]

    // Statistics
    let totalDropsCollected: Int
    let totalPearlsCollected: Int
    let totalLeavesCollected: Int
    let totalPlayTime: Int
    let totalUpgradesPurchased: Int
    let loginStreak: Int

    // Prestige
    let prestigeLevel: Int
    let zenPoints: Int
    let totalPrestiges: Int

    // Metadata
    let lastVisit: Date
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, userId = "user_id"
        case drops, pearls, leaves
        case boatSpeedLevel = "boat_speed_level"
        case collectionRadiusLevel = "collection_radius_level"
        case dropRateLevel = "drop_rate_level"
        case rainCollectorLevel = "rain_collector_level"
        case origamiFlag = "origami_flag"
        case currentSkin = "current_skin"
        case unlockedSkins = "unlocked_skins"
        case hasFishCompanion = "has_fish_companion"
        case hasBirdCompanion = "has_bird_companion"
        case unlockedAchievements = "unlocked_achievements"
        case totalDropsCollected = "total_drops_collected"
        case totalPearlsCollected = "total_pearls_collected"
        case totalLeavesCollected = "total_leaves_collected"
        case totalPlayTime = "total_play_time"
        case totalUpgradesPurchased = "total_upgrades_purchased"
        case loginStreak = "login_streak"
        case prestigeLevel = "prestige_level"
        case zenPoints = "zen_points"
        case totalPrestiges = "total_prestiges"
        case lastVisit = "last_visit"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // MARK: - Memberwise Initializer (required when implementing custom init)

    init(
        id: UUID?,
        userId: UUID,
        drops: Int,
        pearls: Int,
        leaves: Int,
        boatSpeedLevel: Int,
        collectionRadiusLevel: Int,
        dropRateLevel: Int,
        rainCollectorLevel: Int,
        origamiFlag: Bool,
        currentSkin: String,
        unlockedSkins: [String],
        hasFishCompanion: Bool,
        hasBirdCompanion: Bool,
        unlockedAchievements: [String],
        totalDropsCollected: Int,
        totalPearlsCollected: Int,
        totalLeavesCollected: Int,
        totalPlayTime: Int,
        totalUpgradesPurchased: Int,
        loginStreak: Int,
        prestigeLevel: Int,
        zenPoints: Int,
        totalPrestiges: Int,
        lastVisit: Date,
        createdAt: Date?,
        updatedAt: Date?
    ) {
        self.id = id
        self.userId = userId
        self.drops = drops
        self.pearls = pearls
        self.leaves = leaves
        self.boatSpeedLevel = boatSpeedLevel
        self.collectionRadiusLevel = collectionRadiusLevel
        self.dropRateLevel = dropRateLevel
        self.rainCollectorLevel = rainCollectorLevel
        self.origamiFlag = origamiFlag
        self.currentSkin = currentSkin
        self.unlockedSkins = unlockedSkins
        self.hasFishCompanion = hasFishCompanion
        self.hasBirdCompanion = hasBirdCompanion
        self.unlockedAchievements = unlockedAchievements
        self.totalDropsCollected = totalDropsCollected
        self.totalPearlsCollected = totalPearlsCollected
        self.totalLeavesCollected = totalLeavesCollected
        self.totalPlayTime = totalPlayTime
        self.totalUpgradesPurchased = totalUpgradesPurchased
        self.loginStreak = loginStreak
        self.prestigeLevel = prestigeLevel
        self.zenPoints = zenPoints
        self.totalPrestiges = totalPrestiges
        self.lastVisit = lastVisit
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Nonisolated Codable Conformance (Swift 6 Fix)

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
        self.userId = try container.decode(UUID.self, forKey: .userId)
        self.drops = try container.decode(Int.self, forKey: .drops)
        self.pearls = try container.decode(Int.self, forKey: .pearls)
        self.leaves = try container.decode(Int.self, forKey: .leaves)
        self.boatSpeedLevel = try container.decode(Int.self, forKey: .boatSpeedLevel)
        self.collectionRadiusLevel = try container.decode(Int.self, forKey: .collectionRadiusLevel)
        self.dropRateLevel = try container.decode(Int.self, forKey: .dropRateLevel)
        self.rainCollectorLevel = try container.decode(Int.self, forKey: .rainCollectorLevel)
        self.origamiFlag = try container.decode(Bool.self, forKey: .origamiFlag)
        self.currentSkin = try container.decode(String.self, forKey: .currentSkin)
        self.unlockedSkins = try container.decode([String].self, forKey: .unlockedSkins)
        self.hasFishCompanion = try container.decode(Bool.self, forKey: .hasFishCompanion)
        self.hasBirdCompanion = try container.decode(Bool.self, forKey: .hasBirdCompanion)
        self.unlockedAchievements = try container.decode([String].self, forKey: .unlockedAchievements)
        self.totalDropsCollected = try container.decode(Int.self, forKey: .totalDropsCollected)
        self.totalPearlsCollected = try container.decode(Int.self, forKey: .totalPearlsCollected)
        self.totalLeavesCollected = try container.decode(Int.self, forKey: .totalLeavesCollected)
        self.totalPlayTime = try container.decode(Int.self, forKey: .totalPlayTime)
        self.totalUpgradesPurchased = try container.decode(Int.self, forKey: .totalUpgradesPurchased)
        self.loginStreak = try container.decode(Int.self, forKey: .loginStreak)
        self.prestigeLevel = try container.decode(Int.self, forKey: .prestigeLevel)
        self.zenPoints = try container.decode(Int.self, forKey: .zenPoints)
        self.totalPrestiges = try container.decode(Int.self, forKey: .totalPrestiges)
        self.lastVisit = try container.decode(Date.self, forKey: .lastVisit)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(drops, forKey: .drops)
        try container.encode(pearls, forKey: .pearls)
        try container.encode(leaves, forKey: .leaves)
        try container.encode(boatSpeedLevel, forKey: .boatSpeedLevel)
        try container.encode(collectionRadiusLevel, forKey: .collectionRadiusLevel)
        try container.encode(dropRateLevel, forKey: .dropRateLevel)
        try container.encode(rainCollectorLevel, forKey: .rainCollectorLevel)
        try container.encode(origamiFlag, forKey: .origamiFlag)
        try container.encode(currentSkin, forKey: .currentSkin)
        try container.encode(unlockedSkins, forKey: .unlockedSkins)
        try container.encode(hasFishCompanion, forKey: .hasFishCompanion)
        try container.encode(hasBirdCompanion, forKey: .hasBirdCompanion)
        try container.encode(unlockedAchievements, forKey: .unlockedAchievements)
        try container.encode(totalDropsCollected, forKey: .totalDropsCollected)
        try container.encode(totalPearlsCollected, forKey: .totalPearlsCollected)
        try container.encode(totalLeavesCollected, forKey: .totalLeavesCollected)
        try container.encode(totalPlayTime, forKey: .totalPlayTime)
        try container.encode(totalUpgradesPurchased, forKey: .totalUpgradesPurchased)
        try container.encode(loginStreak, forKey: .loginStreak)
        try container.encode(prestigeLevel, forKey: .prestigeLevel)
        try container.encode(zenPoints, forKey: .zenPoints)
        try container.encode(totalPrestiges, forKey: .totalPrestiges)
        try container.encode(lastVisit, forKey: .lastVisit)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
}

// MARK: - Codable Conformance
extension GameStateDTO: Codable {}

// MARK: - DTO Conversion Extensions
extension GameState {
    nonisolated func toDTO(userId: UUID) -> GameStateDTO {
        GameStateDTO(
            id: nil,
            userId: userId,
            drops: currencies.drop,
            pearls: currencies.pearl,
            leaves: currencies.leaf,
            boatSpeedLevel: upgrades.speed,
            collectionRadiusLevel: upgrades.radius,
            dropRateLevel: upgrades.rate,
            rainCollectorLevel: upgrades.collector,
            origamiFlag: addOns.flag,
            currentSkin: activeSkin.rawValue,
            unlockedSkins: skins.swanSkin ? ["swan_skin"] : [],
            hasFishCompanion: companions.origamiFish,
            hasBirdCompanion: companions.origamiBird,
            unlockedAchievements: achievements.filter { $0.value.unlocked }.map { $0.key },
            totalDropsCollected: totalCollected.drop,
            totalPearlsCollected: totalCollected.pearl,
            totalLeavesCollected: totalCollected.leaf,
            totalPlayTime: playTime,
            totalUpgradesPurchased: totalUpgradesPurchased,
            loginStreak: loginStreak,
            prestigeLevel: prestige.level,
            zenPoints: prestige.zenPoints,
            totalPrestiges: prestige.totalPrestiges,
            lastVisit: lastVisit,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    nonisolated static func fromDTO(_ dto: GameStateDTO) -> GameState {
        var achievements: [String: AchievementState] = [:]
        for id in dto.unlockedAchievements {
            achievements[id] = AchievementState(unlocked: true, unlockedAt: nil, progress: 0)
        }

        return GameState(
            currencies: Currencies(
                drop: dto.drops,
                pearl: dto.pearls,
                leaf: dto.leaves
            ),
            upgrades: UpgradesState(
                speed: dto.boatSpeedLevel,
                radius: dto.collectionRadiusLevel,
                rate: dto.dropRateLevel,
                collector: dto.rainCollectorLevel
            ),
            addOns: AddOnsState(flag: dto.origamiFlag),
            skins: SkinsState(swanSkin: dto.unlockedSkins.contains("swan_skin")),
            companions: CompanionsState(
                origamiFish: dto.hasFishCompanion,
                origamiBird: dto.hasBirdCompanion
            ),
            activeSkin: Skin(rawValue: dto.currentSkin) ?? .default,
            achievements: achievements,
            totalCollected: Currencies(
                drop: dto.totalDropsCollected,
                pearl: dto.totalPearlsCollected,
                leaf: dto.totalLeavesCollected
            ),
            playTime: dto.totalPlayTime,
            totalUpgradesPurchased: dto.totalUpgradesPurchased,
            loginStreak: dto.loginStreak,
            prestige: PrestigeState(
                level: dto.prestigeLevel,
                zenPoints: dto.zenPoints,
                totalPrestiges: dto.totalPrestiges
            ),
            lastVisit: dto.lastVisit,
            createdAt: dto.createdAt ?? Date(),
            updatedAt: dto.updatedAt ?? Date()
        )
    }
}
