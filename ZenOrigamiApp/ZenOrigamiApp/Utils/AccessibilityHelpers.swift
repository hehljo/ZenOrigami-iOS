import SwiftUI

/// Accessibility helpers and extensions
enum AccessibilityHelper {
    /// Check if VoiceOver is enabled
    static var isVoiceOverEnabled: Bool {
        #if canImport(UIKit)
        return UIAccessibility.isVoiceOverRunning
        #else
        return false
        #endif
    }

    /// Check if Reduce Motion is enabled
    static var isReduceMotionEnabled: Bool {
        #if canImport(UIKit)
        return UIAccessibility.isReduceMotionEnabled
        #else
        return false
        #endif
    }

    /// Check if Bold Text is enabled
    static var isBoldTextEnabled: Bool {
        #if canImport(UIKit)
        return UIAccessibility.isBoldTextEnabled
        #else
        return false
        #endif
    }

    /// Get appropriate animation duration (respects Reduce Motion)
    static func animationDuration(_ defaultDuration: TimeInterval) -> TimeInterval {
        return isReduceMotionEnabled ? 0.01 : defaultDuration
    }

    /// Create accessible button with label and hint
    static func makeAccessibleButton(
        label: String,
        hint: String,
        value: String? = nil,
        traits: AccessibilityTraits = .isButton
    ) -> some ViewModifier {
        return AccessibleButtonModifier(
            label: label,
            hint: hint,
            value: value,
            traits: traits
        )
    }
}

// MARK: - View Modifiers

struct AccessibleButtonModifier: ViewModifier {
    let label: String
    let hint: String
    let value: String?
    let traits: AccessibilityTraits

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityValue(value ?? "")
            .accessibilityAddTraits(traits)
    }
}

struct AccessibleImageModifier: ViewModifier {
    let label: String
    let isDecorative: Bool

    func body(content: Content) -> some View {
        if isDecorative {
            content.accessibilityHidden(true)
        } else {
            content.accessibilityLabel(label)
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Mark as accessible button with label and hint
    func accessibleButton(label: String, hint: String, value: String? = nil) -> some View {
        self.modifier(AccessibleButtonModifier(
            label: label,
            hint: hint,
            value: value,
            traits: .isButton
        ))
    }

    /// Mark as accessible image
    func accessibleImage(label: String, isDecorative: Bool = false) -> some View {
        self.modifier(AccessibleImageModifier(
            label: label,
            isDecorative: isDecorative
        ))
    }

    /// Add currency accessibility
    func accessibleCurrency(amount: Int, type: String) -> some View {
        self
            .accessibilityLabel("\(amount) \(type)")
            .accessibilityHint("Currency amount")
    }

    /// Add upgrade accessibility
    func accessibleUpgrade(
        name: String,
        level: Int,
        cost: Int,
        canAfford: Bool
    ) -> some View {
        self
            .accessibilityLabel("\(name), level \(level)")
            .accessibilityHint(canAfford ? "Tap to upgrade for \(cost) drops" : "Not enough drops, need \(cost)")
            .accessibilityValue("Level \(level)")
            .accessibilityAddTraits(canAfford ? [.isButton] : [.isButton, .isStaticText])
    }

    /// Apply reduced motion alternatives
    func reduceMotionAnimation<V: Equatable>(_ animation: Animation, value: V) -> some View {
        if AccessibilityHelper.isReduceMotionEnabled {
            return self.animation(nil, value: value)
        } else {
            return self.animation(animation, value: value)
        }
    }
}

// MARK: - Color Accessibility

extension Color {
    /// High contrast version of color for accessibility
    func highContrast() -> Color {
        #if canImport(UIKit)
        if UIAccessibility.isDarkerSystemColorsEnabled {
            return self.opacity(1.0) // Full opacity
        }
        #endif
        return self
    }

    /// Check if color has sufficient contrast with background
    static func sufficientContrast(foreground: Color, background: Color) -> Bool {
        // Simplified WCAG contrast ratio check
        // TODO: Implement full WCAG 2.1 contrast calculation
        return true // Placeholder
    }
}

// MARK: - Dynamic Type Support

enum DynamicTypeSize {
    case small
    case medium
    case large
    case extraLarge

    var scaleFactor: CGFloat {
        switch self {
        case .small: return 0.85
        case .medium: return 1.0
        case .large: return 1.15
        case .extraLarge: return 1.3
        }
    }

    static var current: DynamicTypeSize {
        #if canImport(UIKit)
        let contentSize = UIApplication.shared.preferredContentSizeCategory
        switch contentSize {
        case .extraSmall, .small:
            return .small
        case .medium, .large:
            return .medium
        case .extraLarge, .extraExtraLarge:
            return .large
        default:
            return .extraLarge
        }
        #else
        return .medium
        #endif
    }
}

// MARK: - Accessible Game Components

struct AccessibleCurrencyDisplay: View {
    let currency: Currency
    let amount: Int

    var body: some View {
        HStack {
            Text(currency.emoji)
                .accessibilityHidden(true) // Emoji is decorative
            Text("\(amount)")
                .accessibilityLabel("\(amount) \(currency.displayName)")
                .accessibilityAddTraits(.isStaticText)
        }
    }
}

extension Currency {
    var displayName: String {
        switch self {
        case .drop: return "drops"
        case .pearl: return "pearls"
        case .leaf: return "leaves"
        }
    }

    var emoji: String {
        switch self {
        case .drop: return "💧"
        case .pearl: return "🔵"
        case .leaf: return "🍃"
        }
    }
}
