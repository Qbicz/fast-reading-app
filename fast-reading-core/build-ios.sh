#!/bin/bash

set -e

# Build script for iOS targets
# This script builds the Rust library for iOS architectures

echo "Building Rust library for iOS..."

# Install iOS targets if not already installed
rustup target add aarch64-apple-ios
rustup target add aarch64-apple-ios-sim
rustup target add x86_64-apple-ios

# Build for iOS device (ARM64)
echo "Building for iOS device (aarch64)..."
cargo build --release --target aarch64-apple-ios

# Build for iOS simulator (ARM64)
echo "Building for iOS simulator (aarch64)..."
cargo build --release --target aarch64-apple-ios-sim

# Build for iOS simulator (x86_64)
echo "Building for iOS simulator (x86_64)..."
cargo build --release --target x86_64-apple-ios

# Create output directory
mkdir -p ../ios-lib

# Create universal library for simulator
echo "Creating universal library for iOS simulator..."
lipo -create \
    target/aarch64-apple-ios-sim/release/libfast_reading_core.a \
    target/x86_64-apple-ios/release/libfast_reading_core.a \
    -output ../ios-lib/libfast_reading_core_sim.a

# Copy device library
echo "Copying library for iOS device..."
cp target/aarch64-apple-ios/release/libfast_reading_core.a ../ios-lib/libfast_reading_core_device.a

# Generate C header file
echo "Generating C header file..."
cat > ../ios-lib/fast_reading_core.h << 'EOF'
#ifndef FAST_READING_CORE_H
#define FAST_READING_CORE_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Opaque handle for TextReader
typedef struct TextReaderHandle TextReaderHandle;

// Create a new text reader from text
TextReaderHandle* text_reader_new(const char* text);

// Free a text reader
void text_reader_free(TextReaderHandle* handle);

// Get the total word count
size_t text_reader_get_word_count(const TextReaderHandle* handle);

// Get the current word (must be freed with free_string)
char* text_reader_get_current_word(const TextReaderHandle* handle);

// Move to the next word (must be freed with free_string)
char* text_reader_next_word(TextReaderHandle* handle);

// Move to the previous word (must be freed with free_string)
char* text_reader_previous_word(TextReaderHandle* handle);

// Reset to the beginning
void text_reader_reset(TextReaderHandle* handle);

// Get reading progress (0.0 to 1.0)
float text_reader_get_progress(const TextReaderHandle* handle);

// Free a string returned by this library
void free_string(char* s);

#ifdef __cplusplus
}
#endif

#endif // FAST_READING_CORE_H
EOF

echo "Build complete! Libraries are in ../ios-lib/"
echo "  - libfast_reading_core_device.a (for iOS devices)"
echo "  - libfast_reading_core_sim.a (for iOS simulator)"
echo "  - fast_reading_core.h (C header file)"
