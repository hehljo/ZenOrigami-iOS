import XCTest
@testable import ZenOrigami

final class GameConfigTests: XCTestCase {

    // MARK: - Idle Earnings Tests

    func testIdleEarningsBaseRate() {
        // Given
        let upgrades = UpgradesState(speed: 0, radius: 0, rate: 0, collector: 10)
        let companions = CompanionsState(origamiFish: false, origamiBird: false)

        // When
        let earnings = GameConfig.calculateIdleEarnings(
            upgrades: upgrades,
            companions: companions,
            minutesOffline: 60
        )

        // Then
        // 10 collector * 2 drops/min = 20 drops/min * 60 min = 1200
        XCTAssertEqual(earnings, 1200, "Base idle earnings calculation incorrect")
    }

    func testIdleEarningsWithAllUpgrades() {
        // Given
        let upgrades = UpgradesState(speed: 10, radius: 10, rate: 10, collector: 10)
        let companions = CompanionsState(origamiFish: false, origamiBird: false)

        // When
        let earnings = GameConfig.calculateIdleEarnings(
            upgrades: upgrades,
            companions: companions,
            minutesOffline: 60
        )

        // Then
        // collector: 10 * 2 = 20
        // speed: 10 * 0.5 = 5
        // radius: 10 * 0.75 = 7.5
        // rate: 10 * 1.0 = 10
        // total: 42.5 drops/min * 60 min = 2550
        XCTAssertEqual(earnings, 2550)
    }

    func testIdleEarningsWithCompanions() {
        // Given
        let upgrades = UpgradesState(speed: 0, radius: 0, rate: 0, collector: 10)
        let companions = CompanionsState(origamiFish: true, origamiBird: true)

        // When
        let earnings = GameConfig.calculateIdleEarnings(
            upgrades: upgrades,
            companions: companions,
            minutesOffline: 60
        )

        // Then
        // Base: 10 * 2 = 20 drops/min
        // With both companions: 20 * 1.2 = 24 drops/min
        // 24 * 60 = 1440
        XCTAssertEqual(earnings, 1440)
    }

    func testIdleEarningsCappedAt24Hours() {
        // Given
        let upgrades = UpgradesState(speed: 0, radius: 0, rate: 0, collector: 10)
        let companions = CompanionsState(origamiFish: false, origamiBird: false)

        // When - 48 hours offline (should cap at 24)
        let earnings = GameConfig.calculateIdleEarnings(
            upgrades: upgrades,
            companions: companions,
            minutesOffline: 60 * 48
        )

        // Then - Should be same as 24 hours
        let expectedEarnings = GameConfig.calculateIdleEarnings(
            upgrades: upgrades,
            companions: companions,
            minutesOffline: 60 * 24
        )
        XCTAssertEqual(earnings, expectedEarnings)
        XCTAssertEqual(earnings, 28800) // 10*2*60*24
    }

    func testIdleEarningsPerHour() {
        // Given
        let upgrades = UpgradesState(speed: 0, radius: 0, rate: 0, collector: 5)
        let companions = CompanionsState(origamiFish: false, origamiBird: false)

        // When
        let earningsPerHour = GameConfig.calculateIdleEarningsPerHour(
            upgrades: upgrades,
            companions: companions
        )

        // Then
        // 5 * 2 * 60 = 600
        XCTAssertEqual(earningsPerHour, 600)
    }

    // MARK: - Upgrade Cost Tests

    func testUpgradeCostScaling() {
        // Test exponential cost scaling
        let level0 = GameConfig.calculateUpgradeCost(for: .speed, level: 0)
        let level1 = GameConfig.calculateUpgradeCost(for: .speed, level: 1)
        let level10 = GameConfig.calculateUpgradeCost(for: .speed, level: 10)

        XCTAssertEqual(level0.drop, 10) // Base cost
        XCTAssertGreaterThan(level1.drop, level0.drop)
        XCTAssertGreaterThan(level10.drop, level1.drop)
    }

    func testDifferentUpgradeBaseCosts() {
        // Each upgrade should have different base cost
        let speed = GameConfig.calculateUpgradeCost(for: .speed, level: 0)
        let radius = GameConfig.calculateUpgradeCost(for: .radius, level: 0)
        let rate = GameConfig.calculateUpgradeCost(for: .rate, level: 0)
        let collector = GameConfig.calculateUpgradeCost(for: .collector, level: 0)

        XCTAssertLessThan(speed.drop, radius.drop)
        XCTAssertLessThan(radius.drop, rate.drop)
        XCTAssertLessThan(rate.drop, collector.drop)
    }

    func testOneTimeCosts() {
        let flag = GameConfig.calculateOneTimeCost(for: .flag)
        let swan = GameConfig.calculateOneTimeCost(for: .swanSkin)
        let fish = GameConfig.calculateOneTimeCost(for: .origamiFish)
        let bird = GameConfig.calculateOneTimeCost(for: .origamiBird)

        // Flag should be cheapest (drops only)
        XCTAssertEqual(flag.drop, 1000)
        XCTAssertEqual(flag.pearl, 0)

        // Swan requires pearls
        XCTAssertGreaterThan(swan.pearl, 0)

        // Companions should be most expensive
        XCTAssertGreaterThan(fish.drop, swan.drop)
        XCTAssertGreaterThan(bird.drop, fish.drop)
    }
}
