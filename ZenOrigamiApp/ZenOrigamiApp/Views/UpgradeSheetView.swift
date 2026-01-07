import SwiftUI

/// Shop/Upgrade screen
struct UpgradeSheetView: View {
    @Bindable var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Leveled Upgrades
                    Section {
                        VStack(spacing: 12) {
                            UpgradeCard(
                                emoji: "⚡",
                                title: "Boat Speed",
                                description: "Move faster to collect more",
                                level: viewModel.gameState.upgrades.speed,
                                cost: GameConfig.calculateUpgradeCost(for: .speed, level: viewModel.gameState.upgrades.speed),
                                canAfford: viewModel.canAfford(GameConfig.calculateUpgradeCost(for: .speed, level: viewModel.gameState.upgrades.speed))
                            ) {
                                if viewModel.purchaseUpgrade(.speed) {
                                    HapticFeedback.medium()
                                    SoundManager.shared.playUpgradePurchase()
                                }
                            }

                            UpgradeCard(
                                emoji: "📡",
                                title: "Collection Radius",
                                description: "Collect from further away",
                                level: viewModel.gameState.upgrades.radius,
                                cost: GameConfig.calculateUpgradeCost(for: .radius, level: viewModel.gameState.upgrades.radius),
                                canAfford: viewModel.canAfford(GameConfig.calculateUpgradeCost(for: .radius, level: viewModel.gameState.upgrades.radius))
                            ) {
                                if viewModel.purchaseUpgrade(.radius) {
                                    HapticFeedback.medium()
                                    SoundManager.shared.playUpgradePurchase()
                                }
                            }

                            UpgradeCard(
                                emoji: "💧",
                                title: "Drop Rate",
                                description: "Items fall more frequently",
                                level: viewModel.gameState.upgrades.rate,
                                cost: GameConfig.calculateUpgradeCost(for: .rate, level: viewModel.gameState.upgrades.rate),
                                canAfford: viewModel.canAfford(GameConfig.calculateUpgradeCost(for: .rate, level: viewModel.gameState.upgrades.rate))
                            ) {
                                if viewModel.purchaseUpgrade(.rate) {
                                    HapticFeedback.medium()
                                    SoundManager.shared.playUpgradePurchase()
                                }
                            }

                            UpgradeCard(
                                emoji: "🌧️",
                                title: "Rain Collector",
                                description: "Earn drops while offline",
                                level: viewModel.gameState.upgrades.collector,
                                cost: GameConfig.calculateUpgradeCost(for: .collector, level: viewModel.gameState.upgrades.collector),
                                canAfford: viewModel.canAfford(GameConfig.calculateUpgradeCost(for: .collector, level: viewModel.gameState.upgrades.collector))
                            ) {
                                if viewModel.purchaseUpgrade(.collector) {
                                    HapticFeedback.medium()
                                    SoundManager.shared.playUpgradePurchase()
                                }
                            }
                        }
                    } header: {
                        SectionHeader(title: "Upgrades")
                    }

