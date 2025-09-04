#!/bin/bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

DEST_DIR="$1"
if [ -n "$DEST_DIR" ]; then
    echo "DEST_DIR: $DEST_DIR"
else
    echo "Error: DEST_DIR is empty or not provided"
    exit 1
fi

cd "${SRCROOT}/.." && echo "cd: $(pwd) to replace..." &&

# Copy PolarGX-SDK files
rm -rf "${DEST_DIR}/polargx-swift-sdk.lib" && mkdir -p "${DEST_DIR}/polargx-swift-sdk.lib" &&
cp -R ./PolarGX-SDK "${DEST_DIR}/polargx-swift-sdk.lib/" &&
cp ./PolarGX.podspec "${DEST_DIR}/polargx-swift-sdk.lib/" &&
cp ./README.md "${DEST_DIR}/polargx-swift-sdk.lib/" &&

cd "${DEST_DIR}" && echo "cd: $(pwd) to pod install..." &&
pod update PolarGX
