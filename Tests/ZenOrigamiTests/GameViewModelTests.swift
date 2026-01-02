import XCTest
@testable import ZenOrigami

@MainActor
final class GameViewModelTests: XCTestCase {
    var viewModel: GameViewModel!
    var mockDatabaseService: DatabaseService!
    var mockAuthService: AuthService!

    override func setUp() async throws {
        // Setup mock services
        mockDatabaseService = DatabaseService(
            supabaseURL: "https://test.supabase.co",
            supabaseKey: "test-key"
        )
        mockAuthService = AuthService(
            supabaseURL: "https://test.supabase.co",
            supabaseKey: "test-key"
        )

        viewModel = GameViewModel(
            databaseService: mockDatabaseService,
            authService: mockAuthService
        )
    }

    override func tearDown() {
        viewModel = nil
        mockDatabaseService = nil
        mockAuthService = nil
    }

    // MARK: - Currency Tests

    func testCollectDrop() {
        // Given
        let initialDrops = viewModel.gameState.currencies.drop

        // When
        viewModel.collect(currency: .drop, amount: 10)

        // Then
        XCTAssertEqual(
            viewModel.gameState.currencies.drop,
            initialDrops + 10,
            "Collecting 10 drops should increase currency by 10"
        )
    }

    func testCollectPearlWithCompanion() {
        // Given
        viewModel.gameState.companions.origamiFish = true
        let initialPearls = viewModel.gameState.currencies.pearl

        // When
        viewModel.collect(currency: .pearl, amount: 10)

        // Then
        // Companion doubles pearl value
        XCTAssertEqual(
            viewModel.gameState.currencies.pearl,
            initialPearls + 20,
            "Collecting 10 pearls with fish companion should give 20"
        )
    }

    func testTotalCollectedTracking() {
        // When
        viewModel.collect(currency: .drop, amount: 100)
        viewModel.collect(currency: .pearl, amount: 5)

        // Then
        XCTAssertEqual(viewModel.gameState.totalCollected.drop, 100)
        XCTAssertEqual(viewModel.gameState.totalCollected.pearl, 5)
    }

    // MARK: - Upgrade Tests

    func testCanAffordUpgrade() {
        // Given
        viewModel.gameState.currencies.drop = 1000

        // When
        let cost = GameConfig.calculateUpgradeCost(for: .speed, level: 0)
        let canAfford = viewModel.canAfford(cost)

        // Then
        XCTAssertTrue(canAfford, "Should be able to afford first speed upgrade")
    }

    func testCannotAffordExpensiveUpgrade() {
        // Given
        viewModel.gameState.currencies.drop = 5

        // When
        let cost = GameConfig.calculateUpgradeCost(for: .collector, level: 10)
        let canAfford = viewModel.canAfford(cost)

        // Then
        XCTAssertFalse(canAfford, "Should not afford high-level collector upgrade")
    }

    func testPurchaseUpgrade() {
        // Given
        viewModel.gameState.currencies.drop = 1000
        let initialLevel = viewModel.gameState.upgrades.speed

        // When
        let success = viewModel.purchaseUpgrade(.speed)

        // Then
        XCTAssertTrue(success, "Purchase should succeed")
        XCTAssertEqual(
            viewModel.gameState.upgrades.speed,
            initialLevel + 1,
            "Upgrade level should increase by 1"
        )
    }

    func testPurchaseUpgradeDeductsCost() {
        // Given
        viewModel.gameState.currencies.drop = 1000
        let cost = GameConfig.calculateUpgradeCost(for: .speed, level: 0)

        // When
        viewModel.purchaseUpgrade(.speed)

        // Then
        XCTAssertEqual(
            viewModel.gameState.currencies.drop,
            1000 - cost.drop,
            "Currency should be deducted by upgrade cost"
        )
    }

    func testCannotPurchaseUpgradeWithoutFunds() {
        // Given
        viewModel.gameState.currencies.drop = 1

        // When
        let success = viewModel.purchaseUpgrade(.collector)

        // Then
        XCTAssertFalse(success, "Purchase should fail without sufficient funds")
    }

    // MARK: - One-Time Item Tests

    func testPurchaseCompanion() {
        // Given
        viewModel.gameState.currencies.drop = 20000
        viewModel.gameState.currencies.pearl = 100

        // When
        let success = viewModel.purchaseOneTimeItem(.origamiFish)

        // Then
        XCTAssertTrue(success, "Purchase should succeed")
        XCTAssertTrue(viewModel.gameState.companions.origamiFish, "Companion should be unlocked")
    }

    func testCannotPurchaseSameItemTwice() {
        // Given
        viewModel.gameState.currencies.drop = 50000
        viewModel.gameState.companions.origamiFish = true

        // When
        let success = viewModel.purchaseOneTimeItem(.origamiFish)

        // Then
        XCTAssertFalse(success, "Should not be able to purchase already owned item")
    }

    // MARK: - Skin Tests

    func testSetActiveSkin() {
        // Given
        viewModel.gameState.skins.swanSkin = true

        // When
        viewModel.setActiveSkin(.swanSkin)

        // Then
        XCTAssertEqual(viewModel.gameState.activeSkin, .swanSkin)
    }

    func testCannotSetLockedSkin() {
        // Given
        viewModel.gameState.skins.swanSkin = false
        let initialSkin = viewModel.gameState.activeSkin

        // When
        viewModel.setActiveSkin(.swanSkin)

        // Then
        XCTAssertEqual(
            viewModel.gameState.activeSkin,
            initialSkin,
            "Should not change skin to locked skin"
        )
    }
}