                    // One-Time Purchases
                    Section {
                        VStack(spacing: 12) {
                            OneTimeItemCard(
                                emoji: "🚩",
                                title: "Origami Flag",
                                description: "Decorative flag for your boat",
                                cost: GameConfig.calculateOneTimeCost(for: .flag),
                                isPurchased: viewModel.gameState.addOns.flag,
                                canAfford: viewModel.canAfford(GameConfig.calculateOneTimeCost(for: .flag))
                            ) {
                                if viewModel.purchaseOneTimeItem(.flag) {
                                    HapticFeedback.success()
                                    SoundManager.shared.playUpgradePurchase()
                                }
                            }

                            OneTimeItemCard(
                                emoji: "🦢",
                                title: "Swan Skin",
                                description: "Transform into an elegant swan",
                                cost: GameConfig.calculateOneTimeCost(for: .swanSkin),
                                isPurchased: viewModel.gameState.skins.swanSkin,
                                canAfford: viewModel.canAfford(GameConfig.calculateOneTimeCost(for: .swanSkin))
                            ) {
                                if viewModel.purchaseOneTimeItem(.swanSkin) {
                                    HapticFeedback.success()
                                    SoundManager.shared.playUpgradePurchase()
                                }
                            }

                            OneTimeItemCard(
                                emoji: "🐟",
                                title: "Origami Fish",
                                description: "2x Pearl value companion",
                                cost: GameConfig.calculateOneTimeCost(for: .origamiFish),
                                isPurchased: viewModel.gameState.companions.origamiFish,
                                canAfford: viewModel.canAfford(GameConfig.calculateOneTimeCost(for: .origamiFish))
                            ) {
                                if viewModel.purchaseOneTimeItem(.origamiFish) {
                                    HapticFeedback.success()
                                    SoundManager.shared.playUpgradePurchase()
                                }
                            }

                            OneTimeItemCard(
                                emoji: "🐦",
                                title: "Origami Bird",
                                description: "2x Leaf value companion",
                                cost: GameConfig.calculateOneTimeCost(for: .origamiBird),
                                isPurchased: viewModel.gameState.companions.origamiBird,
                                canAfford: viewModel.canAfford(GameConfig.calculateOneTimeCost(for: .origamiBird))
                            ) {
                                if viewModel.purchaseOneTimeItem(.origamiBird) {
                                    HapticFeedback.success()
                                    SoundManager.shared.playUpgradePurchase()
                                }
                            }
                        }
                    } header: {
                        SectionHeader(title: "Special Items")
                    }
                }
                .padding()
            }
            .navigationTitle("Upgrades")
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
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(QuietLuxuryTheme.Typography.headlineSmall)
                .foregroundStyle(QuietLuxuryTheme.textPrimary)
                .textCase(.uppercase)
                .tracking(1.5)
            Spacer()
        }
        .padding(.top, QuietLuxuryTheme.Spacing.lg)
        .padding(.bottom, QuietLuxuryTheme.Spacing.sm)
    }
}

struct UpgradeCard: View {
    let emoji: String
    let title: String
    let description: String
    let level: Int
    let cost: Currencies
    let canAfford: Bool
    let onPurchase: () -> Void

