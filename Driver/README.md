# vRemote HAL driver

The standalone installer includes this driver and the Typeless App. Neither the build machine nor the destination Mac needs BlackHole or the original vRemoter installed.

## Build

```sh
zsh Driver/build-driver.sh
zsh Scripts/test-driver.sh
```

The build uses Apple's SDK and clang (`xcrun`), and emits a locally signed universal `arm64` + `x86_64` driver at `Driver/build/vRemoteDriver.driver`. The standalone App/PKG is currently Apple Silicon only. No binary patching or installed-driver copying is performed.

The included source is derived from BlackHole 0.4.1, commit `903a7be255e77a4bc7847e0cfb9a46c190038d4e`, under GPL v3. See [BlackHole/UPSTREAM.md](BlackHole/UPSTREAM.md) and [BlackHole/LICENSE](BlackHole/LICENSE).

The App accesses the CoreAudio device `vRemoteDr 2ch`. Bundle ID `audio.local.vRemoteDriver2chXX`, UID `vRemoteDr2ch_UID`, factory UUID `B7C4C615-9E72-4C83-A329-71C4E50E4A91`, and the USB Device transport identity match previous installations. The outer Box transport remains virtual. This preserves the existing audio route while replacing the binary-patching build with a source build.

## Install

Use the fork's standalone `.pkg`, built by `zsh Scripts/build-pkg.sh`. It installs:

- `/Applications/vRemote.app`
- `/Library/Audio/Plug-Ins/HAL/vRemoteDriver.driver`

Installer requires administrator authorization and restarts the audio service on the startup volume. App preferences are not overwritten. The App is launched for the logged-in user when possible; if there is no interactive session, launch it manually after signing in.

For driver-only development, `install-driver.sh` refuses to overwrite an existing copy; the standalone PKG supports replacing it. `uninstall-driver.sh` removes only this dedicated HAL plug-in. Do not set a virtual audio device as the system speaker output merely to use Typeless.

Release assets include a source archive with the complete driver source, license, metadata and build scripts. The same files remain in the repository. The original project's historical instructions are superseded by this source-based workflow.
