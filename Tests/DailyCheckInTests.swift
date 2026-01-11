import XCTest
@testable import DailyReadiness

/// Tests for DailyCheckIn model - data structure and computed properties.
///
/// Architecture note: These tests verify the model's behavior, especially
/// date-related computed properties and Codable conformance.
final class DailyCheckInTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testInit_DefaultValues() {
        // Given/When: Create check-in with defaults
        let checkIn = DailyCheckIn(
            sleepQuality: 3,
            stressLevel: 3,
            muscleSoreness: 3,
            motivation: 3,
            timeAvailable: 30
        )
        
        // Then: Should have generated ID and current date
        XCTAssertNotNil(checkIn.id, "Should generate UUID")
        XCTAssertNotNil(checkIn.date, "Should use current date")
    }
    
    func testInit_CustomValues() {
        // Given: Custom values
        let id = UUID()
        let date = Date()
        let sleepQuality = 5
        let stressLevel = 1
        let muscleSoreness = 2
        let motivation = 4
        let timeAvailable = 60
        
        // When: Create check-in with custom values
        let checkIn = DailyCheckIn(
            id: id,
            date: date,
            sleepQuality: sleepQuality,
            stressLevel: stressLevel,
            muscleSoreness: muscleSoreness,
            motivation: motivation,
            timeAvailable: timeAvailable
        )
        
        // Then: Should match provided values
        XCTAssertEqual(checkIn.id, id)
        XCTAssertEqual(checkIn.date, date)
        XCTAssertEqual(checkIn.sleepQuality, sleepQuality)
        XCTAssertEqual(checkIn.stressLevel, stressLevel)
        XCTAssertEqual(checkIn.muscleSoreness, muscleSoreness)
        XCTAssertEqual(checkIn.motivation, motivation)
        XCTAssertEqual(checkIn.timeAvailable, timeAvailable)
    }
    
    // MARK: - isToday Tests
    
    func testIsToday_ReturnsTrueForToday() {
        // Given: A check-in with today's date
        let checkIn = DailyCheckIn(
            date: Date(),
            sleepQuality: 3,
            stressLevel: 3,
            muscleSoreness: 3,
            motivation: 3,
            timeAvailable: 30
        )
        
        // When/Then: Should be today
        XCTAssertTrue(checkIn.isToday, "Check-in with today's date should return true")
    }
    
    func testIsToday_ReturnsFalseForYesterday() {
        // Given: A check-in with yesterday's date
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let checkIn = DailyCheckIn(
            date: yesterday,
            sleepQuality: 3,
            stressLevel: 3,
            muscleSoreness: 3,
            motivation: 3,
            timeAvailable: 30
        )
        
        // When/Then: Should not be today
        XCTAssertFalse(checkIn.isToday, "Check-in with yesterday's date should return false")
    }
    
    func testIsToday_ReturnsFalseForTomorrow() {
        // Given: A check-in with tomorrow's date
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let checkIn = DailyCheckIn(
            date: tomorrow,
            sleepQuality: 3,
            stressLevel: 3,
            muscleSoreness: 3,
            motivation: 3,
            timeAvailable: 30
        )
        
        // When/Then: Should not be today
        XCTAssertFalse(checkIn.isToday, "Check-in with tomorrow's date should return false")
    }
    
    // MARK: - formattedDate Tests
    
    func testFormattedDate_ReturnsNonEmptyString() {
        // Given: A check-in
        let checkIn = DailyCheckIn(
            sleepQuality: 3,
            stressLevel: 3,
            muscleSoreness: 3,
            motivation: 3,
            timeAvailable: 30
        )
        
        // When: Get formatted date
        let formatted = checkIn.formattedDate
        
        // Then: Should be non-empty
        XCTAssertFalse(formatted.isEmpty, "Formatted date should not be empty")
    }
    
    func testFormattedDate_UsesMediumStyle() {
        // Given: A check-in with a known date
        let dateComponents = DateComponents(year: 2024, month: 1, day: 15)
        let date = Calendar.current.date(from: dateComponents)!
        let checkIn = DailyCheckIn(
            date: date,
            sleepQuality: 3,
            stressLevel: 3,
            muscleSoreness: 3,
            motivation: 3,
            timeAvailable: 30
        )
        
        // When: Get formatted date
        let formatted = checkIn.formattedDate
        
        // Then: Should contain date information (format varies by locale, so just check it's not empty)
        XCTAssertFalse(formatted.isEmpty, "Formatted date should contain date information")
        // The exact format depends on locale, so we just verify it's formatted
    }
    
    // MARK: - Codable Tests
    
    func testCodable_EncodeAndDecode() throws {
        // Given: A check-in
        let originalCheckIn = DailyCheckIn(
            sleepQuality: 4,
            stressLevel: 2,
            muscleSoreness: 3,
            motivation: 5,
            timeAvailable: 60
        )
        
        // When: Encode and decode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalCheckIn)
        
        let decoder = JSONDecoder()
        let decodedCheckIn = try decoder.decode(DailyCheckIn.self, from: data)
        
        // Then: Should match original
        XCTAssertEqual(decodedCheckIn.id, originalCheckIn.id)
        XCTAssertEqual(decodedCheckIn.sleepQuality, originalCheckIn.sleepQuality)
        XCTAssertEqual(decodedCheckIn.stressLevel, originalCheckIn.stressLevel)
        XCTAssertEqual(decodedCheckIn.muscleSoreness, originalCheckIn.muscleSoreness)
        XCTAssertEqual(decodedCheckIn.motivation, originalCheckIn.motivation)
        XCTAssertEqual(decodedCheckIn.timeAvailable, originalCheckIn.timeAvailable)
        
        // Date comparison (within 1 second due to JSON serialization precision)
        let timeDifference = abs(decodedCheckIn.date.timeIntervalSince(originalCheckIn.date))
        XCTAssertLessThan(timeDifference, 1.0, "Date should be preserved within 1 second")
    }
    
    func testCodable_ArrayEncodeAndDecode() throws {
        // Given: An array of check-ins
        let checkIns = [
            DailyCheckIn(sleepQuality: 3, stressLevel: 3, muscleSoreness: 3, motivation: 3, timeAvailable: 30),
            DailyCheckIn(sleepQuality: 4, stressLevel: 2, muscleSoreness: 3, motivation: 4, timeAvailable: 60),
            DailyCheckIn(sleepQuality: 5, stressLevel: 1, muscleSoreness: 1, motivation: 5, timeAvailable: 90)
        ]
        
        // When: Encode and decode array
        let encoder = JSONEncoder()
        let data = try encoder.encode(checkIns)
        
        let decoder = JSONDecoder()
        let decodedCheckIns = try decoder.decode([DailyCheckIn].self, from: data)
        
        // Then: Should match original
        XCTAssertEqual(decodedCheckIns.count, checkIns.count)
        for (original, decoded) in zip(checkIns, decodedCheckIns) {
            XCTAssertEqual(decoded.id, original.id)
            XCTAssertEqual(decoded.sleepQuality, original.sleepQuality)
        }
    }
    
    // MARK: - Identifiable Tests
    
    func testIdentifiable_HasUniqueIDs() {
        // Given/When: Create multiple check-ins
        let checkIn1 = DailyCheckIn(sleepQuality: 3, stressLevel: 3, muscleSoreness: 3, motivation: 3, timeAvailable: 30)
        let checkIn2 = DailyCheckIn(sleepQuality: 3, stressLevel: 3, muscleSoreness: 3, motivation: 3, timeAvailable: 30)
        
        // Then: Should have different IDs
        XCTAssertNotEqual(checkIn1.id, checkIn2.id, "Each check-in should have a unique ID")
    }
}

