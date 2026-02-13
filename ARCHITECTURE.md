# Architecture Documentation

## Overview

Fast Reading App is a hybrid iOS application that combines Rust for business logic with SwiftUI for the user interface. This document explains the architecture, component interactions, and design decisions.

## Technology Stack

- **Rust**: Core text processing logic
  - Memory-safe, high-performance
  - Cross-platform potential
  - Easy FFI integration

- **Swift/SwiftUI**: User interface
  - Native iOS experience
  - Declarative UI
  - Modern iOS features

- **C FFI**: Bridge between Rust and Swift
  - Standard interop mechanism
  - Zero-cost abstractions
  - Direct function calls

## Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        iOS App Layer                         │
│                                                              │
│  ┌──────────────────┐         ┌──────────────────┐         │
│  │  ContentView     │◄────────┤ ReadingViewModel │         │
│  │  (SwiftUI)       │         │  (State)         │         │
│  └──────────────────┘         └────────┬─────────┘         │
│           │                             │                    │
│           │                             ▼                    │
│           │                   ┌──────────────────┐         │
│           │                   │ TextReaderWrapper│         │
│           │                   │  (Swift)         │         │
│           │                   └────────┬─────────┘         │
└───────────┼─────────────────────────────┼──────────────────┘
            │                             │
            │        C FFI Boundary       │
            │                             ▼
┌───────────┼─────────────────────────────────────────────────┐
│           │              Rust Core Layer                     │
│           │                                                  │
│           │                   ┌──────────────────┐          │
│           │                   │  FFI Functions   │          │
│           │                   │  (extern "C")    │          │
│           │                   └────────┬─────────┘          │
│           │                            │                    │
│           │                            ▼                    │
│           │                   ┌──────────────────┐          │
│           └──────────────────►│  TextReader      │          │
│                               │  (Core Logic)    │          │
│                               └──────────────────┘          │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Layer Details

### 1. iOS App Layer (Swift/SwiftUI)

#### ContentView
- Main UI component
- Handles user input and display
- Two states: Input mode and Reading mode
- Uses SwiftUI's declarative syntax

Key Features:
- Text input field
- URL input dialog
- Speed control slider (100-1000 WPM)
- Playback controls (play, pause, forward, backward)
- Progress bar and word counter

#### ReadingViewModel
- Manages application state
- Observable object pattern
- Controls reading playback
- Handles URL loading

State Properties:
- `currentWord`: Currently displayed word
- `currentWordIndex`: Position in text
- `totalWords`: Total word count
- `isReading`: Whether in reading mode
- `isPlaying`: Whether auto-play is active
- `wordsPerMinute`: Reading speed
- `progress`: Reading progress (0.0-1.0)

#### TextReaderWrapper
- Swift wrapper around Rust FFI
- Memory management (init/deinit)
- Type conversions (Swift ↔ C strings)
- Safe interface for Swift code

### 2. C FFI Boundary

The boundary between Swift and Rust uses C-compatible types:

Swift Type → C Type → Rust Type:
- `String` → `const char*` → `CStr` → `&str`
- `OpaquePointer` → `*mut TextReaderHandle` → `Box<TextReader>`
- `Int` → `size_t` → `usize`
- `Float` → `float` → `f32`

### 3. Rust Core Layer

#### TextReader (Core Logic)
Pure Rust implementation:

```rust
pub struct TextReader {
    words: Vec<String>,
    current_index: usize,
}
```

Responsibilities:
- Parse text into words
- Navigate through words
- Track progress
- No unsafe code (except FFI boundary)

Methods:
- `new(text: String)`: Create reader
- `get_word_count()`: Get total words
- `get_current_word()`: Get current word
- `next_word()`: Advance to next
- `previous_word()`: Go to previous
- `reset()`: Return to start
- `get_progress()`: Calculate progress

#### FFI Functions
C-compatible interface:

```rust
#[no_mangle]
pub extern "C" fn text_reader_new(text: *const c_char) -> *mut TextReaderHandle
```

