#!/bin/zsh
set -euo pipefail
ROOT="${0:A:h:h}"
mkdir -p "$ROOT/.build"
xcrun clang "$ROOT/SelfTests/driver-smoke.c" -framework CoreAudio -framework CoreFoundation -o "$ROOT/.build/driver-smoke"
"$ROOT/.build/driver-smoke" "${1:-$ROOT/Driver/build/vRemoteDriver.driver}/Contents/MacOS/BlackHole"
