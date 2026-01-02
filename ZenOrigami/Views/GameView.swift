import SwiftUI

/// Main gameplay screen with falling items and boat
struct GameView: View {
    @Bindable var viewModel: GameViewModel
    @State private var fallingItemManager = FallingItemManager()
    @State private var boatPosition: CGFloat = 0.5
    @State private var showUpgrades = false
    @State private var showSettings = false
    @State private var showStatistics = false

    var body: some View {
        ZStack {
            // Background gradient (lake/sky)
            LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.8, blue: 0.9),
                    Color(red: 0.4, green: 0.7, blue: 0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Game elements
            GeometryReader { geometry in
                ZStack {
                    // Falling Drops
                    ForEach(fallingItemManager.fallingDrops) { item in
                        FallingItemView(item: item, emoji: "💧")
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
                        FallingItemView(item: item, emoji: "🔵")
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
                        FallingItemView(item: item, emoji: "🍃")
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
                            y: geometry.size.height * 0.75
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    boatPosition = max(0.1, min(0.9, value.location.x / geometry.size.width))
                                }
                        )

                    // Companions
                    if viewModel.gameState.companions.origamiFish {
                        Text("🐟")
                            .font(.system(size: 32))
                            .position(
                                x: (boatPosition * geometry.size.width) - 40,
                                y: (geometry.size.height * 0.75) + 20
                            )
                    }

                    if viewModel.gameState.companions.origamiBird {
                        Text("🐦")
                            .font(.system(size: 32))
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

                    // Menu Buttons
                    HStack(spacing: 12) {
                        Button {
                            HapticFeedback.selection()
                            showStatistics = true
                        } label: {
                            Image(systemName: "chart.bar.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        Button {
                            HapticFeedback.selection()
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
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
        .sheet(isPresented: $showUpgrades) {
            UpgradeSheetView(viewModel: viewModel)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showStatistics) {
            StatisticsView(gameState: viewModel.gameState)
        }
        .sheet(isPresented: $viewModel.showWelcomeBack) {
            WelcomeBackView(
                offlineEarnings: viewModel.offlineEarnings ?? 0,
                minutesOffline: viewModel.minutesOffline
            )
        }
        .onAppear {
            fallingItemManager.startSpawning()
        }
        .onDisappear {
            fallingItemManager.stopSpawning()
        }
    }
}

struct BoatView: View {
    let skin: Skin

    var body: some View {
        Text(skin == .default ? "🚤" : "🦢")
            .font(.system(size: 60))
            .shadow(radius: 2)
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
