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
    echo "💡 Try opening the project in Xcode first, or check DerivedData path"
  fi
else
  echo "❌ Build failed!"
  exit 1
fi

