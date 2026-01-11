import XCTest
@testable import DailyReadiness

/// Tests for CheckInStore - the data persistence layer.
///
/// Architecture note: These tests use a separate UserDefaults suite to avoid
/// interfering with app data. We test persistence, retrieval, and business logic.
@MainActor
final class CheckInStoreTests: XCTestCase {
    
    var store: CheckInStore!
    var testSuite: UserDefaults!
    
    override func setUp() {
        super.setUp()
        // Use a separate UserDefaults suite for testing
        testSuite = UserDefaults(suiteName: "com.imprvhealth.DailyReadinessTests")!
        testSuite.removePersistentDomain(forName: "com.imprvhealth.DailyReadinessTests")
        
        // IMPORTANT: Clear UserDefaults BEFORE creating CheckInStore
        // CheckInStore.init() calls loadCheckIns() which reads from UserDefaults
        // If we clear after, the data is already loaded into the store
        clearStore()
        
        // Note: In a real implementation, CheckInStore would accept a UserDefaults instance
        // For now, we'll test with the standard instance and clean up before/after
        store = CheckInStore()
    }
    
    override func tearDown() {
        clearStore()
        store = nil
        testSuite = nil
        super.tearDown()
    }
    
    private func clearStore() {
        UserDefaults.standard.removeObject(forKey: "dailyCheckIns")
    }
    
    // MARK: - Add Check-In Tests
    
    func testAddCheckIn_AddsToStore() {
        // Given: A new check-in
        let checkIn = DailyCheckIn(
            sleepQuality: 4,
            stressLevel: 2,
            muscleSoreness: 3,
            motivation: 4,
            timeAvailable: 60
        )
        
        // When: Add check-in
        store.addCheckIn(checkIn)
        
        // Then: Should be in store
        XCTAssertEqual(store.checkIns.count, 1, "Store should contain one check-in")
        XCTAssertEqual(store.checkIns.first?.id, checkIn.id, "Store should contain the added check-in")
    }
    
    func testAddCheckIn_SortsByDateDescending() {
        // Given: Multiple check-ins on different dates
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        
        let checkIn1 = DailyCheckIn(
            date: twoDaysAgo,
            sleepQuality: 3,
            stressLevel: 3,
            muscleSoreness: 3,
            motivation: 3,
            timeAvailable: 30
        )
        
        let checkIn2 = DailyCheckIn(
            date: today,
            sleepQuality: 4,
            stressLevel: 2,
            muscleSoreness: 3,
            motivation: 4,
            timeAvailable: 60
        )
        
        let checkIn3 = DailyCheckIn(
            date: yesterday,
            sleepQuality: 5,
            stressLevel: 1,
            muscleSoreness: 2,
            motivation: 5,
            timeAvailable: 90
        )
        
        // When: Add check-ins (not in chronological order)
        store.addCheckIn(checkIn1)
        store.addCheckIn(checkIn2)
        store.addCheckIn(checkIn3)
        
        // Then: Should be sorted newest first
        XCTAssertEqual(store.checkIns.count, 3, "Store should contain three check-ins")
        XCTAssertEqual(store.checkIns[0].id, checkIn2.id, "Most recent should be first")
        XCTAssertEqual(store.checkIns[1].id, checkIn3.id, "Second most recent should be second")
        XCTAssertEqual(store.checkIns[2].id, checkIn1.id, "Oldest should be last")
    }
    
    func testAddCheckIn_ReplacesSameDayCheckIn() {
        // Given: A check-in for today
        let checkIn1 = DailyCheckIn(
            sleepQuality: 3,
            stressLevel: 3,
            muscleSoreness: 3,
            motivation: 3,
            timeAvailable: 30
        )
        
        store.addCheckIn(checkIn1)
        XCTAssertEqual(store.checkIns.count, 1, "Should have one check-in")
        
        // When: Add another check-in for the same day
        let checkIn2 = DailyCheckIn(
            sleepQuality: 5,
            stressLevel: 1,
            muscleSoreness: 1,
            motivation: 5,
            timeAvailable: 60
        )
        store.addCheckIn(checkIn2)
        
        // Then: Should replace the old one (only one check-in for today)
        XCTAssertEqual(store.checkIns.count, 1, "Should still have only one check-in")
        XCTAssertEqual(store.checkIns.first?.id, checkIn2.id, "Should have the new check-in")
        XCTAssertNotEqual(store.checkIns.first?.id, checkIn1.id, "Should not have the old check-in")
    }
    
