import Foundation
import SwiftUI

/// Calculates readiness score based on check-in inputs.
///
/// Architecture note: This is a pure function service - no state, no side effects.
/// All logic is static, making it easy to test and reason about. Business logic
/// lives here rather than in views to keep views focused on presentation.
/// 
/// Note: We import SwiftUI here only for the Color type. This is acceptable because
/// this calculator is app-specific, not a generic library that needs framework independence.
struct ReadinessCalculator {
    
    /// Calculates readiness score (0-100) based on check-in inputs.
    ///
    /// Scoring algorithm:
    /// - Start at 100
    /// - Subtract: stress * 10
    /// - Subtract: soreness * 10
    /// - Add: sleep * 10
    /// - Add: motivation * 10
    /// - Clamp result between 0 and 100
    ///
    /// - Parameter checkIn: The daily check-in data
    /// - Returns: A score between 0 and 100
    static func calculateScore(for checkIn: DailyCheckIn) -> Int {
        var score = 100
        
        // Subtract negative factors
        score -= checkIn.stressLevel * 10
        score -= checkIn.muscleSoreness * 10
        
        // Add positive factors
        score += checkIn.sleepQuality * 10
        score += checkIn.motivation * 10
        
        // Clamp to valid range
        return max(0, min(100, score))
    }
    
    /// Determines the readiness zone based on score.
    ///
    /// - Parameter score: The calculated readiness score
    /// - Returns: The readiness zone (train hard, moderate, or recovery)
    static func zone(for score: Int) -> ReadinessZone {
        switch score {
        case 80...100:
            return .trainHard
        case 50..<80:
            return .trainModerate
        default:
            return .recovery
        }
    }
    
    /// Returns the recommendation text for a given zone.
    ///
    /// - Parameter zone: The readiness zone
    /// - Returns: User-facing recommendation text
    static func recommendation(for zone: ReadinessZone) -> String {
        switch zone {
        case .trainHard:
            return "Train hard"
        case .trainModerate:
            return "Train moderate"
        case .recovery:
            return "Focus on recovery"
        }
    }
    
    /// Returns the SwiftUI Color for a zone.
    /// 
    /// Architecture note: We use SwiftUI system colors that automatically
    /// adapt to dark mode. System colors like .green, .orange, .red are
    /// semantically meaningful and look great in both light and dark modes.
    ///
    /// - Parameter zone: The readiness zone
    /// - Returns: A SwiftUI Color appropriate for the zone
    static func color(for zone: ReadinessZone) -> Color {
        switch zone {
        case .trainHard:
            return .green
        case .trainModerate:
            return .orange
        case .recovery:
            return .red
        }
    }
}

/// Represents the readiness training zone.
enum ReadinessZone {
    case trainHard      // 80-100
    case trainModerate  // 50-79
    case recovery       // < 50
}

