#!/bin/bash

echo "🚀 Daily Readiness - Project Setup"
echo "===================================="
echo ""

# Check if XcodeGen is installed
if command -v xcodegen &> /dev/null; then
    echo "✅ XcodeGen is installed"
    echo ""
    echo "Generating Xcode project..."
    xcodegen generate
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Project generated successfully!"
        echo ""
        echo "Next steps:"
        echo "1. Verify: xcodebuild -list -project DailyReadiness.xcodeproj"
        echo "2. Build: ./build.sh"
        echo "3. Open: open DailyReadiness.xcodeproj"
    else
        echo ""
        echo "❌ Failed to generate project"
        echo "Check project.yml for errors"
        exit 1
    fi
else
    echo "❌ XcodeGen is not installed"
    echo ""
    echo "To install XcodeGen (recommended):"
    echo "  brew install xcodegen"
    echo ""
    echo "If you don't have Homebrew:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo ""
    echo "Alternatively, create the project manually in Xcode:"
    echo "  See QUICK_START.md for detailed instructions"
    echo ""
    echo "Manual steps:"
    echo "1. Open Xcode"
    echo "2. File → New → Project"
    echo "3. iOS → App → SwiftUI"
    echo "4. Save in /Users/imprvhealth/swiftly"
    echo "5. Delete default files, add your Swift files"
    echo ""
    exit 1
fi

