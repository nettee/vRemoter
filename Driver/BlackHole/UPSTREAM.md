# BlackHole source provenance

- Project: https://github.com/ExistentialAudio/BlackHole
- Version: v0.4.1
- Commit: 903a7be255e77a4bc7847e0cfb9a46c190038d4e
- Copyright: Existential Audio Inc.
- License: GNU General Public License v3 (see LICENSE).
- Files included: BlackHole/BlackHole.c, BlackHole/BlackHole.icns, LICENSE.

Modifications for vRemoter (2026-11-20):

1. Device transport property returns `kAudioDeviceTransportTypeUSB`; the Box transport remains virtual, matching earlier vRemoteDriver installations.
2. Default Box name is `vRemoteDr Box`.
3. `../build-driver.sh` sets `kDriver_Name="vRemoteDr"` and `kPlugIn_BundleID="audio.local.vRemoteDriver2chXX"`, producing the existing device name and UID without changing their format.
4. `../Info.plist` supplies vRemote's factory UUID, identity and version. The executable entry point remains `BlackHole_Create`.

Build recipe: run `zsh Driver/build-driver.sh` from the repository root with Apple's command line developer tools installed. This produces both arm64 and x86_64 slices, links CoreAudio, CoreFoundation and Accelerate, and ad-hoc signs the bundle. No installed BlackHole binary or original vRemoter package is read.

This modified driver remains GPL v3. The original copyright header and full license are retained. Source archives distributed with the standalone installer contain this directory, its parent build script and Info.plist.
