# e3q-S928W-S928USQS6DZF2 target profile

Canadian Galaxy S24 Ultra (`SM-S928W`) on the shared US DZF2 kernel
`6.1.145-android14-11-33419968-abS928USQS6DZF2`.

This is a separate profile from `e3q-S928USQS6DZF2`. The W kernel uses the
same vermagic as U/U1, but two runtime differences were recorded in
[BuSung-dev/Root-My-Galaxy-Payloads#216](https://github.com/BuSung-dev/Root-My-Galaxy-Payloads/pull/216):

- SLUB packs 28 `mm_struct` objects, so `SLIDE_S928_BANK_LOCK_MAX_BUCKET` is
  `28` and `SLIDE_BANK_SLOTS` is `1`.
- The U/U1 `ksud` live-patches text and panics under KDP/RKP. W uses the
  S928B no-patch-text `ksud-e3q-S928BXXS6DZF2-kdp`.

Do not replace the U/U1 payload or `ksud` with these W values. The U/U1
profile stays on bucket `27`, four bank slots, and its own late-load pair.

The PR #216 commit did not actually replace
`artifacts/e3q-S928USQS6DZF2/cve-2026-43499-app.so`; that file still hashes
as the original U/U1 payload. The W payload in this pack was rebuilt here
from this header with `make TARGET=e3q-S928W-S928USQS6DZF2 stable`.
