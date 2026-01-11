import XCTest
@testable import DailyReadiness

/// Tests for ReadinessCalculator - the core business logic for score calculation.
///
/// Architecture note: These are unit tests for pure functions, making them
/// easy to test without mocking or setup. We test edge cases and boundary conditions.
final class ReadinessCalculatorTests: XCTestCase {
    
    // MARK: - Score Calculation Tests
    
    func testCalculateScore_OptimalInputs_ReturnsMaximumScore() {
        // Given: Perfect inputs (sleep 5, stress 1, soreness 1, motivation 5)
        let checkIn = DailyCheckIn(
            sleepQuality: 5,
            stressLevel: 1,
            muscleSoreness: 1,
            motivation: 5,
            timeAvailable: 60
        )
        
        // When: Calculate score
        let score = ReadinessCalculator.calculateScore(for: checkIn)
        
        // Then: Should be maximum (100 - 10 - 10 + 50 + 50 = 180, clamped to 100)
        XCTAssertEqual(score, 100, "Perfect inputs should yield maximum score")
    }
    
    func testCalculateScore_PoorInputs_ReturnsMinimumScore() {
        // Given: Worst inputs (sleep 1, stress 5, soreness 5, motivation 1)
        let checkIn = DailyCheckIn(
            sleepQuality: 1,
            stressLevel: 5,
            muscleSoreness: 5,
            motivation: 1,
            timeAvailable: 0
        )
        
        // When: Calculate score
        let score = ReadinessCalculator.calculateScore(for: checkIn)
        
        // Then: Should be minimum (100 - 50 - 50 + 10 + 10 = 20, but clamped to 0 if negative)
        XCTAssertEqual(score, 20, "Poor inputs should yield low score")
    }
    
    func testCalculateScore_AverageInputs_ReturnsMidRangeScore() {
        // Given: Average inputs (all 3s)
        let checkIn = DailyCheckIn(
            sleepQuality: 3,
            stressLevel: 3,
            muscleSoreness: 3,
            motivation: 3,
            timeAvailable: 30
        )
        
        // When: Calculate score
        let score = ReadinessCalculator.calculateScore(for: checkIn)
        
        // Then: Should be mid-range (100 - 30 - 30 + 30 + 30 = 100)
        XCTAssertEqual(score, 100, "Average inputs should yield mid-range score")
    }
    
    func testCalculateScore_ClampsToValidRange() {
        // Given: Extreme inputs that would exceed bounds
        let checkIn = DailyCheckIn(
            sleepQuality: 5,
            stressLevel: 1,
            muscleSoreness: 1,
            motivation: 5,
            timeAvailable: 120
        )
        
        // When: Calculate score
        let score = ReadinessCalculator.calculateScore(for: checkIn)
        
        // Then: Should be clamped to 0-100 range
        XCTAssertGreaterThanOrEqual(score, 0, "Score should not be negative")
        XCTAssertLessThanOrEqual(score, 100, "Score should not exceed 100")
    }
    
    // MARK: - Zone Determination Tests
    
    func testZone_TrainHard_ReturnsCorrectZone() {
        // Given: Score in train hard range (80-100)
        let scores = [80, 85, 90, 95, 100]
        
        for score in scores {
            // When: Get zone
            let zone = ReadinessCalculator.zone(for: score)
            
            // Then: Should be train hard
            XCTAssertEqual(zone, .trainHard, "Score \(score) should be train hard zone")
        }
    }
    
    func testZone_TrainModerate_ReturnsCorrectZone() {
        // Given: Score in moderate range (50-79)
        let scores = [50, 60, 65, 70, 79]
        
        for score in scores {
            // When: Get zone
            let zone = ReadinessCalculator.zone(for: score)
            
            // Then: Should be train moderate
            XCTAssertEqual(zone, .trainModerate, "Score \(score) should be train moderate zone")
        }
    }
    
    func testZone_Recovery_ReturnsCorrectZone() {
        // Given: Score in recovery range (0-49)
        let scores = [0, 10, 25, 40, 49]
        
        for score in scores {
            // When: Get zone
            let zone = ReadinessCalculator.zone(for: score)
            
            // Then: Should be recovery
            XCTAssertEqual(zone, .recovery, "Score \(score) should be recovery zone")
        }
    }
    
    // MARK: - Recommendation Tests
    
    func testRecommendation_ReturnsCorrectText() {
        XCTAssertEqual(
            ReadinessCalculator.recommendation(for: .trainHard),
            "Train hard",
            "Train hard zone should return correct recommendation"
        )
        
        XCTAssertEqual(
            ReadinessCalculator.recommendation(for: .trainModerate),
            "Train moderate",
            "Train moderate zone should return correct recommendation"
        )
        
        XCTAssertEqual(
            ReadinessCalculator.recommendation(for: .recovery),
            "Focus on recovery",
            "Recovery zone should return correct recommendation"
        )
    }
    
    // MARK: - Integration Tests
    
    func testCalculateScoreAndZone_Integration() {
        // Given: A realistic check-in
        let checkIn = DailyCheckIn(
            sleepQuality: 4,
            stressLevel: 2,
            muscleSoreness: 3,
            motivation: 4,
            timeAvailable: 45
        )
        
        // When: Calculate score and zone
        let score = ReadinessCalculator.calculateScore(for: checkIn)
        let zone = ReadinessCalculator.zone(for: score)
        let recommendation = ReadinessCalculator.recommendation(for: zone)
        
        // Then: All should be consistent
        XCTAssertGreaterThanOrEqual(score, 0)
        XCTAssertLessThanOrEqual(score, 100)
        XCTAssertFalse(recommendation.isEmpty, "Recommendation should not be empty")
        
        // Verify zone matches score range
        switch zone {
        case .trainHard:
            XCTAssertGreaterThanOrEqual(score, 80)
        case .trainModerate:
            XCTAssertGreaterThanOrEqual(score, 50)
            XCTAssertLessThan(score, 80)
        case .recovery:
            XCTAssertLessThan(score, 50)
        }
    }
}

