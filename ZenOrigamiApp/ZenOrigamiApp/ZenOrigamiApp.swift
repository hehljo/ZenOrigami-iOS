import SwiftUI

@main
struct ZenOrigamiApp: App {
    @State private var authService: AuthService
    @State private var databaseService: DatabaseService

    init() {
        // Load environment variables
        let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""
        let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? ""

        // Initialize services
        _authService = State(initialValue: AuthService(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        ))

        _databaseService = State(initialValue: DatabaseService(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        ))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authService)
                .onOpenURL { url in
                    // Handle OAuth callback
                    Task {
                        try? await authService.handleOAuthCallback(url: url)
                    }
                }
        }
    }
}
