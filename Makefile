.PHONY: build-rust test-rust clean build-ios open

# Build Rust library (host platform, for testing)
build-rust:
	cd fast-reading-core && cargo build

# Run Rust unit tests
test-rust:
	cd fast-reading-core && cargo test

# Build Rust for all iOS targets (requires macOS)
build-ios:
	cd fast-reading-core && ./build-ios.sh

# Clean build artifacts
clean:
	cd fast-reading-core && cargo clean
	rm -rf ios-lib/*.a

# Open Xcode project (macOS only)
open:
	open FastReadingApp.xcodeproj 2>/dev/null || echo "Xcode project not found. See SETUP.md."
