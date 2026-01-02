import SwiftUI

/// Main game screen with boat, falling items, and UI
struct GameView: View {
    @Bindable var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var boatPosition: CGFloat = 0.5 // 0.0 to 1.0 (left to right)
    @State private var showMenu = false

    var body: some View {
        ZStack {
            // Background gradient (lake)
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.7, blue: 0.9),
                    Color(red: 0.2, green: 0.5, blue: 0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geometry in
                ZStack {
                    // Falling drops
                    ForEach(viewModel.fallingDrops) { drop in
                        FallingItemView(
                            item: drop,
                            emoji: "💧",
                            screenWidth: geometry.size.width
                        )
                        .onTapGesture {
                            collectItem(drop, currency: .drop)
                        }
                    }

                    // Falling leaves
                    ForEach(viewModel.fallingLeaves) { leaf in
                        FallingItemView(
                            item: leaf,
                            emoji: "🍃",
                            screenWidth: geometry.size.width
                        )
                        .onTapGesture {
                            collectItem(leaf, currency: .leaf)
                        }
                    }

                    // Falling pearls
                    ForEach(viewModel.fallingPearls) { pearl in
                        FallingItemView(
                            item: pearl,
                            emoji: "🔵",
                            screenWidth: geometry.size.width
                        )
                        .onTapGesture {
                            collectItem(pearl, currency: .pearl)
                        }
                    }

                    // Boat (player)
                    BoatView(skin: viewModel.gameState.activeSkin)
                        .frame(width: 80, height: 80)
                        .position(
                            x: geometry.size.width * boatPosition,
                            y: geometry.size.height * 0.7
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // Move boat horizontally
                                    let newPosition = value.location.x / geometry.size.width
                                    boatPosition = max(0.1, min(0.9, newPosition))
                                }
                        )
                }
            }

            // Top HUD
            VStack {
                HStack {
                    // Currency display
                    CurrencyView(
                        icon: "💧",
                        amount: viewModel.gameState.currencies.drop
                    )

                    Spacer()

                    // Menu button
                    Button {
                        showMenu = true
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding()

                Spacer()
            }
        }
        .sheet(isPresented: $showMenu) {
            MenuView()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.showWelcomeBack) {
            WelcomeBackView(
                offlineEarnings: viewModel.offlineEarnings ?? 0,
                minutesOffline: viewModel.minutesOffline
            )
        }
    }

    private func collectItem(_ item: FallingItem, currency: Currency) {
        // Collect currency
        viewModel.collect(currency: currency, amount: 1)

        // TODO: Animate collection
        // TODO: Remove item from falling items list
    }
}

struct FallingItemView: View {
    let item: FallingItem
    let emoji: String
    let screenWidth: CGFloat

    var body: some View {
        Text(emoji)
            .font(.largeTitle)
            .position(
                x: screenWidth * item.x,
                y: 100 // TODO: Animate falling
            )
    }
}

struct BoatView: View {
    let skin: Skin

    var body: some View {
        ZStack {
            // Simple boat representation
            // TODO: Create proper SVG boat shape
            switch skin {
            case .default:
                Text("🚤")
                    .font(.system(size: 60))
            case .swanSkin:
                Text("🦢")
                    .font(.system(size: 60))
            }
        }
    }
}

struct CurrencyView: View {
    let icon: String
    let amount: Int

    var body: some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.title2)

            Text("\(amount)")
                .font(.headline)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

struct MenuView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Game") {
                    NavigationLink("Upgrades") {
                        Text("Upgrades Screen")
                    }
                    NavigationLink("Achievements") {
                        Text("Achievements Screen")
                    }
                    NavigationLink("Statistics") {
                        Text("Statistics Screen")
                    }
                }

                Section("Settings") {
                    NavigationLink("Profile") {
                        Text("Profile Screen")
                    }
                    Button("Sign Out") {
                        // TODO: Sign out
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WelcomeBackView: View {
    @Environment(\.dismiss) private var dismiss
    let offlineEarnings: Int
    let minutesOffline: Double

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)

            Text("Welcome Back!")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 8) {
                Text("While you were away...")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                HStack {
                    Text("💧")
                        .font(.title)
                    Text("+\(offlineEarnings)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding()
                .background(.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("(\(Int(minutesOffline)) minutes)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button {
                dismiss()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
        }
        .padding()
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
