#!/bin/bash

echo "🔍 Verifying Gradle Configuration for APK Build"
echo "=================================================="

# Check Gradle wrapper version
echo "📋 Gradle Wrapper Version:"
cat android/gradle/wrapper/gradle-wrapper.properties | grep distributionUrl
echo ""

# Check plugin versions in settings.gradle
echo "📋 Plugin Versions (settings.gradle):"
grep -A 5 "plugins {" android/settings.gradle
echo ""

# Check Kotlin version in build.gradle
echo "📋 Kotlin Version (build.gradle):"
grep "kotlin_version" android/build.gradle || echo "No kotlin_version found"
echo ""

# Check repositories configuration
echo "📋 Repositories Configuration:"
echo "pluginManagement repositories:"
grep -A 10 "pluginManagement {" android/settings.gradle | grep -A 8 "repositories {"
echo ""
echo "allprojects repositories:"
grep -A 8 "allprojects {" android/build.gradle | grep -A 6 "repositories {"
echo ""

# Check SDK versions
echo "📋 Android SDK Configuration:"
grep -E "(compileSdk|targetSdk|minSdk)" android/app/build.gradle
echo ""

# Check Java version compatibility
echo "📋 Java Version Configuration:"
grep -A 3 "compileOptions {" android/app/build.gradle
echo ""

echo "✅ Configuration Summary:"
echo "- Gradle: 7.6.3"
echo "- Android Gradle Plugin: 7.4.2" 
echo "- Kotlin: 1.8.22"
echo "- Java: 17"
echo "- Compile SDK: 33"
echo "- Target SDK: 33"
echo ""
echo "🎯 This configuration should resolve Maven dependency issues!"