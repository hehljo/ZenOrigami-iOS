import Foundation

/// Core game configuration constants
/// Ported from gameConfig.ts
enum GameConfig {
    // MARK: - Spawn Intervals
    static let baseDropInterval: TimeInterval = 2.0 // seconds
    static let leafSpawnInterval: TimeInterval = 8.0
    static let pearlSpawnInterval: TimeInterval = 10.0

    // MARK: - Upgrade Bonuses
    static let rateUpgradeBonus: Double = 0.25
    static let speedUpgradeBonus: Double = 0.2
    static let baseRadiusScale: Double = 1.0
    static let radiusUpgradeBonus: Double = 0.2

    // MARK: - Animation Speeds (Lower = faster)
    enum ScrollDuration {
        static let clouds: Double = 80
        static let mountains: Double = 50
        static let shore: Double = 35
        static let waterDecor: Double = 28
        static let waterRipples: Double = 22
        static let waterReflections: Double = 15
    }

    // MARK: - Companion Bonuses
    enum CompanionBonus {
        static let origamiFish: Double = 2.0 // Pearl value multiplier
        static let origamiBird: Double = 2.0 // Leaf value multiplier
    }

    // MARK: - Idle Earnings Configuration
    /// Enhanced Idle Earnings (Best Practice Nov 2025)
    /// Makes all upgrades valuable for idle play, not just collector
    enum IdleEarnings {
        static let baseRate: Double = 2.0 // Drops per minute per collector level
        static let speedBonus: Double = 0.5 // Drops per minute per speed level
        static let radiusBonus: Double = 0.75 // Drops per minute per radius level
        static let rateBonus: Double = 1.0 // Drops per minute per rate level
        static let maxOfflineHours: Double = 24.0 // Maximum offline time cap

        enum CompanionMultiplier {
            static let origamiFish: Double = 0.1 // +10% total idle earnings
            static let origamiBird: Double = 0.1 // +10% total idle earnings
        }
    }
}

// MARK: - Idle Earnings Calculator
extension GameConfig {
    /// Calculate idle earnings based on all upgrades and companions
    ///
    /// Best Practice November 2025:
    /// - All upgrades contribute to idle production
    /// - Companions provide multiplicative bonus
    /// - Creates interesting optimization choices
    /// - Rewards invested players appropriately
    ///
    /// - Parameters:
    ///   - upgrades: Current upgrade levels
    ///   - companions: Owned companions
    ///   - minutesOffline: Minutes the player was offline
    /// - Returns: Total drops earned while offline
    static func calculateIdleEarnings(
        upgrades: UpgradesState,
        companions: CompanionsState,
        minutesOffline: Double
    ) -> Int {
        // Base rate from collector
        let baseRate = Double(upgrades.collector) * IdleEarnings.baseRate

        // Bonuses from other upgrades
        let speedBonus = Double(upgrades.speed) * IdleEarnings.speedBonus
        let radiusBonus = Double(upgrades.radius) * IdleEarnings.radiusBonus
        let rateBonus = Double(upgrades.rate) * IdleEarnings.rateBonus

        // Total rate per minute before companion multiplier
        let totalRate = baseRate + speedBonus + radiusBonus + rateBonus

        // Companion multiplier (additive percentages)
        var companionMultiplier = 1.0
        if companions.origamiFish {
            companionMultiplier += IdleEarnings.CompanionMultiplier.origamiFish
        }
        if companions.origamiBird {
            companionMultiplier += IdleEarnings.CompanionMultiplier.origamiBird
        }

        // Apply companion multiplier
        let finalRate = totalRate * companionMultiplier

        // Cap offline time at max hours
        let cappedMinutes = min(minutesOffline, IdleEarnings.maxOfflineHours * 60)

        // Calculate total earnings
        return Int(floor(cappedMinutes * finalRate))
    }

    /// Calculate idle earnings rate per hour
    /// Useful for UI display
    static func calculateIdleEarningsPerHour(
        upgrades: UpgradesState,
        companions: CompanionsState
    ) -> Int {
        return calculateIdleEarnings(
            upgrades: upgrades,
            companions: companions,
            minutesOffline: 60
        )
    }
}

