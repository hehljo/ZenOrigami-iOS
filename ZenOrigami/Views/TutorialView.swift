import SwiftUI

/// Tutorial/Onboarding flow for new users
struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0

    let steps: [TutorialStep] = [
        TutorialStep(
            emoji: "🚤",
            title: "Welcome to Zen Origami Journey!",
            description: "Guide your origami boat through a peaceful idle adventure"
        ),
        TutorialStep(
            emoji: "💧",
            title: "Collect Drops",
            description: "Tap falling drops, pearls, and leaves to collect them"
        ),
        TutorialStep(
            emoji: "⬆️",
            title: "Buy Upgrades",
            description: "Spend drops to improve your boat and collection abilities"
        ),
        TutorialStep(
            emoji: "😴",
            title: "Earn While Offline",
            description: "Your boat continues collecting drops even when you're away"
        ),
        TutorialStep(
            emoji: "🏆",
            title: "Unlock Achievements",
            description: "Complete challenges to earn bonus drops and rewards"
        ),
        TutorialStep(
            emoji: "🎉",
            title: "Ready to Play!",
            description: "Tap anywhere to collect your first drop and begin your journey"
        )
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.8, blue: 0.9),
                    Color(red: 0.4, green: 0.7, blue: 0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Step content
                VStack(spacing: 20) {
                    Text(steps[currentStep].emoji)
                        .font(.system(size: 100))
                        .transition(.scale.combined(with: .opacity))

                    Text(steps[currentStep].title)
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .transition(.slide.combined(with: .opacity))

                    Text(steps[currentStep].description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal)
                        .transition(.slide.combined(with: .opacity))
                }
                .frame(maxWidth: .infinity)
                .id(currentStep) // Force recreation for transitions

                Spacer()

                // Progress indicators
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }

                // Navigation buttons
                HStack(spacing: 20) {
                    if currentStep > 0 {
                        Button {
                            withAnimation(.spring(response: 0.4)) {
                                currentStep -= 1
                            }
                            HapticFeedback.selection()
                        } label: {
                            Text("Back")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }

                    Spacer()

                    if currentStep < steps.count - 1 {
                        Button {
                            withAnimation(.spring(response: 0.4)) {
                                currentStep += 1
                            }
                            HapticFeedback.selection()
                        } label: {
                            Text("Next")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                    } else {
                        Button {
                            HapticFeedback.success()
                            UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
                            dismiss()
                        } label: {
                            Text("Start Playing!")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .interactiveDismissDisabled()
    }
}

struct TutorialStep {
    let emoji: String
    let title: String
    let description: String
}

#Preview {
    TutorialView()
}
