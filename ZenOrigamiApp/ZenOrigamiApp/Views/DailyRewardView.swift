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
                Text("🎁")
                    .font(.system(size: 60))
                Text("Daily Rewards")
                    .font(.largeTitle.bold())
                Text("Login every day for bigger rewards!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Current Streak
            VStack(spacing: 4) {
                Text("Current Streak")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.title)
                    Text("\(viewModel.gameState.loginStreak)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    Text("days")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))

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
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
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
                .font(.caption.bold())
                .foregroundStyle(isCurrent ? .white : .secondary)

            if day == 7 {
                Text("🎉")
                    .font(.title)
            } else {
                Text("🎁")
                    .font(.title2)
            }

            HStack(spacing: 2) {
                Text("💧")
                    .font(.caption)
                Text("\(drops)")
                    .font(.caption.bold())
            }
            .foregroundStyle(isCurrent ? .white : .primary)

            if isClaimed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isCurrent ? Color.blue : (isClaimed ? Color.green.opacity(0.1) : Color.gray.opacity(0.1)))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    DailyRewardView(viewModel: GameViewModel(
        databaseService: DatabaseService(supabaseURL: "https://example.supabase.co", supabaseKey: "key"),
        authService: AuthService(supabaseURL: "https://example.supabase.co", supabaseKey: "key")
    ))
}
