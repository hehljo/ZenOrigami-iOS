import SwiftUI
import AuthenticationServices

/// Authentication screen with OAuth login
struct AuthView: View {
    @Environment(AuthService.self) private var authService
    @State private var isSigningIn = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.8, blue: 0.9),
                    Color(red: 0.4, green: 0.6, blue: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo and title
                VStack(spacing: 16) {
                    Image(systemName: "water.waves")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)

                    Text("Zen Origami Journey")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("A relaxing idle game")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))
                }

                Spacer()

                // OAuth buttons
                VStack(spacing: 16) {
                    // Google Sign In
                    OAuthButton(
                        icon: "g.circle.fill",
                        title: "Sign in with Google",
                        backgroundColor: .white,
                        foregroundColor: .black
                    ) {
                        await signIn(with: .google)
                    }

                    // GitHub Sign In
                    OAuthButton(
                        icon: "github",
                        title: "Sign in with GitHub",
                        backgroundColor: Color(red: 0.13, green: 0.13, blue: 0.13),
                        foregroundColor: .white
                    ) {
                        await signIn(with: .github)
                    }
                }
                .padding(.horizontal, 32)

                // Offline mode option
                Button {
                    // TODO: Implement offline mode
                } label: {
                    Text("Continue without signing in")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.top, 8)

                if let error = authService.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                Spacer()
            }
        }
        .disabled(isSigningIn)
    }

    private func signIn(with provider: Supabase.Provider) async {
        isSigningIn = true
        do {
            try await authService.signIn(with: provider)
        } catch {
            print("Sign in failed: \(error)")
        }
        isSigningIn = false
    }
}

struct OAuthButton: View {
    let icon: String
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () async -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)

                Text(title)
                    .font(.headline)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity,
                            pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    AuthView()
        .environment(AuthService(
            supabaseURL: "https://example.supabase.co",
            supabaseKey: "test-key"
        ))
}
