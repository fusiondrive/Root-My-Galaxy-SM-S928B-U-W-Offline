# PORTING.md — S928 DZF2 offline pack

This pack is not an offset-patched closed engine. Both targets are public
payloads from the Root-My-Galaxy-Payloads tree, packaged the same way as the
SM-S918B offline workspace.

## What this pack is

- One Android app
- Two exact DZF2 profiles
- Bundled `asset://` payloads and `ksud` binaries
- No GitHub download at install time

## What must stay separate

The S928B kernel is not a rename of the S928U1 kernel.

| Item | S928U / S928U1 | S928B |
| --- | --- | --- |
| Kernel release | `...-abS928USQS6DZF2` | `...-abS928BXXS6DZF2` |
| Build fingerprint product | `e3quew` | `e3qxxx` |
| `SLIDE_NFULNL_LOGGER_OFF` | `0x016a61b8` | `0x016a622a` |
| Payload SHA-256 | `b2931d89...` | `a49b378d...` |
| `ksud` size | 4,998,352 | 4,748,232 |

BTF and the P0 fingerprint table match. Vermagic and the logger-string offset
do not. Copying one profile onto the other device is a firmware mismatch.

## Adding another S928 build

1. Recover that build's kernel and BTF.
2. Create a new `src/targets/<profile>/` directory. Do not edit the DZF2
   headers in place.
3. Rebuild with `make TARGET=<profile> stable`.
4. Build or audit a KernelSU pair with that exact vermagic.
5. Add a new payload entry. Never widen `SM-S928U` / `SM-S928B` to cover the
   new build.