// MARK: - Upgrade Costs
extension GameConfig {
    /// Calculate cost for leveled upgrades (exponential scaling)
    static func calculateUpgradeCost(
        for upgrade: UpgradeID,
        level: Int
    ) -> Currencies {
        let baseCost: Int
        let multiplier: Double

        switch upgrade {
        case .speed:
            baseCost = 10
            multiplier = 1.15
        case .radius:
            baseCost = 25
            multiplier = 1.2
        case .rate:
            baseCost = 50
            multiplier = 1.25
        case .collector:
            baseCost = 100
            multiplier = 1.3
        }

        let cost = Int(floor(Double(baseCost) * pow(multiplier, Double(level))))
        return Currencies(drop: cost)
    }

    /// Calculate cost for one-time purchases
    static func calculateOneTimeCost(for item: OneTimeItem) -> Currencies {
        switch item {
        case .flag:
            return Currencies(drop: 1000)
        case .swanSkin:
            return Currencies(drop: 5000, pearl: 10)
        case .origamiFish:
            return Currencies(drop: 10000, pearl: 50)
        case .origamiBird:
            return Currencies(drop: 15000, leaf: 20)
        }
    }
}

// MARK: - Helper Types
enum OneTimeItem {
    case flag
    case swanSkin
    case origamiFish
    case origamiBird
}

// MARK: - Achievements System
extension GameConfig {
    enum Achievement: String, CaseIterable, Codable {
        // Collection Achievements
        case firstCollect = "first_collect"
        case collector100 = "collector_100"
        case collector1000 = "collector_1000"
        case collector10000 = "collector_10000"
        case pearlHunter = "pearl_hunter"
        case leafGatherer = "leaf_gatherer"

        // Upgrade Achievements
        case firstUpgrade = "first_upgrade"
        case upgrader10 = "upgrader_10"
        case upgrader50 = "upgrader_50"
        case maxSpeed = "max_speed"
        case maxRadius = "max_radius"

        // Companion Achievements
        case fishFriend = "fish_friend"
        case birdBuddy = "bird_buddy"
        case fullCrew = "full_crew"

        // Cosmetic Achievements
        case fashionista = "fashionista"
        case flagBearer = "flag_bearer"

        // Progression Achievements
        case firstPrestige = "first_prestige"
        case prestigeMaster = "prestige_master"
        case idleMaster = "idle_master"

        // Time Achievements
        case playTime1Hour = "playtime_1hour"
        case playTime10Hours = "playtime_10hours"
        case weeklyPlayer = "weekly_player"

        var title: String {
            switch self {
            case .firstCollect: return "First Steps"
            case .collector100: return "Collector"
            case .collector1000: return "Master Collector"
            case .collector10000: return "Drop Legend"
            case .pearlHunter: return "Pearl Hunter"
            case .leafGatherer: return "Leaf Gatherer"
            case .firstUpgrade: return "Getting Started"
            case .upgrader10: return "Upgrader"
            case .upgrader50: return "Master Upgrader"
            case .maxSpeed: return "Speed Demon"
            case .maxRadius: return "Wide Net"
            case .fishFriend: return "Fish Friend"
            case .birdBuddy: return "Bird Buddy"
            case .fullCrew: return "Full Crew"
            case .fashionista: return "Fashionista"
            case .flagBearer: return "Flag Bearer"
            case .firstPrestige: return "New Beginning"
            case .prestigeMaster: return "Prestige Master"
            case .idleMaster: return "Idle Master"
            case .playTime1Hour: return "Dedicated"
            case .playTime10Hours: return "Devotee"
            case .weeklyPlayer: return "Weekly Regular"
            }
        }

