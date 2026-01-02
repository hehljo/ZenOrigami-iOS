#if canImport(UIKit)
import UIKit
#endif

/// Haptic feedback utilities for tactile user feedback
enum HapticFeedback {
    #if canImport(UIKit)
    /// Light impact (e.g., item collect)
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium impact (e.g., upgrade purchase)
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy impact (e.g., achievement unlock, prestige)
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Selection feedback (e.g., button tap, tab switch)
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    /// Success notification (e.g., level up, purchase complete)
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning notification (e.g., not enough currency)
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error notification (e.g., purchase failed)
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    #else
    // Fallbacks for non-UIKit platforms
    static func light() {}
    static func medium() {}
    static func heavy() {}
    static func selection() {}
    static func success() {}
    static func warning() {}
    static func error() {}
    #endif
}
