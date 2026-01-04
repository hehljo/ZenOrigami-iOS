import SwiftUI

/// New sidescrolling game view with parallax background
struct ScrollingGameView: View {
    @Bindable var viewModel: GameViewModel
    @State private var fallingItemManager = FallingItemManager()
    @State private var scrollingWorld = ScrollingWorldManager()
    @State private var showUpgrades = false
    @State private var showSettings = false
    @State private var showStatistics = false
    @State private var showDailyReward = false
    @State private var showPrestige = false
    @State private var showTutorial = false
    @State private var autoCollectionTimer: Timer?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Scrolling parallax background
                ParallaxBackgroundView(
                    scrollingWorld: scrollingWorld,
                    screenWidth: geometry.size.width,
                    screenHeight: geometry.size.height
                )

                // Falling items (positioned in world coordinates)
                ForEach(fallingItemManager.fallingDrops) { item in
                    FallingItemView(item: item, emoji: "💧")
                        .offset(x: calculateItemScreenX(item: item, geometry: geometry))
                        .onTapGesture {
                            if fallingItemManager.collectDrop(at: item.id) {
                                viewModel.collect(currency: .drop, amount: 1)
                                SoundManager.shared.playDropCollect()
                                HapticFeedback.light()
                            }
                        }
                }

                ForEach(fallingItemManager.fallingPearls) { item in
                    FallingItemView(item: item, emoji: "🔵")
                        .offset(x: calculateItemScreenX(item: item, geometry: geometry))
                        .onTapGesture {
                            if fallingItemManager.collectPearl(at: item.id) {
                                viewModel.collect(currency: .pearl, amount: 1)
                                SoundManager.shared.playPearlCollect()
                                HapticFeedback.light()
                            }
                        }
                }

                ForEach(fallingItemManager.fallingLeaves) { item in
                    FallingItemView(item: item, emoji: "🍃")
                        .offset(x: calculateItemScreenX(item: item, geometry: geometry))
                        .onTapGesture {
                            if fallingItemManager.collectLeaf(at: item.id) {
                                viewModel.collect(currency: .leaf, amount: 1)
                                SoundManager.shared.playLeafCollect()
                                HapticFeedback.light()
                            }
                        }
                }

                // Collection radius (visual feedback)
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(
                        width: getCollectionRadius(),
                        height: getCollectionRadius()
                    )
                    .position(
                        x: geometry.size.width * 0.3,
                        y: geometry.size.height * 0.5
                    )

                // Boat (fixed position, auto-scrolling)
                BoatView(skin: viewModel.gameState.activeSkin)
                    .rotationEffect(.degrees(scrollingWorld.boatRockingAngle))
                    .position(
                        x: geometry.size.width * 0.3, // Fixed at 30% from left
                        y: geometry.size.height * 0.5 // Fixed vertically centered
                    )

                // Companions (follow boat at fixed position)
                if viewModel.gameState.companions.origamiFish {
                    Text("🐟")
                        .font(.system(size: 32))
                        .position(
                            x: (geometry.size.width * 0.3) - 40,
                            y: (geometry.size.height * 0.5) + 20
                        )
                }

                if viewModel.gameState.companions.origamiBird {
                    Text("🐦")
                        .font(.system(size: 32))
                        .position(
                            x: (geometry.size.width * 0.3) + 40,
                            y: (geometry.size.height * 0.5) - 40
                        )
                }

