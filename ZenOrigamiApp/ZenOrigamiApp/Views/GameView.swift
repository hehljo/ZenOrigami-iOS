import SwiftUI

/// Main gameplay screen with falling items and boat
struct GameView: View {
    @Bindable var viewModel: GameViewModel
    @State private var fallingItemManager = FallingItemManager()
    @State private var boatPosition: CGFloat = 0.5
    @State private var boatY: CGFloat = 0.6  // At water surface line
    @State private var showUpgrades = false
    @State private var showSettings = false
    @State private var showStatistics = false
    @State private var showDailyReward = false
    @State private var showPrestige = false
    @State private var showTutorial = false
    @State private var collisionCheckTimer: Timer?

    var body: some View {
        ZStack {
            // Quiet Luxury sky gradient
            QuietLuxuryTheme.skyGradient
                .ignoresSafeArea()

            // Parallax background layers
            GeometryReader { geometry in
                // Clouds (slowest)
                Image("parallax_clouds")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.3)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.2)
                    .opacity(0.4)

                // Far mountains
                Image("parallax_mountains_far")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.35)
                    .opacity(0.5)

                // Near mountains
                Image("parallax_mountains_near")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.35)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.48)
                    .opacity(0.6)

                // Trees/Shore (fastest - foreground)
                Image("parallax_trees")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.25)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.85)
                    .opacity(0.3)
            }

            // Water surface line (at 60% down the screen)
            GeometryReader { geometry in
                VStack {
                    Spacer()
                        .frame(height: geometry.size.height * 0.6)

                    // Quiet Luxury water gradient (zen-inspired)
                    QuietLuxuryTheme.waterGradient

                    Spacer()
                }
                .ignoresSafeArea()

                // Water surface shimmer line
                Rectangle()
                    .fill(Color.white.opacity(0.4))
                    .frame(height: 2)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.6)
                    .blur(radius: 1)
            }

            // Game elements
            GeometryReader { geometry in
                ZStack {
                    // Falling Drops
                    ForEach(fallingItemManager.fallingDrops) { item in
                        FallingItemView(
                            item: item,
                            assetName: "drop",
                            screenWidth: geometry.size.width,
                            screenHeight: geometry.size.height
                        )
                        .onTapGesture {
                            if fallingItemManager.collectDrop(at: item.id) {
                                viewModel.collect(currency: .drop, amount: 1)
                                SoundManager.shared.playDropCollect()
                                HapticFeedback.light()
                            }
                        }
                    }

                    // Falling Pearls
                    ForEach(fallingItemManager.fallingPearls) { item in
                        FallingItemView(
                            item: item,
                            assetName: "pearl",
                            screenWidth: geometry.size.width,
                            screenHeight: geometry.size.height
                        )
                        .onTapGesture {
                            if fallingItemManager.collectPearl(at: item.id) {
                                viewModel.collect(currency: .pearl, amount: 1)
                                SoundManager.shared.playPearlCollect()
                                HapticFeedback.light()
                            }
                        }
                    }

                    // Falling Leaves
                    ForEach(fallingItemManager.fallingLeaves) { item in
                        FallingItemView(
                            item: item,
                            assetName: "leaf",
                            screenWidth: geometry.size.width,
                            screenHeight: geometry.size.height
                        )
                        .onTapGesture {
                            if fallingItemManager.collectLeaf(at: item.id) {
                                viewModel.collect(currency: .leaf, amount: 1)
                                SoundManager.shared.playLeafCollect()
                                HapticFeedback.light()
                            }
                        }
                    }

                    // Boat (Player)
                    BoatView(skin: viewModel.gameState.activeSkin)
                        .position(
                            x: boatPosition * geometry.size.width,
                            y: geometry.size.height * boatY
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    boatPosition = max(0.1, min(0.9, value.location.x / geometry.size.width))
                                    // Update boat position in collision manager
                                    fallingItemManager.boatPosition = CGPoint(x: boatPosition, y: boatY)
                                }
                        )
                        .onChange(of: boatPosition) { _, newPosition in
                            // Update collision manager when boat moves
                            fallingItemManager.boatPosition = CGPoint(x: newPosition, y: boatY)
                        }

                    // Companions
                    if viewModel.gameState.companions.origamiFish {
                        Image("companion_fish")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .fishSwimming()
                            .position(
                                x: (boatPosition * geometry.size.width) - 40,
                                y: (geometry.size.height * 0.75) + 20
                            )
                    }

                    if viewModel.gameState.companions.origamiBird {
                        Image("companion_bird")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .birdHovering()
                            .position(
                                x: (boatPosition * geometry.size.width) + 40,
                                y: (geometry.size.height * 0.75) - 40
                            )
                    }
                }
            }

            // Top HUD
            VStack {
                HStack {
                    // Currency Display
                    CurrencyDisplayView(currencies: viewModel.gameState.currencies)

                    Spacer()

                    // Menu Buttons (Quiet Luxury)
                    HStack(spacing: QuietLuxuryTheme.Spacing.sm) {
                        Button {
                            HapticFeedback.selection()
                            showDailyReward = true
                        } label: {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 18, weight: .light))
                                .foregroundStyle(QuietLuxuryTheme.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(QuietLuxuryTheme.surface.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: QuietLuxuryTheme.charcoal.opacity(0.08), radius: 4, x: 0, y: 2)
                        }

                        Button {
                            HapticFeedback.selection()
                            showPrestige = true
                        } label: {
                            Image(systemName: "star.fill")
                                .font(.system(size: 18, weight: .light))
                                .foregroundStyle(QuietLuxuryTheme.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(QuietLuxuryTheme.surface.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: QuietLuxuryTheme.charcoal.opacity(0.08), radius: 4, x: 0, y: 2)
                        }

                        Button {
                            HapticFeedback.selection()
                            showStatistics = true
                        } label: {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 18, weight: .light))
                                .foregroundStyle(QuietLuxuryTheme.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(QuietLuxuryTheme.surface.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: QuietLuxuryTheme.charcoal.opacity(0.08), radius: 4, x: 0, y: 2)
                        }

                        Button {
                            HapticFeedback.selection()
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .light))
                                .foregroundStyle(QuietLuxuryTheme.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(QuietLuxuryTheme.surface.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: QuietLuxuryTheme.charcoal.opacity(0.08), radius: 4, x: 0, y: 2)
                        }
                    }
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
                        HStack(spacing: QuietLuxuryTheme.Spacing.xs) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Upgrades")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .quietLuxuryButton(style: .primary, size: .medium)
                    }
                    .padding(.bottom, QuietLuxuryTheme.Spacing.xl)
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
            fallingItemManager.startSpawning()

            // Initialize boat position in collision manager
            fallingItemManager.boatPosition = CGPoint(x: boatPosition, y: boatY)

            // Start collision checking timer (60 FPS)
            collisionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
                let collisions = fallingItemManager.checkCollisions()

                // Auto-collect drops
                for dropId in collisions.drops {
                    if fallingItemManager.collectDrop(at: dropId) {
                        viewModel.collect(currency: .drop, amount: 1)
                        SoundManager.shared.playDropCollect()
                        HapticFeedback.light()
                    }
                }

                // Auto-collect pearls
                for pearlId in collisions.pearls {
                    if fallingItemManager.collectPearl(at: pearlId) {
                        viewModel.collect(currency: .pearl, amount: 1)
                        SoundManager.shared.playPearlCollect()
                        HapticFeedback.light()
                    }
                }

                // Auto-collect leaves
                for leafId in collisions.leaves {
                    if fallingItemManager.collectLeaf(at: leafId) {
                        viewModel.collect(currency: .leaf, amount: 1)
                        SoundManager.shared.playLeafCollect()
                        HapticFeedback.light()
                    }
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
            fallingItemManager.stopSpawning()
            collisionCheckTimer?.invalidate()
            collisionCheckTimer = nil
        }
    }
}

struct BoatView: View {
    let skin: Skin

    var body: some View {
        if skin == .default {
            Image("boat_default")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)  // Increased from 80 to 120
                .boatRocking()  // Apply gentle wave animation
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 3)
        } else {
            Image("boat_swan")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)  // Increased from 80 to 120
                .swanGliding()  // Smoother gliding animation
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 3)
        }
    }
}

#Preview {
    GameView(viewModel: GameViewModel(
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
