#!/usr/bin/env bash
set -euo pipefail

# Maintainer-only build: consumers use the checked-in XCFramework.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HEADERS_DIR="$ROOT_DIR/include"
BINARIES_DIR="$ROOT_DIR/Binaries"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/icpkit-bls.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT

export IPHONEOS_DEPLOYMENT_TARGET=16.0
export MACOSX_DEPLOYMENT_TARGET=13.0

TARGETS=(
    aarch64-apple-ios
    aarch64-apple-ios-sim
    x86_64-apple-ios
    aarch64-apple-darwin
    x86_64-apple-darwin
    aarch64-apple-ios-macabi
    x86_64-apple-ios-macabi
)

for target in "${TARGETS[@]}"; do
    cargo build --manifest-path "$ROOT_DIR/Cargo.toml" --package bls12381 \
        --lib --release --locked --target "$target" --target-dir "$BUILD_DIR/cargo"
done

# Merge architectures within each destination; never merge different platforms.
for destination in simulator macos catalyst; do
    mkdir -p "$BUILD_DIR/$destination"
done
xcrun lipo -create \
    "$BUILD_DIR/cargo/aarch64-apple-ios-sim/release/libbls12381.a" \
    "$BUILD_DIR/cargo/x86_64-apple-ios/release/libbls12381.a" \
    -output "$BUILD_DIR/simulator/libbls12381.a"
xcrun lipo -create \
    "$BUILD_DIR/cargo/aarch64-apple-darwin/release/libbls12381.a" \
    "$BUILD_DIR/cargo/x86_64-apple-darwin/release/libbls12381.a" \
    -output "$BUILD_DIR/macos/libbls12381.a"
xcrun lipo -create \
    "$BUILD_DIR/cargo/aarch64-apple-ios-macabi/release/libbls12381.a" \
    "$BUILD_DIR/cargo/x86_64-apple-ios-macabi/release/libbls12381.a" \
    -output "$BUILD_DIR/catalyst/libbls12381.a"

xcodebuild -create-xcframework \
    -library "$BUILD_DIR/cargo/aarch64-apple-ios/release/libbls12381.a" -headers "$HEADERS_DIR" \
    -library "$BUILD_DIR/simulator/libbls12381.a" -headers "$HEADERS_DIR" \
    -library "$BUILD_DIR/macos/libbls12381.a" -headers "$HEADERS_DIR" \
    -library "$BUILD_DIR/catalyst/libbls12381.a" -headers "$HEADERS_DIR" \
    -output "$BUILD_DIR/Bls12381.xcframework"

# Replace the distributed artifact only after every build and packaging step succeeds.
mkdir -p "$BINARIES_DIR"
rm -rf "$BINARIES_DIR/Bls12381.xcframework"
mv "$BUILD_DIR/Bls12381.xcframework" "$BINARIES_DIR/Bls12381.xcframework"
