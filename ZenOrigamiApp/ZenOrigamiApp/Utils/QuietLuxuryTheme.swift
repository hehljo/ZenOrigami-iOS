import SwiftUI

/// Quiet Luxury color palette and design system (2026)
/// Forbes Top 10 aesthetic: Understated elegance, refined sophistication
enum QuietLuxuryTheme {

    // MARK: - Neutrals (Primary Palette)

    static let cream = Color(red: 0.96, green: 0.95, blue: 0.93)           // #F5F2ED
    static let warmBeige = Color(red: 0.90, green: 0.87, blue: 0.83)       // #E5DED4
    static let softTaupe = Color(red: 0.78, green: 0.75, blue: 0.71)       // #C7BFB5
    static let mutedGray = Color(red: 0.62, green: 0.60, blue: 0.58)       // #9E9994
    static let charcoal = Color(red: 0.26, green: 0.25, blue: 0.24)        // #42403D

    // MARK: - Accents (Muted & Sophisticated)

    static let softBlueGray = Color(red: 0.61, green: 0.67, blue: 0.71)    // #9BADB5
    static let champagne = Color(red: 0.90, green: 0.86, blue: 0.82)       // #E5DCD1
    static let mutedSage = Color(red: 0.69, green: 0.71, blue: 0.66)       // #B0B5A8
    static let dustyRose = Color(red: 0.82, green: 0.76, blue: 0.75)       // #D1C2BF

    // MARK: - Semantic Colors

    static let background = cream
    static let surface = Color.white
    static let surfaceElevated = warmBeige

    static let textPrimary = charcoal
    static let textSecondary = mutedGray
    static let textTertiary = softTaupe

    static let border = softTaupe.opacity(0.3)
    static let divider = softTaupe.opacity(0.2)

    // MARK: - Interactive States

    static let buttonPrimary = charcoal
    static let buttonSecondary = warmBeige
    static let buttonTertiary = surface

    static let buttonPrimaryText = cream
    static let buttonSecondaryText = charcoal

    // MARK: - Gradients

    static let skyGradient = LinearGradient(
        colors: [
            Color(red: 0.93, green: 0.94, blue: 0.95),  // Very soft blue-gray
            Color(red: 0.96, green: 0.95, blue: 0.93)   // Cream
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let waterGradient = LinearGradient(
        colors: [
            Color(red: 0.61, green: 0.67, blue: 0.71),  // Soft blue-gray
            Color(red: 0.54, green: 0.60, blue: 0.64)   // Slightly darker
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Spacing (8pt Grid System)

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let pill: CGFloat = 999
    }

    // MARK: - Shadows (Minimal & Soft)

    static func softShadow(radius: CGFloat = 8, opacity: Double = 0.08) -> some View {
        EmptyView()
            .shadow(color: charcoal.opacity(opacity), radius: radius, x: 0, y: 2)
    }

    static func elevatedShadow(radius: CGFloat = 12, opacity: Double = 0.12) -> some View {
        EmptyView()
            .shadow(color: charcoal.opacity(opacity), radius: radius, x: 0, y: 4)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply quiet luxury primary button style
    func quietLuxuryButton(
        style: QuietLuxuryButtonStyle = .primary,
        size: QuietLuxuryButtonSize = .medium
    ) -> some View {
        modifier(QuietLuxuryButtonModifier(style: style, size: size))
    }
}

// MARK: - Button Styles

enum QuietLuxuryButtonStyle {
    case primary
    case secondary
    case tertiary
}

enum QuietLuxuryButtonSize {
    case small
    case medium
    case large

    var padding: EdgeInsets {
        switch self {
        case .small:
            return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        case .medium:
            return EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        case .large:
            return EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        }
    }
}

struct QuietLuxuryButtonModifier: ViewModifier {
    let style: QuietLuxuryButtonStyle
    let size: QuietLuxuryButtonSize

    func body(content: Content) -> some View {
        content
            .font(.system(size: size.fontSize, weight: .medium, design: .default))
            .padding(size.padding)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: QuietLuxuryTheme.CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: QuietLuxuryTheme.CornerRadius.md)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: QuietLuxuryTheme.charcoal.opacity(shadowOpacity), radius: 4, x: 0, y: 2)
    }

    var backgroundColor: Color {
        switch style {
        case .primary: return QuietLuxuryTheme.buttonPrimary
        case .secondary: return QuietLuxuryTheme.buttonSecondary
        case .tertiary: return QuietLuxuryTheme.buttonTertiary
        }
    }

    var foregroundColor: Color {
        switch style {
        case .primary: return QuietLuxuryTheme.buttonPrimaryText
        case .secondary, .tertiary: return QuietLuxuryTheme.buttonSecondaryText
        }
    }

    var borderColor: Color {
        switch style {
        case .primary: return .clear
        case .secondary, .tertiary: return QuietLuxuryTheme.border
        }
    }

    var borderWidth: CGFloat {
        switch style {
        case .primary: return 0
        case .secondary, .tertiary: return 1
        }
    }

    var shadowOpacity: Double {
        switch style {
        case .primary: return 0.12
        case .secondary: return 0.06
        case .tertiary: return 0.03
        }
    }
}
