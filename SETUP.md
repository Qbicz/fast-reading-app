# Fast Reading App - Setup Guide

This iOS application uses Rust for business logic and SwiftUI for the user interface.

## Architecture

```
fast-reading-app/
├── fast-reading-core/         # Rust library for text processing
│   ├── src/
│   │   └── lib.rs            # Core text reader logic with FFI
│   ├── Cargo.toml            # Rust project configuration
│   └── build-ios.sh          # Script to build for iOS targets
├── ios-lib/                   # Generated iOS libraries (after build)
│   ├── libfast_reading_core_device.a
│   ├── libfast_reading_core_sim.a
│   └── fast_reading_core.h
└── FastReadingApp/            # iOS SwiftUI application
    └── FastReadingApp/
        ├── FastReadingApp.swift          # App entry point
        ├── ContentView.swift             # Main UI
        ├── ReadingViewModel.swift        # View model
        ├── TextReaderWrapper.swift       # Swift wrapper for Rust
        └── FastReadingApp-Bridging-Header.h
```

## Prerequisites

1. **Rust** - Install from https://rustup.rs/
2. **Xcode** - Install from Mac App Store (macOS required)
3. **iOS Targets** - Installed automatically by build script

## Building the Rust Library

The Rust library must be built before creating the iOS project:

```bash
cd fast-reading-core
./build-ios.sh
```

This will:
- Install required iOS targets (aarch64-apple-ios, aarch64-apple-ios-sim, x86_64-apple-ios)
- Build the library for iOS device and simulator
- Create universal libraries in `../ios-lib/`
- Generate C header file for Swift interop

## Creating the Xcode Project

### Option 1: Create New Xcode Project (Recommended)

1. Open Xcode
2. Create a new iOS App project:
   - Product Name: **FastReadingApp**
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Save in the repository root

3. Add Swift files:
   - Drag all `.swift` files from `FastReadingApp/FastReadingApp/` into Xcode
   - Copy items if needed

4. Add Rust libraries:
   - In Xcode, select your project
   - Go to **Build Phases** → **Link Binary With Libraries**
   - Click **+** and choose **Add Other** → **Add Files**
   - Navigate to `ios-lib/` and add both `.a` files:
     - `libfast_reading_core_device.a`
     - `libfast_reading_core_sim.a`

5. Configure build settings:
   - Go to **Build Settings**
   - Search for **Library Search Paths**
   - Add: `$(PROJECT_DIR)/../ios-lib`
   - Search for **Header Search Paths**
   - Add: `$(PROJECT_DIR)/../ios-lib`

6. Add bridging header:
   - Go to **Build Settings**
   - Search for **Objective-C Bridging Header**
   - Set to: `FastReadingApp/FastReadingApp-Bridging-Header.h`

7. Build and run!

### Option 2: Manual Xcode Project Setup

If you prefer, you can create the project manually:

1. Copy the project files:
```bash
# The Swift source files are already in FastReadingApp/FastReadingApp/
# Just open Xcode and create a new project pointing to that directory
```

2. Follow steps 3-7 from Option 1

## Features

### Current Features

- **Text Input**: Paste or type text directly into the app
- **Word-by-Word Display**: Shows one word at a time in large, centered text
- **Speed Control**: Adjust reading speed from 100 to 1000 words per minute
- **Playback Controls**: Play, pause, forward, and backward
- **Progress Tracking**: Visual progress bar and word counter
- **URL Loading**: Load text from URLs (basic implementation)

### Rust Business Logic

The Rust library (`fast-reading-core`) provides:

- **Text Parsing**: Splits text into words
- **Navigation**: Move forward/backward through words
- **Progress Tracking**: Calculate reading progress
- **Memory Safe**: Rust ensures no memory leaks or unsafe operations
- **C FFI**: Exposes C-compatible interface for Swift

### Future Enhancements

- PDF parsing (requires additional Rust dependencies)
- Web scraping for URL content extraction
- Reading statistics and history
- Customizable display (fonts, colors)
- Bookmarks and saved positions
- Export reading sessions

## Testing

### Test Rust Library

```bash
cd fast-reading-core
cargo test
```

### Test iOS App

1. Open project in Xcode
2. Select a simulator or device
3. Press Cmd+R to build and run

## Troubleshooting

### Build Errors

**"Library not found"**
- Ensure you've run `./build-ios.sh` in `fast-reading-core/`
- Check that `ios-lib/` contains the `.a` files
- Verify Library Search Paths in Xcode Build Settings

**"Undefined symbols"**
- Make sure both simulator and device libraries are added
- Check that the bridging header path is correct

**"Swift Compiler Error"**
- Ensure bridging header is set in Build Settings
- Verify all Swift files are added to the target

### Runtime Errors

**App crashes on launch**
- Check that the Rust library is properly linked
- Verify FFI calls are correct in `TextReaderWrapper.swift`

## Development Workflow

1. Make changes to Rust code in `fast-reading-core/src/lib.rs`
2. Run tests: `cargo test`
3. Rebuild for iOS: `./build-ios.sh`
4. Changes to Swift code can be made directly in Xcode
5. Build and run in Xcode

## License

This project is open source.
