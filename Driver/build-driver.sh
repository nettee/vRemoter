#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
BUILD_DIR="$SCRIPT_DIR/build"
OUTPUT_DRIVER="$BUILD_DIR/vRemoteDriver.driver"
CONTENTS="$OUTPUT_DRIVER/Contents"
# Build from the included GPL source. No installed BlackHole or vRemote driver is used.
for required in BlackHole.c BlackHole.icns LICENSE; do
  [[ -f "$SCRIPT_DIR/BlackHole/$required" ]] || { print -u2 "Missing driver source: $required"; exit 1; }
done
xcrun --find clang >/dev/null
rm -rf "$OUTPUT_DRIVER"
mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources"
xcrun clang -arch arm64 -arch x86_64 -mmacosx-version-min=12.0 \
  -O2 -fblocks -bundle -DNDEBUG \
  '-DkDriver_Name="vRemoteDr"' \
  '-DkPlugIn_BundleID="audio.local.vRemoteDriver2chXX"' \
  "$SCRIPT_DIR/BlackHole/BlackHole.c" \
  -framework CoreAudio -framework CoreFoundation -framework Accelerate \
  -o "$CONTENTS/MacOS/BlackHole"
cp "$SCRIPT_DIR/Info.plist" "$CONTENTS/Info.plist"
cp "$SCRIPT_DIR/BlackHole/BlackHole.icns" "$CONTENTS/Resources/"
cp "$SCRIPT_DIR/BlackHole/LICENSE" "$CONTENTS/Resources/LICENSE.txt"
codesign --force --deep --sign - --timestamp=none "$OUTPUT_DRIVER"
codesign --verify --deep --strict --verbose=2 "$OUTPUT_DRIVER"
print "Built from source: $OUTPUT_DRIVER"
lipo -archs "$CONTENTS/MacOS/BlackHole"
