# DailyReadiness Tests

This directory contains unit tests for the DailyReadiness app using XCTest.

## Test Files

- **ReadinessCalculatorTests.swift** - Tests for score calculation, zone determination, and recommendations
- **CheckInStoreTests.swift** - Tests for data persistence, retrieval, and business logic
- **DailyCheckInTests.swift** - Tests for the data model, date handling, and Codable conformance

## Running Tests

### In Xcode

1. Open `DailyReadiness.xcodeproj` in Xcode
2. Press `Cmd + U` to run all tests
3. Or select a specific test file/function and press `Cmd + U`

### Command Line

```bash
# Generate Xcode project (if using XcodeGen)
xcodegen generate

# Run all tests
xcodebuild test \
  -project DailyReadiness.xcodeproj \
  -scheme DailyReadiness \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.2' \
  -configuration Debug

# Run specific test class
xcodebuild test \
  -project DailyReadiness.xcodeproj \
  -scheme DailyReadiness \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.2' \
  -only-testing:DailyReadinessTests/ReadinessCalculatorTests
```

## Test Coverage

Current test coverage includes:

- ✅ ReadinessCalculator (100% coverage)
  - Score calculation with various inputs
  - Zone determination (train hard, moderate, recovery)
  - Recommendation text generation
  - Boundary conditions and edge cases

- ✅ CheckInStore (Core functionality)
  - Adding check-ins
  - Sorting by date
  - Replacing same-day check-ins
  - Recent check-ins retrieval
  - Has check-in for today logic

- ✅ DailyCheckIn Model
  - Initialization
  - Date handling (isToday)
  - Date formatting
  - Codable conformance
  - Identifiable conformance

## Adding New Tests

When adding new features:

1. Create a test file following the naming convention: `[ComponentName]Tests.swift`
2. Import the module: `@testable import DailyReadiness`
3. Use descriptive test names: `test[Component]_[Scenario]_[ExpectedResult]()`
4. Follow AAA pattern: Arrange, Act, Assert
5. Test edge cases and error conditions

Example:

```swift
import XCTest
@testable import DailyReadiness

final class MyComponentTests: XCTestCase {
    func testMyComponent_ValidInput_ReturnsExpectedResult() {
        // Arrange
        let input = "test"
        
        // Act
        let result = MyComponent.process(input)
        
        // Assert
        XCTAssertEqual(result, "expected")
    }
}
```

## CI/CD Integration

Tests run automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`

See `.github/workflows/ios-ci.yml` for CI configuration.

