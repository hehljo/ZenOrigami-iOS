import SwiftUI

/// Daily login rewards view
struct DailyRewardView: View {
    @Bindable var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    let rewards: [(day: Int, drops: Int)] = [
        (1, 100),
        (2, 200),
        (3, 400),
        (4, 800),
        (5, 1600),
        (6, 3200),
        (7, 10000) // Jackpot!
    ]

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 36, weight: .thin))
                    .foregroundStyle(QuietLuxuryTheme.textSecondary)
                Text("Daily Rewards")
                    .font(QuietLuxuryTheme.Typography.headlineLarge)
                Text("Login every day for bigger rewards!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Current Streak
            VStack(alignment: .leading, spacing: QuietLuxuryTheme.Spacing.md) {
                Text("Current Streak")
                    .font(QuietLuxuryTheme.Typography.bodySmall)
                    .foregroundStyle(QuietLuxuryTheme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                HStack(alignment: .firstTextBaseline, spacing: QuietLuxuryTheme.Spacing.sm) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(QuietLuxuryTheme.champagne)
                    Text("\(viewModel.gameState.loginStreak)")
                        .font(QuietLuxuryTheme.Typography.monoLarge)
                        .foregroundStyle(QuietLuxuryTheme.textPrimary)
                    Text("days")
                        .font(QuietLuxuryTheme.Typography.bodyMedium)
                        .foregroundStyle(QuietLuxuryTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .refinedCard(padding: QuietLuxuryTheme.Spacing.lg)

            // Rewards Grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(rewards, id: \.day) { reward in
                    DailyRewardCard(
                        day: reward.day,
                        drops: reward.drops,
                        isClaimed: viewModel.gameState.loginStreak >= reward.day,
                        isCurrent: viewModel.gameState.loginStreak + 1 == reward.day
                    )
                }
            }

            Spacer()

            // Claim Button
            if canClaimToday() {
                Button {
                    claimDailyReward()
                } label: {
                    Text("Claim Today's Reward")
                        .frame(maxWidth: .infinity)
                        .quietLuxuryButton(style: .primary, size: .large)
                }
            } else {
                Text("Come back tomorrow!")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .padding()
    }

    private func canClaimToday() -> Bool {
        // Check if last claim was yesterday or earlier
        let calendar = Calendar.current
        let lastVisit = viewModel.gameState.lastVisit

        if calendar.isDateInToday(lastVisit) {
            return false // Already claimed today
        }

        return true
    }

    private func claimDailyReward() {
        _ = viewModel.claimDailyReward()

        HapticFeedback.success()
        SoundManager.shared.playAchievementUnlock()

        dismiss()
    }
}

struct DailyRewardCard: View {
    let day: Int
    let drops: Int
    let isClaimed: Bool
    let isCurrent: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text("Day \(day)")
                .font(QuietLuxuryTheme.Typography.labelSmall)
                .foregroundStyle(isCurrent ? QuietLuxuryTheme.surface : QuietLuxuryTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(1.0)

            Image(systemName: day == 7 ? "star.fill" : "gift.fill")
                .font(.system(size: day == 7 ? 24 : 20, weight: .light))
                .foregroundStyle(isCurrent ? QuietLuxuryTheme.surface : QuietLuxuryTheme.textTertiary)

            HStack(spacing: 2) {
                Text("💧")
                    .font(.caption)
                Text("\(drops)")
                    .font(.caption.bold())
            }
            .foregroundStyle(isCurrent ? .white : .primary)

            if isClaimed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(QuietLuxuryTheme.mutedSage)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isCurrent ? QuietLuxuryTheme.softBlueGray : (isClaimed ? QuietLuxuryTheme.mutedSage.opacity(0.15) : QuietLuxuryTheme.surfaceElevated))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? QuietLuxuryTheme.softBlueGray : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    DailyRewardView(viewModel: GameViewModel(
        databaseService: DatabaseService(supabaseURL: "https://example.supabase.co", supabaseKey: "key"),
        authService: AuthService(supabaseURL: "https://example.supabase.co", supabaseKey: "key")
    ))
}
