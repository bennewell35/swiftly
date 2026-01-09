import Foundation

/// Manages persistence of daily check-ins using UserDefaults.
///
/// Architecture note: This is a simple persistence layer. We use UserDefaults
/// rather than Core Data because:
/// 1. The data model is simple (just an array of check-ins)
/// 2. No complex queries needed
/// 3. UserDefaults is sufficient for small amounts of data (< 100KB)
///
/// We use a class with ObservableObject to allow views to react to data changes.
/// The @Published property will trigger view updates when check-ins are added/removed.
@MainActor
class CheckInStore: ObservableObject {
    /// The array of all stored check-ins, sorted by date (newest first).
    /// 
    /// Architecture note: @Published means any view observing this object
    /// will automatically update when this array changes. This is SwiftUI's
    /// reactive data binding system.
    @Published var checkIns: [DailyCheckIn] = []
    
    private let storageKey = "dailyCheckIns"
    
    init() {
        loadCheckIns()
    }
    
    /// Loads check-ins from UserDefaults.
    /// 
    /// Architecture note: This is called during init, so the app loads
    /// existing data immediately on launch. We decode JSON data that was
    /// previously encoded and stored.
    private func loadCheckIns() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            // No existing data - start with empty array
            return
        }
        
        do {
            let decoder = JSONDecoder()
            checkIns = try decoder.decode([DailyCheckIn].self, from: data)
            // Sort by date descending (newest first) for better UX
            checkIns.sort { $0.date > $1.date }
        } catch {
            print("Failed to load check-ins: \(error)")
            checkIns = []
        }
    }
    
    /// Saves check-ins to UserDefaults.
    /// 
    /// Architecture note: We encode to JSON for storage. This method is
    /// called after any mutation to persist changes.
    private func saveCheckIns() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(checkIns)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save check-ins: \(error)")
        }
    }
    
    /// Adds a new check-in, replacing any existing check-in for the same day.
    ///
    /// Architecture note: This method ensures only one check-in per calendar day.
    /// If the user already checked in today, we remove the old one and add the new.
    /// This prevents duplicates while allowing updates.
    ///
    /// - Parameter checkIn: The check-in to add
    func addCheckIn(_ checkIn: DailyCheckIn) {
        // Remove any existing check-in for the same calendar day
        let calendar = Calendar.current
        checkIns.removeAll { existingCheckIn in
            calendar.isDate(existingCheckIn.date, inSameDayAs: checkIn.date)
        }
        
        // Add the new check-in
        checkIns.append(checkIn)
        
        // Sort by date descending (newest first)
        checkIns.sort { $0.date > $1.date }
        
        // Persist to storage
        saveCheckIns()
    }
    
    /// Returns the last N check-ins, or all if there are fewer than N.
    ///
    /// - Parameter count: Maximum number of check-ins to return
    /// - Returns: Array of the most recent check-ins
    func recentCheckIns(count: Int = 7) -> [DailyCheckIn] {
        Array(checkIns.prefix(count))
    }
    
    /// Returns true if a check-in exists for today.
    /// Used to prevent duplicate submissions on the same day.
    func hasCheckInForToday() -> Bool {
        checkIns.contains { $0.isToday }
    }
}

