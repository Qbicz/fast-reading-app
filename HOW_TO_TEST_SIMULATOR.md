# How to Start the iOS Simulator - Quick Reference

## 🚀 Fastest Way (Xcode)

```bash
# 1. Open your Xcode project
open FastReadingApp.xcodeproj

# 2. In Xcode:
#    - Select a simulator from the device menu (e.g., "iPhone 15 Pro")
#    - Press ⌘+R to build and run
```

## 🤖 Automated Way (One Command)

```bash
# Run the automated test script
./test-simulator.sh

# Or using make
make sim-test
```

This script will:
- Check prerequisites (Xcode, Rust, macOS)
- Build the Rust library
- Start the iOS simulator
- Give you next steps

## 🔧 Manual Way (Command Line)

```bash
# Step 1: List available simulators
make sim-list

# Step 2: Boot a simulator
make sim-boot

# Step 3: Open Simulator app
make sim-open

# Step 4: Build and run in Xcode (⌘+R)
```

Or with direct commands:
```bash
xcrun simctl boot "iPhone 15 Pro"
open -a Simulator
# Then build in Xcode
```

## 📚 Available Commands

| Command | Description |
|---------|-------------|
| `make sim-test` | Run full automated test (build + start simulator) |
| `make sim-list` | List available iOS simulators |
| `make sim-boot` | Boot iPhone 15 Pro simulator |
| `make sim-open` | Open Simulator app |
| `make sim-shutdown` | Shutdown all running simulators |
| `./test-simulator.sh` | Interactive test script with checks |

## 📖 Detailed Documentation

- **SIMULATOR_GUIDE.md** - Complete simulator testing guide (11KB)
  - All simulator commands and shortcuts
  - Troubleshooting common issues
  - Performance tips
  - Testing workflows

- **QUICKSTART.md** - Step-by-step Xcode setup
- **SETUP.md** - Complete project setup guide
- **README.md** - Project overview

## 🎯 Quick Test Workflow

```bash
# Full workflow in 3 commands:
make build-ios        # Build Rust library
make sim-test         # Start simulator
# Press ⌘+R in Xcode to run
```

## ⚠️ Prerequisites

- ✅ macOS (iOS Simulator only runs on macOS)
- ✅ Xcode installed (from Mac App Store)
- ✅ Rust toolchain installed
- ✅ Xcode project created and configured

## 💡 Tips

1. **First time setup**: Follow QUICKSTART.md completely
2. **Testing changes**: Just press ⌘+R in Xcode
3. **Simulator shortcuts**: 
   - ⌘+1/2/3 - Scale window
   - ⌘+K - Toggle keyboard
   - ⌘+Shift+H - Home button

## 🔍 Troubleshooting

If simulator won't start:
```bash
# Kill all simulator processes
killall Simulator

# Shutdown all simulators
make sim-shutdown

# Try again
make sim-boot
make sim-open
```

## 📱 Testing the App

Once the app is running in simulator:

1. **Text Input**: Paste or type text
2. **Speed Control**: Adjust slider (100-1000 WPM)
3. **Start Reading**: Tap "Start Reading" button
4. **Playback**: Use play/pause/forward/backward controls
5. **URL Test**: Try "Load URL" with a text file URL

Try the example text:
```bash
cat example-text.md
# Copy and paste into the app
```

---

**Need more help?** See [SIMULATOR_GUIDE.md](SIMULATOR_GUIDE.md) for the complete guide.
