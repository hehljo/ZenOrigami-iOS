import Foundation
import Combine

/// Offline-only game view model (no Supabase required)
/// Uses UserDefaults + iCloud for persistence
@MainActor
@Observable
class OfflineGameViewModel {
    // MARK: - Services
    private let storageService: LocalStorageService

    // MARK: - Game State
    private(set) var gameState: GameState
    private var saveTimer: Timer?
    private var playTimeTimer: Timer?

    // MARK: - UI State
    var isLoading = false
    var offlineEarnings: Int?
    var minutesOffline: Double = 0
    var showWelcomeBack = false

    // MARK: - Falling Items (for animation)
    var fallingDrops: [FallingItem] = []
    var fallingLeaves: [FallingItem] = []
    var fallingPearls: [FallingItem] = []

    // MARK: - Initialization
    init(storageService: LocalStorageService) {
        self.storageService = storageService
        self.gameState = .initial

        // Start play time tracking
        startPlayTimeTracking()
    }

    // MARK: - Loading & Saving

    /// Load game state from local storage
    func loadGameState() async {
        isLoading = true

        if let loadedState = await storageService.loadGameState() {
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

            print("[OfflineGameVM] ✅ Loaded from local storage")
        } else {
            // New user, start fresh
            self.gameState = .initial
        }

        isLoading = false

        // Start auto-save timer
        startAutoSave()
    }

    /// Save game state
    @discardableResult
    func saveGameState(immediate: Bool = false) async -> Bool {
        // Update metadata
        gameState.updatedAt = Date()
        gameState.lastVisit = Date()

        do {
            try await storageService.saveGameState(gameState)
            print("[OfflineGameVM] ✅ Saved to local storage")
            return true
        } catch {
            print("[OfflineGameVM] ❌ Error saving: \(error)")
            return false
        }
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

        print("[OfflineGameVM] ➕ Collected \(multipliedAmount) \(currency.rawValue)")

        // Check achievements
        checkAchievements()
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
            print("[OfflineGameVM] ❌ Cannot afford upgrade \(upgradeId)")
            return false
        }

        deductCost(cost)
        gameState.upgrades[upgradeId] += 1
        gameState.totalUpgradesPurchased += 1

        print("[OfflineGameVM] ✅ Purchased upgrade \(upgradeId), new level: \(gameState.upgrades[upgradeId])")

        checkAchievements()
        return true
    }

    /// Purchase one-time item
    func purchaseOneTimeItem(_ item: OneTimeItem) -> Bool {
        let cost = GameConfig.calculateOneTimeCost(for: item)

        guard canAfford(cost) else {
            print("[OfflineGameVM] ❌ Cannot afford item \(item)")
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
        print("[OfflineGameVM] ✅ Purchased item \(item)")

        checkAchievements()
        return true
    }

    /// Set active skin
    func setActiveSkin(_ skin: Skin) {
        guard gameState.skins.isUnlocked(skin) else { return }
        gameState.activeSkin = skin
        print("[OfflineGameVM] 🎨 Active skin changed to \(skin.rawValue)")
    }

    // MARK: - Achievement System

    private func checkAchievements() {
        // TODO: Implement achievement checking logic
    }

    // MARK: - Auto-Save & Play Time

    private func startAutoSave() {
        // Debounced save every 2 seconds
        saveTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.saveGameState()
            }
        }
    }

    private func startPlayTimeTracking() {
        playTimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.gameState.playTime += 1
        }
    }

    // MARK: - Cleanup

    deinit {
        Task { @MainActor in
            saveTimer?.invalidate()
            playTimeTimer?.invalidate()
        }
    }
}
