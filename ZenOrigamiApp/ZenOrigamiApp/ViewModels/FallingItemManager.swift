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
    private let collectionRadius: CGFloat = 0.12  // Normalized screen space (12% of screen width) - increased for larger boat

    // Boat position tracking
    var boatPosition: CGPoint = CGPoint(x: 0.5, y: 0.6)  // Normalized position (at water surface)

    init(spawnInterval: TimeInterval = 2.0) {
        self.spawnInterval = spawnInterval
    }

    // MARK: - Lifecycle

    /// Start spawning items
    func startSpawning() {
        stopSpawning() // Clean up existing timers

        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.spawnRandomItem()
            }
        }

        // Cleanup timer to remove items that went off-screen
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.cleanupOffscreenItems()
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
        print("[Spawn] 💧 Drop at x:\(item.x), y:\(item.y) → \(item.targetY)")
    }

    private func spawnPearl() {
        // Pearls rise from bottom to surface (opposite of falling)
        let item = createRisingItem()
        fallingPearls.append(item)
        print("[Spawn] 🔵 Pearl at x:\(item.x), y:\(item.y) → \(item.targetY) (rising)")
    }

    private func spawnLeaf() {
        let item = createFallingItem()
        fallingLeaves.append(item)
        print("[Spawn] 🍃 Leaf at x:\(item.x), y:\(item.y) → \(item.targetY)")
    }

    /// Create a falling item (drops, leaves) - falls from top to bottom
    private func createFallingItem() -> FallingItem {
        let randomX = CGFloat.random(in: 0.1...0.9) // 10-90% of screen width
        return FallingItem(
            x: randomX,
            y: -0.1, // Start above screen
            targetY: 1.1, // End below screen (falls down)
            duration: fallDuration,
            worldSpawnPosition: 0.0 // Will be set by ScrollingWorldManager if used
        )
    }

    /// Create a rising item (pearls) - rises from bottom to top
    private func createRisingItem() -> FallingItem {
        let randomX = CGFloat.random(in: 0.1...0.9) // 10-90% of screen width
        return FallingItem(
            x: randomX,
            y: 1.1, // Start below screen (in water)
            targetY: -0.1, // Rise to surface (above screen)
            duration: fallDuration,
            worldSpawnPosition: 0.0 // Will be set by ScrollingWorldManager if used
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

    // MARK: - Collision Detection

    /// Check for collisions between falling items and boat
    /// Returns IDs of collected items by type
    func checkCollisions() -> (drops: [UUID], pearls: [UUID], leaves: [UUID]) {
        var collectedDrops: [UUID] = []
        var collectedPearls: [UUID] = []
        var collectedLeaves: [UUID] = []

        // DEBUG: Log current state
        let totalItems = fallingDrops.count + fallingPearls.count + fallingLeaves.count
        if totalItems > 0 && collisionCheckCount % 120 == 0 {  // Every 2 seconds
            print("[Collision] Checking \(totalItems) items, boat at (\(boatPosition.x), \(boatPosition.y)), radius: \(collectionRadius)")
        }

        // Check drops
        for item in fallingDrops where !item.isCollected {
            if isItemNearBoat(item) {
                collectedDrops.append(item.id)
            }
        }

        // Check pearls
        for item in fallingPearls where !item.isCollected {
            if isItemNearBoat(item) {
                collectedPearls.append(item.id)
            }
        }

        // Check leaves
        for item in fallingLeaves where !item.isCollected {
            if isItemNearBoat(item) {
                collectedLeaves.append(item.id)
            }
        }

        collisionCheckCount += 1
        return (collectedDrops, collectedPearls, collectedLeaves)
    }

    private var collisionCheckCount = 0

    /// Check if an item is within collection radius of the boat
    private func isItemNearBoat(_ item: FallingItem) -> Bool {
        let itemY = getCurrentItemY(item)
        let dx = item.x - boatPosition.x
        let dy = itemY - boatPosition.y
        let distance = sqrt(dx * dx + dy * dy)
        let isNear = distance <= collectionRadius

        // DEBUG: Log first collision check
        if isNear {
            print("[Collision] 🎯 Item near boat! itemPos:(\(item.x), \(itemY)), boatPos:(\(boatPosition.x), \(boatPosition.y)), distance:\(distance), radius:\(collectionRadius)")
        }

        return isNear
    }

    /// Get current Y position of an item (accounting for animation)
    private func getCurrentItemY(_ item: FallingItem) -> CGFloat {
        let elapsed = Date().timeIntervalSince(item.startTime)
        let progress = min(elapsed / item.duration, 1.0)
        return item.y + (item.targetY - item.y) * progress
    }

    // MARK: - Cleanup

    private func cleanupOffscreenItems() {
        // Remove drops and leaves that fell off bottom of screen
        fallingDrops.removeAll { getCurrentItemY($0) > 1.05 }
        fallingLeaves.removeAll { getCurrentItemY($0) > 1.05 }

        // Remove pearls that rose off top of screen (they rise up, not fall)
        fallingPearls.removeAll { getCurrentItemY($0) < -0.05 }
    }

    // MARK: - Cleanup

    deinit {
        // Note: Timers will be invalidated automatically when deallocated
        // Accessing @MainActor properties from deinit is not safe in Swift 6
        // Call stopSpawning() before releasing if cleanup is needed
    }
}

// MARK: - Supporting Types

struct FallingItem: Identifiable {
    let id = UUID()
    var x: CGFloat // Normalized position (0.0 - 1.0) or world offset for scrolling
    var y: CGFloat // Normalized position (0.0 - 1.0)
    let targetY: CGFloat
    let duration: TimeInterval
    var isCollected: Bool = false
    var worldSpawnPosition: CGFloat = 0.0 // For sidescrolling mode

    var startTime: Date = Date()
}
