import Foundation
import SwiftUI

/// Manages spawning and animation of falling collectible items
@MainActor
@Observable
class FallingItemManager {
    // MARK: - Falling Items State
    var fallingDrops: [FallingItem] = []
    var fallingPearls: [FallingItem] = []
    var fallingLeaves: [FallingItem] = []

    private var spawnTimer: Timer?
    private var cleanupTimer: Timer?

    // MARK: - Configuration
    private let spawnInterval: TimeInterval
    private let fallDuration: TimeInterval = 3.0

    init(spawnInterval: TimeInterval = 2.0) {
        self.spawnInterval = spawnInterval
    }

    // MARK: - Lifecycle

    /// Start spawning items
    func startSpawning() {
        stopSpawning() // Clean up existing timers

        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.spawnRandomItem()
            }
        }

        // Cleanup timer to remove items that went off-screen
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.cleanupOffscreenItems()
            }
        }

        print("[FallingItemManager] ✅ Started spawning (interval: \(spawnInterval)s)")
    }

    /// Stop spawning items
    func stopSpawning() {
        spawnTimer?.invalidate()
        spawnTimer = nil
        cleanupTimer?.invalidate()
        cleanupTimer = nil
        print("[FallingItemManager] ⏸️ Stopped spawning")
    }

    // MARK: - Spawning Logic

    private func spawnRandomItem() {
        // Weighted spawn rates
        let random = Int.random(in: 1...100)

        switch random {
        case 1...70:
            // 70% Drops (common)
            spawnDrop()
        case 71...90:
            // 20% Pearls (uncommon)
            spawnPearl()
        case 91...100:
            // 10% Leaves (rare)
            spawnLeaf()
        default:
            break
        }
    }

    private func spawnDrop() {
        let item = createFallingItem()
        fallingDrops.append(item)
    }

    private func spawnPearl() {
        let item = createFallingItem()
        fallingPearls.append(item)
    }

    private func spawnLeaf() {
        let item = createFallingItem()
        fallingLeaves.append(item)
    }

    private func createFallingItem() -> FallingItem {
        let randomX = CGFloat.random(in: 0.1...0.9) // 10-90% of screen width
        return FallingItem(
            x: randomX,
            y: -0.1, // Start above screen
            targetY: 1.1, // End below screen
            duration: fallDuration
        )
    }

    // MARK: - Collection

    /// Attempt to collect a drop at the given position
    func collectDrop(at id: UUID) -> Bool {
        guard let index = fallingDrops.firstIndex(where: { $0.id == id }) else {
            return false
        }

        fallingDrops[index].isCollected = true
        // Remove after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.fallingDrops.removeAll { $0.id == id }
        }
        return true
    }

    func collectPearl(at id: UUID) -> Bool {
        guard let index = fallingPearls.firstIndex(where: { $0.id == id }) else {
            return false
        }

        fallingPearls[index].isCollected = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.fallingPearls.removeAll { $0.id == id }
        }
        return true
    }

    func collectLeaf(at id: UUID) -> Bool {
        guard let index = fallingLeaves.firstIndex(where: { $0.id == id }) else {
            return false
        }

        fallingLeaves[index].isCollected = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.fallingLeaves.removeAll { $0.id == id }
        }
        return true
    }

    // MARK: - Cleanup

    private func cleanupOffscreenItems() {
        // Remove items that fell off screen (y > 1.0)
        fallingDrops.removeAll { $0.y > 1.05 }
        fallingPearls.removeAll { $0.y > 1.05 }
        fallingLeaves.removeAll { $0.y > 1.05 }
    }

    // MARK: - Cleanup

    deinit {
        Task { @MainActor in
            stopSpawning()
        }
    }
}

// MARK: - Supporting Types

struct FallingItem: Identifiable {
    let id = UUID()
    var x: CGFloat // Normalized position (0.0 - 1.0)
    var y: CGFloat // Normalized position (0.0 - 1.0)
    let targetY: CGFloat
    let duration: TimeInterval
    var isCollected: Bool = false

    var startTime: Date = Date()
}