Key aspects:
- `#[no_mangle]`: Preserve function names
- `extern "C"`: Use C calling convention
- Opaque pointers for Rust objects
- Manual memory management at boundary
- Null pointer checks

## Data Flow

### Initialization Flow
```
1. User enters text in ContentView
2. ContentView calls ReadingViewModel.loadText()
3. ViewModel creates TextReaderWrapper
4. Wrapper calls text_reader_new() FFI
5. Rust creates TextReader instance
6. Returns opaque pointer to Swift
7. ViewModel updates UI state
```

### Reading Flow
```
1. User presses play in ContentView
2. ViewModel starts Timer
3. Timer fires every (60/WPM) seconds
4. ViewModel calls wrapper.nextWord()
5. Wrapper calls text_reader_next_word() FFI
6. Rust advances index and returns word
7. Wrapper converts C string to Swift String
8. ViewModel updates @Published currentWord
9. SwiftUI automatically refreshes view
```

### Memory Management Flow
```
Swift Side:
- ARC manages Swift objects
- TextReaderWrapper holds OpaquePointer
- deinit calls text_reader_free()

Rust Side:
- Box<TextReader> lives on heap
- Box::into_raw() transfers ownership to FFI
- Box::from_raw() reclaims ownership
- Drop trait handles cleanup
```

## Design Decisions

### Why Rust for Business Logic?

1. **Performance**: Fast text processing
2. **Safety**: Memory-safe by default
3. **Portability**: Can target iOS, Android, web
4. **Learning**: Demonstrates Rust-iOS integration
5. **Scalability**: Easy to add features (PDF parsing, NLP)

### Why SwiftUI?

1. **Native**: Best iOS experience
2. **Modern**: Declarative, reactive
3. **Productivity**: Less boilerplate
4. **Integration**: Easy Xcode workflow

### Why C FFI?

1. **Standard**: Well-documented approach
2. **Stable**: Part of Rust core
3. **Efficient**: No runtime overhead
4. **Compatible**: Works with all platforms

## Building for iOS

### Build Process

```
1. Rust code compiled to static library
   - cargo build --target aarch64-apple-ios (device)
   - cargo build --target aarch64-apple-ios-sim (sim)
   - cargo build --target x86_64-apple-ios (x86 sim)

2. Libraries combined with lipo
   - Universal simulator library created
   - Device library kept separate

3. C header generated
   - Function declarations
   - Type definitions

4. Xcode links libraries
   - Static libraries added to project
   - Header included via bridging header
   - Library search paths configured
```

### Build Outputs

- `libfast_reading_core_device.a`: For iOS devices (ARM64)
- `libfast_reading_core_sim.a`: For simulator (ARM64 + x86_64)
- `fast_reading_core.h`: C header file

## Testing Strategy

### Rust Layer
- Unit tests for TextReader logic
- Property-based testing possible
- No FFI testing (unsafe)

### Swift Layer
- UI testing in Xcode
- Integration testing with Rust
- Manual testing on device/simulator

## Future Enhancements

### Planned Features
1. **PDF Support**: Add Rust PDF parser
2. **Web Scraping**: Extract text from URLs
3. **Statistics**: Track reading history
4. **Customization**: Themes, fonts, animations
5. **Persistence**: Save reading sessions

### Technical Improvements
1. **Error Handling**: Better FFI error propagation
2. **Async Support**: Tokio for URL fetching
3. **Unicode**: Better handling of complex text
4. **Performance**: SIMD for text processing
5. **Testing**: More comprehensive test suite

## Security Considerations

1. **Memory Safety**: Rust prevents common vulnerabilities
2. **FFI Boundary**: Careful pointer handling
3. **Input Validation**: Check text input
4. **URL Loading**: Validate URLs, handle HTTPS
5. **Sandboxing**: iOS app sandbox protects system

## Conclusion

This architecture demonstrates a practical approach to integrating Rust with iOS. The clean separation between business logic and UI allows for:

- Independent development of each layer
- Easy testing of core functionality
- Potential reuse of Rust code on other platforms
- Maintainable, type-safe codebase

The FFI boundary is small and well-defined, minimizing complexity while maximizing the benefits of both languages.
