# Root My Galaxy SM-S928 DZF2 Offline

Offline Root My Galaxy workspace for Galaxy S24 Ultra `e3q` on exact DZF2
firmware. One APK bundles three independently audited targets:

| Model | Firmware | Kernel | Profile |
| --- | --- | --- | --- |
| `SM-S928U` / `SM-S928U1` | `S928U1UES6DZF2` / `S928USQS6DZF2` | `6.1.145-android14-11-33419968-abS928USQS6DZF2` | `e3q-S928USQS6DZF2` |
| `SM-S928W` | `S928WVLS6DZF2` | `6.1.145-android14-11-33419968-abS928USQS6DZF2` | `e3q-S928W-S928USQS6DZF2` |
| `SM-S928B` | `S928BXXS6DZF2` | `6.1.145-android14-11-33419968-abS928BXXS6DZF2` | `e3q-S928BXXS6DZF2` |

This repository keeps the public-source payload tree, the offline Android app,
target manifests, KernelSU pairs, and the helper scripts needed to reproduce
the pack. Use it only on devices you own or are explicitly authorized to test.

The app does not download payloads from GitHub. Matching is exact: model plus
kernel `6.1.145` plus the DZF2 kernel release and build token. `SM-S928N`,
`SM-S9280`, and any non-DZF2 build are rejected. `SM-S928W` is its own
profile; it does not reuse the U/U1 payload or `ksud`.

## Screenshots

These screenshots come from the validated DZF2 devices. Root is per-boot.
No boot image is modified, so reboot survival is not claimed.

<table>
  <tr>
    <td align="center"><strong>SM-S928U1 Root My Galaxy</strong></td>
    <td align="center"><strong>SM-S928U1 KernelSU</strong></td>
    <td align="center"><strong>SM-S928W KernelSU</strong></td>
    <td align="center"><strong>SM-S928B KernelSU</strong></td>
  </tr>
  <tr>
    <td align="center">
      <img src="docs/assets/screenshots/s928u1-root-my-galaxy.jpg" alt="Root My Galaxy showing KernelSU active on SM-S928U1" width="180">
    </td>
    <td align="center">
      <img src="docs/assets/screenshots/s928u1-kernelsu.jpg" alt="KernelSU Manager on SM-S928U1 DZF2" width="180">
    </td>
    <td align="center">
      <img src="docs/assets/screenshots/s928w-kernelsu.jpg" alt="KernelSU Manager on SM-S928W DZF2" width="180">
    </td>
    <td align="center">
      <img src="docs/assets/screenshots/s928b-kernelsu.png" alt="KernelSU Manager on SM-S928B DZF2" width="180">
    </td>
  </tr>
</table>

## Validated Targets

```text
model: SM-S928U1
device: e3q
build display: BP4A.251205.006.S928U1UES6DZF2
fingerprint: samsung/e3quew/e3q:16/BP4A.251205.006/S928U1UES6DZF2:user/release-keys
kernel release: 6.1.145-android14-11-33419968-abS928USQS6DZF2

model: SM-S928W
device: e3q
product: e3qcsx
build display: BP4A.251205.006.S928WVLS6DZF2
fingerprint: samsung/e3qcsx/e3q:16/BP4A.251205.006/S928WVLS6DZF2:user/release-keys
kernel release: 6.1.145-android14-11-33419968-abS928USQS6DZF2

model: SM-S928B
device: e3q
build display: BP4A.251205.006.S928BXXS6DZF2
fingerprint: samsung/e3qxxx/e3q:16/BP4A.251205.006/S928BXXS6DZF2:user/release-keys
kernel release: 6.1.145-android14-11-33419968-abS928BXXS6DZF2
```

U/U1 and W share the US DZF2 kernel banner, but W is still a separate port:
bucket `28` / one bank slot, and the S928B no-patch-text `ksud`. S928B keeps
its own kernel vermagic and `SLIDE_NFULNL_LOGGER_OFF` (`0x016a622a` vs
`0x016a61b8` on U/U1 and W). Do not swap the three payloads or the U `ksud`.

## Prerequisites

