import SwiftUI

/// Main app entry point - Offline-Only version
@main
struct ZenOrigamiApp: App {
    var body: some Scene {
        WindowGroup {
            OfflineContentView()
        }
    }
}

/// Root view for offline-only mode
struct OfflineContentView: View {
    @State private var gameViewModel: OfflineGameViewModel?
    @AppStorage("useScrollingMode") private var useScrollingMode = true

    var body: some View {
        Group {
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
        }
    }

    @MainActor
    private func initializeGameViewModel() async {
        let storageService = LocalStorageService()
        let viewModel = OfflineGameViewModel(storageService: storageService)

        await viewModel.loadGameState()
        self.gameViewModel = viewModel
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
    OfflineContentView()
}
