import SwiftUI

/// Prestige/Reset view for late-game progression
struct PrestigeView: View {
    @Bindable var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 48, weight: .thin))
                            .foregroundStyle(QuietLuxuryTheme.softTaupe)
                        Text("Prestige")
                            .font(QuietLuxuryTheme.Typography.headlineLarge)
                        Text("Reset progress for permanent bonuses")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    // Current Prestige
                    VStack(alignment: .leading, spacing: QuietLuxuryTheme.Spacing.md) {
                        Text("Current Prestige Level")
                            .font(QuietLuxuryTheme.Typography.bodySmall)
                            .foregroundStyle(QuietLuxuryTheme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1.2)

                        Text("\(viewModel.gameState.prestige.level)")
                            .font(QuietLuxuryTheme.Typography.displayMedium)
                            .foregroundStyle(QuietLuxuryTheme.textPrimary)

                        Text("+\(viewModel.gameState.prestige.level * 10)% idle earnings")
                            .font(QuietLuxuryTheme.Typography.labelMedium)
                            .foregroundStyle(QuietLuxuryTheme.mutedSage)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .refinedCard(padding: QuietLuxuryTheme.Spacing.xl)

                    // Zen Points Available
                    let zenPoints = calculateZenPoints()
                    VStack(alignment: .leading, spacing: QuietLuxuryTheme.Spacing.md) {
                        Text("Zen Points Available")
                            .font(QuietLuxuryTheme.Typography.bodySmall)
                            .foregroundStyle(QuietLuxuryTheme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1.2)

                        Text("\(zenPoints)")
                            .font(QuietLuxuryTheme.Typography.monoLarge)
                            .foregroundStyle(QuietLuxuryTheme.softTaupe)

                        Text("Based on \(viewModel.gameState.totalCollected.drop) total drops")
                            .font(QuietLuxuryTheme.Typography.bodySmall)
                            .foregroundStyle(QuietLuxuryTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .refinedCard(padding: QuietLuxuryTheme.Spacing.lg)

                    // Requirements
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Prestige Requirements")

                        RequirementRow(
                            label: "Total Drops Collected",
                            current: viewModel.gameState.totalCollected.drop,
                            required: 50000,
                            emoji: "💧"
                        )
                    }

                    // Benefits
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Prestige Benefits")

                        BenefitRow(emoji: "📈", text: "+10% idle earnings per level")
                        BenefitRow(emoji: "🌟", text: "Earn Zen Points for special upgrades")
                        BenefitRow(emoji: "🏆", text: "Unlock prestige achievements")
                        BenefitRow(emoji: "♾️", text: "Infinite progression")
                    }

                    // What You Keep
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "You Keep")

                        BenefitRow(emoji: "🦢", text: "All skins and cosmetics")
                        BenefitRow(emoji: "🐟", text: "All companions")
                        BenefitRow(emoji: "🏆", text: "All achievements")
                        BenefitRow(emoji: "📊", text: "Total statistics")
                    }

                    // What Resets
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Resets")

                        WarningRow(emoji: "💧", text: "All currencies (Drops, Pearls, Leaves)")
                        WarningRow(emoji: "⬆️", text: "All upgrade levels")
                        WarningRow(emoji: "🚩", text: "Decorative add-ons (Flag)")
                    }

                    // Prestige Button
                    if canPrestige() {
                        Button {
                            showConfirmation = true
                        } label: {
                            Text("Prestige Now")
                                .frame(maxWidth: .infinity)
                                .quietLuxuryButton(style: .primary, size: .large)
                        }
                    } else {
                        VStack {
                            Text("Not Ready Yet")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text("Collect \(50000 - viewModel.gameState.totalCollected.drop) more drops")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding()
            }
            .navigationTitle("Prestige")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .confirmationDialog("Prestige", isPresented: $showConfirmation) {
            Button("Prestige (\(calculateZenPoints()) Zen Points)", role: .destructive) {
                performPrestige()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure? This will reset most progress but grant permanent bonuses!")
        }
    }

    private func canPrestige() -> Bool {
        viewModel.gameState.totalCollected.drop >= 50000
    }

    private func calculateZenPoints() -> Int {
        let totalDrops = viewModel.gameState.totalCollected.drop
        return Int(sqrt(Double(totalDrops) / 10000))
    }

    private func performPrestige() {
        let zenPoints = viewModel.performPrestige()

        // Play feedback
        SoundManager.shared.playPrestige()
        HapticFeedback.heavy()

        print("[Prestige] ✨ Prestiged to level \(viewModel.gameState.prestige.level) (+\(zenPoints) Zen Points)")

        dismiss()
    }
}

struct RequirementRow: View {
    let label: String
    let current: Int
    let required: Int
    let emoji: String

    var isMet: Bool { current >= required }

    var body: some View {
        HStack(spacing: QuietLuxuryTheme.Spacing.md) {
            Image(systemName: "drop.fill")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(QuietLuxuryTheme.textTertiary)
            Text(label)
                .font(QuietLuxuryTheme.Typography.bodyMedium)
            Spacer()
            Text("\(current) / \(required)")
                .font(.caption.bold())
                .foregroundStyle(isMet ? QuietLuxuryTheme.mutedSage : QuietLuxuryTheme.dustyRose)
        }
        .padding()
        .background(isMet ? QuietLuxuryTheme.mutedSage.opacity(0.15) : QuietLuxuryTheme.dustyRose.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct BenefitRow: View {
    let emoji: String
    let text: String

    private var sfSymbol: String {
        switch emoji {
        case "📈": return "chart.line.uptrend.xyaxis"
        case "🌟": return "sparkles"
        case "🏆": return "trophy.fill"
        case "♾️": return "infinity"
        case "🦢": return "bird.fill"
        case "🐟": return "fish.fill"
        case "📊": return "chart.bar.fill"
        default: return "checkmark.circle.fill"
        }
    }

    var body: some View {
        HStack(spacing: QuietLuxuryTheme.Spacing.md) {
            Image(systemName: sfSymbol)
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(QuietLuxuryTheme.mutedSage)
            Text(text)
                .font(QuietLuxuryTheme.Typography.bodyMedium)
            Spacer()
        }
        .padding()
        .background(QuietLuxuryTheme.mutedSage.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct WarningRow: View {
    let emoji: String
    let text: String

    private var sfSymbol: String {
        switch emoji {
        case "💧": return "drop.fill"
        case "⬆️": return "arrow.up.circle.fill"
        case "🚩": return "flag.fill"
        default: return "exclamationmark.triangle.fill"
        }
    }

    var body: some View {
        HStack(spacing: QuietLuxuryTheme.Spacing.md) {
            Image(systemName: sfSymbol)
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(QuietLuxuryTheme.dustyRose)
            Text(text)
                .font(QuietLuxuryTheme.Typography.bodyMedium)
            Spacer()
        }
        .padding()
        .background(QuietLuxuryTheme.dustyRose.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    PrestigeView(viewModel: GameViewModel(
        databaseService: DatabaseService(supabaseURL: "https://example.supabase.co", supabaseKey: "key"),
        authService: AuthService(supabaseURL: "https://example.supabase.co", supabaseKey: "key")
    ))
}