1. **Enable Developer options and USB debugging**.
2. **Enable "Disable child process restrictions"** in Developer options.
   Shizuku needs this to spawn the helper processes.
3. **Install [Shizuku](https://shizuku.rikka.app/).** These ports were validated
   in Shizuku mode (`uid=2000`, `u:r:shell:s0`, `Seccomp=0`).
4. **Reboot the phone.**
5. **Close every other app.** Keep only Shizuku and Root My Galaxy running.
6. **Start Shizuku**, then open Root My Galaxy and grant permission.
7. If a previous attempt left a stale file, remove it before retrying:

```sh
adb shell rm -f /data/local/tmp/ksu-payload
```

The method is per-boot. A reboot drops KernelSU until you run the app again.

## Documentation

- [Documentation Index](docs/README.md)
- [Target Profile](docs/TARGET.md)
- [Project Structure](docs/PROJECT_STRUCTURE.md)
- [Reproduce The Port](docs/REPRODUCE_PORT.md)
- [Build, Install, And ADB](docs/BUILD_INSTALL_ADB.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [SM-S928U1 record](docs/SM-S928U1-S928U1UES6DZF2.md)
- [SM-S928W record](docs/SM-S928W-S928USQS6DZF2.md)
- [SM-S928B record](docs/SM-S928B-S928BXXS6DZF2.md)

## Quick Start

From the repository root:

```sh
./tools/prepare-s928-dzf2.sh
```

Build the debug APK:

```sh
./tools/prepare-s928-dzf2.sh --build-apk
```

A prebuilt debug APK from this tree is:

```text
dist/RootMyGalaxy-S928-DZF2-offline-v0.3.2.apk
```

Rebuild one public payload:

```sh
make TARGET=e3q-S928USQS6DZF2 stable
make TARGET=e3q-S928W-S928USQS6DZF2 stable
make TARGET=e3q-S928BXXS6DZF2 stable
```

## Important Files

```text
tools/prepare-s928-dzf2.sh
app/src/main/assets/targets-v3.json
src/targets/e3q-S928USQS6DZF2/target.h
src/targets/e3q-S928W-S928USQS6DZF2/target.h
src/targets/e3q-S928BXXS6DZF2/target.h
artifacts/e3q-S928USQS6DZF2/cve-2026-43499-app.so
artifacts/e3q-S928W-S928USQS6DZF2/cve-2026-43499-app.so
artifacts/e3q-S928BXXS6DZF2/cve-2026-43499-app.so
kernelsu/ksud-e3q-S928USQS6DZF2-kdp
kernelsu/ksud-e3q-S928BXXS6DZF2-kdp
```

## Credits

- Device-tested `SM-S928U1` DZF2 payload and offline launcher work in this
  workspace.
- [RiosWesley](https://github.com/RiosWesley) for the `SM-S928B` /
  `S928BXXS6DZF2` payload, KernelSU pair, and hardware evidence in
  [BuSung-dev/Root-My-Galaxy-Payloads#208](https://github.com/BuSung-dev/Root-My-Galaxy-Payloads/pull/208).
- [mvfsullivan](https://github.com/mvfsullivan) for the Canadian `SM-S928W`
  bucket/`ksud` findings and hardware evidence in
  [BuSung-dev/Root-My-Galaxy-Payloads#216](https://github.com/BuSung-dev/Root-My-Galaxy-Payloads/pull/216).
- [soumarcelino/Root-My-Galaxy-SM-S918B](https://github.com/soumarcelino/Root-My-Galaxy-SM-S918B)
  for the offline repository layout, bundled `asset://` app flow, and
  reproduction-script structure used as the packaging model.
- [youyoudezhuzhu/rmg-f731u](https://github.com/youyoudezhuzhu/rmg-f731u) for
  the Root My Galaxy app baseline.
- [BuSung-dev/Root-My-Galaxy-Payloads](https://github.com/BuSung-dev/Root-My-Galaxy-Payloads)
  for the public payload source tree and support-manifest schema.

This repository is an offline S24 Ultra DZF2 pack. It is not the official
multi-device Root My Galaxy feed.
