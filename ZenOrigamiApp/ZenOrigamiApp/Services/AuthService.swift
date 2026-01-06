import Foundation
import Supabase
import AuthenticationServices

/// Authentication service for OAuth and session management
@MainActor
@Observable
class AuthService {
    private let supabase: SupabaseClient

    // MARK: - Published State
    var currentUser: Supabase.User?
    var isAuthenticated: Bool { currentUser != nil }
    var isLoading = false
    var errorMessage: String?

    init(supabaseURL: String, supabaseKey: String) {
        guard let url = URL(string: supabaseURL) else {
            fatalError("Invalid Supabase URL: \(supabaseURL)")
        }
        self.supabase = SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseKey,
            options: SupabaseClientOptions(
                auth: .init(
                    autoRefreshToken: true,
                    emitLocalSessionAsInitialSession: true  // Fix Supabase warning
                )
            )
        )

        // Check for existing session on init
        Task {
            await checkSession()
        }
    }

    // MARK: - Authentication Methods

    /// Check for existing session
    func checkSession() async {
        do {
            let session = try await supabase.auth.session
            self.currentUser = session.user
            print("[Auth] ✅ Found existing session for user: \(session.user.id)")
        } catch {
            print("[Auth] ⚠️ No existing session found")
            self.currentUser = nil
        }
    }

    /// Sign in with OAuth provider (Google, GitHub)
    /// - Parameter provider: OAuth provider
    func signIn(with provider: Auth.Provider) async throws {
        isLoading = true
        errorMessage = nil

        do {
            // For iOS, we use Universal Links / Deep Links
            guard let redirectURL = URL(string: "zenorigami://auth/callback") else {
                throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid redirect URL"])
            }

            _ = try await supabase.auth.signInWithOAuth(
                provider: provider,
                redirectTo: redirectURL
            )

            print("[Auth] ✅ OAuth initiated for provider: \(provider.rawValue)")

            // The actual sign-in will complete via deep link callback
            // handled in AppDelegate/SceneDelegate
        } catch {
            errorMessage = "Failed to sign in: \(error.localizedDescription)"
            print("[Auth] ❌ Sign in error: \(error)")
            throw error
        }

        isLoading = false
    }

    /// Handle OAuth callback (called from deep link)
    /// - Parameter url: Callback URL with tokens
    func handleOAuthCallback(url: URL) async throws {
        do {
            let session = try await supabase.auth.session(from: url)
            self.currentUser = session.user
            print("[Auth] ✅ OAuth completed, user: \(session.user.id)")
        } catch {
            errorMessage = "Failed to complete authentication"
            print("[Auth] ❌ OAuth callback error: \(error)")
            throw error
        }
    }

    /// Sign out current user
    func signOut() async throws {
        do {
            try await supabase.auth.signOut()
            self.currentUser = nil
            print("[Auth] ✅ User signed out")
        } catch {
            errorMessage = "Failed to sign out"
            print("[Auth] ❌ Sign out error: \(error)")
            throw error
        }
    }

    /// Get current user ID
    var userId: UUID? {
        currentUser?.id
    }

    /// Get access token for API calls
    func getAccessToken() async throws -> String? {
        let session = try await supabase.auth.session
        return session.accessToken
    }
}
