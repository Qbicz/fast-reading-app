# Quick Start Guide

## Step 1: Build the Rust Library

```bash
cd fast-reading-app
make build-ios
```

Or manually:
```bash
cd fast-reading-core
./build-ios.sh
```

This creates:
- `ios-lib/libfast_reading_core_device.a`
- `ios-lib/libfast_reading_core_sim.a`
- `ios-lib/fast_reading_core.h`

## Step 2: Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Choose "iOS" → "App"
4. Settings:
   - Product Name: `FastReadingApp`
   - Team: (your team)
   - Organization Identifier: `com.yourname`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: None
   - Include Tests: Optional
5. Choose location: Save next to this repository
6. Click "Create"

## Step 3: Add Swift Files

1. In Xcode, delete the default `ContentView.swift` that was created
2. Drag these files from Finder into your Xcode project:
   - `FastReadingApp/FastReadingApp/FastReadingApp.swift`
   - `FastReadingApp/FastReadingApp/ContentView.swift`
   - `FastReadingApp/FastReadingApp/ReadingViewModel.swift`
   - `FastReadingApp/FastReadingApp/TextReaderWrapper.swift`
   - `FastReadingApp/FastReadingApp/FastReadingApp-Bridging-Header.h`

3. When prompted:
   - ✅ Copy items if needed
   - ✅ Add to targets: FastReadingApp

## Step 4: Link Rust Libraries

### Add Libraries

1. Select your project in the Project Navigator
2. Select your app target
3. Go to "Build Phases" tab
4. Expand "Link Binary With Libraries"
5. Click the "+" button
6. Click "Add Other..." → "Add Files..."
7. Navigate to `ios-lib/`
8. Select BOTH:
   - `libfast_reading_core_device.a`
   - `libfast_reading_core_sim.a`
9. Click "Open"

### Configure Library Search Paths

1. Still in your target settings
2. Go to "Build Settings" tab
3. Search for "Library Search Paths"
4. Double-click the value
5. Click "+" and add:
   ```
   $(PROJECT_DIR)/../ios-lib
   ```
   (Or absolute path to ios-lib folder)

### Configure Header Search Paths

1. Still in "Build Settings"
2. Search for "Header Search Paths"
3. Double-click the value
4. Click "+" and add:
   ```
   $(PROJECT_DIR)/../ios-lib
   ```

## Step 5: Configure Bridging Header

1. Still in "Build Settings"
2. Search for "Objective-C Bridging Header"
3. Set value to:
   ```
   FastReadingApp/FastReadingApp-Bridging-Header.h
   ```
   (Adjust path based on your project structure)

## Step 6: Build and Run

1. Select a simulator or device from the scheme menu
2. Press `Cmd + R` or click the Play button
3. The app should build and launch!

## Troubleshooting

### "Cannot find 'text_reader_new' in scope"

- Check that bridging header path is correct
- Verify bridging header includes "fast_reading_core.h"
- Clean build folder (Cmd + Shift + K)

### "Library not found for -lfast_reading_core"

- Verify both .a files are in Link Binary With Libraries
- Check Library Search Paths includes ios-lib folder
- Make sure you ran the build-ios.sh script

### "Undefined symbols" errors

- Make sure you're using the correct library for your target:
  - Simulator needs `libfast_reading_core_sim.a`
  - Device needs `libfast_reading_core_device.a`
- Try adding both libraries to Link Binary With Libraries

### Build succeeds but app crashes on launch

- Check that the bridging header is correctly configured
- Verify all Swift files are added to the target
- Look at crash logs in Xcode console

## Testing the App

1. Launch the app
2. Type or paste some text in the input field
3. Adjust the speed slider (100-1000 WPM)
4. Tap "Start Reading"
5. Use play/pause to control playback
6. Use forward/backward to navigate
7. Tap "Stop" to return to input screen

Try the example text:
```bash
cat example-text.md
```

## Next Steps

- Customize the UI in `ContentView.swift`
- Modify reading logic in `fast-reading-core/src/lib.rs`
- Add new features!

## Development Cycle

When making changes:

1. **Rust changes**: 
   ```bash
   cd fast-reading-core
   cargo test          # Run tests
   ./build-ios.sh      # Rebuild for iOS
   ```

2. **Swift changes**: Just edit in Xcode and build

3. **Clean build**: If things get weird:
   ```bash
   cd fast-reading-core
   cargo clean
   ./build-ios.sh
   ```
   Then in Xcode: Product → Clean Build Folder (Cmd + Shift + K)

## Tips

- Keep Xcode and terminal side-by-side
- Use `make test-rust` to quickly test Rust changes
- Simulator is faster for testing than device
- Use Xcode debugger for Swift issues
- Add print statements in Rust for FFI debugging
- Check Console.app for detailed crash logs

Enjoy building with Rust and Swift! 🦀 🍎
