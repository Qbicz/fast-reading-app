# PR #1 Review: "Add iOS Simulator test automation and documentation"

Branch: `copilot/setup-ios-app-structure`

## Requirements

> iOS app that accepts a link to a **website**, **text file**, or **PDF**, and shows content centrally on screen for fast reading (word by word).

## What the PR delivers

| Area | Status | Notes |
|------|--------|-------|
| Rust core (text splitting, navigation) | Done | Clean TextReader with FFI |
| SwiftUI word-by-word display | Done | Central word, progress bar, controls |
| Speed control (WPM) | Done | 100–1000 WPM slider |
| Playback controls | Done | Play/pause, forward, backward |
| Plain text URL loading | Partial | Fetches raw bytes, decodes as UTF-8 |
| **Website (HTML) support** | **Missing** | Raw HTML shown to user instead of extracted text |
| **PDF support** | **Missing** | Listed as "Future Ideas" in README |
| **File picker** | **Missing** | No local file import |

## Critical gaps

### 1. No PDF support
This is a core requirement. The Rust layer has no PDF parsing, and the Swift layer has no logic for PDF data. The README itself lists it under "Future Ideas."

### 2. No HTML content extraction
`ReadingViewModel.loadFromURL()` fetches data and decodes it as plain UTF-8. For any website this produces raw HTML (tags, scripts, CSS) rather than readable content. Needs an HTML-to-text pipeline.

### 3. No file picker
Users should be able to open local PDF and text files. The app has no `UIDocumentPickerViewController` or SwiftUI `.fileImporter`.

### 4. No Xcode project file
`.xcodeproj` is gitignored. Anyone cloning the repo must create the Xcode project from scratch and manually configure bridging headers, library search paths, and linking — a significant barrier to building the app.

## Minor issues

- **Excessive documentation**: 7 markdown files (ARCHITECTURE.md, HOW_TO_TEST_SIMULATOR.md, PROJECT_SUMMARY.md, QUICKSTART.md, SETUP.md, SIMULATOR_GUIDE.md, example-text.md) for an app missing 2 of 3 input types.
- **Naming**: File `TextReaderWrapper.swift` contains a class named `TextReader` — potentially confusing with the Rust struct of the same name.
- **URL handling**: No automatic `https://` prefix; no content-type detection from HTTP response headers.
- **No loading indicator**: Users get no feedback while a URL is being fetched.

## Verdict

The PR provides a solid foundation (Rust ↔ Swift FFI bridge, basic RSVP UI) but covers approximately **40% of the requirements**. The two most important input types — websites and PDFs — are not functional.

## What this branch adds

The `cursor/fast-reader-app-requirements-df5a` branch addresses all the gaps:

1. **PDF extraction** via Rust `pdf-extract` crate, exposed through `extract_pdf_text()` FFI
2. **HTML extraction** via Rust `html2text` crate, exposed through `extract_html_text()` FFI
3. **Smart content detection** from MIME type and file extension
4. **Document picker** for importing local PDF/TXT files
5. **Loading overlay** while fetching URL content
6. **Seek support** for jumping to specific word positions
7. **Restart** functionality
8. Wider speed range (60–1200 WPM)
9. Clean, concise documentation
