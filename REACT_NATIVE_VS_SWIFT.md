# React Native vs Swift/SwiftUI: Key Differences

Coming from React Native? Here are the main differences you'll notice:

---

## 🎯 **1. Language & Syntax**

### React Native (JavaScript/TypeScript)
```javascript
// JavaScript - dynamically typed, flexible
const [count, setCount] = useState(0);
const name = "Daily Readiness";
const handlePress = () => { ... };
```

### Swift/SwiftUI
```swift
// Swift - statically typed, type-safe
@State private var count: Int = 0
let name: String = "Daily Readiness"
func handlePress() { ... }
```

**Key Differences:**
- ✅ **Swift is type-safe** - compiler catches errors before runtime
- ✅ **Optionals** - `String?` vs `String` (handles null explicitly)
- ✅ **Strong typing** - `Int` vs `Double` matters (no automatic coercion)
- ❌ **More verbose** - but catches bugs early

---

## 🎨 **2. State Management**

### React Native
```javascript
// React hooks
const [data, setData] = useState([]);
const [loading, setLoading] = useState(false);

// Context API for global state
const { user } = useContext(UserContext);

// Redux for complex state
dispatch({ type: 'ADD_CHECKIN', payload: checkIn });
```

### SwiftUI
```swift
// Local state
@State private var data: [CheckIn] = []
@State private var loading: Bool = false

// Shared observable object (like Context)
@ObservedObject var store: CheckInStore

// Environment object (global, like Provider)
@EnvironmentObject var store: CheckInStore

// Property wrappers handle reactivity automatically
```

**Key Differences:**
- ✅ **SwiftUI is more declarative** - state changes automatically update UI
- ✅ **Less boilerplate** - no `setState`, no reducers for simple cases
- ✅ **Built-in reactivity** - `@Published` = automatic re-renders
- ⚠️ **Different mental model** - property wrappers vs hooks

---

## 🖼️ **3. UI Components**

### React Native
```jsx
// JSX - JavaScript in markup
<View style={styles.container}>
  <Text style={styles.title}>Hello</Text>
  <Button title="Press" onPress={handlePress} />
  <FlatList data={items} renderItem={...} />
</View>
```

### SwiftUI
```swift
// SwiftUI - Swift code as UI (DSL)
VStack {
    Text("Hello")
        .font(.title)
    Button("Press") {
        handlePress()
    }
    List(items) { item in
        Text(item.name)
    }
}
```

**Key Differences:**
- ✅ **SwiftUI is pure Swift** - no separate template language
- ✅ **More type-safe** - compiler validates UI structure
- ✅ **Less styling code** - modifiers instead of StyleSheet objects
- ⚠️ **Different component names** - `VStack` not `View`, `List` not `FlatList`

**Component Mapping:**
| React Native | SwiftUI |
|--------------|---------|
| `<View>` | `VStack`, `HStack`, `ZStack` |
| `<Text>` | `Text()` |
| `<ScrollView>` | `ScrollView` |
| `<FlatList>` | `List` or `ForEach` |
| `<Button>` | `Button()` |
| `<TextInput>` | `TextField()` |
| `<Image>` | `Image()` |

---

## 📱 **4. Navigation**

### React Native
```javascript
// React Navigation
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

<Stack.Navigator>
  <Stack.Screen name="Home" component={HomeScreen} />
  <Stack.Screen name="Details" component={DetailsScreen} />
</Stack.Navigator>

// Navigate
navigation.navigate('Details', { itemId: 42 });
```

### SwiftUI
```swift
// Built-in NavigationStack
NavigationStack {
    List(items) { item in
        NavigationLink(value: item) {
            Text(item.name)
        }
    }
    .navigationDestination(for: Item.self) { item in
        DetailsView(item: item)
    }
}

// Programmatic navigation
@State private var path = NavigationPath()
path.append(item)
```

**Key Differences:**
- ✅ **Built-in** - no extra libraries needed (iOS 16+)
- ✅ **Type-safe** - navigation destinations are typed
- ⚠️ **iOS-only** - SwiftUI navigation only works on iOS
- 📚 **Learning curve** - different API than React Navigation

---

## 🔄 **5. Data Flow & Props**

### React Native
```javascript
// Props drilling
function Parent() {
  const data = fetchData();
  return <Child data={data} />;
}

function Child({ data }) {
  return <GrandChild data={data} />;
}

// Context to avoid drilling
const DataContext = createContext();
<DataContext.Provider value={data}>
  <Child />  // Can access via useContext
</DataContext.Provider>
```

### SwiftUI
```swift
// Direct passing (like props)
struct Parent: View {
    let data = fetchData()
    var body: some View {
        Child(data: data)
    }
}

struct Child: View {
    let data: Data  // Like props
    var body: some View {
        GrandChild(data: data)
    }
}

// Environment to avoid drilling
.environmentObject(store)  // Available to all children
@EnvironmentObject var store: Store  // Access anywhere
```

**Key Differences:**
- ✅ **Similar concepts** - props = direct parameters, context = environment
- ✅ **Type-safe props** - struct properties are typed, not objects
- ✅ **Less boilerplate** - no Context.Provider setup needed

---

## 💾 **6. Persistence**

### React Native
```javascript
// AsyncStorage (React Native)
import AsyncStorage from '@react-native-async-storage/async-storage';

await AsyncStorage.setItem('key', JSON.stringify(data));
const data = JSON.parse(await AsyncStorage.getItem('key'));

// Redux Persist, MMKV, etc.
```

