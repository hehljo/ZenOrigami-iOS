import SwiftUI

/// OFFLINE-ONLY VERSION
/// Nutze diese Datei statt ZenOrigamiApp.swift für 100% Offline-Modus
///
/// Setup in Xcode:
/// 1. Lösche ZenOrigamiApp.swift (die alte Datei)
/// 2. Benenne diese Datei um zu: ZenOrigamiApp.swift
/// 3. Build & Run!

@main
struct ZenOrigamiApp: App {
    var body: some Scene {
        WindowGroup {
            OfflineRootView()
        }
    }
}

/// Root view für Offline-Modus
struct OfflineRootView: View {
    @State private var gameViewModel: OfflineGameViewModel?
    @AppStorage("useScrollingMode") private var useScrollingMode = true

    var body: some View {
        Group {
            if let viewModel = gameViewModel {
                if useScrollingMode {
                    OfflineScrollingGameView(viewModel: viewModel)
                } else {
                    OfflineGameView(viewModel: viewModel)
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
    OfflineRootView()
}
