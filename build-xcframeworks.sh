#!/usr/bin/env bash

set -e

# Configuration
PROJECT_PATH="PolarGX-SDK/PolarGX.xcodeproj"
BUILD_DIR="build"
XCFRAMEWORK_DIR="XCFrameworks"

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf "$BUILD_DIR"
rm -rf "$XCFRAMEWORK_DIR"
mkdir -p "$XCFRAMEWORK_DIR"

# Function to build xcframework
build_xcframework() {
    local SCHEME=$1
    local FRAMEWORK_NAME=$2

    echo "Building $SCHEME (Framework: $FRAMEWORK_NAME)..."

    # Build for iOS device
    echo "Building for iOS device..."
    xcodebuild archive \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -destination "generic/platform=iOS" \
        -archivePath "$BUILD_DIR/$SCHEME-iOS" \
        -sdk iphoneos \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    # Build for iOS simulator
    echo "Building for iOS simulator..."
    xcodebuild archive \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -destination "generic/platform=iOS Simulator" \
        -archivePath "$BUILD_DIR/$SCHEME-Simulator" \
        -sdk iphonesimulator \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    # Create XCFramework
    echo "Creating XCFramework for $FRAMEWORK_NAME..."
    xcodebuild -create-xcframework \
        -framework "$BUILD_DIR/$SCHEME-iOS.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
        -framework "$BUILD_DIR/$SCHEME-Simulator.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
        -output "$XCFRAMEWORK_DIR/$FRAMEWORK_NAME.xcframework"

    echo "✓ $FRAMEWORK_NAME.xcframework created successfully"
}

# Build frameworks
build_xcframework "PolarGX" "PolarGX"
build_xcframework "PolarGX-NotificationServiceExtension" "PolarGX_NotificationServiceExtension"

echo ""
echo "All XCFrameworks created successfully in $XCFRAMEWORK_DIR/"
echo "Cleaning up build artifacts..."
rm -rf "$BUILD_DIR"
echo "Done!"
