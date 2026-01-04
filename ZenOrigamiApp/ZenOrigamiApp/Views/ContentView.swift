import SwiftUI

/// Root view that handles authentication state
struct ContentView: View {
    @Environment(AuthService.self) private var authService
    @State private var gameViewModel: GameViewModel?
    @AppStorage("useScrollingMode") private var useScrollingMode = true
    @AppStorage("offlineMode") private var offlineMode = false

    var body: some View {
        Group {
            if authService.isLoading && !offlineMode {
                LoadingView()
            } else if authService.isAuthenticated || offlineMode {
                if let viewModel = gameViewModel {
                    if useScrollingMode {
                        ScrollingGameView(viewModel: viewModel)
                    } else {
                        GameView(viewModel: viewModel)
                    }
                } else {
                    LoadingView()
                        .task {
                            await initializeGameViewModel()
                        }
                }
            } else {
                AuthView()
            }
        }
        .onChange(of: authService.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                Task {
                    await initializeGameViewModel()
                }
            } else {
                gameViewModel = nil
            }
        }
        .onChange(of: offlineMode) { _, offline in
            if offline {
                Task {
                    await initializeGameViewModel()
                }
            }
        }
    }

    @MainActor
    private func initializeGameViewModel() async {
        // Get database service from environment
        guard let dbService = getDatabaseService() else { return }

        let viewModel = GameViewModel(
            databaseService: dbService,
            authService: authService
        )

        await viewModel.loadGameState()
        self.gameViewModel = viewModel
    }

    private func getDatabaseService() -> DatabaseService? {
        // This will be injected via environment
        // For now, create a temporary instance
        guard let url = ProcessInfo.processInfo.environment["SUPABASE_URL"],
              let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] else {
            return nil
        }
        return DatabaseService(supabaseURL: url, supabaseKey: key)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading...")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthService(
            supabaseURL: "https://example.supabase.co",
            supabaseKey: "test-key"
        ))
}
