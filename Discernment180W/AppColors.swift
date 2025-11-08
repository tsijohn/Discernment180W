import SwiftUI

// MARK: - App Color System for Dark Mode Support
// This provides a centralized color system that automatically adapts to dark/light mode

struct AppColors {
    // MARK: - Background Colors
    static let primaryBackground = Color(.systemBackground) // White in light, black in dark
    static let secondaryBackground = Color(.secondarySystemBackground) // Light gray in light, dark gray in dark
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)

    // MARK: - Text Colors
    static let primaryText = Color(.label) // Black in light, white in dark
    static let secondaryText = Color(.secondaryLabel) // Gray in both modes, adjusted for contrast
    static let tertiaryText = Color(.tertiaryLabel)
    static let placeholderText = Color(.placeholderText)

    // MARK: - UI Element Colors
    static let separator = Color(.separator)
    static let opaqueSeparator = Color(.opaqueSeparator)
    static let systemFill = Color(.systemFill)
    static let secondarySystemFill = Color(.secondarySystemFill)
    static let tertiarySystemFill = Color(.tertiarySystemFill)

    // MARK: - Card/Form Colors
    static let cardBackground = Color(.systemBackground)
    static let cardBorder = Color(.separator)
    static let formBackground = Color(.secondarySystemBackground)
    static let formFieldBackground = Color(.systemBackground)

    // MARK: - Button Colors
    static let buttonBackground = Color(.systemBlue)
    static let buttonText = Color.white // Always white on colored buttons
    static let secondaryButtonBackground = Color(.secondarySystemFill)
    static let disabledButtonBackground = Color(.systemGray4)

    // MARK: - System Grays (Adaptive)
    static let systemGray = Color(.systemGray)
    static let systemGray2 = Color(.systemGray2)
    static let systemGray3 = Color(.systemGray3)
    static let systemGray4 = Color(.systemGray4)
    static let systemGray5 = Color(.systemGray5)
    static let systemGray6 = Color(.systemGray6)

    // MARK: - Brand Colors with Dark Mode Variants
    @Environment(\.colorScheme) private var colorScheme

    // Primary brand blue - adapts for dark mode
    static func primaryBlue(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.3, green: 0.5, blue: 0.8)  // Lighter blue for dark mode
            : Color(hex: "#132A47")  // Original dark blue for light mode
    }

    // Gold/accent color - adapts for dark mode
    static func goldAccent(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(hex: "#FFD700")  // Brighter gold for dark mode
            : Color(hex: "#DAA520")  // Original goldenrod for light mode
    }

    // Orange accent - adapts for dark mode
    static func orangeAccent(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(hex: "#FF9F40")  // Brighter orange for dark mode
            : Color(hex: "#d89e63")  // Original orange for light mode
    }
}

// MARK: - Semantic Color Extensions
// These provide semantic names for common use cases

extension AppColors {
    // Headers and titles
    static let headerBackground = primaryBlue(for: .light) // Will need @Environment in views
    static let headerText = Color.white

    // Forms and inputs
    static let inputBackground = formFieldBackground
    static let inputBorder = separator
    static let inputText = primaryText

    // Alerts and status
    static let successColor = Color.green
    static let warningColor = Color.orange
    static let errorColor = Color.red
    static let infoColor = Color.blue

    // Navigation
    static let navigationBackground = primaryBackground
    static let navigationTint = primaryBlue(for: .light) // Will need @Environment in views

    // Content areas
    static let contentBackground = primaryBackground
    static let contentCardBackground = cardBackground
}

// MARK: - View Modifier for Adaptive Colors
// This modifier helps apply the correct color based on color scheme

struct AdaptiveColorModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let lightColor: Color
    let darkColor: Color
    let colorProperty: ColorProperty

    enum ColorProperty {
        case foreground
        case background
    }

    func body(content: Content) -> some View {
        let color = colorScheme == .dark ? darkColor : lightColor

        switch colorProperty {
        case .foreground:
            return AnyView(content.foregroundColor(color))
        case .background:
            return AnyView(content.background(color))
        }
    }
}

extension View {
    func adaptiveColor(light: Color, dark: Color, for property: AdaptiveColorModifier.ColorProperty = .foreground) -> some View {
        self.modifier(AdaptiveColorModifier(lightColor: light, darkColor: dark, colorProperty: property))
    }
}

// MARK: - Gradient Helpers for Dark Mode

struct AdaptiveGradient {
    @Environment(\.colorScheme) var colorScheme

    static func goldGradient(for colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#FFD700"),
                    Color(hex: "#FFA500"),
                    Color(hex: "#FF8C00")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#FFD700"),
                    Color(hex: "#DAA520"),
                    Color(hex: "#B8860B")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    static func blueGradient(for colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.4, blue: 0.7),
                    Color(red: 0.3, green: 0.5, blue: 0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#1A3556"),
                    Color(hex: "#132A47")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - Convenience Methods for Common Patterns

extension Color {
    // Initialize with hex but provide dark mode variant
    init(hex lightHex: String, darkHex: String, for colorScheme: ColorScheme) {
        if colorScheme == .dark {
            self.init(hex: darkHex)
        } else {
            self.init(hex: lightHex)
        }
    }

    // Common adaptive colors as static properties
    static let adaptiveCardBackground = AppColors.cardBackground
    static let adaptiveText = AppColors.primaryText
    static let adaptiveSecondaryText = AppColors.secondaryText
    static let adaptiveBorder = AppColors.separator
    static let adaptiveFormBackground = AppColors.formBackground
}