# Quick Start: Create Xcode Project

You have two options to create the Xcode project:

## Option 0: Automated Setup Script (Easiest!)

Just run:
```bash
cd /Users/imprvhealth/swiftly
./setup-project.sh
```

This will check if XcodeGen is installed and generate the project automatically, or guide you through manual setup.

---

## Option 1: Using XcodeGen (Recommended - Terminal-Based)

This generates the project from YAML configuration - perfect for terminal workflow!

### Step 1: Install XcodeGen
```bash
brew install xcodegen
```

If you don't have Homebrew installed:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 2: Generate the Project
```bash
cd /Users/imprvhealth/swiftly
xcodegen generate
```

This will create `DailyReadiness.xcodeproj` automatically!

### Step 3: Verify It Works
```bash
xcodebuild -list -project DailyReadiness.xcodeproj
```

You should see the schemes and targets listed.

### Step 4: Build from Terminal
```bash
./build.sh
# or
xcodebuild -project DailyReadiness.xcodeproj -scheme DailyReadiness -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
```

---

## Option 2: Manual Creation in Xcode (Alternative)

If you prefer the GUI or XcodeGen isn't working:

### Step 1: Open Xcode
```bash
open -a Xcode
```

### Step 2: Create New Project
1. **File → New → Project** (or ⌘⇧N)
2. Choose **iOS** → **App**
3. Click **Next**

### Step 3: Configure Project
- **Product Name:** `DailyReadiness`
- **Team:** Select your team (or leave None for personal use)
- **Organization Identifier:** `com.imprvhealth`
- **Bundle Identifier:** Will auto-populate as `com.imprvhealth.DailyReadiness`
- **Interface:** **SwiftUI** ⚠️ (important!)
- **Language:** **Swift**
- **Storage:** **None** (uncheck Core Data)
- **Include Tests:** Your choice (recommended: checked)
- Click **Next**

### Step 4: Save Location
- Navigate to `/Users/imprvhealth/swiftly`
- **IMPORTANT:** Make sure "Create Git repository" is **UNCHECKED** (we already have git initialized)
- Click **Create**

### Step 5: Delete Default Files
Xcode will create default files. Delete these:
- Right-click `DailyReadinessApp.swift` in Project Navigator → Delete → Move to Trash
- Right-click `ContentView.swift` in Project Navigator → Delete → Move to Trash

### Step 6: Add Your Existing Swift Files
1. In Xcode Project Navigator, right-click the project name (`DailyReadiness`)
2. Select **Add Files to "DailyReadiness"...**
3. Navigate to `/Users/imprvhealth/swiftly`
4. Select these files/folders (⌘+Click to multi-select):
   - `DailyReadinessApp.swift`
   - `Models/` folder
   - `Services/` folder
   - `Views/` folder
5. **IMPORTANT Settings:**
   - ✅ Check "Create groups" (NOT "Create folder references")
   - ❌ UNCHECK "Copy items if needed" (files are already in the right place)
   - ✅ Make sure "Add to targets: DailyReadiness" is checked
6. Click **Add**

### Step 7: Configure Build Settings
1. Click the project name (`DailyReadiness`) in Project Navigator (blue icon at top)
2. Select the **DailyReadiness** target (under TARGETS)
3. Go to **General** tab
4. Set **Minimum Deployments** to **iOS 17.0**
5. Go to **Build Settings** tab
6. Search for "Swift Language Version"
7. Set to **Swift 5** (or Swift 5.9 if available)

### Step 8: Build and Run
- Select a simulator from the device menu (e.g., iPhone 15 Pro)
- Press **⌘R** or click the Play button
- The app should build and launch!

---

## Verify Everything Works

After either option, test your setup:

```bash
cd /Users/imprvhealth/swiftly

# List schemes
xcodebuild -list -project DailyReadiness.xcodeproj

# Build for simulator
./build.sh

# Or build manually
xcodebuild \
  -project DailyReadiness.xcodeproj \
  -scheme DailyReadiness \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build
```

---

## Troubleshooting

### "xcodegen: command not found"
Install Homebrew first, then install xcodegen:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install xcodegen
```

### "No such file or directory: DailyReadiness.xcodeproj"
You need to generate/create the project first. Follow Option 1 or 2 above.

### "No scheme named 'DailyReadiness'"
The scheme should be created automatically. If not, open the project in Xcode and check the scheme dropdown. You may need to create it manually in Xcode.

### Build errors about missing files
Make sure all Swift files are added to the target:
1. Select a file in Xcode
2. Open File Inspector (right panel)
3. Under "Target Membership", ensure "DailyReadiness" is checked

---

## Next Steps

Once the project is created:
1. ✅ You can build from terminal: `./build.sh`
2. ✅ You can build and run: `./build-and-run.sh`
3. ✅ You can open in Xcode: `open DailyReadiness.xcodeproj`
4. ✅ You can use all the commands in `BUILD_COMMANDS.md`

