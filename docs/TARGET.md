# Target Profile

This pack supports three exact DZF2 builds of Galaxy S24 Ultra, codename `e3q`.
Values must not be copied onto another firmware.

## SM-S928U / SM-S928U1

```text
models: SM-S928U, SM-S928U1
device: e3q
product: e3quew
package firmware: S928U1UES6DZF2
internal kernel build: S928USQS6DZF2
build display: BP4A.251205.006.S928U1UES6DZF2
fingerprint: samsung/e3quew/e3q:16/BP4A.251205.006/S928U1UES6DZF2:user/release-keys
kernel release: 6.1.145-android14-11-33419968-abS928USQS6DZF2
kernel build: #1 SMP PREEMPT Tue Jun  9 08:23:14 UTC 2026
sdk: 36
abi: arm64-v8a
page size: 4096
```

The outer package uses `SM-S928U1` / `S928U1UES6DZF2`. The kernel banner uses
`S928USQS6DZF2`. Both forms are accepted.

## SM-S928W

```text
model: SM-S928W
device: e3q
product: e3qcsx
package firmware: S928WVLS6DZF2
internal kernel build: S928USQS6DZF2
build display: BP4A.251205.006.S928WVLS6DZF2
fingerprint: samsung/e3qcsx/e3q:16/BP4A.251205.006/S928WVLS6DZF2:user/release-keys
kernel release: 6.1.145-android14-11-33419968-abS928USQS6DZF2
kernel build: #1 Tue Jun 9 12:38:51 UTC 2026
sdk: 36
abi: arm64-v8a
page size: 4096
```

W shares the US DZF2 kernel banner with U/U1. It is still a separate port:
`SLIDE_S928_BANK_LOCK_MAX_BUCKET` is `28`, `SLIDE_BANK_SLOTS` is `1`, and
late-load uses the S928B no-patch-text `ksud`.

## SM-S928B

```text
model: SM-S928B
device: e3q
product: e3qxxx
firmware: S928BXXS6DZF2
build display: BP4A.251205.006.S928BXXS6DZF2
fingerprint: samsung/e3qxxx/e3q:16/BP4A.251205.006/S928BXXS6DZF2:user/release-keys
kernel release: 6.1.145-android14-11-33419968-abS928BXXS6DZF2
kernel build: #1 SMP PREEMPT Tue Jun  9 07:41:42 UTC 2026
sdk: 36
abi: arm64-v8a
page size: 4096
```

## Shared vs separate

The recovered BTF hash is the same on both kernels:

```text
8415104c012e18942b18bcb52f401075cb6b92df837b9552a8c11070d65efe56
```

The audited symbol set also matches, except `SLIDE_NFULNL_LOGGER_OFF`:

```text
S928U/U1: 0x016a61b8
S928B:    0x016a622a
```

KernelSU vermagic is firmware-specific. Do not load the U/U1 module on B or
the B module on U/U1.

## Explicitly unsupported

- `SM-S928N`, `SM-S9280`
- Any CZC1 / ZDP / non-DZF2 build
- Any kernel that is not the exact `6.1.145-android14-11-33419968-ab...DZF2`
  string listed above
