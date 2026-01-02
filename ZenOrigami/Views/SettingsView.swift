import SwiftUI

/// Settings and preferences
struct SettingsView: View {
    @Bindable var soundManager: SoundManager
    @State private var hapticsEnabled = true
    @AppStorage("useScrollingMode") private var useScrollingMode = true
    @AppStorage("showPerformanceOverlay") private var showPerformanceOverlay = false
    @Environment(\.dismiss) private var dismiss

    init() {
        self.soundManager = SoundManager.shared
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Audio & Haptics") {
                    Toggle("Sound Effects", isOn: $soundManager.isSoundEnabled)
                    Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                        .onChange(of: hapticsEnabled) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: "hapticsEnabled")
                            if newValue {
                                HapticFeedback.selection()
                            }
                        }
                }

                Section("Gameplay") {
                    Toggle("Sidescrolling Mode", isOn: $useScrollingMode)
                        .onChange(of: useScrollingMode) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: "useScrollingMode")
                            HapticFeedback.selection()
                        }

                    Toggle("Performance Overlay", isOn: $showPerformanceOverlay)
                        .onChange(of: showPerformanceOverlay) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: "showPerformanceOverlay")
                        }
                }

                Section("Game") {
                    Button("Reset Progress") {
                        // TODO: Implement reset confirmation
                    }
                    .foregroundStyle(.red)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            hapticsEnabled = UserDefaults.standard.bool(forKey: "hapticsEnabled")
        }
    }
}

#Preview {
    SettingsView()
}
