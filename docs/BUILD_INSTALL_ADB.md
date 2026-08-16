# Build, Install, And ADB

This page covers the local flow after the bundled files have been verified.

## Build The Debug APK

```sh
./tools/prepare-s928-dzf2.sh --build-apk
```

APK output:

```text
app/build/outputs/apk/debug/app-debug.apk
```

Manual Gradle build:

```sh
./gradlew :app:assembleDebug
```

Package identity:

```text
applicationId: io.github.fusiondrive.s928offline
versionName: 0.3.2-s928-dzf2-offline
```

This is distinct from official Root My Galaxy (`dev.busung.s25uroot`) and
from the S918B offline app (`io.github.rootmygalaxy.s23ultra`).

## Install The APK

```sh
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

Or let the script build and install:

```sh
./tools/prepare-s928-dzf2.sh --build-apk --install-apk
```

## Stage Files With ADB

```sh
./tools/prepare-s928-dzf2.sh --stage-adb
```

The script reads the connected device model and stages the matching pair:

```text
/data/local/tmp/rmg-s928/<profile>/cve-2026-43499-app.so
/data/local/tmp/rmg-s928/<profile>/ksud
/data/local/tmp/libcve43499root
/data/local/tmp/ksud-selected
```

## Full Local Flow

```sh
./tools/prepare-s928-dzf2.sh --all
```

This does:

```text
1. Verify bundled hashes.
2. Refresh app assets.
3. Build the debug APK.
4. Install the APK if a device is connected.
5. Stage the matching payload/helper/ksud files.
6. Print the manual ADB command.
```

## Manual ADB Test Commands

Clear a stale previous attempt:

```sh
adb shell rm -f /data/local/tmp/ksu-payload
```

Read the identity the pack will match:

```sh
adb shell 'getprop ro.product.model; getprop ro.build.display.id; getprop ro.build.fingerprint; uname -r'
```

The script prints the payload path for the connected model. It does not open a
root shell automatically.

## Notes

Use Shizuku. The S928B validation record and later public testers both needed
`uid=2000` / `u:r:shell:s0`. A normal untrusted_app run can reboot or fail.