### SwiftUI
```swift
// UserDefaults (built-in)
UserDefaults.standard.set(data, forKey: "key")
let data = UserDefaults.standard.data(forKey: "key")

// @AppStorage (SwiftUI wrapper)
@AppStorage("key") var value: String = ""

// Core Data, SwiftData for complex data
```

**Key Differences:**
- ✅ **Built-in options** - UserDefaults, @AppStorage are native
- ✅ **Type-safe** - @AppStorage handles types automatically
- ⚠️ **No direct JSON** - need Codable for custom objects (but it's powerful)

---

## 🏗️ **7. Build & Development**

### React Native
```bash
# JavaScript bundler (Metro)
npm start
# Runs Metro bundler, hot reload

# Build
npx react-native run-ios
npx react-native run-android

# Cross-platform from one codebase
```

### Swift/SwiftUI
```bash
# Xcode only (no command-line dev server)
# Open Xcode → Build (⌘R)
# Simulator launches automatically

# iOS only (by default)
# Need separate codebase for Android
```

**Key Differences:**
- ❌ **No hot reload** - but Xcode has previews (faster than full build)
- ❌ **iOS-only** - SwiftUI doesn't work on Android (need SwiftUI for Android or separate code)
- ✅ **Native performance** - no JavaScript bridge
- ✅ **Better debugging** - Xcode debugger is powerful
- ✅ **Live Previews** - see UI changes instantly (like hot reload)

---

## 🎭 **8. Styling**

### React Native
```javascript
// StyleSheet API
const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#fff',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000',
  }
});

<View style={styles.container}>
  <Text style={styles.title}>Hello</Text>
</View>
```

### SwiftUI
```swift
// Modifiers (method chaining)
VStack {
    Text("Hello")
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(.primary)
}
.padding()
.background(Color.white)

// Or custom ViewModifier
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(12)
    }
}
```

**Key Differences:**
- ✅ **More intuitive** - modifiers read like natural language
- ✅ **Type-safe colors** - `.blue`, `.primary` (adapts to dark mode)
- ✅ **Composable** - modifiers can be combined/extracted
- ⚠️ **Different syntax** - method chaining vs object styles

---

## 🧪 **9. Testing**

### React Native
```javascript
// Jest + React Native Testing Library
import { render, fireEvent } from '@testing-library/react-native';

test('button press works', () => {
  const { getByText } = render(<Button title="Press" />);
  fireEvent.press(getByText('Press'));
  // Assert
});
```

### SwiftUI
```swift
// XCTest (built-in)
import XCTest
@testable import DailyReadiness

func testScoreCalculation() {
    let checkIn = DailyCheckIn(...)
    let score = ReadinessCalculator.calculateScore(for: checkIn)
    XCTAssertEqual(score, 85)
}

// UI Testing (separate)
let app = XCUIApplication()
app.launch()
app.buttons["Submit"].tap()
```

**Key Differences:**
- ✅ **Built-in testing** - XCTest comes with Xcode
- ✅ **Type-safe tests** - compiler catches test errors
- ⚠️ **Different approach** - unit tests + UI tests (separate targets)

---

## 📊 **10. Performance**

| Aspect | React Native | Swift/SwiftUI |
|--------|--------------|---------------|
| **Rendering** | JavaScript → Native Bridge | Direct native |
| **Startup Time** | Slower (JS bundle load) | Faster (native binary) |
| **Animations** | 60fps (with effort) | 60fps (native) |
| **Memory** | Higher (JS runtime) | Lower (native) |
| **App Size** | Larger (JS runtime + bundle) | Smaller (just Swift code) |

---

## 🎓 **11. Learning Curve**

### If you know React Native, you'll find SwiftUI:
- ✅ **Familiar concepts** - components, state, props
- ✅ **Declarative UI** - similar mental model
- ⚠️ **Different syntax** - Swift vs JavaScript
- ⚠️ **Type system** - need to learn optionals, generics
- ⚠️ **iOS ecosystem** - Xcode, CocoaPods, SPM vs npm

### The Good News:
- SwiftUI was **inspired by React** - Apple engineers studied React
- Same core ideas: declarative, component-based, reactive
- If you understand React, SwiftUI will feel familiar (with new syntax)

---

## 🎯 **Quick Mental Model Translation**

| Concept | React Native | SwiftUI |
|---------|--------------|---------|
| Component | `function Component()` | `struct Component: View` |
| State | `useState()` | `@State` |
| Props | Function parameters | Struct properties |
| Context | `createContext()` | `@EnvironmentObject` |
| Effect | `useEffect()` | `.onAppear()` / `.task()` |
| Conditional | `{condition && <View />}` | `if condition { View() }` |
| Loop | `{items.map(...)}` | `ForEach(items) { ... }` |
| Style | `style={styles.x}` | `.modifier()` |

---

## 🚀 **Bottom Line**

**React Native is great when you need:**
- ✅ Cross-platform (iOS + Android)
- ✅ Large JavaScript ecosystem
- ✅ Faster iteration (hot reload)
- ✅ Web developers can contribute

**Swift/SwiftUI is great when you need:**
- ✅ Native iOS performance
- ✅ Platform-specific features (widgets, shortcuts, etc.)
- ✅ Better App Store integration
- ✅ Type safety and compiler checks
- ✅ Apple ecosystem integration

**For your Daily Readiness app:** SwiftUI makes sense because it's iOS-only, uses native iOS features (UserDefaults, Charts), and you're learning iOS development!