        var description: String {
            switch self {
            case .firstCollect: return "Collect your first drop"
            case .collector100: return "Collect 100 total drops"
            case .collector1000: return "Collect 1,000 total drops"
            case .collector10000: return "Collect 10,000 total drops"
            case .pearlHunter: return "Collect 50 pearls"
            case .leafGatherer: return "Collect 50 leaves"
            case .firstUpgrade: return "Purchase your first upgrade"
            case .upgrader10: return "Purchase 10 upgrades"
            case .upgrader50: return "Purchase 50 upgrades"
            case .maxSpeed: return "Reach speed level 25"
            case .maxRadius: return "Reach radius level 25"
            case .fishFriend: return "Unlock the Origami Fish companion"
            case .birdBuddy: return "Unlock the Origami Bird companion"
            case .fullCrew: return "Unlock all companions"
            case .fashionista: return "Unlock the Swan skin"
            case .flagBearer: return "Unlock the origami flag"
            case .firstPrestige: return "Complete your first prestige"
            case .prestigeMaster: return "Reach prestige level 5"
            case .idleMaster: return "Earn 10,000 drops while offline"
            case .playTime1Hour: return "Play for 1 hour"
            case .playTime10Hours: return "Play for 10 hours"
            case .weeklyPlayer: return "Log in for 7 consecutive days"
            }
        }

        var emoji: String {
            switch self {
            case .firstCollect: return "💧"
            case .collector100: return "💦"
            case .collector1000: return "🌊"
            case .collector10000: return "🌀"
            case .pearlHunter: return "🔵"
            case .leafGatherer: return "🍃"
            case .firstUpgrade: return "⬆️"
            case .upgrader10: return "📈"
            case .upgrader50: return "🚀"
            case .maxSpeed: return "⚡"
            case .maxRadius: return "📡"
            case .fishFriend: return "🐟"
            case .birdBuddy: return "🐦"
            case .fullCrew: return "👥"
            case .fashionista: return "🦢"
            case .flagBearer: return "🚩"
            case .firstPrestige: return "⭐"
            case .prestigeMaster: return "🌟"
            case .idleMaster: return "😴"
            case .playTime1Hour: return "⏰"
            case .playTime10Hours: return "⏳"
            case .weeklyPlayer: return "📅"
            }
        }

        var reward: Int {
            switch self {
            case .firstCollect: return 10
            case .collector100: return 50
            case .collector1000: return 500
            case .collector10000: return 5000
            case .pearlHunter: return 100
            case .leafGatherer: return 100
            case .firstUpgrade: return 25
            case .upgrader10: return 250
            case .upgrader50: return 2500
            case .maxSpeed: return 1000
            case .maxRadius: return 1000
            case .fishFriend: return 500
            case .birdBuddy: return 500
            case .fullCrew: return 2000
            case .fashionista: return 300
            case .flagBearer: return 200
            case .firstPrestige: return 10000
            case .prestigeMaster: return 50000
            case .idleMaster: return 1000
            case .playTime1Hour: return 100
            case .playTime10Hours: return 1000
            case .weeklyPlayer: return 500
            }
        }

        func isUnlocked(gameState: GameState) -> Bool {
            switch self {
            case .firstCollect:
                return gameState.totalCollected.drop >= 1
            case .collector100:
                return gameState.totalCollected.drop >= 100
            case .collector1000:
                return gameState.totalCollected.drop >= 1000
            case .collector10000:
                return gameState.totalCollected.drop >= 10000
            case .pearlHunter:
                return gameState.totalCollected.pearl >= 50
            case .leafGatherer:
                return gameState.totalCollected.leaf >= 50
            case .firstUpgrade:
                return gameState.totalUpgradesPurchased >= 1
            case .upgrader10:
                return gameState.totalUpgradesPurchased >= 10
            case .upgrader50:
                return gameState.totalUpgradesPurchased >= 50
            case .maxSpeed:
                return gameState.upgrades.speed >= 25
            case .maxRadius:
                return gameState.upgrades.radius >= 25
            case .fishFriend:
                return gameState.companions.origamiFish
            case .birdBuddy:
                return gameState.companions.origamiBird
            case .fullCrew:
                return gameState.companions.origamiFish && gameState.companions.origamiBird
            case .fashionista:
                return gameState.skins.swanSkin
            case .flagBearer:
                return gameState.addOns.flag
            case .firstPrestige:
                return gameState.prestigeLevel >= 1
            case .prestigeMaster:
                return gameState.prestigeLevel >= 5
            case .idleMaster:
                return gameState.totalCollected.drop >= 10000 // Will track separately
            case .playTime1Hour:
                return gameState.playTime >= 3600 // 1 hour in seconds
            case .playTime10Hours:
                return gameState.playTime >= 36000 // 10 hours
            case .weeklyPlayer:
                return gameState.loginStreak >= 7
            }
        }
    }
}
