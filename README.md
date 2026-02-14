# Fast Reader

Speed-read any **website**, **PDF**, or **text file** — one word at a time (RSVP).

Two versions are available:

| Version | Platform | Build Requirements |
|---------|----------|--------------------|
| **PWA (web app)** | Any device with a browser | None — just serve static files |
| **Native iOS** | iPhone / iPad | macOS + Xcode + Rust toolchain |

---

## PWA (Progressive Web App) — recommended

A mobile-first web app that works on any device. No Mac or Xcode required.

### Features

- **Three input methods**: paste text, enter a URL, or pick a local file (PDF / TXT)
- **Smart content detection**: auto-detects HTML pages, PDFs, and plain text
- **HTML extraction**: browser's built-in DOMParser strips tags and extracts article content
- **PDF extraction**: Mozilla pdf.js extracts text from PDFs
- **CORS fallback**: auto-retries via CORS proxy when sites block direct access
- **Central word display**: large, bold, centered — distraction-free RSVP reading
- **Adjustable speed**: 60 – 1,500 WPM with live adjustment during playback
- **Playback controls**: play/pause, forward, backward, seek bar, restart, stop
- **Keyboard shortcuts**: Space, arrows, Escape, R
- **Dark / light theme**: auto-detects system preference, manual toggle
- **Installable**: add to home screen on iOS/Android for a native-app feel
- **Offline capable**: service worker caches the app shell
- **No dependencies**: zero build step, pure HTML/CSS/JS + ES modules

### Quick Start

```bash
cd web-app
python3 -m http.server 8080
# Open http://localhost:8080 in your browser
```

To install on your iPhone:
1. Open the URL in Safari
2. Tap the Share button → "Add to Home Screen"
3. The app launches in standalone mode (no browser chrome)

### Deploy

Any static file host works: GitHub Pages, Netlify, Vercel, Cloudflare Pages, or a simple nginx server. Just upload the `web-app/` directory.

### Project Structure

```
web-app/
├── index.html          Single-page app
├── css/style.css       All styles (light + dark theme)
├── js/
│   ├── app.js          Main controller, UI, keyboard shortcuts
│   ├── reader.js       TextReader class (word navigation)
│   └── extractor.js    Content extraction (HTML, PDF, URL fetch)
├── manifest.json       PWA manifest
├── sw.js               Service worker (offline support)
└── icons/              App icons (192px, 512px)
```

---

## Native iOS App

Uses **Rust** for business logic (text parsing, HTML extraction, PDF extraction) with a **SwiftUI** interface, bridged via C FFI. Requires a Mac with Xcode.

See [SETUP.md](SETUP.md) for full build instructions.

### Architecture

```
SwiftUI (ContentView, ReadingViewModel)
  │
  ▼
Swift wrapper (RustBridge.swift)
  │  C FFI
  ▼
Rust core (fast-reading-core)
  ├── text_reader   — word splitting & navigation
  ├── html_extractor — HTML → plain text (html2text crate)
  └── pdf_extractor  — PDF bytes → plain text (pdf-extract crate)
```

### Build

```bash
# 1. Build Rust for iOS
cd fast-reading-core && ./build-ios.sh

# 2. Open in Xcode, configure per SETUP.md, then Cmd+R
```

---

## Running Tests

```bash
# Rust unit tests (11 tests)
cd fast-reading-core && cargo test

# JS TextReader tests
node --input-type=module -e "
import { TextReader } from './web-app/js/reader.js';
const r = new TextReader('Hello world');
console.assert(r.wordCount === 2);
console.assert(r.currentWord() === 'Hello');
console.log('OK');
"
```
