import SwiftUI

/// Statistics and progression tracking
struct StatisticsView: View {
    let gameState: GameState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Play Time
                    StatCard(
                        emoji: "⏰",
                        title: "Play Time",
                        value: formatPlayTime(gameState.playTime)
                    )

                    // Total Collected
                    Section {
                        StatRow(emoji: "💧", label: "Total Drops", value: "\(gameState.totalCollected.drop)")
                        StatRow(emoji: "🔵", label: "Total Pearls", value: "\(gameState.totalCollected.pearl)")
                        StatRow(emoji: "🍃", label: "Total Leaves", value: "\(gameState.totalCollected.leaf)")
                    } header: {
                        SectionHeader(title: "Collection Stats")
                    }

                    // Upgrades
                    Section {
                        StatRow(emoji: "⬆️", label: "Total Upgrades", value: "\(gameState.totalUpgradesPurchased)")
                        StatRow(emoji: "⚡", label: "Speed Level", value: "\(gameState.upgrades.speed)")
                        StatRow(emoji: "📡", label: "Radius Level", value: "\(gameState.upgrades.radius)")
                        StatRow(emoji: "💧", label: "Rate Level", value: "\(gameState.upgrades.rate)")
                        StatRow(emoji: "🌧️", label: "Collector Level", value: "\(gameState.upgrades.collector)")
                    } header: {
                        SectionHeader(title: "Upgrade Stats")
                    }

                    // Prestige
                    Section {
                        StatRow(emoji: "⭐", label: "Prestige Level", value: "\(gameState.prestige.level)")
                        StatRow(emoji: "🌟", label: "Zen Points", value: "\(gameState.prestige.zenPoints)")
                        StatRow(emoji: "🔁", label: "Total Prestiges", value: "\(gameState.prestige.totalPrestiges)")
                    } header: {
                        SectionHeader(title: "Prestige Stats")
                    }

                    // Idle Earnings
                    let idlePerHour = GameConfig.calculateIdleEarningsPerHour(
                        upgrades: gameState.upgrades,
                        companions: gameState.companions
                    )
                    Section {
                        StatRow(emoji: "😴", label: "Per Hour (Offline)", value: "\(idlePerHour) 💧")
                        StatRow(emoji: "📅", label: "Login Streak", value: "\(gameState.loginStreak) days")
                    } header: {
                        SectionHeader(title: "Idle Stats")
                    }

                    // Account Info
                    Section {
                        StatRow(emoji: "📅", label: "Account Created", value: formatDate(gameState.createdAt))
                        StatRow(emoji: "🕐", label: "Last Played", value: formatDate(gameState.lastVisit))
                    } header: {
                        SectionHeader(title: "Account")
                    }
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func formatPlayTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let emoji: String
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: QuietLuxuryTheme.Spacing.md) {
            HStack {
                Text(emoji)
                    .font(.system(size: 32))
                Spacer()
            }

            VStack(alignment: .leading, spacing: QuietLuxuryTheme.Spacing.xs) {
                Text(title)
                    .font(QuietLuxuryTheme.Typography.bodySmall)
                    .foregroundStyle(QuietLuxuryTheme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Text(value)
                    .font(QuietLuxuryTheme.Typography.monoMedium)
                    .foregroundStyle(QuietLuxuryTheme.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .refinedCard(padding: QuietLuxuryTheme.Spacing.lg)
    }
}

struct StatRow: View {
    let emoji: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: QuietLuxuryTheme.Spacing.md) {
            Text(emoji)
                .font(.system(size: 20))
                .frame(width: 28)

            Text(label)
                .font(QuietLuxuryTheme.Typography.bodyMedium)
                .foregroundStyle(QuietLuxuryTheme.textPrimary)

            Spacer()

            Text(value)
                .font(QuietLuxuryTheme.Typography.monoSmall)
                .foregroundStyle(QuietLuxuryTheme.textSecondary)
        }
        .padding(.vertical, QuietLuxuryTheme.Spacing.sm)
    }
}

#Preview {
    StatisticsView(gameState: .initial)
}
