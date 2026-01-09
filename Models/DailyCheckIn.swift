import Foundation

/// Represents a single daily readiness check-in.
/// 
/// Architecture note: This model is intentionally simple and pure data.
/// It conforms to Codable so it can be easily serialized to/from JSON
/// for persistence in UserDefaults. Identifiable is required for SwiftUI
/// list rendering and enables automatic list item tracking.
struct DailyCheckIn: Codable, Identifiable {
    let id: UUID
    let date: Date
    let sleepQuality: Int        // 1-5
    let stressLevel: Int         // 1-5
    let muscleSoreness: Int      // 1-5
    let motivation: Int          // 1-5
    let timeAvailable: Int       // 0-120 minutes
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        sleepQuality: Int,
        stressLevel: Int,
        muscleSoreness: Int,
        motivation: Int,
        timeAvailable: Int
    ) {
        self.id = id
        self.date = date
        self.sleepQuality = sleepQuality
        self.stressLevel = stressLevel
        self.muscleSoreness = muscleSoreness
        self.motivation = motivation
        self.timeAvailable = timeAvailable
    }
    
    /// Returns true if this check-in was recorded today (same calendar day).
    /// Used to prevent duplicate entries for the same day.
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    /// Returns a formatted date string for display.
    /// Example: "Jan 15, 2024"
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

