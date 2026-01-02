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
