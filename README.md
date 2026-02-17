# Fast Reader

Speed-read any **website**, **PDF**, or **text file** — one word at a time (Rapid Serial Visual Presentation).

**Try it now:** [kubicz.engineer/fast-reading-app](https://kubicz.engineer/fast-reading-app/)

A mobile-first web app that works on any device. Install it on your phone for a native-app experience — no app store needed.

To install on your iPhone:
1. Open the URL in Safari or other browser
2. Tap the Share button → "Add to Home Screen"
3. The app launches in standalone mode

### Features

- **Read anything**: paste text, enter a URL, or open a local file (PDF / TXT)
- **Distraction-free reading**: one word at a time, large and centered
- **Adjustable speed**: 60 – 1,500 WPM, changeable during playback
- **Full playback controls**: play / pause, skip forward / backward, seek bar, keyboard shortcuts
- **Dark / light theme**: follows your system preference with a manual toggle
- **Installable**: add to home screen on iOS / Android for a native-app feel
- **Works offline**: keep reading even without a connection

### Quick Start

```bash
cd web-app
python3 -m http.server 8080
# Open http://localhost:8080 in your browser
```

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

## Native iOS App (experimental)

The repo also contains a native iOS app built with **Rust** + **SwiftUI**. This is a separate codebase from the PWA — the two don't share data. For most users the PWA is the easier choice since it already installs on iPhones via "Add to Home Screen."

See [SETUP.md](SETUP.md) for build instructions (requires macOS + Xcode + Rust toolchain).