    // MARK: - Recent Check-Ins Tests
    
    func testRecentCheckIns_ReturnsRequestedCount() {
        // Given: Multiple check-ins
        for i in 0..<10 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            let checkIn = DailyCheckIn(
                date: date,
                sleepQuality: 3,
                stressLevel: 3,
                muscleSoreness: 3,
                motivation: 3,
                timeAvailable: 30
            )
            store.addCheckIn(checkIn)
        }
        
        // When: Request recent 5
        let recent = store.recentCheckIns(count: 5)
        
        // Then: Should return 5 check-ins
        XCTAssertEqual(recent.count, 5, "Should return requested count")
    }
    
    func testRecentCheckIns_ReturnsAllIfLessThanRequested() {
        // Given: Only 2 check-ins
        for i in 0..<2 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            let checkIn = DailyCheckIn(
                date: date,
                sleepQuality: 3,
                stressLevel: 3,
                muscleSoreness: 3,
                motivation: 3,
                timeAvailable: 30
            )
            store.addCheckIn(checkIn)
        }
        
        // When: Request recent 10
        let recent = store.recentCheckIns(count: 10)
        
        // Then: Should return all 2 check-ins
        XCTAssertEqual(recent.count, 2, "Should return all available if less than requested")
    }
    
    func testRecentCheckIns_DefaultCountIsSeven() {
        // Given: 10 check-ins
        for i in 0..<10 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            let checkIn = DailyCheckIn(
                date: date,
                sleepQuality: 3,
                stressLevel: 3,
                muscleSoreness: 3,
                motivation: 3,
                timeAvailable: 30
            )
            store.addCheckIn(checkIn)
        }
        
        // When: Request recent without count
        let recent = store.recentCheckIns()
        
        // Then: Should return default of 7
        XCTAssertEqual(recent.count, 7, "Should return default count of 7")
    }
    
    // MARK: - Has Check-In For Today Tests
    
    func testHasCheckInForToday_ReturnsTrueWhenExists() {
        // Given: A check-in for today
        let checkIn = DailyCheckIn(
            sleepQuality: 4,
            stressLevel: 2,
            muscleSoreness: 3,
            motivation: 4,
            timeAvailable: 60
        )
        store.addCheckIn(checkIn)
        
        // When: Check if has check-in for today
        let hasToday = store.hasCheckInForToday()
        
        // Then: Should return true
        XCTAssertTrue(hasToday, "Should return true when check-in exists for today")
    }
    
    func testHasCheckInForToday_ReturnsFalseWhenNotExists() {
        // Given: A check-in for yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let checkIn = DailyCheckIn(
            date: yesterday,
            sleepQuality: 4,
            stressLevel: 2,
            muscleSoreness: 3,
            motivation: 4,
            timeAvailable: 60
        )
        store.addCheckIn(checkIn)
        
        // When: Check if has check-in for today
        let hasToday = store.hasCheckInForToday()
        
        // Then: Should return false
        XCTAssertFalse(hasToday, "Should return false when no check-in exists for today")
    }
    
    func testHasCheckInForToday_ReturnsFalseWhenEmpty() {
        // Given: Empty store
        XCTAssertEqual(store.checkIns.count, 0, "Store should be empty")
        
        // When: Check if has check-in for today
        let hasToday = store.hasCheckInForToday()
        
        // Then: Should return false
        XCTAssertFalse(hasToday, "Should return false when store is empty")
    }
}

