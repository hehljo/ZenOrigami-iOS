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
                .font(.title2.bold())
            Spacer()
        }
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
            HStack {
                // Icon
                Text(emoji)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Level \(level)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                // Cost
                VStack(alignment: .trailing, spacing: 4) {
                    if cost.drop > 0 {
                        HStack(spacing: 2) {
                            Text("💧")
                            Text("\(cost.drop)")
                        }
                        .font(.caption.bold())
                    }
                    if cost.pearl > 0 {
                        HStack(spacing: 2) {
                            Text("🔵")
                            Text("\(cost.pearl)")
                        }
                        .font(.caption.bold())
                    }
                    if cost.leaf > 0 {
                        HStack(spacing: 2) {
                            Text("🍃")
                            Text("\(cost.leaf)")
                        }
                        .font(.caption.bold())
                    }
                }
                .foregroundStyle(canAfford ? .primary : .red)
            }
            .padding()
            .background(canAfford ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!canAfford)
        .buttonStyle(.plain)
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
            HStack {
                Text(emoji)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(isPurchased ? Color.green.opacity(0.2) : Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isPurchased {
                    Text("✓ Owned")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                } else {
                    VStack(alignment: .trailing, spacing: 4) {
                        if cost.drop > 0 {
                            HStack(spacing: 2) {
                                Text("💧")
                                Text("\(cost.drop)")
                            }
                            .font(.caption.bold())
                        }
                        if cost.pearl > 0 {
                            HStack(spacing: 2) {
                                Text("🔵")
                                Text("\(cost.pearl)")
                            }
                            .font(.caption.bold())
                        }
                        if cost.leaf > 0 {
                            HStack(spacing: 2) {
                                Text("🍃")
                                Text("\(cost.leaf)")
                            }
                            .font(.caption.bold())
                        }
                    }
                    .foregroundStyle(canAfford ? .primary : .red)
                }
            }
            .padding()
            .background(isPurchased ? Color.green.opacity(0.1) : (canAfford ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1)))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isPurchased || !canAfford)
        .buttonStyle(.plain)
    }
}

#Preview {
    UpgradeSheetView(viewModel: GameViewModel(
        databaseService: DatabaseService(supabaseURL: "https://example.supabase.co", supabaseKey: "key"),
        authService: AuthService(supabaseURL: "https://example.supabase.co", supabaseKey: "key")
    ))
}
