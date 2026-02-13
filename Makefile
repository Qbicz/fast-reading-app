.PHONY: help build-rust test-rust build-ios clean sim-list sim-boot sim-open sim-shutdown sim-test

help:
	@echo "Fast Reading App - Build Commands"
	@echo ""
	@echo "Rust Build:"
	@echo "  make build-rust    - Build Rust library"
	@echo "  make test-rust     - Run Rust tests"
	@echo "  make build-ios     - Build Rust library for iOS targets"
	@echo "  make clean         - Clean build artifacts"
	@echo ""
	@echo "Simulator (macOS only):"
	@echo "  make sim-test      - Run automated test script (build + start simulator)"
	@echo "  make sim-list      - List available iOS simulators"
	@echo "  make sim-boot      - Boot iPhone 15 Pro simulator"
	@echo "  make sim-open      - Open Simulator app"
	@echo "  make sim-shutdown  - Shutdown all simulators"
	@echo ""
	@echo "Quick Test:"
	@echo "  ./test-simulator.sh or make sim-test"
	@echo ""
	@echo "See SIMULATOR_GUIDE.md for detailed simulator instructions"
	@echo ""

build-rust:
	cd fast-reading-core && cargo build --release

test-rust:
	cd fast-reading-core && cargo test

build-ios:
	cd fast-reading-core && ./build-ios.sh

clean:
	cd fast-reading-core && cargo clean
	rm -rf ios-lib

# Simulator management commands (macOS only)
sim-test:
	@./test-simulator.sh

sim-list:
	@echo "Available iOS Simulators:"
	@xcrun simctl list devices available | grep -E "iPhone|iPad"

sim-boot:
	@echo "Booting iPhone 15 Pro simulator..."
	@xcrun simctl boot "iPhone 15 Pro" || echo "Simulator already booted or not found"

sim-open:
	@echo "Opening Simulator app..."
	@open -a Simulator

sim-shutdown:
	@echo "Shutting down all simulators..."
	@xcrun simctl shutdown all

