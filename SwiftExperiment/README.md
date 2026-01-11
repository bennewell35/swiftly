# Swift Experiment

A learning sandbox iOS app built with Swift + SwiftUI + AWS Amplify, designed to mirror modern production practices aligned with SupraHuman's technology stack.

## Purpose

This app exists for:
1. **Learning Swift deeply** - Understanding iOS-native patterns vs React/JS mental models
2. **Ramping on SupraHuman's stack** - AWS Amplify integration (Auth, API, DataStore)
3. **Establishing engineering hygiene** - CI/CD, linting, PR templates, testing patterns

## Architecture

```
SwiftExperiment/
├── Sources/
│   ├── App/                    # App entry point and root navigation
│   │   ├── SwiftExperimentApp.swift
│   │   └── RootView.swift
│   ├── Features/               # Feature modules (vertical slices)
│   │   ├── Auth/               # Login/signup flow
│   │   ├── Dashboard/          # Main dashboard
│   │   └── Notes/              # Notes CRUD feature
│   ├── Services/               # Business logic and data layer
│   │   ├── AuthService.swift   # Amplify Auth wrapper
│   │   └── NotesService.swift  # Notes persistence
│   └── Models/                 # Data models
│       └── Note.swift
├── Resources/                  # App configuration
│   ├── Info.plist
│   └── SwiftExperiment.entitlements
├── Tests/                      # Unit tests
├── .github/                    # CI/CD and PR templates
│   ├── workflows/
│   │   └── ios-ci.yml
│   └── PULL_REQUEST_TEMPLATE/
├── project.yml                 # XcodeGen configuration
├── Package.swift               # Swift Package Manager manifest
└── .swiftlint.yml              # Linting rules
```

## Key Concepts Demonstrated

### SwiftUI State Management

| Wrapper | Purpose | React Equivalent |
|---------|---------|------------------|
| `@State` | Local view state (value types) | `useState()` |
| `@Binding` | Two-way binding to parent's state | Props with onChange |
| `@StateObject` | Create & own an observable object | `createContext()` provider |
| `@ObservedObject` | Reference an observable object | Props for class instances |
| `@EnvironmentObject` | Access shared objects from environment | `useContext()` |
| `@Published` | Property that triggers view updates | Redux state |

### Async/Await in Swift

```swift
// Swift
func fetchData() async throws -> Data {
    let result = try await URLSession.shared.data(from: url)
    return result.0
}

// Calling from synchronous context
Task {
    do {
        let data = try await fetchData()
    } catch {
        print(error)
    }
}
```

### View Lifecycle

- `onAppear` - View appeared (like componentDidMount)
- `onDisappear` - View disappeared (like componentWillUnmount)
- `task` - Run async code on appear, auto-cancel on disappear
- `onChange(of:)` - React to value changes (like useEffect with deps)

## AWS Amplify Integration

### Services Used

| Service | Purpose | AWS Backend |
|---------|---------|-------------|
| **Amplify Auth** | User authentication | Amazon Cognito |
| **Amplify API** | REST/GraphQL APIs | API Gateway / AppSync |
| **Amplify DataStore** | Offline-first data | DynamoDB + AppSync |

### Why Amplify Auth (Cognito)?

1. **Enterprise-grade security** - HIPAA compliant, SOC certified
2. **Token management** - Automatic refresh, secure storage
3. **Social login** - Google, Apple, Facebook out of the box
4. **MFA support** - SMS, TOTP, biometric
5. **User management** - AWS Console for user administration

### Configuration (Production Setup)

1. Install Amplify CLI: `npm install -g @aws-amplify/cli`
2. Initialize: `amplify init`
3. Add auth: `amplify add auth`
4. Push to AWS: `amplify push`
5. Copy `amplifyconfiguration.json` to app

## Running the App

### Prerequisites

- Xcode 15.0+
- macOS Sonoma (14.0+)
- iOS 17.0+ simulator or device
- (Optional) XcodeGen: `brew install xcodegen`
- (Optional) SwiftLint: `brew install swiftlint`

### Setup

```bash
# Clone the repository
cd SwiftExperiment

# Generate Xcode project (if using XcodeGen)
xcodegen generate

# Open in Xcode
open SwiftExperiment.xcodeproj

# Or use SPM directly
swift build
```

### Running Tests

```bash
# Via Xcode
Cmd + U

# Via command line
xcodebuild test \
  -project SwiftExperiment.xcodeproj \
  -scheme SwiftExperiment \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Common Mistakes from React/JS

| React Pattern | Swift Pitfall | Correct Swift Approach |
|---------------|---------------|------------------------|
| `useState` for everything | Using `@State` for shared state | Use `@StateObject` for shared objects |
| Inline object creation | Creating objects in view body | Create once in `@StateObject` or outside view |
| `useEffect` for everything | Complex `onAppear` logic | Use `.task` for async, `onChange` for reactions |
| Props drilling | Passing through many levels | Use `@EnvironmentObject` |
| Mutable objects | Mutating data directly | Use immutable structs, create new instances |

## Production Considerations

What this experiment demonstrates that SupraHuman would expect:

- [ ] Clean architecture with separation of concerns
- [ ] Type-safe API responses with Codable
- [ ] Proper error handling (no silent failures)
- [ ] Loading states and user feedback
- [ ] Accessibility support (VoiceOver, Dynamic Type)
- [ ] Dark mode support
- [ ] Offline-first data strategy
- [ ] Automated testing (unit, integration, UI)
- [ ] CI/CD pipeline (build, lint, test)
- [ ] Code review hygiene (PR templates, conventions)

## License

This is a learning project. Use freely for educational purposes.