                // Top HUD (same as before)
                VStack {
                    HStack {
                        CurrencyDisplayView(currencies: viewModel.gameState.currencies)

                        Spacer()

                        HStack(spacing: 12) {
                            MenuButton(icon: "gift.fill") {
                                HapticFeedback.selection()
                                showDailyReward = true
                            }

                            MenuButton(icon: "star.fill") {
                                HapticFeedback.selection()
                                showPrestige = true
                            }

                            MenuButton(icon: "chart.bar.fill") {
                                HapticFeedback.selection()
                                showStatistics = true
                            }

                            MenuButton(icon: "gearshape.fill") {
                                HapticFeedback.selection()
                                showSettings = true
                            }
                        }
                    }
                    .padding()

                    Spacer()

                    // Speed indicator
                    HStack {
                        Text("🏎️")
                        Text(String(format: "%.0f px/s", scrollingWorld.scrollSpeed))
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .padding()

                    Spacer()

                    // Bottom UI
                    VStack {
                        Spacer()

                        Button {
                            HapticFeedback.selection()
                            showUpgrades = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.circle.fill")
                                Text("Upgrades")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .sheet(isPresented: $showUpgrades) {
            UpgradeSheetView(viewModel: viewModel)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showStatistics) {
            StatisticsView(gameState: viewModel.gameState)
        }
        .sheet(isPresented: $showDailyReward) {
            DailyRewardView(viewModel: viewModel)
        }
        .sheet(isPresented: $showPrestige) {
            PrestigeView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView()
        }
        .sheet(isPresented: $viewModel.showWelcomeBack) {
            WelcomeBackView(
                offlineEarnings: viewModel.offlineEarnings ?? 0,
                minutesOffline: viewModel.minutesOffline
            )
        }
        .onAppear {
            // Start all systems
            fallingItemManager.startSpawning()
            scrollingWorld.startScrolling(speed: 50.0)
            scrollingWorld.startBoatRocking()

            // Apply speed upgrades
            let speedLevel = viewModel.gameState.upgrades.speed
            let speedMultiplier = 1.0 + (Double(speedLevel) * 0.1)
            scrollingWorld.scrollSpeed = 50.0 * speedMultiplier

            // Apply drop rate upgrades (spawn interval)
            let dropRateLevel = viewModel.gameState.upgrades.rate
            let spawnInterval = max(0.5, 2.0 - (Double(dropRateLevel) * 0.1))
            fallingItemManager = FallingItemManager(spawnInterval: spawnInterval)
            fallingItemManager.startSpawning()

            // Auto-collection timer
            autoCollectionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.autoCollectItems(geometry: geometry)
                }
            }

            // Show tutorial for first-time users
            if !UserDefaults.standard.bool(forKey: "hasSeenTutorial") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showTutorial = true
                }
            }
        }
        .onDisappear {
            autoCollectionTimer?.invalidate()
            autoCollectionTimer = nil
            fallingItemManager.stopSpawning()
            scrollingWorld.stopScrolling()
            scrollingWorld.stopBoatRocking()
        }
    }

    // MARK: - Helper Methods

    private func calculateItemScreenX(item: FallingItem, geometry: GeometryProxy) -> CGFloat {
        // Items spawn relative to boat's world position
        let itemWorldX = scrollingWorld.boatWorldPosition + (item.x * geometry.size.width) - (geometry.size.width * 0.3)
        let cameraX = scrollingWorld.boatWorldPosition - (geometry.size.width * 0.3)
        return (itemWorldX - cameraX) - (geometry.size.width / 2)
    }

    private func getCollectionRadius() -> CGFloat {
        let radiusLevel = viewModel.gameState.upgrades.radius
        let baseRadius: CGFloat = 100.0
        let radiusMultiplier = 1.0 + (CGFloat(radiusLevel) * 0.2)
        return baseRadius * radiusMultiplier
    }

    private func autoCollectItems(geometry: GeometryProxy) {
        let boatX = geometry.size.width * 0.3
        let boatY = geometry.size.height * 0.5
        let radius = getCollectionRadius()

        // Auto-collect drops within radius
        for item in fallingItemManager.fallingDrops {
            let itemScreenX = calculateItemScreenX(item: item, geometry: geometry)
            let itemScreenY = item.y * geometry.size.height
            let distance = hypot(itemScreenX - boatX, itemScreenY - boatY)

            if distance <= radius / 2 {
                if fallingItemManager.collectDrop(at: item.id) {
                    viewModel.collect(currency: .drop, amount: 1)
                }
            }
        }

        // Auto-collect pearls within radius
        for item in fallingItemManager.fallingPearls {
            let itemScreenX = calculateItemScreenX(item: item, geometry: geometry)
            let itemScreenY = item.y * geometry.size.height
            let distance = hypot(itemScreenX - boatX, itemScreenY - boatY)

            if distance <= radius / 2 {
                if fallingItemManager.collectPearl(at: item.id) {
                    viewModel.collect(currency: .pearl, amount: 1)
                }
            }
        }

        // Auto-collect leaves within radius
        for item in fallingItemManager.fallingLeaves {
            let itemScreenX = calculateItemScreenX(item: item, geometry: geometry)
            let itemScreenY = item.y * geometry.size.height
            let distance = hypot(itemScreenX - boatX, itemScreenY - boatY)

            if distance <= radius / 2 {
                if fallingItemManager.collectLeaf(at: item.id) {
                    viewModel.collect(currency: .leaf, amount: 1)
                }
            }
        }
    }
}

// MARK: - Parallax Background View

struct ParallaxBackgroundView: View {
    let scrollingWorld: ScrollingWorldManager
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    var body: some View {
        ZStack {
            // Base gradient (sky/water)
            LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.8, blue: 0.9),
                    Color(red: 0.4, green: 0.7, blue: 0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Parallax layers
            ForEach(scrollingWorld.backgroundLayers) { layer in
                ParallaxLayerView(
                    layer: layer,
                    scrollingWorld: scrollingWorld,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )
            }
        }
    }
}

struct ParallaxLayerView: View {
    let layer: ScrollingWorldManager.ParallaxLayer
    let scrollingWorld: ScrollingWorldManager
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    var body: some View {
        let offset = scrollingWorld.getLayerOffset(
            parallaxFactor: layer.parallaxFactor,
            screenWidth: screenWidth
        )
        let visibleElements = scrollingWorld.getVisibleElements(
            for: layer,
            screenWidth: screenWidth
        )

        GeometryReader { _ in
            ForEach(visibleElements) { element in
                Text(element.emoji)
                    .font(.system(size: 40))
                    .position(
                        x: element.xPosition + offset,
                        y: screenHeight * layer.yPosition
                    )
            }
        }
    }
}

// MARK: - Menu Button Component

struct MenuButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }
}

#Preview {
    ScrollingGameView(viewModel: GameViewModel(
        databaseService: DatabaseService(
            supabaseURL: "https://example.supabase.co",
            supabaseKey: "test-key"
        ),
        authService: AuthService(
            supabaseURL: "https://example.supabase.co",
            supabaseKey: "test-key"
        )
    ))
}
