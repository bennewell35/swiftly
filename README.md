# Daily Readiness

A clean SwiftUI iOS app for tracking daily readiness scores and training recommendations.

## Features

- **Daily Check-In**: 5-question assessment (sleep quality, stress level, muscle soreness, motivation, time available)
- **Readiness Score**: Calculated score (0-100) with zone-based recommendations
- **History Tracking**: View last 7 check-ins with interactive trend chart
- **Local Persistence**: Data stored locally using UserDefaults (no backend required)
- **Dark Mode Support**: Automatically adapts to system appearance settings

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

1. Clone the repository
2. Open `DailyReadiness.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (⌘R)

## Project Structure

```
DailyReadiness/
├── DailyReadinessApp.swift       # App entry point and navigation structure
├── Models/
│   └── DailyCheckIn.swift        # Data model (Codable, Identifiable)
├── Services/
│   ├── ReadinessCalculator.swift # Scoring logic (pure functions)
│   └── CheckInStore.swift        # Persistence layer (UserDefaults)
└── Views/
    ├── CheckInView.swift         # Input form with validation
    ├── ResultView.swift          # Score display with color-coded zones
    ├── HistoryView.swift         # History list with Swift Charts
    └── Components/
        └── LabeledSlider.swift   # Reusable slider component
```

## Scoring Algorithm

The readiness score is calculated as follows:

- Start at 100
- Subtract: `stressLevel × 10`
- Subtract: `muscleSoreness × 10`
- Add: `sleepQuality × 10`
- Add: `motivation × 10`
- Clamp final result between 0 and 100

### Readiness Zones

| Score Range | Zone | Recommendation |
|------------|------|----------------|
| 80-100 | Train Hard | Ideal for intense training or challenging workouts |
| 50-79 | Train Moderate | Good shape - moderate workout recommended |
| 0-49 | Recovery | Focus on rest, light stretching, or gentle movement |

## Architecture

This app follows a simple, pragmatic architecture:

- **State Management**: Uses SwiftUI's built-in `@State`, `@ObservedObject`, and `@EnvironmentObject`
- **Business Logic**: Pure functions in `ReadinessCalculator` (no state, easily testable)
- **Data Persistence**: `CheckInStore` manages local storage using UserDefaults
- **Component-Based UI**: Reusable components for maintainability
- **One Check-In Per Day**: Prevents duplicate entries for the same calendar day

## Development

### Branch Strategy

- `main`: Production-ready code
- `staging`: Integration branch for testing before production

### Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Include inline comments for non-obvious logic
- Keep views focused on presentation, logic in services

## License

[Add your license here]

