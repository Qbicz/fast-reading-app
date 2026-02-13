# Fast Reading App

An iOS application for speed reading that displays text word-by-word at a configurable pace.

## Overview

This app helps you read faster by displaying one word at a time in the center of the screen. It uses:

- **Rust** for business logic (text parsing, word navigation)
- **SwiftUI** for the iOS user interface
- **C FFI** for Rust-Swift interoperability

## Features

- 📖 **Word-by-Word Reading**: Display text one word at a time
- ⚡ **Adjustable Speed**: Control reading speed (100-1000 WPM)
- 🎮 **Playback Controls**: Play, pause, skip forward/backward
- 📊 **Progress Tracking**: Visual progress bar and word counter
- 📝 **Text Input**: Paste or type text directly
- 🔗 **URL Support**: Load text from URLs
- 🎯 **Clean UI**: Simple, distraction-free interface

## Getting Started

### Quick Start

1. Build the Rust library:
```bash
cd fast-reading-core
./build-ios.sh
```

2. Open Xcode and create a new iOS project
3. Add the Swift files and link the Rust libraries
4. Build and run in simulator (⌘+R)

### Testing in Simulator

**Easiest method**:
```bash
# Open your Xcode project
open FastReadingApp.xcodeproj

# In Xcode:
# 1. Select simulator from device menu (e.g., "iPhone 15 Pro")
# 2. Press ⌘+R to build and run
```

**Command line method**:
```bash
# Boot simulator
xcrun simctl boot "iPhone 15 Pro"
open -a Simulator

# Build and run in Xcode (⌘+R)
```

See [SIMULATOR_GUIDE.md](SIMULATOR_GUIDE.md) for comprehensive simulator testing instructions.

### Documentation

- [SETUP.md](SETUP.md) - Detailed build and installation instructions
- [QUICKSTART.md](QUICKSTART.md) - Step-by-step Xcode project setup
- [SIMULATOR_GUIDE.md](SIMULATOR_GUIDE.md) - How to test in iOS Simulator
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical architecture details

## Architecture

```
┌─────────────────────────────────┐
│      SwiftUI Interface          │
│  (ContentView, ReadingViewModel) │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│   Swift Wrapper                 │
│   (TextReaderWrapper)           │
└────────────┬────────────────────┘
             │ C FFI
             ▼
┌─────────────────────────────────┐
│   Rust Core Library             │
│   (Text parsing & navigation)   │
└─────────────────────────────────┘
```

## Project Structure

- `fast-reading-core/` - Rust library with core functionality
- `FastReadingApp/` - iOS SwiftUI application
- `ios-lib/` - Compiled Rust libraries (generated)

## Requirements

- macOS with Xcode 14+
- Rust toolchain (1.70+)
- iOS 16.0+

## Future Ideas

- PDF file support
- Web page content extraction
- Reading statistics and analytics
- Multiple reading modes (RSVP, pacing)
- Customizable themes and fonts
- Reading history and bookmarks

## Contributing

This is a demonstration project showing how to integrate Rust with iOS using C FFI.

## License

Open source project for educational purposes.
