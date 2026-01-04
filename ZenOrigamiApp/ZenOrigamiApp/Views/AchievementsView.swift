import SwiftUI

/// Achievements screen showing unlocked and locked achievements
struct AchievementsView: View {
    let gameState: GameState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    Text("Achievements")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    // Achievement Progress
                    let unlockedCount = gameState.achievements.values.filter { $0.unlocked }.count
                    let totalCount = GameConfig.Achievement.allCases.count

                    ProgressView(value: Double(unlockedCount), total: Double(totalCount))
                        .padding(.horizontal)

                    Text("\(unlockedCount) / \(totalCount) Unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Divider()
                        .padding(.vertical)

                    // Achievement List
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                        ForEach(GameConfig.Achievement.allCases, id: \.self) { achievement in
                            AchievementCard(
                                achievement: achievement,
                                achievementState: gameState.achievements[achievement.rawValue] ?? .initial
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Achievement Card

struct AchievementCard: View {
    let achievement: GameConfig.Achievement
    let achievementState: AchievementState

    var body: some View {
        VStack(spacing: 8) {
            // Icon
            Text(achievement.emoji)
                .font(.system(size: 40))
                .opacity(achievementState.unlocked ? 1.0 : 0.3)

            // Title
            Text(achievement.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(achievementState.unlocked ? .primary : .secondary)

            // Description
            Text(achievement.description)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            // Progress or Reward
            if achievementState.unlocked {
                // Reward
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                    Text("+\(achievement.reward)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                // Progress (if tracked)
                if achievementState.progress > 0 {
                    ProgressView(value: Double(achievementState.progress), total: 100)
                        .padding(.horizontal, 8)

                    Text("\(achievementState.progress) / 100")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(achievementState.unlocked ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay {
            if achievementState.unlocked {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
            }
        }
    }
}

#Preview {
    AchievementsView(gameState: .initial)
}
