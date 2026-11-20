# Third-party notices

`vRemoter` contains code adapted from
[fanxeon/mi-ao](https://github.com/fanxeon/mi-ao), distributed under the MIT
License, Copyright (c) 2026 FanXeon@Poemcoder with Codex.

Its ATVV protocol and IMA/DVI ADPCM implementation were informed by:

- [b0o/ATVVoice](https://github.com/b0o/ATVVoice), MIT License,
  Copyright (c) 2026 Maddison Cohodas.
- [Google Voice over BLE specification v1.0](https://wangefan.github.io/linux_kernel_driver/resources/Google_Voice_over_BLE_spec_v1.0.pdf).

`vRemoteDriver.driver` is built from the included modified source of
[ExistentialAudio/BlackHole](https://github.com/ExistentialAudio/BlackHole)
0.4.1 (commit `903a7be255e77a4bc7847e0cfb9a46c190038d4e`) and remains
licensed under GNU GPL v3, Copyright (C) 2019 Existential Audio Inc.
The full license, source and modification notes are in `Driver/BlackHole/`.
The standalone PKG includes the license inside the driver bundle; release
assets also include the corresponding driver source and build scripts.
This supersedes the original proof-of-concept binary-patching build.
