import Foundation
import Combine

/// Central game state management
/// Ported from useGameState.ts hook
@MainActor
@Observable
class GameViewModel {
    // MARK: - Services
    private let databaseService: DatabaseService
    private let authService: AuthService

    // MARK: - Game State
    private(set) var gameState: GameState
    private var saveTimer: Timer?
    private var playTimeTimer: Timer?

    // MARK: - UI State
    var isLoading = false
    var offlineEarnings: Int?
    var minutesOffline: Double = 0
    var showWelcomeBack = false

    // MARK: - Initialization
    init(databaseService: DatabaseService, authService: AuthService) {
        self.databaseService = databaseService
        self.authService = authService
        self.gameState = .initial

        // Start play time tracking
        startPlayTimeTracking()
    }

    // MARK: - Loading & Saving

    /// Load game state (from DB or UserDefaults)
    func loadGameState() async {
        isLoading = true

        // If user is authenticated, load from database
        if let userId = authService.userId {
            do {
                if let loadedState = try await databaseService.loadGameState(userId: userId) {
                    // Calculate offline earnings
                    let minutesOffline = Date().timeIntervalSince(loadedState.lastVisit) / 60
                    let earnings = GameConfig.calculateIdleEarnings(
                        upgrades: loadedState.upgrades,
                        companions: loadedState.companions,
                        minutesOffline: minutesOffline
                    )

                    if earnings > 0 {
                        self.offlineEarnings = earnings
                        self.minutesOffline = minutesOffline
                        self.showWelcomeBack = true

                        // Add offline earnings to state
                        var updatedState = loadedState
                        updatedState.currencies.drop += earnings
                        updatedState.lastVisit = Date()
                        self.gameState = updatedState
                    } else {
                        self.gameState = loadedState
                    }

                    print("[GameVM] ✅ Loaded from database")
                } else {
                    // Try loading from local storage and migrate
                    if let localState = loadFromUserDefaults() {
                        self.gameState = localState
                        // Migrate to cloud
                        await saveGameState()
                        print("[GameVM] ✅ Migrated local state to cloud")
                    } else {
                        // New user, start fresh
                        self.gameState = .initial
                    }
                }
            } catch {
                print("[GameVM] ❌ Error loading from database: \(error)")
                // Fallback to local storage
                if let localState = loadFromUserDefaults() {
                    self.gameState = localState
                }
            }
        } else {
            // Offline mode - load from UserDefaults
            if let localState = loadFromUserDefaults() {
                self.gameState = localState
            }
            print("[GameVM] ✅ Loaded from UserDefaults (offline mode)")
        }

        isLoading = false

        // Start auto-save timer
        startAutoSave()
    }

    /// Save game state (debounced)
    @discardableResult
    func saveGameState(immediate: Bool = false) async -> Bool {
        // Update metadata
        gameState.updatedAt = Date()
        gameState.lastVisit = Date()

        // Save to UserDefaults immediately (fast)
        saveToUserDefaults()

        // Save to database if authenticated
        if let userId = authService.userId {
            do {
                try await databaseService.saveGameState(userId: userId, gameState: gameState)
                print("[GameVM] ✅ Saved to database")
                return true
            } catch {
                print("[GameVM] ❌ Error saving to database: \(error)")
                return false
            }
        }

        return true
    }

    // MARK: - Currency Operations

    /// Collect currency
    func collect(currency: Currency, amount: Int) {
        var multipliedAmount = amount

        // Apply companion bonuses
        switch currency {
        case .pearl where gameState.companions.origamiFish:
            multipliedAmount *= Int(GameConfig.CompanionBonus.origamiFish)
        case .leaf where gameState.companions.origamiBird:
            multipliedAmount *= Int(GameConfig.CompanionBonus.origamiBird)
        default:
            break
        }

        gameState.currencies[currency] += multipliedAmount
        gameState.totalCollected[currency] += multipliedAmount

        print("[GameVM] ➕ Collected \(multipliedAmount) \(currency.rawValue)")

        // Check achievements
        checkAchievements()
    }

    /// Claim daily login reward
    func claimDailyReward() -> Int {
        let currentDay = min(gameState.loginStreak + 1, 7)
        let rewards = [(1, 100), (2, 200), (3, 400), (4, 800), (5, 1600), (6, 3200), (7, 10000)]
        let reward = rewards[currentDay - 1].1

        gameState.currencies.drop += reward
        gameState.loginStreak = currentDay

        print("[GameVM] 🎁 Claimed daily reward: \(reward) drops (Day \(currentDay))")
        return reward
    }

    /// Check if player can afford cost
    func canAfford(_ cost: Currencies) -> Bool {
        return gameState.currencies.drop >= cost.drop &&
               gameState.currencies.pearl >= cost.pearl &&
               gameState.currencies.leaf >= cost.leaf
    }

