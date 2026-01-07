import SwiftUI

/// Welcome back sheet showing offline earnings
struct WelcomeBackView: View {
    let offlineEarnings: Int
    let minutesOffline: Double
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Boat animation
            Image("boat_default")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .scaleEffect(1.2)
                .animation(.spring(response: 0.6, dampingFraction: 0.6).repeatForever(autoreverses: true), value: UUID())

            // Title
            Text("Welcome Back!")
                .font(.largeTitle.bold())

            // Offline time
            Text("You were away for")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(formatOfflineTime(minutesOffline))
                .font(.title2.bold())

            // Earnings
            VStack(spacing: 8) {
                Text("Your boat collected:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    Text("💧")
                        .font(.system(size: 40))
                    Text("\(offlineEarnings)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
            }
            .padding()
            .background(QuietLuxuryTheme.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Spacer()

            // Claim button
            Button {
                HapticFeedback.success()
                dismiss()
            } label: {
                Text("Claim Rewards")
                    .frame(maxWidth: .infinity)
                    .quietLuxuryButton(style: .primary, size: .large)
            }
            .buttonStyle(.plain)
        }
        .padding(32)
        .interactiveDismissDisabled()
    }

    private func formatOfflineTime(_ minutes: Double) -> String {
        let hours = Int(minutes / 60)
        let mins = Int(minutes.truncatingRemainder(dividingBy: 60))

        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
}

#Preview {
    WelcomeBackView(offlineEarnings: 1234, minutesOffline: 125.5)
}
