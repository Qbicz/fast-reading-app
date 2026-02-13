# iOS Simulator Testing Guide

This guide explains how to start and use the iOS Simulator to test the Fast Reading App.

## Overview

```
┌─────────────────────────────────────────────────────────┐
│                   Testing Workflow                       │
└─────────────────────────────────────────────────────────┘

1. Build Rust Library          2. Open Xcode           3. Run in Simulator
   ┌──────────────┐              ┌──────────────┐        ┌──────────────┐
   │ make build-ios│             │ open project  │        │   ⌘ + R       │
   │      or       │──────────►  │   configure   │───────►│  (Build+Run)  │
   │ ./build-ios.sh│             │  link libs    │        │              │
   └──────────────┘              └──────────────┘        └──────────────┘
                                                                 │
                                                                 ▼
                                                         ┌──────────────┐
                                                         │  Simulator   │
                                                         │   Opens &    │
                                                         │  App Runs!   │
                                                         └──────────────┘
```

## Prerequisites

Before starting the simulator, ensure you have:

1. ✅ **Xcode installed** - Download from Mac App Store
2. ✅ **Rust library built** - Run `make build-ios` or `cd fast-reading-core && ./build-ios.sh`
3. ✅ **Xcode project created** - Follow QUICKSTART.md steps 1-5
4. ✅ **macOS system** - iOS Simulator only runs on macOS

## Quick Start - Run from Xcode

The easiest way to start the simulator and test your app:

### Method 1: Using Xcode (Recommended)

1. **Open your Xcode project**
   ```bash
   open FastReadingApp.xcodeproj
   ```

2. **Select a simulator** from the device menu (top toolbar):
   - Click on the device dropdown (shows "iPhone 15 Pro" or similar)
   - Choose from available simulators:
     - iPhone 15 Pro
     - iPhone 15
     - iPhone 14 Pro
     - iPad Pro
     - etc.

3. **Build and Run**:
   - Press `⌘ + R` (Cmd + R)
   - OR click the ▶️ Play button in the toolbar
   - OR menu: Product → Run

4. **Wait for the simulator to start**:
   - First launch may take 1-2 minutes
   - Simulator window will appear
   - Your app will automatically install and launch

### Method 2: Using Command Line

If you prefer command line, you can use `xcodebuild` and `xcrun`:

#### Step 1: List Available Simulators

```bash
xcrun simctl list devices available
```

This shows all available simulators like:
```
== Devices ==
-- iOS 17.2 --
    iPhone 15 (UDID-HERE) (Shutdown)
    iPhone 15 Pro (UDID-HERE) (Shutdown)
    iPad Pro (12.9-inch) (UDID-HERE) (Shutdown)
```

#### Step 2: Boot a Simulator

```bash
# Boot by name (recommended)
xcrun simctl boot "iPhone 15 Pro"

# OR boot by UDID if you have it
xcrun simctl boot UDID-HERE
```

#### Step 3: Open Simulator App

```bash
open -a Simulator
```

The Simulator window will appear showing your chosen device.

#### Step 4: Build and Install Your App

From your project directory:

```bash
# Build for simulator
xcodebuild -scheme FastReadingApp \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build

# Install the app to the running simulator
xcrun simctl install booted path/to/FastReadingApp.app

# Launch the app
xcrun simctl launch booted com.yourname.FastReadingApp
```

**Note**: The exact bundle ID depends on your Organization Identifier set in Xcode.

## Common Simulator Operations

### Check Simulator Status

```bash
# List all devices and their status
xcrun simctl list devices

# Show only booted simulators
xcrun simctl list devices | grep Booted
```

### Start a Specific Simulator

```bash
# Boot iPhone 15 Pro
xcrun simctl boot "iPhone 15 Pro"

# Boot iPad
xcrun simctl boot "iPad Pro (12.9-inch) (6th generation)"
```

### Shutdown Simulator

```bash
# Shutdown specific device
xcrun simctl shutdown "iPhone 15 Pro"

# Shutdown all running simulators
xcrun simctl shutdown all
```

### Delete and Reset Simulator

```bash
# Erase all data from a simulator (like factory reset)
xcrun simctl erase "iPhone 15 Pro"

# Delete a simulator entirely
xcrun simctl delete "iPhone 15 Pro"
```

### Install App Manually

```bash
# Install your built app
xcrun simctl install booted /path/to/FastReadingApp.app
```

### Uninstall App

```bash
xcrun simctl uninstall booted com.yourname.FastReadingApp
```

### Open URL in Simulator

```bash
xcrun simctl openurl booted "https://example.com"
```

## Simulator Shortcuts (When Simulator is Active)

- **⌘ + 1, 2, 3** - Scale simulator window (100%, 75%, 50%)
- **⌘ + K** - Toggle keyboard
- **⌘ + Shift + H** - Home button
- **⌘ + Shift + H + H** - App switcher (double-press home)
- **⌘ + L** - Lock screen
- **⌃ + ⌘ + Z** - Shake device
- **⌘ + →** - Rotate right
- **⌘ + ←** - Rotate left
- **⌘ + S** - Take screenshot

## Testing the Fast Reading App

Once your app is running in the simulator:

### Test Basic Functionality

1. **Text Input Test**:
   - Click in the text field
   - Type or paste: "The quick brown fox jumps over the lazy dog"
   - Adjust speed slider to 300 WPM
   - Tap "Start Reading"
   - Observe words appearing one at a time

2. **URL Loading Test**:
   - Tap "Load URL" button
   - Enter a text file URL (e.g., a raw GitHub gist)
   - Tap "Load"
   - Verify text loads and reading starts

