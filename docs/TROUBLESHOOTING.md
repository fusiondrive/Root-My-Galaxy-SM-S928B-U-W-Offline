# Troubleshooting

## Support check failed

The phone is not one of the three exact DZF2 profiles.

```sh
adb shell 'getprop ro.product.model; getprop ro.build.display.id; getprop ro.build.fingerprint; uname -r'
```

Accepted:

```text
SM-S928U or SM-S928U1
...S928U1UES6DZF2 or ...S928USQS6DZF2
6.1.145-android14-11-33419968-abS928USQS6DZF2

SM-S928W
...S928WVLS6DZF2
6.1.145-android14-11-33419968-abS928USQS6DZF2

SM-S928B
...S928BXXS6DZF2
6.1.145-android14-11-33419968-abS928BXXS6DZF2
```

`SM-S928N`, `SM-S9280`, CZC1, and ZDP are not in this pack.

## uid is 10xxx and context is untrusted_app

The exploit ran in normal app mode. Shizuku is not actually executing the
payload.

The successful path must show:

```text
uid=2000
context=u:r:shell:s0
Seccomp=0
```

Open Shizuku, authorize Root My Galaxy again, and confirm "Disable child
process restrictions" is enabled. Then reboot once and retry.

## Reboot on attempt 1, or leftover ksu-payload

A previous failed run can leave `/data/local/tmp/ksu-payload`. Clear it:

```sh
adb shell rm -f /data/local/tmp/ksu-payload
```

## Checksum mismatch while extracting bundled files

The APK assets no longer match `app/src/main/assets/targets-v3.json`.

```sh
./tools/prepare-s928-dzf2.sh
```

Do not replace a payload or `ksud` from another model just because the file
size looks similar.

## `late-load: bind mount: No such file or directory` (`rc=11`)

Bootstrap root succeeded, but the helper bind-mounts
`/data/local/tmp/ksud-s25u-kdp` onto `/system/bin/logcat`. If Shizuku only
staged `ksud-selected`, that source path is missing.

v0.3.4 stages both names. Reinstall that APK, or copy the file once:

```sh
adb shell cp /data/local/tmp/ksud-selected /data/local/tmp/ksud-s25u-kdp
```

## KernelSU loads then watchdog / reboot

Confirm the selected profile matches the phone. The U/U1 `ksud` live-patches
text and panics on `SM-S928W`. W must use the S928B no-patch-text `ksud`.
The U/U1 and B modules also have different vermagic strings.

## Hash mismatch on a rebuilt payload

The published SHA-256 values are the device-tested files. A local rebuild
must match those hashes before it replaces `artifacts/`. If it does not,
keep the published file.
