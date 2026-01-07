import SwiftUI

/// Tutorial/Onboarding flow for new users
struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0

    let steps: [TutorialStep] = [
        TutorialStep(
            icon: "sailboat.fill",
            title: "Welcome to Zen Origami",
            description: "Guide your origami boat through a peaceful idle journey"
        ),
        TutorialStep(
            icon: "drop.fill",
            title: "Collect Resources",
            description: "Tap falling items to collect drops, pearls, and leaves"
        ),
        TutorialStep(
            icon: "arrow.up.circle.fill",
            title: "Purchase Upgrades",
            description: "Invest resources to improve your boat and abilities"
        ),
        TutorialStep(
            icon: "moon.stars.fill",
            title: "Passive Earnings",
            description: "Your boat continues collecting resources while offline"
        ),
        TutorialStep(
            icon: "trophy.fill",
            title: "Complete Achievements",
            description: "Unlock challenges to earn bonus resources and rewards"
        ),
        TutorialStep(
            icon: "checkmark.circle.fill",
            title: "Begin Your Journey",
            description: "You're ready to start your zen origami adventure"
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
                    Image(systemName: steps[currentStep].icon)
                        .font(.system(size: 64, weight: .thin))
                        .foregroundStyle(QuietLuxuryTheme.textSecondary)
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
    let icon: String
    let title: String
    let description: String
}

#Preview {
    TutorialView()
}