    /// Deduct cost from currencies
    private func deductCost(_ cost: Currencies) {
        gameState.currencies.drop -= cost.drop
        gameState.currencies.pearl -= cost.pearl
        gameState.currencies.leaf -= cost.leaf
    }

    // MARK: - Upgrade Operations

    /// Purchase upgrade
    func purchaseUpgrade(_ upgradeId: UpgradeID) -> Bool {
        let currentLevel = gameState.upgrades[upgradeId]
        let cost = GameConfig.calculateUpgradeCost(for: upgradeId, level: currentLevel)

        guard canAfford(cost) else {
            print("[GameVM] ❌ Cannot afford upgrade \(upgradeId)")
            return false
        }

        deductCost(cost)
        gameState.upgrades[upgradeId] += 1
        gameState.totalUpgradesPurchased += 1

        print("[GameVM] ✅ Purchased upgrade \(upgradeId), new level: \(gameState.upgrades[upgradeId])")

        checkAchievements()
        return true
    }

    /// Purchase one-time item
    func purchaseOneTimeItem(_ item: OneTimeItem) -> Bool {
        let cost = GameConfig.calculateOneTimeCost(for: item)

        guard canAfford(cost) else {
            print("[GameVM] ❌ Cannot afford item \(item)")
            return false
        }

        switch item {
        case .flag:
            guard !gameState.addOns.flag else { return false }
            deductCost(cost)
            gameState.addOns.flag = true

        case .swanSkin:
            guard !gameState.skins.swanSkin else { return false }
            deductCost(cost)
            gameState.skins.swanSkin = true

        case .origamiFish:
            guard !gameState.companions.origamiFish else { return false }
            deductCost(cost)
            gameState.companions.origamiFish = true

        case .origamiBird:
            guard !gameState.companions.origamiBird else { return false }
            deductCost(cost)
            gameState.companions.origamiBird = true
        }

        gameState.totalUpgradesPurchased += 1
        print("[GameVM] ✅ Purchased item \(item)")

        checkAchievements()
        return true
    }

    /// Set active skin
    func setActiveSkin(_ skin: Skin) {
        guard gameState.skins.isUnlocked(skin) else { return }
        gameState.activeSkin = skin
        print("[GameVM] 🎨 Active skin changed to \(skin.rawValue)")
    }

    // MARK: - Prestige System

    /// Perform prestige (reset progress for permanent bonuses)
    func performPrestige() -> Int {
        let totalDrops = gameState.totalCollected.drop
        let zenPoints = Int(sqrt(Double(totalDrops) / 10000))

        // Reset currencies
        gameState.currencies = .zero

        // Reset upgrades
        gameState.upgrades = .initial

        // Reset decorative add-ons
        gameState.addOns.flag = false

        // Keep: skins, companions, achievements, prestige

        // Increase prestige
        gameState.prestige.level += 1
        gameState.prestige.zenPoints += zenPoints
        gameState.prestige.totalPrestiges += 1

        print("[GameVM] ✨ Prestiged to level \(gameState.prestige.level) (+\(zenPoints) Zen Points)")
        return zenPoints
    }

    // MARK: - Achievement System

    private func checkAchievements() {
        for achievement in GameConfig.Achievement.allCases {
            // Skip if already unlocked
            if let state = gameState.achievements[achievement.rawValue], state.unlocked {
                continue
            }

            // Check if achievement should be unlocked
            if achievement.isUnlocked(gameState: gameState) {
                unlockAchievement(achievement)
            }
        }
    }

    private func unlockAchievement(_ achievement: GameConfig.Achievement) {
        // Mark as unlocked
        gameState.achievements[achievement.rawValue] = AchievementState(
            unlocked: true,
            unlockedAt: Date(),
            progress: 0
        )

        // Award reward
        gameState.currencies.drop += achievement.reward

        // Play feedback
        SoundManager.shared.playAchievementUnlock()
        HapticFeedback.success()

        print("[GameVM] 🏆 Achievement unlocked: \(achievement.title) (+\(achievement.reward) drops)")

        // TODO: Show achievement toast notification
    }

    // MARK: - Auto-Save & Play Time

    private func startAutoSave() {
        // Debounced save every 2 seconds (like the React version)
        saveTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.saveGameState()
            }
        }
    }

    private func startPlayTimeTracking() {
        playTimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.gameState.playTime += 1
            }
        }
    }

    // MARK: - UserDefaults Persistence

    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(gameState) {
            UserDefaults.standard.set(encoded, forKey: "zenOrigamiGameState")
        }
    }

    private func loadFromUserDefaults() -> GameState? {
        guard let data = UserDefaults.standard.data(forKey: "zenOrigamiGameState"),
              let state = try? JSONDecoder().decode(GameState.self, from: data) else {
            return nil
        }
        return state
    }

    // MARK: - Cleanup

    deinit {
        // Note: Timers will be invalidated automatically when deallocated
        // Accessing @MainActor properties from deinit is not safe in Swift 6
        // If cleanup is needed, call stopTimers() before releasing the view model
    }
}
