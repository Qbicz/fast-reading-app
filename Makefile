.PHONY: help build-rust test-rust build-ios clean

help:
	@echo "Fast Reading App - Build Commands"
	@echo ""
	@echo "  make build-rust    - Build Rust library"
	@echo "  make test-rust     - Run Rust tests"
	@echo "  make build-ios     - Build Rust library for iOS targets"
	@echo "  make clean         - Clean build artifacts"
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