3. **Playback Controls**:
   - While reading, tap Pause ⏸
   - Verify reading stops
   - Tap Play ▶️
   - Verify reading resumes
   - Tap Forward ⏩
   - Verify advances to next word
   - Tap Backward ⏪
   - Verify goes to previous word

4. **Speed Adjustment**:
   - While reading, drag speed slider
   - Verify speed changes immediately
   - Try minimum (100 WPM) and maximum (1000 WPM)

5. **Progress Tracking**:
   - Verify progress bar updates
   - Verify word counter shows "X / Total"
   - Verify counter doesn't exceed total

### Test with Example Text

```bash
# Copy example text to clipboard
cat example-text.md | pbcopy

# In simulator:
# 1. Click text field
# 2. Paste (Cmd+V)
# 3. Start reading
```

## Troubleshooting

### Simulator Won't Start

**Problem**: Simulator app doesn't open

**Solutions**:
```bash
# Kill all simulator processes
killall Simulator

# Reset Launch Services
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

# Try opening again
open -a Simulator
```

### "Unable to boot device" Error

**Problem**: Device fails to boot

**Solutions**:
```bash
# Delete and recreate the simulator
xcrun simctl delete "iPhone 15 Pro"
xcrun simctl create "iPhone 15 Pro" "com.apple.CoreSimulator.SimDeviceType.iPhone-15-Pro" "com.apple.CoreSimulator.SimRuntime.iOS-17-2"

# Or erase and try again
xcrun simctl erase "iPhone 15 Pro"
xcrun simctl boot "iPhone 15 Pro"
```

### App Crashes on Launch

**Problem**: App crashes immediately when opening

**Solutions**:
1. Check Xcode console for crash logs
2. Verify Rust library is properly linked:
   ```bash
   # Check if libraries exist
   ls -la ios-lib/
   ```
3. Clean and rebuild:
   ```bash
   # In Xcode: Product → Clean Build Folder (Cmd+Shift+K)
   # Or from terminal:
   xcodebuild clean -scheme FastReadingApp
   ```
4. Check bridging header is configured
5. Verify all Swift files are added to target

### "Library not found" Error

**Problem**: Linker can't find Rust library

**Solutions**:
1. Rebuild Rust library:
   ```bash
   cd fast-reading-core
   ./build-ios.sh
   ```
2. Check Library Search Paths in Xcode:
   - Target → Build Settings → Library Search Paths
   - Should include: `$(PROJECT_DIR)/../ios-lib`
3. Verify libraries are linked:
   - Target → Build Phases → Link Binary With Libraries
   - Should include both `.a` files

### Simulator is Slow

**Problem**: Simulator runs slowly

**Solutions**:
- Close other applications
- Reduce simulator scale: Window → Physical Size (⌘+1)
- Use newer Mac with Apple Silicon for better performance
- Use iPhone models (faster than iPad simulators)
- Restart your Mac

### Keyboard Doesn't Appear

**Problem**: Can't type in text fields

**Solutions**:
- Toggle software keyboard: I/O → Keyboard → Toggle Software Keyboard (⌘+K)
- OR use your Mac keyboard directly (⌘+K should be OFF)
- Check: I/O → Keyboard → Connect Hardware Keyboard

### Touch/Click Not Working

**Problem**: Can't interact with app

**Solutions**:
- Make sure Simulator window is focused
- Try restarting the simulator
- Check if app is frozen (look at Xcode debugger)

## Advanced: Creating Custom Simulators

### Create a New Simulator

```bash
# List available device types
xcrun simctl list devicetypes

# List available runtimes
xcrun simctl list runtimes

# Create new simulator
xcrun simctl create "My iPhone 15" \
  "com.apple.CoreSimulator.SimDeviceType.iPhone-15" \
  "com.apple.CoreSimulator.SimRuntime.iOS-17-2"
```

### Configure Simulator Settings

```bash
# Enable dark mode
xcrun simctl ui booted appearance dark

# Enable light mode
xcrun simctl ui booted appearance light

# Increase font size
xcrun simctl ui booted increase_contrast enabled
```

## Performance Tips

1. **Use Apple Silicon Macs** - M1/M2/M3 Macs run simulators much faster
2. **Close unused simulators** - Only run one simulator at a time
3. **Use smaller devices** - iPhone SE is faster than iPad Pro
4. **Reduce scale** - Use 50% or 75% window size
5. **Disable Metal HUD** - If you don't need frame rate overlay

## Integration with Development Workflow

### Quick Test Script

Create a script `test-sim.sh`:

```bash
#!/bin/bash
set -e

echo "🔨 Building Rust library..."
cd fast-reading-core
./build-ios.sh
cd ..

echo "🚀 Booting simulator..."
xcrun simctl boot "iPhone 15 Pro" || true
open -a Simulator

echo "🏗️ Building and running app..."
xcodebuild -scheme FastReadingApp \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  run

echo "✅ App launched in simulator!"
```

Make it executable:
```bash
chmod +x test-sim.sh
./test-sim.sh
```

## Additional Resources

- [Apple Developer: Simulator Documentation](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)
- [simctl Command Reference](https://nshipster.com/simctl/)
- [Xcode Keyboard Shortcuts](https://developer.apple.com/documentation/xcode/keyboard-shortcuts)

## Summary

**Fastest way to test**:
1. Open Xcode project
2. Select simulator from device menu
3. Press ⌘+R
4. Wait for app to launch
5. Test your features!

**Command line workflow**:
```bash
# One-time setup
cd fast-reading-core && ./build-ios.sh && cd ..

# Each test run
xcrun simctl boot "iPhone 15 Pro"
open -a Simulator
# Build in Xcode (⌘+R) or use xcodebuild
```

For more details on building the project, see [QUICKSTART.md](QUICKSTART.md).
