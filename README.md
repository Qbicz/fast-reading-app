# Fast Reading App

An iOS speed-reading app that accepts a **website link**, **text file**, or **PDF** and displays content centrally on screen, one word at a time (RSVP — Rapid Serial Visual Presentation).

## Features

- **Three input methods**: paste text, enter a URL, or pick a local file (PDF / TXT)
- **Smart content detection**: auto-detects HTML pages, PDFs, and plain text from URLs (via MIME type and file extension)
- **HTML extraction**: strips tags, scripts, and styles — shows only readable text (powered by Rust `html2text`)
- **PDF extraction**: extracts text from PDF documents (powered by Rust `pdf-extract`)
- **Central word display**: large, bold, centered word — distraction-free reading
- **Adjustable speed**: 60 – 1,200 WPM with real-time adjustment during playback
- **Playback controls**: play / pause, forward, backward, restart, stop
- **Progress tracking**: progress bar and word counter

## Architecture

```
SwiftUI (ContentView, ReadingViewModel)
  │
  ▼
Swift wrapper (RustBridge.swift)
  │  C FFI
  ▼
Rust core (fast-reading-core)
  ├── text_reader   — word splitting & navigation
  ├── html_extractor — HTML → plain text
  └── pdf_extractor  — PDF bytes → plain text
```

- **Rust** handles all content processing (text parsing, HTML extraction, PDF extraction)
- **Swift/SwiftUI** handles networking (URLSession), file access, and UI
- **C FFI** provides the bridge via an opaque `TextReaderHandle` pointer

## Quick Start

### Prerequisites

- macOS with Xcode 15+
- Rust toolchain (`rustup` from <https://rustup.rs>)
- iOS deployment target: 16.0+

### 1. Build the Rust library

```bash
cd fast-reading-core
./build-ios.sh
```

This produces:
- `ios-lib/libfast_reading_core_device.a` (ARM64 device)
- `ios-lib/libfast_reading_core_sim.a` (universal simulator)
- `ios-lib/fast_reading_core.h` (C header)

### 2. Set up the Xcode project

See [SETUP.md](SETUP.md) for step-by-step Xcode project configuration.

In summary:
1. Create a new iOS App project in Xcode (SwiftUI, Swift)
2. Add the Swift source files from `FastReadingApp/FastReadingApp/`
3. Add the bridging header (`FastReadingApp-Bridging-Header.h`)
4. Add `ios-lib/` to **Library Search Paths** and **Header Search Paths**
5. Link `libfast_reading_core_sim.a` (simulator) or `libfast_reading_core_device.a` (device)
6. Build and run (Cmd+R)

### 3. Run tests

```bash
make test-rust
```

## Project Structure

```
├── fast-reading-core/          Rust library
│   ├── Cargo.toml
│   ├── build-ios.sh            Cross-compile for iOS
│   └── src/
│       ├── lib.rs              FFI exports + integration tests
│       ├── text_reader.rs      Word navigation engine
│       ├── html_extractor.rs   HTML → text
│       └── pdf_extractor.rs    PDF → text
├── FastReadingApp/             SwiftUI iOS app
│   └── FastReadingApp/
│       ├── FastReadingApp.swift           App entry point
│       ├── ContentView.swift              UI (input + reading views)
│       ├── ReadingViewModel.swift         State & playback logic
│       ├── RustBridge.swift               Swift ↔ Rust FFI wrapper
│       ├── FastReadingApp-Bridging-Header.h
│       └── Assets.xcassets/
├── ios-lib/                    Build outputs (generated)
│   └── fast_reading_core.h     C header (checked in for reference)
├── Makefile
├── SETUP.md                    Xcode project setup guide
├── PR_REVIEW.md                Review of PR #1
└── README.md
```
