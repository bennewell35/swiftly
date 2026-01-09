# Quick Setup Guide for Xcode

## Option 1: Create New Xcode Project (Recommended)

1. **Open Xcode** (if not already open)

2. **Create New Project:**
   - File → New → Project (or ⌘⇧N)
   - Choose **iOS** → **App**
   - Click **Next**

3. **Configure Project:**
   - **Product Name:** `DailyReadiness`
   - **Team:** Select your team (or leave None)
   - **Organization Identifier:** `com.imprvhealth` (or your preference)
   - **Bundle Identifier:** Will auto-populate as `com.imprvhealth.DailyReadiness`
   - **Interface:** **SwiftUI**
   - **Language:** **Swift**
   - **Storage:** Core Data (uncheck this - we're using UserDefaults)
   - **Include Tests:** Optional (recommended: checked)
   - Click **Next**

4. **Choose Location:**
   - Navigate to `/Users/imprvhealth/swiftly`
   - **IMPORTANT:** Check "Create Git repository" is **UNCHECKED** (we already have git initialized)
   - Click **Create**

5. **Replace Default Files:**
   - Delete the default `ContentView.swift` and `DailyReadinessApp.swift` files Xcode created
   - In Xcode, right-click the project → **Add Files to "DailyReadiness"...**
   - Select all the existing Swift files:
     - `DailyReadinessApp.swift`
     - `Models/DailyCheckIn.swift`
     - `Services/CheckInStore.swift`
     - `Services/ReadinessCalculator.swift`
     - `Views/CheckInView.swift`
     - `Views/ResultView.swift`
     - `Views/HistoryView.swift`
     - `Views/Components/LabeledSlider.swift`
   - Make sure "Copy items if needed" is **UNCHECKED**
   - Make sure "Create groups" is selected
   - Click **Add**

6. **Configure Build Settings:**
   - Select the project in the navigator
   - Select the **DailyReadiness** target
   - Go to **General** tab
   - Set **Minimum Deployments** to **iOS 17.0**
   - Go to **Build Settings** tab
   - Search for "Swift Language Version"
   - Ensure it's set to **Swift 5** or later

7. **Build and Run:**
   - Select a simulator (e.g., iPhone 15 Pro) from the device menu
   - Press **⌘R** or click the Play button
   - The app should build and launch in the simulator!

## Option 2: Command Line (if you prefer terminal)

If you have Xcode command-line tools and want to create it via script, you can use:

```bash
# This would require additional setup - Option 1 is easier
```

## Troubleshooting

**If you get compilation errors:**
- Make sure all files are added to the target (check Target Membership in File Inspector)
- Ensure iOS deployment target is 17.0+
- Clean build folder: Product → Clean Build Folder (⇧⌘K)

**If Charts don't work:**
- Make sure you're building for iOS 16+ (we're using iOS 17+)
- Charts framework is built-in to iOS 16+

**If simulator doesn't launch:**
- Check Xcode → Settings → Platforms → iOS Simulator is installed
- Try: Xcode → Open Developer Tool → Simulator

