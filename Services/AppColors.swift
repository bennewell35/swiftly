import SwiftUI

/// Professional color scheme for the Daily Readiness app.
///
/// Architecture note: Centralized color definitions ensure consistency
/// across the app and make it easy to update the theme. These colors
/// adapt automatically to light and dark mode.
struct AppColors {
    // Primary brand colors - sophisticated, professional palette
    static let primary = Color(red: 0.20, green: 0.40, blue: 0.85)  // Deep professional blue
    static let primaryDark = Color(red: 0.15, green: 0.30, blue: 0.75)
    
    // Background gradients
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.97, blue: 1.0),  // Soft white-blue
            Color(red: 0.92, green: 0.94, blue: 0.98)  // Light gray-blue
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradientDark = LinearGradient(
        colors: [
            Color(red: 0.10, green: 0.12, blue: 0.18),  // Dark blue-gray
            Color(red: 0.08, green: 0.10, blue: 0.15)   // Darker blue-gray
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Readiness zone colors - refined, professional tones
    static let trainHard = Color(red: 0.15, green: 0.65, blue: 0.35)      // Professional green
    static let trainModerate = Color(red: 0.95, green: 0.60, blue: 0.20)  // Warm amber
    static let recovery = Color(red: 0.85, green: 0.30, blue: 0.35)       // Muted red
    
    // Glass morphism colors
    static let glassLight = Color.white.opacity(0.15)
    static let glassDark = Color.black.opacity(0.15)
    
    // Text colors
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textOnGlass = Color.primary
    
    /// Returns the appropriate background gradient based on color scheme
    static func background(for colorScheme: ColorScheme) -> LinearGradient {
        colorScheme == .dark ? backgroundGradientDark : backgroundGradient
    }
    
    /// Returns glass material that adapts to color scheme
    static func glassMaterial(for colorScheme: ColorScheme) -> Material {
        .ultraThinMaterial
    }
}

