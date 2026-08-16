# Reproduce The Port

The published payloads are already checked in. Rebuild them only when a
target header changes. The two firmware builds must be compiled separately.

## Prerequisites

- Android NDK with `aarch64-linux-android35-clang`
- `ANDROID_NDK_HOME` pointing at that NDK
- `jq` and `sha256sum` for the prepare script

## Rebuild One Target

```sh
make TARGET=e3q-S928USQS6DZF2 stable
make TARGET=e3q-S928BXXS6DZF2 stable
```

Copy the rebuilt `build/<target>/cve-2026-43499-app.stable.so` over
`artifacts/<target>/cve-2026-43499-app.so` only after the SHA-256 matches the
expected value in `PROJECT-MANIFEST.txt`.

## Expected Payload Hashes

```text
e3q-S928USQS6DZF2/cve-2026-43499-app.so
size 104128
SHA-256 b2931d8980f969b5a0cb05bd67f6804f445ad4a4c867a7b4c4081c2ffac5b36a

e3q-S928BXXS6DZF2/cve-2026-43499-app.so
size 104128
SHA-256 a49b378d654c7e637697a701c3c4c5fd02d22b9b30a7069c03e64ec5844af206
```

## Prepare App Assets

```sh
./tools/prepare-s928-dzf2.sh
```

The script checks the two payloads, two `ksud` binaries, and the public root
helper, then copies them into `app/src/main/assets/<profileId>/`.

## What Must Not Be Reused

- Do not compile S928B with `TARGET=e3q-S928USQS6DZF2`.
- Do not copy `SLIDE_NFULNL_LOGGER_OFF` between the two headers.
- Do not embed the U/U1 `ksud` in the B asset directory, or the reverse.
- Do not treat BTF identity as proof that vermagic or logger-string offsets
  are identical.
