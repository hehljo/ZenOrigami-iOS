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
            // Background gradient - Quiet Luxury
            QuietLuxuryTheme.skyGradient
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
                        .foregroundStyle(QuietLuxuryTheme.textPrimary)
                        .transition(.slide.combined(with: .opacity))

                    Text(steps[currentStep].description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(QuietLuxuryTheme.textSecondary)
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
                            .fill(index == currentStep ? QuietLuxuryTheme.charcoal : QuietLuxuryTheme.softTaupe)
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
                                .quietLuxuryButton(style: .secondary, size: .medium)
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
                                .quietLuxuryButton(style: .primary, size: .medium)
                        }
                    } else {
                        Button {
                            HapticFeedback.success()
                            UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
                            dismiss()
                        } label: {
                            Text("Start Playing!")
                                .quietLuxuryButton(style: .primary, size: .large)
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
