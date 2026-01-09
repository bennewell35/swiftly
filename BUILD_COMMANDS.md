# Terminal Build Commands for Xcode Project

## Prerequisites

Before building from terminal, you need an Xcode project file (`.xcodeproj`). 
If you don't have one yet, see "Creating the Project" section below.

---

## Building from Terminal

Once you have `DailyReadiness.xcodeproj`, use these commands:

### 1. List Available Schemes
```bash
cd /Users/imprvhealth/swiftly
xcodebuild -list -project DailyReadiness.xcodeproj
```

### 2. Build for Simulator
```bash
# Build for iOS Simulator (generic)
xcodebuild \
  -project DailyReadiness.xcodeproj \
  -scheme DailyReadiness \
  -sdk iphonesimulator \
  -configuration Debug \
  build

# Build for specific simulator (e.g., iPhone 15 Pro)
xcodebuild \
  -project DailyReadiness.xcodeproj \
  -scheme DailyReadiness \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -configuration Debug \
  build
```

### 3. Build and Run in Simulator
```bash
# Build, install, and launch in simulator
xcodebuild \
  -project DailyReadiness.xcodeproj \
  -scheme DailyReadiness \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build \
  && xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || true \
  && xcodebuild \
    -project DailyReadiness.xcodeproj \
    -scheme DailyReadiness \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
    test-without-building
```

### 4. Build for Device (requires code signing)
```bash
# Build for physical device (requires valid provisioning profile)
xcodebuild \
  -project DailyReadiness.xcodeproj \
  -scheme DailyReadiness \
  -sdk iphoneos \
  -configuration Release \
  -archivePath ./build/DailyReadiness.xcarchive \
  archive
```

### 5. Clean Build
```bash
# Clean build folder
xcodebuild \
  -project DailyReadiness.xcodeproj \
  -scheme DailyReadiness \
  clean
```

### 6. Build and Export IPA (for distribution)
```bash
# After archiving, export IPA
xcodebuild -exportArchive \
  -archivePath ./build/DailyReadiness.xcarchive \
  -exportPath ./build/export \
  -exportOptionsPlist ExportOptions.plist
```

---

## Quick Build Scripts

### Simple Build Script (`build.sh`)
```bash
#!/bin/bash

PROJECT_NAME="DailyReadiness"
SCHEME="DailyReadiness"
SIMULATOR="iPhone 15 Pro"
SDK="iphonesimulator"

echo "Building $PROJECT_NAME for $SIMULATOR..."

xcodebuild \
  -project "$PROJECT_NAME.xcodeproj" \
  -scheme "$SCHEME" \
  -sdk "$SDK" \
  -destination "platform=iOS Simulator,name=$SIMULATOR" \
  -configuration Debug \
  clean build

if [ $? -eq 0 ]; then
  echo "✅ Build succeeded!"
else
  echo "❌ Build failed!"
  exit 1
fi
```

### Build and Run Script (`build-and-run.sh`)
```bash
#!/bin/bash

PROJECT_NAME="DailyReadiness"
SCHEME="DailyReadiness"
SIMULATOR="iPhone 15 Pro"

echo "Building and running $PROJECT_NAME..."

# Build
xcodebuild \
  -project "$PROJECT_NAME.xcodeproj" \
  -scheme "$SCHEME" \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=$SIMULATOR" \
  build

if [ $? -eq 0 ]; then
  echo "✅ Build succeeded! Launching simulator..."
  
  # Get the app bundle path
  APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "DailyReadiness.app" | head -1)
  
  if [ -n "$APP_PATH" ]; then
    # Boot simulator if needed
    xcrun simctl boot "$SIMULATOR" 2>/dev/null || true
    
    # Install app
    xcrun simctl install "$SIMULATOR" "$APP_PATH"
    
    # Launch app
    xcrun simctl launch --console "$SIMULATOR" com.imprvhealth.DailyReadiness
    
    echo "✅ App launched!"
  else
    echo "❌ Could not find app bundle"
  fi
else
  echo "❌ Build failed!"
  exit 1
fi
```

---

## Listing Available Simulators
```bash
# List all available simulators
xcrun simctl list devices available

# List booted simulators
xcrun simctl list devices | grep Booted
```

---

## Common Build Issues & Solutions

### Issue: "No such scheme"
**Solution:** Make sure the scheme name matches. List schemes first:
```bash
xcodebuild -list -project DailyReadiness.xcodeproj
```

### Issue: "No destination"
**Solution:** List available destinations:
```bash
xcodebuild -project DailyReadiness.xcodeproj -scheme DailyReadiness -showdestinations
```

### Issue: Build folder not found
**Solution:** Build creates output in DerivedData. Find it:
```bash
find ~/Library/Developer/Xcode/DerivedData -name "DailyReadiness.app" -type d
```

### Issue: Code signing errors
**Solution:** For simulator builds, code signing is usually automatic. For device builds, configure signing in Xcode first.

---

## Creating the Project (If You Don't Have One)

You need to create the Xcode project first. Unfortunately, `xcodebuild` cannot create projects - you must use Xcode GUI.

### Option 1: Create in Xcode (Recommended)
1. Open Xcode
2. File → New → Project
3. iOS → App
4. Product Name: `DailyReadiness`
5. Interface: SwiftUI
6. Save in `/Users/imprvhealth/swiftly`
7. Add existing Swift files to the project (don't copy, just reference)

### Option 2: Use XcodeGen (Advanced)
If you want to define the project via YAML:

```bash
# Install XcodeGen
brew install xcodegen

# Create project.yml (see below)
# Then generate project
xcodegen generate
```

**Example `project.yml`:**
```yaml
name: DailyReadiness
options:
  bundleIdPrefix: com.imprvhealth
  deploymentTarget:
    iOS: "17.0"
targets:
  DailyReadiness:
    type: application
    platform: iOS
    sources:
      - path: .
        excludes:
          - "*.md"
          - ".git/**"
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.imprvhealth.DailyReadiness
        SWIFT_VERSION: "5.9"
        IPHONEOS_DEPLOYMENT_TARGET: "17.0"
```

---

## Useful Terminal Aliases

Add these to your `~/.zshrc` or `~/.bashrc`:

```bash
# Quick build for simulator
alias xcode-build-sim='xcodebuild -project DailyReadiness.xcodeproj -scheme DailyReadiness -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 15 Pro" build'

# Quick clean build
alias xcode-clean='xcodebuild -project DailyReadiness.xcodeproj -scheme DailyReadiness clean'

# List schemes
alias xcode-schemes='xcodebuild -list -project DailyReadiness.xcodeproj'

# Open project
alias xcode-open='open DailyReadiness.xcodeproj'
```

Then reload: `source ~/.zshrc`

---

## CI/CD Integration

These commands work great in CI/CD pipelines (GitHub Actions, GitLab CI, etc.):

```yaml
# Example GitHub Actions workflow
- name: Build iOS App
  run: |
    xcodebuild \
      -project DailyReadiness.xcodeproj \
      -scheme DailyReadiness \
      -sdk iphonesimulator \
      -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
      clean build
```

---

## Performance Tips

- Use `-derivedDataPath` to control build output location
- Use `-parallelizeTargets` to build multiple targets simultaneously
- Use `-jobs` to control parallel compilation jobs
- Cache `~/Library/Developer/Xcode/DerivedData` in CI

```bash
# Example with custom derived data path
xcodebuild \
  -project DailyReadiness.xcodeproj \
  -scheme DailyReadiness \
  -derivedDataPath ./build \
  -jobs 8 \
  build
```

