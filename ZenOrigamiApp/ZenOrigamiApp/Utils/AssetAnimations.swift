import SwiftUI

/// Animation library for game assets
/// Provides reusable animation modifiers for different asset types
enum AssetAnimations {

    // MARK: - Boat Animations

    /// Gentle rocking motion for boats (wave simulation)
    struct BoatRocking: ViewModifier {
        @State private var angle: Double = 0
        @State private var yOffset: Double = 0

        let rockingAngle: Double
        let wavePeriod: Double

        init(rockingAngle: Double = 2.0, wavePeriod: Double = 4.0) {  // Slower, more cozy
            self.rockingAngle = rockingAngle
            self.wavePeriod = wavePeriod
        }

        func body(content: Content) -> some View {
            content
                .rotationEffect(.degrees(angle))
                .offset(y: yOffset)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: wavePeriod)
                        .repeatForever(autoreverses: true)
                    ) {
                        angle = rockingAngle
                    }

                    withAnimation(
                        .easeInOut(duration: wavePeriod * 0.8)
                        .repeatForever(autoreverses: true)
                    ) {
                        yOffset = 5
                    }
                }
        }
    }

    /// Swan gliding animation (smoother than default boat)
    struct SwanGliding: ViewModifier {
        @State private var angle: Double = 0
        @State private var yOffset: Double = 0

        func body(content: Content) -> some View {
            content
                .rotationEffect(.degrees(angle))
                .offset(y: yOffset)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 5.0)  // Slower, more elegant
                        .repeatForever(autoreverses: true)
                    ) {
                        angle = 1.0  // Less angle for cozy feel
                    }

                    withAnimation(
                        .easeInOut(duration: 4.5)  // Slower vertical motion
                        .repeatForever(autoreverses: true)
                    ) {
                        yOffset = 3
                    }
                }
        }
    }

    // MARK: - Falling Item Animations

    /// Water drop falling (no rotation - smooth cozy)
    struct DropFalling: ViewModifier {
        func body(content: Content) -> some View {
            content  // No animation - just falls smoothly
        }
    }

    /// Pearl falling with subtle shimmer (quiet luxury)
    struct PearlFalling: ViewModifier {
        @State private var scale: Double = 1.0
        @State private var opacity: Double = 1.0

        func body(content: Content) -> some View {
            content
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 1.5)  // Slower, more elegant
                        .repeatForever(autoreverses: true)
                    ) {
                        scale = 1.08  // Subtle effect
                        opacity = 0.9  // Less opacity change
                    }
                }
        }
    }

    /// Leaf falling with gentle flutter (cozy)
    struct LeafFluttering: ViewModifier {
        @State private var rotation: Double = 0
        @State private var xOffset: Double = 0

        func body(content: Content) -> some View {
            content
                .rotationEffect(.degrees(rotation))
                .offset(x: xOffset)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 2.5)  // Slower, more gentle
                        .repeatForever(autoreverses: true)
                    ) {
                        rotation = 10  // Less rotation
                        xOffset = 6  // Less horizontal movement
                    }
                }
        }
    }

    // MARK: - Companion Animations

    /// Fish swimming motion (smooth and calm)
    struct FishSwimming: ViewModifier {
        @State private var yOffset: Double = 0
        @State private var xOffset: Double = 0

        func body(content: Content) -> some View {
            content
                .offset(x: xOffset, y: yOffset)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 3.0)  // Slower swimming
                        .repeatForever(autoreverses: true)
                    ) {
                        yOffset = 6  // Less vertical movement
                    }

                    withAnimation(
                        .easeInOut(duration: 4.5)  // Very slow horizontal
                        .repeatForever(autoreverses: true)
                    ) {
                        xOffset = 4  // Subtle movement
                    }
                }
        }
    }

    /// Bird hovering motion (gentle and calm)
    struct BirdHovering: ViewModifier {
        @State private var yOffset: Double = 0
        @State private var wingFlap: Double = 1.0

        func body(content: Content) -> some View {
            content
                .offset(y: yOffset)
                .scaleEffect(y: wingFlap)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 2.5)  // Slower hovering
                        .repeatForever(autoreverses: true)
                    ) {
                        yOffset = -8  // Less vertical movement
                    }

                    withAnimation(
                        .easeInOut(duration: 0.6)  // Slower wing flap
                        .repeatForever(autoreverses: true)
                    ) {
                        wingFlap = 1.03  // Subtle wing movement
                    }
                }
        }
    }

    // MARK: - Particle Effects

    /// Collect sparkles burst (subtle and elegant)
    struct CollectSparkles: ViewModifier {
        @State private var opacity: Double = 1.0
        @State private var scale: Double = 0.5
        @State private var rotation: Double = 0

        let onComplete: () -> Void

        func body(content: Content) -> some View {
            content
                .opacity(opacity)
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.easeOut(duration: 1.2)) {  // Slower, more graceful
                        opacity = 0
                        scale = 1.8  // Less dramatic
                        rotation = 90  // Less rotation
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        onComplete()
                    }
                }
        }
    }

    /// Water splash effect (gentle)
    struct WaterSplash: ViewModifier {
        @State private var opacity: Double = 1.0
        @State private var yOffset: Double = 0

        let onComplete: () -> Void

        func body(content: Content) -> some View {
            content
                .opacity(opacity)
                .offset(y: yOffset)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0)) {  // Slower splash
                        opacity = 0
                        yOffset = -20  // Less dramatic movement
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        onComplete()
                    }
                }
        }
    }

    // MARK: - Idle Animations

    /// Flag waving (gentle breeze)
    struct FlagWaving: ViewModifier {
        @State private var wavePhase: Double = 0

        func body(content: Content) -> some View {
            content
                .rotationEffect(.degrees(sin(wavePhase) * 3))  // Less movement
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.8)  // Slower waving
                        .repeatForever(autoreverses: false)
                    ) {
                        wavePhase = .pi * 2
                    }
                }
        }
    }

    /// Achievement star rotation (subtle elegance)
    struct StarRotation: ViewModifier {
        @State private var rotation: Double = 0
        @State private var scale: Double = 1.0

        func body(content: Content) -> some View {
            content
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(
                        .linear(duration: 8.0)  // Much slower rotation
                        .repeatForever(autoreverses: false)
                    ) {
                        rotation = 360
                    }

                    withAnimation(
                        .easeInOut(duration: 2.5)  // Slower pulsing
                        .repeatForever(autoreverses: true)
                    ) {
                        scale = 1.05  // Subtle scale change
                    }
                }
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply boat rocking animation
    func boatRocking(angle: Double = 3.0, period: Double = 2.5) -> some View {
        modifier(AssetAnimations.BoatRocking(rockingAngle: angle, wavePeriod: period))
    }

    /// Apply swan gliding animation
    func swanGliding() -> some View {
        modifier(AssetAnimations.SwanGliding())
    }

    /// Apply drop falling animation
    func dropFalling() -> some View {
        modifier(AssetAnimations.DropFalling())
    }

    /// Apply pearl falling animation
    func pearlFalling() -> some View {
        modifier(AssetAnimations.PearlFalling())
    }

    /// Apply leaf fluttering animation
    func leafFluttering() -> some View {
        modifier(AssetAnimations.LeafFluttering())
    }

    /// Apply fish swimming animation
    func fishSwimming() -> some View {
        modifier(AssetAnimations.FishSwimming())
    }

    /// Apply bird hovering animation
    func birdHovering() -> some View {
        modifier(AssetAnimations.BirdHovering())
    }

    /// Apply collect sparkles effect
    func collectSparkles(onComplete: @escaping () -> Void) -> some View {
        modifier(AssetAnimations.CollectSparkles(onComplete: onComplete))
    }

    /// Apply water splash effect
    func waterSplash(onComplete: @escaping () -> Void) -> some View {
        modifier(AssetAnimations.WaterSplash(onComplete: onComplete))
    }

    /// Apply flag waving animation
    func flagWaving() -> some View {
        modifier(AssetAnimations.FlagWaving())
    }

    /// Apply star rotation animation
    func starRotation() -> some View {
        modifier(AssetAnimations.StarRotation())
    }
}