    var body: some View {
        Button(action: onPurchase) {
            HStack(alignment: .center, spacing: QuietLuxuryTheme.Spacing.md) {
                // Icon (minimal, refined)
                Text(emoji)
                    .font(.system(size: 28))
                    .frame(width: 48, height: 48)
                    .background(QuietLuxuryTheme.surfaceElevated)
                    .clipShape(Circle())

                // Info
                VStack(alignment: .leading, spacing: QuietLuxuryTheme.Spacing.xxs) {
                    Text(title)
                        .font(QuietLuxuryTheme.Typography.bodyLarge)
                        .foregroundStyle(QuietLuxuryTheme.textPrimary)

                    Text(description)
                        .font(QuietLuxuryTheme.Typography.bodySmall)
                        .foregroundStyle(QuietLuxuryTheme.textSecondary)

                    Text("Lv. \(level)")
                        .font(QuietLuxuryTheme.Typography.labelSmall)
                        .foregroundStyle(QuietLuxuryTheme.textTertiary)
                        .textCase(.uppercase)
                        .tracking(1.0)
                }

                Spacer()

                // Cost (refined, monospaced)
                VStack(alignment: .trailing, spacing: QuietLuxuryTheme.Spacing.xxs) {
                    if cost.drop > 0 {
                        HStack(spacing: 4) {
                            Text("💧")
                                .font(.system(size: 12))
                            Text("\(cost.drop)")
                                .font(QuietLuxuryTheme.Typography.monoSmall)
                        }
                    }
                    if cost.pearl > 0 {
                        HStack(spacing: 4) {
                            Text("🔵")
                                .font(.system(size: 12))
                            Text("\(cost.pearl)")
                                .font(QuietLuxuryTheme.Typography.monoSmall)
                        }
                    }
                    if cost.leaf > 0 {
                        HStack(spacing: 4) {
                            Text("🍃")
                                .font(.system(size: 12))
                            Text("\(cost.leaf)")
                                .font(QuietLuxuryTheme.Typography.monoSmall)
                        }
                    }
                }
                .foregroundStyle(canAfford ? QuietLuxuryTheme.textPrimary : QuietLuxuryTheme.dustyRose)
            }
            .refinedCard(padding: QuietLuxuryTheme.Spacing.md)
            .overlay(
                RoundedRectangle(cornerRadius: QuietLuxuryTheme.CornerRadius.lg)
                    .strokeBorder(canAfford ? QuietLuxuryTheme.mutedSage.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .disabled(!canAfford)
        .buttonStyle(.plain)
        .opacity(canAfford ? 1.0 : 0.6)
    }
}

struct OneTimeItemCard: View {
    let emoji: String
    let title: String
    let description: String
    let cost: Currencies
    let isPurchased: Bool
    let canAfford: Bool
    let onPurchase: () -> Void

    var body: some View {
        Button(action: onPurchase) {
            HStack(alignment: .center, spacing: QuietLuxuryTheme.Spacing.md) {
                Text(emoji)
                    .font(.system(size: 28))
                    .frame(width: 48, height: 48)
                    .background(isPurchased ? QuietLuxuryTheme.mutedSage.opacity(0.15) : QuietLuxuryTheme.surfaceElevated)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: QuietLuxuryTheme.Spacing.xxs) {
                    Text(title)
                        .font(QuietLuxuryTheme.Typography.bodyLarge)
                        .foregroundStyle(QuietLuxuryTheme.textPrimary)

                    Text(description)
                        .font(QuietLuxuryTheme.Typography.bodySmall)
                        .foregroundStyle(QuietLuxuryTheme.textSecondary)
                }

                Spacer()

                if isPurchased {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                        Text("Owned")
                            .font(QuietLuxuryTheme.Typography.labelSmall)
                            .textCase(.uppercase)
                            .tracking(1.0)
                    }
                    .foregroundStyle(QuietLuxuryTheme.mutedSage)
                } else {
                    VStack(alignment: .trailing, spacing: QuietLuxuryTheme.Spacing.xxs) {
                        if cost.drop > 0 {
                            HStack(spacing: 4) {
                                Text("💧")
                                    .font(.system(size: 12))
                                Text("\(cost.drop)")
                                    .font(QuietLuxuryTheme.Typography.monoSmall)
                            }
                        }
                        if cost.pearl > 0 {
                            HStack(spacing: 4) {
                                Text("🔵")
                                    .font(.system(size: 12))
                                Text("\(cost.pearl)")
                                    .font(QuietLuxuryTheme.Typography.monoSmall)
                            }
                        }
                        if cost.leaf > 0 {
                            HStack(spacing: 4) {
                                Text("🍃")
                                    .font(.system(size: 12))
                                Text("\(cost.leaf)")
                                    .font(QuietLuxuryTheme.Typography.monoSmall)
                            }
                        }
                    }
                    .foregroundStyle(canAfford ? QuietLuxuryTheme.textPrimary : QuietLuxuryTheme.dustyRose)
                }
            }
            .refinedCard(padding: QuietLuxuryTheme.Spacing.md)
            .overlay(
                RoundedRectangle(cornerRadius: QuietLuxuryTheme.CornerRadius.lg)
                    .strokeBorder(isPurchased ? QuietLuxuryTheme.mutedSage.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .disabled(isPurchased || !canAfford)
        .buttonStyle(.plain)
        .opacity((isPurchased || !canAfford) ? 0.6 : 1.0)
    }
}

#Preview {
    UpgradeSheetView(viewModel: GameViewModel(
        databaseService: DatabaseService(supabaseURL: "https://example.supabase.co", supabaseKey: "key"),
        authService: AuthService(supabaseURL: "https://example.supabase.co", supabaseKey: "key")
    ))
}
