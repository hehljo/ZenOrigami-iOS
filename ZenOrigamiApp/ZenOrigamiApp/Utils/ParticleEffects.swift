import SwiftUI

/// Particle effects system for visual feedback
@MainActor
struct ParticleEffect: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var velocity: CGVector
    var scale: CGFloat = 1.0
    var opacity: Double = 1.0
    var emoji: String
    var lifetime: TimeInterval
    var age: TimeInterval = 0.0

    var isExpired: Bool {
        age >= lifetime
    }
}

@MainActor
@Observable
class ParticleEffectManager {
    var particles: [ParticleEffect] = []
    private var updateTimer: Timer?

    // MARK: - Lifecycle

    func start() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.updateParticles()
            }
        }
        print("[Particles] ✅ Started particle system")
    }

    func stop() {
        updateTimer?.invalidate()
        updateTimer = nil
        particles.removeAll()
        print("[Particles] ⏸️ Stopped particle system")
    }

    // MARK: - Particle Emission

    /// Emit collection burst at position
    func emitCollectionBurst(at position: CGPoint, emoji: String = "✨") {
        let particleCount = 8

        for i in 0..<particleCount {
            let angle = (CGFloat(i) / CGFloat(particleCount)) * .pi * 2
            let speed: CGFloat = 150.0
            let velocity = CGVector(
                dx: cos(angle) * speed,
                dy: sin(angle) * speed
            )

            let particle = ParticleEffect(
                x: position.x,
                y: position.y,
                velocity: velocity,
                emoji: emoji,
                lifetime: 0.6
            )

            particles.append(particle)
        }

        print("[Particles] 💫 Emitted collection burst at (\(position.x), \(position.y))")
    }

    /// Emit upgrade purchase glow
    func emitUpgradeGlow(at position: CGPoint) {
        for _ in 0..<12 {
            let randomAngle = CGFloat.random(in: 0...(2 * .pi))
            let randomSpeed = CGFloat.random(in: 50...100)
            let velocity = CGVector(
                dx: cos(randomAngle) * randomSpeed,
                dy: sin(randomAngle) * randomSpeed
            )

            let particle = ParticleEffect(
                x: position.x,
                y: position.y,
                velocity: velocity,
                scale: CGFloat.random(in: 0.5...1.5),
                emoji: "⭐",
                lifetime: 1.0
            )

            particles.append(particle)
        }

        print("[Particles] ⭐ Emitted upgrade glow")
    }

    /// Emit achievement unlock confetti
    func emitAchievementConfetti(screenWidth: CGFloat, screenHeight: CGFloat) {
        let emojis = ["🎉", "✨", "🌟", "💫", "⭐"]

        for _ in 0..<30 {
            let randomX = CGFloat.random(in: 0...screenWidth)
            let randomEmoji = emojis.randomElement() ?? "✨"
            let velocity = CGVector(
                dx: CGFloat.random(in: -100...100),
                dy: CGFloat.random(in: -200...(-50))
            )

            let particle = ParticleEffect(
                x: randomX,
                y: screenHeight * 0.3,
                velocity: velocity,
                scale: CGFloat.random(in: 0.8...1.5),
                emoji: randomEmoji,
                lifetime: 2.0
            )

            particles.append(particle)
        }

        print("[Particles] 🎉 Emitted achievement confetti")
    }

    /// Emit idle water ripples
    func emitWaterRipple(at position: CGPoint) {
        for i in 0..<3 {
            let delay = TimeInterval(i) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                let particle = ParticleEffect(
                    x: position.x,
                    y: position.y,
                    velocity: .zero,
                    scale: 1.0 + CGFloat(i) * 0.5,
                    opacity: 0.5 - (Double(i) * 0.15),
                    emoji: "💧",
                    lifetime: 1.5
                )

                self?.particles.append(particle)
            }
        }
    }

    // MARK: - Update Loop

    private func updateParticles() {
        let deltaTime: TimeInterval = 1/60.0

        // Update all particles
        for i in 0..<particles.count {
            particles[i].age += deltaTime

            // Apply physics
            particles[i].x += particles[i].velocity.dx * deltaTime
            particles[i].y += particles[i].velocity.dy * deltaTime

            // Apply gravity (for confetti)
            particles[i].velocity.dy += 500.0 * deltaTime

            // Fade out over lifetime
            let lifetimeProgress = particles[i].age / particles[i].lifetime
            particles[i].opacity = 1.0 - lifetimeProgress
            particles[i].scale = 1.0 + (lifetimeProgress * 0.5)
        }

        // Remove expired particles
        particles.removeAll { $0.isExpired }
    }

    deinit {
        // Note: Timers will be invalidated automatically when deallocated
        // Accessing @MainActor properties from deinit is not safe in Swift 6
        // Call stop() before releasing if cleanup is needed
    }
}

// MARK: - SwiftUI View

struct ParticleEffectView: View {
    let particle: ParticleEffect

    var body: some View {
        Text(particle.emoji)
            .font(.system(size: 20))
            .scaleEffect(particle.scale)
            .opacity(particle.opacity)
            .position(x: particle.x, y: particle.y)
            .allowsHitTesting(false)
    }
}
