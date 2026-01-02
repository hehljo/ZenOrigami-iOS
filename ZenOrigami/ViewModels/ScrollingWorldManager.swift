import Foundation
import SwiftUI

/// Manages horizontal scrolling world with parallax layers
@MainActor
@Observable
class ScrollingWorldManager {
    // MARK: - Scrolling State

    /// Current scroll offset (0.0 = start, increases as boat moves right)
    var scrollOffset: CGFloat = 0.0

    /// Auto-scroll speed (pixels per second)
    var scrollSpeed: CGFloat = 50.0

    /// Whether auto-scrolling is enabled
    var isAutoScrolling: Bool = true

    /// World bounds (total scrollable width)
    let worldWidth: CGFloat = 10000.0

    // MARK: - Parallax Layers

    struct ParallaxLayer: Identifiable {
        let id = UUID()
        let name: String
        let parallaxFactor: CGFloat // 0.0 = static, 1.0 = moves with boat
        let yPosition: CGFloat // Vertical position (0.0 = top, 1.0 = bottom)
        let emoji: String // Placeholder until assets
        let elements: [Element]

        struct Element: Identifiable {
            let id = UUID()
            var xPosition: CGFloat // World position
            let emoji: String
        }
    }

    var backgroundLayers: [ParallaxLayer] = []

    // MARK: - Boat State

    /// Boat position in world coordinates
    var boatWorldPosition: CGFloat = 0.0

    /// Boat vertical position (0.0 = top, 1.0 = bottom)
    var boatYPosition: CGFloat = 0.75

    /// Boat rocking angle (-10° to +10°)
    var boatRockingAngle: CGFloat = 0.0

    private var scrollTimer: Timer?
    private var rockingTimer: Timer?

    // MARK: - Initialization

    init() {
        setupBackgroundLayers()
    }

    private func setupBackgroundLayers() {
        // Layer 1: Far Mountains (slowest)
        backgroundLayers.append(ParallaxLayer(
            name: "far_mountains",
            parallaxFactor: 0.2,
            yPosition: 0.3,
            emoji: "🏔️",
            elements: generateRandomElements(count: 5, spacing: 2000, emoji: "🏔️")
        ))

        // Layer 2: Near Mountains
        backgroundLayers.append(ParallaxLayer(
            name: "near_mountains",
            parallaxFactor: 0.4,
            yPosition: 0.4,
            emoji: "⛰️",
            elements: generateRandomElements(count: 8, spacing: 1200, emoji: "⛰️")
        ))

        // Layer 3: Clouds
        backgroundLayers.append(ParallaxLayer(
            name: "clouds",
            parallaxFactor: 0.3,
            yPosition: 0.15,
            emoji: "☁️",
            elements: generateRandomElements(count: 15, spacing: 600, emoji: "☁️")
        ))

        // Layer 4: Trees/Shore
        backgroundLayers.append(ParallaxLayer(
            name: "shore",
            parallaxFactor: 0.6,
            yPosition: 0.7,
            emoji: "🌲",
            elements: generateRandomElements(count: 30, spacing: 300, emoji: "🌲")
        ))
    }

    private func generateRandomElements(count: Int, spacing: CGFloat, emoji: String) -> [ParallaxLayer.Element] {
        var elements: [ParallaxLayer.Element] = []
        for i in 0..<count {
            let baseX = CGFloat(i) * spacing
            let randomOffset = CGFloat.random(in: -50...50)
            elements.append(ParallaxLayer.Element(
                xPosition: baseX + randomOffset,
                emoji: emoji
            ))
        }
        return elements
    }

    // MARK: - Scrolling Control

    func startScrolling(speed: CGFloat = 50.0) {
        scrollSpeed = speed
        isAutoScrolling = true

        scrollTimer?.invalidate()
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateScrolling()
            }
        }

        print("[ScrollingWorld] ✅ Started scrolling (speed: \(speed) px/s)")
    }

    func stopScrolling() {
        isAutoScrolling = false
        scrollTimer?.invalidate()
        scrollTimer = nil
        print("[ScrollingWorld] ⏸️ Stopped scrolling")
    }

    private func updateScrolling() {
        guard isAutoScrolling else { return }

        let deltaTime: CGFloat = 1/60.0
        let movement = scrollSpeed * deltaTime

        scrollOffset += movement
        boatWorldPosition += movement

        // Wrap around at world end
        if scrollOffset > worldWidth {
            scrollOffset = 0
            boatWorldPosition = 0
        }
    }

    // MARK: - Boat Animation

    func startBoatRocking() {
        rockingTimer?.invalidate()
        rockingTimer = Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateBoatRocking()
            }
        }
        print("[ScrollingWorld] 🚤 Started boat rocking")
    }

    func stopBoatRocking() {
        rockingTimer?.invalidate()
        rockingTimer = nil
        boatRockingAngle = 0
        print("[ScrollingWorld] 🚤 Stopped boat rocking")
    }

    private var rockingPhase: CGFloat = 0.0

    private func updateBoatRocking() {
        rockingPhase += 0.05
        boatRockingAngle = sin(rockingPhase) * 5.0 // ±5 degrees
    }

    // MARK: - Camera Position

    /// Get screen offset for a layer based on parallax factor
    func getLayerOffset(parallaxFactor: CGFloat, screenWidth: CGFloat) -> CGFloat {
        // Camera follows boat, but layers move at different speeds
        let cameraX = boatWorldPosition - (screenWidth * 0.3) // Boat at 30% from left
        return -cameraX * parallaxFactor
    }

    /// Get visible elements for a layer (optimization)
    func getVisibleElements(for layer: ParallaxLayer, screenWidth: CGFloat) -> [ParallaxLayer.Element] {
        let cameraX = boatWorldPosition - (screenWidth * 0.3)
        let visibleRange = (cameraX - 200)...(cameraX + screenWidth + 200)

        return layer.elements.filter { element in
            visibleRange.contains(element.xPosition)
        }
    }

    // MARK: - Manual Control

    func setBoatYPosition(_ newY: CGFloat) {
        boatYPosition = max(0.1, min(0.9, newY))
    }

    func adjustScrollSpeed(multiplier: CGFloat) {
        scrollSpeed *= multiplier
        print("[ScrollingWorld] 🏎️ Speed adjusted: \(scrollSpeed) px/s")
    }

    // MARK: - Cleanup

    deinit {
        scrollTimer?.invalidate()
        rockingTimer?.invalidate()
    }
}
