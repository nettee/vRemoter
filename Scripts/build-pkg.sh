#!/bin/zsh
set -euo pipefail
ROOT="${0:A:h:h}"
VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT/Packaging/Info.plist")
PACKAGE_VERSION=$(print -r -- "$VERSION" | sed -E 's/[^0-9.]+/./g; s/\.+/./g; s/^\.//; s/\.$//')
PAYLOAD="$ROOT/dist/pkg-root"
COMPONENT="$ROOT/dist/vRemoter-component.pkg"
FINAL="$ROOT/dist/vRemoter-$VERSION-AppleSilicon.pkg"
zsh "$ROOT/Scripts/package-app.sh"
lipo -verify_arch arm64 "$ROOT/dist/build/vRemote.app/Contents/MacOS/vRemote"
zsh "$ROOT/Driver/build-driver.sh"
zsh "$ROOT/Scripts/test-driver.sh"
rm -rf "$PAYLOAD" "$COMPONENT" "$FINAL"
mkdir -p "$PAYLOAD/Applications" "$PAYLOAD/Library/Audio/Plug-Ins/HAL"
ditto "$ROOT/dist/build/vRemote.app" "$PAYLOAD/Applications/vRemote.app"
ditto "$ROOT/Driver/build/vRemoteDriver.driver" "$PAYLOAD/Library/Audio/Plug-Ins/HAL/vRemoteDriver.driver"
# Never relocate to an old copy in Downloads or a mounted disk image.
cat > "$ROOT/dist/components.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><array><dict>
<key>RootRelativeBundlePath</key><string>Applications/vRemote.app</string>
<key>BundleIsRelocatable</key><false/>
<key>BundleOverwriteAction</key><string>upgrade</string>
</dict><dict>
<key>RootRelativeBundlePath</key><string>Library/Audio/Plug-Ins/HAL/vRemoteDriver.driver</string>
<key>BundleIsRelocatable</key><false/>
<key>BundleOverwriteAction</key><string>upgrade</string>
</dict></array></plist>
PLIST
pkgbuild --root "$PAYLOAD" --component-plist "$ROOT/dist/components.plist" \
  --scripts "$ROOT/Packaging/pkg-scripts" --identifier local.simaqingfeng.vRemoter.pkg \
  --version "$PACKAGE_VERSION" "$COMPONENT"
cat > "$ROOT/dist/distribution.xml" <<XML
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="2">
<title>vRemoter $VERSION · Typeless</title>
<options customize="never" require-scripts="false" hostArchitectures="arm64"/>
<domains enable_localSystem="true" enable_currentUserHome="false" enable_anywhere="false"/>
<volume-check><allowed-os-versions><os-version min="12.0"/></allowed-os-versions></volume-check>
<choices-outline><line choice="default"/></choices-outline>
<choice id="default" visible="false"><pkg-ref id="local.simaqingfeng.vRemoter.pkg"/></choice>
<pkg-ref id="local.simaqingfeng.vRemoter.pkg" version="$PACKAGE_VERSION">vRemoter-component.pkg</pkg-ref>
</installer-gui-script>
XML
sign_args=()
if [[ -n "${INSTALLER_SIGN_IDENTITY:-}" ]]; then
  sign_args=(--sign "$INSTALLER_SIGN_IDENTITY")
fi
productbuild --distribution "$ROOT/dist/distribution.xml" --package-path "$ROOT/dist" "${sign_args[@]}" "$FINAL"
if [[ -n "${INSTALLER_SIGN_IDENTITY:-}" ]]; then
  pkgutil --check-signature "$FINAL"
else
  print -u2 'Built unsigned installer (Developer ID signing/notarization not configured).'
fi
print "Built standalone App + source-built driver installer: $FINAL"
