#!/bin/bash

# Quick test script for Fast Reading App in iOS Simulator
# This script helps you quickly build and test the app

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Fast Reading App - Quick Simulator Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script requires macOS"
    echo "   iOS Simulator only runs on macOS"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed"
    echo "   Please install Xcode from the Mac App Store"
    exit 1
fi

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    echo "❌ Error: Rust is not installed"
    echo "   Install from: https://rustup.rs/"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Step 1: Build Rust library
echo "📦 Step 1: Building Rust library for iOS..."
cd fast-reading-core

if [ ! -f "build-ios.sh" ]; then
    echo "❌ Error: build-ios.sh not found"
    exit 1
fi

./build-ios.sh
cd ..

echo "✅ Rust library built successfully"
echo ""

# Step 2: Check if ios-lib directory exists
if [ ! -d "ios-lib" ]; then
    echo "❌ Error: ios-lib directory not created"
    echo "   The Rust build may have failed"
    exit 1
fi

echo "✅ iOS libraries generated:"
ls -lh ios-lib/
echo ""

# Step 3: Check for Xcode project
echo "📱 Step 2: Checking for Xcode project..."

if [ ! -f "FastReadingApp.xcodeproj/project.pbxproj" ] && [ ! -d "FastReadingApp.xcodeproj" ]; then
    echo "⚠️  Warning: Xcode project not found"
    echo ""
    echo "To create the Xcode project:"
    echo "1. Open Xcode"
    echo "2. File → New → Project"
    echo "3. Choose iOS App"
    echo "4. Follow QUICKSTART.md for setup"
    echo ""
    echo "After creating the project, run this script again."
    exit 1
fi

echo "✅ Xcode project found"
echo ""

# Step 4: Start simulator
echo "🚀 Step 3: Starting iOS Simulator..."

# Get list of available simulators
SIMULATOR_NAME="iPhone 15 Pro"

# Try to boot the simulator
echo "   Booting $SIMULATOR_NAME..."
xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || echo "   (Simulator already booted or using fallback)"

# Open Simulator app
echo "   Opening Simulator app..."
open -a Simulator

echo "✅ Simulator started"
echo ""

# Step 5: Instructions for building
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎉 Ready to test!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "1. Open your Xcode project:"
echo "   open FastReadingApp.xcodeproj"
echo ""
echo "2. In Xcode, press ⌘+R to build and run"
echo ""
echo "3. The app will launch in the simulator"
echo ""
echo "For more details, see SIMULATOR_GUIDE.md"
echo ""

# Optional: Open Xcode if project exists
if [ -f "FastReadingApp.xcodeproj/project.pbxproj" ]; then
    read -p "Open Xcode project now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open FastReadingApp.xcodeproj
        echo "✅ Xcode opened - Press ⌘+R to build and run!"
    fi
fi
