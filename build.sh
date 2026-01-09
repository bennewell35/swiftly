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

