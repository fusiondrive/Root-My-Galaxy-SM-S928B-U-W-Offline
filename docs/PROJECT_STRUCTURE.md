# Project Structure

This repository is an offline S24 Ultra DZF2 pack. The layout follows the
SM-S918B offline workspace: source, app, manifests, and helper scripts stay
in git; Gradle caches and built APKs do not.

## Top-Level Layout

```text
app/
  Offline Android application. It reads asset:// payloads only.

src/
  Public payload source snapshot.

src/targets/e3q-S928USQS6DZF2/
  Headers for SM-S928U / SM-S928U1 DZF2.

src/targets/e3q-S928W-S928USQS6DZF2/
  Headers for SM-S928W DZF2. Bucket 28 / one bank slot only.

src/targets/e3q-S928BXXS6DZF2/
  Headers for SM-S928B DZF2.

artifacts/
  Published 104,128-byte app payloads for the two targets.

support/
  Schema v2 and v3 manifests used by the offline app.

kernelsu/
  Exact-vermagic modules, late-load ksud binaries, and audit tools.

tools/
  Prepare/build helpers.

docs/
  Target records, reproduction notes, and screenshots.
```

## Most Relevant Files

```text
tools/prepare-s928-dzf2.sh
  Verifies bundled hashes, copies assets into the app tree, and can build
  the debug APK.

app/src/main/assets/targets-v3.json
  Dual-target offline catalog.

app/src/main/java/dev/busung/s25uroot/PayloadRepository.kt
  Extracts and checksums the matching bundled payload.

src/targets/e3q-S928USQS6DZF2/target.h
src/targets/e3q-S928W-S928USQS6DZF2/target.h
src/targets/e3q-S928BXXS6DZF2/target.h
  Firmware-specific constants. Do not mix them.
```

## Why There Is No app-src Tree

The SM-S918B workspace keeps an extra `app-src/` snapshot of the F731U app.
This pack does not need that comparison tree. The runnable app lives in
`app/` and is already adapted for two bundled DZF2 targets.
