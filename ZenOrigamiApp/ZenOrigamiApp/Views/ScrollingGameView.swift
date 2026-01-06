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
    @State private var showAchievements = false
    @State private var showMoreMenu = false
    @State private var autoCollectionTimer: Timer?
    @State private var screenSize: CGSize = .zero

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
                    FallingItemView(
                        item: item,
                        assetName: "drop",
                        screenWidth: geometry.size.width,
                        screenHeight: geometry.size.height
                    )
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
                    FallingItemView(
                        item: item,
                        assetName: "pearl",
                        screenWidth: geometry.size.width,
                        screenHeight: geometry.size.height
                    )
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
                    FallingItemView(
                        item: item,
                        assetName: "leaf",
                        screenWidth: geometry.size.width,
                        screenHeight: geometry.size.height
                    )
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

                // UI Overlay
                VStack(spacing: 0) {
                    // MARK: - Header (Top HUD)
                    VStack(spacing: 8) {
                        HStack {
                            // Currency Display
                            CurrencyDisplayView(currencies: viewModel.gameState.currencies)

                            Spacer()

                            // Settings only (iOS Best Practice)
                            MenuButton(icon: "gearshape.fill") {
                                HapticFeedback.selection()
                                showSettings = true
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // Idle Status Indicator (if Rain Collector active)
                        if viewModel.gameState.upgrades.collector > 0 {
                            IdleStatusIndicator(
                                isIdle: scrollingWorld.scrollSpeed < 10,
                                collectorLevel: viewModel.gameState.upgrades.collector
                            )
                            .padding(.horizontal)
                        }
                    }

                    Spacer()

                    // MARK: - Footer (Bottom Bar) - iOS Best Practice 2026
                    HStack(spacing: 12) {
                        // Large Upgrades Button (Primary Action)
                        Button {
                            HapticFeedback.selection()
                            showUpgrades = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title3)
                                Text("Upgrades")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                        }

                        // Icon Buttons (Secondary Actions)
                        BottomBarButton(
                            icon: "star.fill",
                            isHighlighted: canPrestige(),
                            action: {
                                HapticFeedback.selection()
                                showPrestige = true
                            }
                        )

                        BottomBarButton(
                            icon: "rosette",
                            action: {
                                HapticFeedback.selection()
                                showAchievements = true
                            }
                        )

                        BottomBarButton(
                            icon: "chart.bar.fill",
                            action: {
                                HapticFeedback.selection()
                                showStatistics = true
                            }
                        )

                        // More Menu Button
                        Menu {
                            Button {
                                showDailyReward = true
                            } label: {
                                Label("Daily Reward", systemImage: "gift.fill")
                            }

                            Divider()

                            Button {
                                // Speed indicator toggle
                            } label: {
                                Label("Speed: \(String(format: "%.0f px/s", scrollingWorld.scrollSpeed))", systemImage: "speedometer")
                            }
                            .disabled(true)
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.title3)
                                .foregroundStyle(.primary)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                screenSize = geometry.size
            }
            .onChange(of: geometry.size) { _, newSize in
                screenSize = newSize
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
        .sheet(isPresented: $showAchievements) {
            AchievementsView(gameState: viewModel.gameState)
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

            // Auto-collection timer (runs every 0.1s)
            autoCollectionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                Task { @MainActor in
                    autoCollectItems()
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

    private func calculateItemScreenX(item: FallingItem, screenWidth: CGFloat) -> CGFloat {
        // Items spawn relative to boat's world position
        let itemWorldX = scrollingWorld.boatWorldPosition + (item.x * screenWidth) - (screenWidth * 0.3)
        let cameraX = scrollingWorld.boatWorldPosition - (screenWidth * 0.3)
        return (itemWorldX - cameraX) - (screenWidth / 2)
    }

    private func getCollectionRadius() -> CGFloat {
        let radiusLevel = viewModel.gameState.upgrades.radius
        let baseRadius: CGFloat = 100.0
        let radiusMultiplier = 1.0 + (CGFloat(radiusLevel) * 0.2)
        return baseRadius * radiusMultiplier
    }

    private func autoCollectItems() {
        guard screenSize != .zero else { return }

        let boatX = screenSize.width * 0.3
        let boatY = screenSize.height * 0.5
        let radius = getCollectionRadius()

        // Auto-collect drops within radius
        for item in fallingItemManager.fallingDrops {
            let itemScreenX = calculateItemScreenX(item: item, screenWidth: screenSize.width)
            let itemScreenY = item.y * screenSize.height
            let distance = hypot(itemScreenX - boatX, itemScreenY - boatY)

            if distance <= radius / 2 {
                if fallingItemManager.collectDrop(at: item.id) {
                    viewModel.collect(currency: .drop, amount: 1)
                }
            }
        }

        // Auto-collect pearls within radius
        for item in fallingItemManager.fallingPearls {
            let itemScreenX = calculateItemScreenX(item: item, screenWidth: screenSize.width)
            let itemScreenY = item.y * screenSize.height
            let distance = hypot(itemScreenX - boatX, itemScreenY - boatY)

            if distance <= radius / 2 {
                if fallingItemManager.collectPearl(at: item.id) {
                    viewModel.collect(currency: .pearl, amount: 1)
                }
            }
        }

        // Auto-collect leaves within radius
        for item in fallingItemManager.fallingLeaves {
            let itemScreenX = calculateItemScreenX(item: item, screenWidth: screenSize.width)
            let itemScreenY = item.y * screenSize.height
            let distance = hypot(itemScreenX - boatX, itemScreenY - boatY)

            if distance <= radius / 2 {
                if fallingItemManager.collectLeaf(at: item.id) {
                    viewModel.collect(currency: .leaf, amount: 1)
                }
            }
        }
    }

    private func canPrestige() -> Bool {
        let totalDrops = viewModel.gameState.totalCollected.drop
        return totalDrops >= 10000 // Minimum drops for prestige
    }
}

// MARK: - Bottom Bar Button Component

struct BottomBarButton: View {
    let icon: String
    var isHighlighted: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(isHighlighted ? Color.amber : .primary)
                .frame(width: 44, height: 44)
                .background {
                    if isHighlighted {
                        Color.amber.opacity(0.2)
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
                .clipShape(Circle())
                .shadow(radius: 2)
                .overlay {
                    if isHighlighted {
                        Circle()
                            .stroke(Color.amber, lineWidth: 2)
                    }
                }
        }
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
    }
}

// MARK: - Idle Status Indicator Component

struct IdleStatusIndicator: View {
    let isIdle: Bool
    let collectorLevel: Int

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isIdle ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
                .shadow(color: isIdle ? .green : .orange, radius: 4)

            Text(isIdle ? "Idle Collecting" : "Active")
                .font(.caption)
                .foregroundStyle(.white)

            Text("Lv.\(collectorLevel)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

// MARK: - Color Extension

extension Color {
    static let amber = Color(red: 1.0, green: 0.75, blue: 0.0)
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
