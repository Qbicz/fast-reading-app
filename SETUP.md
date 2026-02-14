# Xcode Project Setup Guide

Step-by-step instructions to get the Fast Reading App running in Xcode.

## 1. Build the Rust library

```bash
cd fast-reading-core
./build-ios.sh
```

Verify these files exist:
- `ios-lib/libfast_reading_core_device.a`
- `ios-lib/libfast_reading_core_sim.a`
- `ios-lib/fast_reading_core.h`

## 2. Create the Xcode project

1. Open Xcode → **File → New → Project**
2. Choose **iOS → App**
3. Product Name: `FastReadingApp`
4. Interface: **SwiftUI**
5. Language: **Swift**
6. Save in the repository root (alongside `fast-reading-core/`)

## 3. Add source files

Replace the auto-generated `ContentView.swift` with the files from `FastReadingApp/FastReadingApp/`:

- `FastReadingApp.swift`
- `ContentView.swift`
- `ReadingViewModel.swift`
- `RustBridge.swift`

Drag them into the Xcode project navigator.

## 4. Configure the bridging header

1. In **Build Settings**, search for "Objective-C Bridging Header"
2. Set it to: `FastReadingApp/FastReadingApp/FastReadingApp-Bridging-Header.h`

## 5. Add library and header paths

In **Build Settings**:

| Setting | Value |
|---------|-------|
| Header Search Paths | `$(SRCROOT)/ios-lib` |
| Library Search Paths | `$(SRCROOT)/ios-lib` |

## 6. Link the Rust static library

1. Select your target → **Build Phases → Link Binary With Libraries**
2. Click **+** → **Add Other → Add Files**
3. For simulator: select `ios-lib/libfast_reading_core_sim.a`
4. For device: select `ios-lib/libfast_reading_core_device.a`

> Tip: You can add both and use build configurations to pick the right one, or use a single XCFramework. For quick testing with the simulator, just link the `_sim` variant.

## 7. Build and run

1. Select an iOS Simulator (e.g., iPhone 15 Pro)
2. Press **Cmd+R**
3. The app should launch with the input screen

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `Undefined symbols for architecture…` | Verify library search paths and that the correct `.a` file is linked |
| `'fast_reading_core.h' file not found` | Check Header Search Paths includes `$(SRCROOT)/ios-lib` |
| Build fails on device | Make sure you linked `_device.a`, not `_sim.a` |
| PDF extraction returns nil | Verify the PDF is text-based, not scanned images |
