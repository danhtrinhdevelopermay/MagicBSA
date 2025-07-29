#!/bin/bash

echo "Testing Flutter build..."

# Clean first
flutter clean
flutter pub get

# Check for critical errors only
flutter analyze --no-fatal-infos 2>&1 | grep "error •" > analyze_errors.txt

if [ -s analyze_errors.txt ]; then
    echo "Critical errors found:"
    cat analyze_errors.txt
    echo "Fix these errors before building APK"
    exit 1
else
    echo "No critical errors found. Attempting build..."
    flutter build apk --release --verbose --no-tree-shake-icons --no-shrink
fi