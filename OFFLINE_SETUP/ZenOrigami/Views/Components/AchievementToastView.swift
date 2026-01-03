import SwiftUI

/// Toast notification for achievement unlocks
struct AchievementToastView: View {
    let achievement: GameConfig.Achievement
    @Binding var isShowing: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(achievement.emoji)
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 4) {
                Text("Achievement Unlocked!")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                Text(achievement.title)
                    .font(.headline)

                HStack(spacing: 4) {
                    Text("💧")
                    Text("+\(achievement.reward)")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                }
            }

            Spacer()

            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.secondary)
                .onTapGesture {
                    withAnimation {
                        isShowing = false
                    }
                }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
        .padding()
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    isShowing = false
                }
            }
        }
    }
}

#Preview {
    AchievementToastView(
        achievement: .firstCollect,
        isShowing: .constant(true)
    )
}
