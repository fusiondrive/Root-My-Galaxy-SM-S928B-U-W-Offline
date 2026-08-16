#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "${SCRIPT_DIR}/.." && pwd)"

U_PROFILE="e3q-S928USQS6DZF2"
W_PROFILE="e3q-S928W-S928USQS6DZF2"
B_PROFILE="e3q-S928BXXS6DZF2"

U_PAYLOAD_SHA="b2931d8980f969b5a0cb05bd67f6804f445ad4a4c867a7b4c4081c2ffac5b36a"
W_PAYLOAD_SHA="82531cb637067d8e849f1c9d259933dcc3bed3519c1603841333cc8bcbd789e0"
B_PAYLOAD_SHA="a49b378d654c7e637697a701c3c4c5fd02d22b9b30a7069c03e64ec5844af206"
U_KSUD_SHA="10c1bf87f8e475e6ab8c5d1c5a085aa1544ee091f4451ad65141ea75261ab610"
B_KSUD_SHA="43f451313dc111429187f8f93e76c57c42976323782aac936c1c09aa309b76b3"
HELPER_SHA="54894e9bfa80fc36cfa03bd4ec4279e1d56eccc9719c9ee395b64ffd6792866b"
U_KO_SHA="ed7afea6cd221d5698739d3a1633264c084ffb77f2df730e5808941e0a555de5"
B_KO_SHA="14f805c6a03123e84f10a252eb5b47f6c65c56c05ad4ccccf1f836c6867f64a9"

DO_PREPARE_APP=1
DO_BUILD_APK=0
DO_INSTALL_APK=0
DO_STAGE_ADB=0
DO_PRINT_COMMAND=1
DO_ADB_CHECK=1

usage() {
  cat <<USAGE
Usage:
  ${0##*/} [options]

Default:
  verifies the bundled S928U/U1, S928W, and S928B DZF2 artifacts and
  refreshes app/src/main/assets.

Options:
  --all             Verify, refresh assets, build APK, install APK, and stage ADB files.
  --build-apk       Build the debug APK.
  --install-apk     Install the built debug APK with adb install -r.
  --stage-adb       Push the matching payload/helper/ksud to /data/local/tmp.
  --no-adb-check    Do not inspect a connected device.
  --no-app-assets   Do not copy artifacts into app/src/main/assets.
  --no-print        Do not print the final ADB commands.
  -h, --help        Show this help.

This script stages and installs artifacts. It does not start a root shell.
USAGE
}

die() {
  echo "error: $*" >&2
  exit 1
}

info() {
  echo "[*] $*"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

sha256_file() {
  sha256sum "$1" | awk '{print $1}'
}

file_size() {
  if stat -c '%s' "$1" >/dev/null 2>&1; then
    stat -c '%s' "$1"
  else
    stat -f '%z' "$1"
  fi
}

assert_file() {
  test -f "$1" || die "file not found: $1"
}

assert_sha256() {
  local path="$1" expected="$2" label="$3" actual
  actual="$(sha256_file "$path")"
  test "$actual" = "$expected" || die "${label} sha256 mismatch: got ${actual}, expected ${expected}"
}

adb_prop() {
  adb shell "$1" 2>/dev/null | tr -d '\r'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --all)
      DO_BUILD_APK=1
      DO_INSTALL_APK=1
      DO_STAGE_ADB=1
      ;;
    --build-apk) DO_BUILD_APK=1 ;;
    --install-apk) DO_INSTALL_APK=1 ;;
    --stage-adb) DO_STAGE_ADB=1 ;;
    --no-adb-check) DO_ADB_CHECK=0 ;;
    --no-app-assets) DO_PREPARE_APP=0 ;;
    --no-print) DO_PRINT_COMMAND=0 ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
  shift
done

require_cmd sha256sum
require_cmd python3

U_PAYLOAD="${REPO_ROOT}/artifacts/${U_PROFILE}/cve-2026-43499-app.so"
W_PAYLOAD="${REPO_ROOT}/artifacts/${W_PROFILE}/cve-2026-43499-app.so"
B_PAYLOAD="${REPO_ROOT}/artifacts/${B_PROFILE}/cve-2026-43499-app.so"
U_KSUD="${REPO_ROOT}/kernelsu/ksud-${U_PROFILE}-kdp"
B_KSUD="${REPO_ROOT}/kernelsu/ksud-${B_PROFILE}-kdp"
W_KSUD="$B_KSUD"
U_KO="${REPO_ROOT}/kernelsu/android14-6.1_kernelsu-${U_PROFILE}-kdp.ko"
B_KO="${REPO_ROOT}/kernelsu/android14-6.1_kernelsu-${B_PROFILE}-kdp.ko"
HELPER="${REPO_ROOT}/app/src/main/jniLibs/arm64-v8a/libcve43499root.so"

info "verifying published artifacts"
assert_file "$U_PAYLOAD"
assert_file "$W_PAYLOAD"
assert_file "$B_PAYLOAD"
assert_file "$U_KSUD"
assert_file "$B_KSUD"
assert_file "$U_KO"
assert_file "$B_KO"
assert_file "$HELPER"
test "$(file_size "$U_PAYLOAD")" = "104128" || die "U payload size mismatch"
test "$(file_size "$W_PAYLOAD")" = "104128" || die "W payload size mismatch"
test "$(file_size "$B_PAYLOAD")" = "104128" || die "B payload size mismatch"
assert_sha256 "$U_PAYLOAD" "$U_PAYLOAD_SHA" "S928U payload"
assert_sha256 "$W_PAYLOAD" "$W_PAYLOAD_SHA" "S928W payload"
assert_sha256 "$B_PAYLOAD" "$B_PAYLOAD_SHA" "S928B payload"
assert_sha256 "$U_KSUD" "$U_KSUD_SHA" "S928U ksud"
assert_sha256 "$B_KSUD" "$B_KSUD_SHA" "S928B ksud"
assert_sha256 "$U_KO" "$U_KO_SHA" "S928U kernelsu.ko"
assert_sha256 "$B_KO" "$B_KO_SHA" "S928B kernelsu.ko"
assert_sha256 "$HELPER" "$HELPER_SHA" "public root helper"

python3 - "$REPO_ROOT/app/src/main/assets/targets-v3.json" <<'PY'
import json, sys
root = json.load(open(sys.argv[1]))
assert root["schemaVersion"] == 3
ids = [item["payloadId"] for item in root["payloads"]]
assert ids == [
    "e3q-S928USQS6DZF2",
    "e3q-S928W-S928USQS6DZF2",
    "e3q-S928BXXS6DZF2",
], ids
print("[+] targets-v3.json has the three DZF2 profiles")
PY

if [ "$DO_PREPARE_APP" -eq 1 ]; then
  info "refreshing bundled app assets"
  install -d "${REPO_ROOT}/app/src/main/assets/${U_PROFILE}"
  install -d "${REPO_ROOT}/app/src/main/assets/${W_PROFILE}"
  install -d "${REPO_ROOT}/app/src/main/assets/${B_PROFILE}"
  install -m 0644 "$U_PAYLOAD" "${REPO_ROOT}/app/src/main/assets/${U_PROFILE}/cve-2026-43499-app.so"
  install -m 0644 "$U_KSUD" "${REPO_ROOT}/app/src/main/assets/${U_PROFILE}/ksud-${U_PROFILE}-kdp"
  install -m 0644 "$W_PAYLOAD" "${REPO_ROOT}/app/src/main/assets/${W_PROFILE}/cve-2026-43499-app.so"
  install -m 0644 "$B_PAYLOAD" "${REPO_ROOT}/app/src/main/assets/${B_PROFILE}/cve-2026-43499-app.so"
  install -m 0644 "$B_KSUD" "${REPO_ROOT}/app/src/main/assets/${B_PROFILE}/ksud-${B_PROFILE}-kdp"
  install -m 0644 "${REPO_ROOT}/support/targets-v3.json" "${REPO_ROOT}/app/src/main/assets/targets-v3.json"
fi

if [ "$DO_BUILD_APK" -eq 1 ]; then
  require_cmd "$REPO_ROOT/gradlew"
  info "building debug APK"
  (CDPATH= cd -- "$REPO_ROOT" && ./gradlew :app:assembleDebug)
fi

if [ "$DO_INSTALL_APK" -eq 1 ]; then
  require_cmd adb
  APK="${REPO_ROOT}/app/build/outputs/apk/debug/app-debug.apk"
  assert_file "$APK"
  info "installing $APK"
  adb install -r "$APK"
fi

SELECTED_PROFILE=""
SELECTED_PAYLOAD=""
SELECTED_KSUD=""
if [ "$DO_ADB_CHECK" -eq 1 ] && { [ "$DO_STAGE_ADB" -eq 1 ] || [ "$DO_PRINT_COMMAND" -eq 1 ]; }; then
  if adb get-state >/dev/null 2>&1; then
    MODEL="$(adb_prop 'getprop ro.product.model')"
    KERNEL="$(adb_prop 'uname -r')"
    info "connected model=${MODEL} kernel=${KERNEL}"
    case "$MODEL" in
      SM-S928U|SM-S928U1)
        SELECTED_PROFILE="$U_PROFILE"
        SELECTED_PAYLOAD="$U_PAYLOAD"
        SELECTED_KSUD="$U_KSUD"
        ;;
      SM-S928W)
        SELECTED_PROFILE="$W_PROFILE"
        SELECTED_PAYLOAD="$W_PAYLOAD"
        SELECTED_KSUD="$W_KSUD"
        ;;
      SM-S928B)
        SELECTED_PROFILE="$B_PROFILE"
        SELECTED_PAYLOAD="$B_PAYLOAD"
        SELECTED_KSUD="$B_KSUD"
        ;;
      *)
        echo "warning: connected model ${MODEL} is not a bundled DZF2 target" >&2
        ;;
    esac
  else
    echo "warning: no adb device connected" >&2
  fi
fi

if [ "$DO_STAGE_ADB" -eq 1 ]; then
  [ -n "$SELECTED_PROFILE" ] || die "cannot stage ADB files without a matching S928 DZF2 device"
  require_cmd adb
  STAGE="/data/local/tmp/rmg-s928/${SELECTED_PROFILE}"
  info "staging ${SELECTED_PROFILE} to ${STAGE}"
  adb shell "mkdir -p '${STAGE}'"
  adb push "$SELECTED_PAYLOAD" "${STAGE}/cve-2026-43499-app.so"
  adb push "$SELECTED_KSUD" "${STAGE}/ksud"
  adb push "$HELPER" /data/local/tmp/libcve43499root
  adb push "$SELECTED_KSUD" /data/local/tmp/ksud-selected
  adb shell "chmod 755 /data/local/tmp/libcve43499root /data/local/tmp/ksud-selected '${STAGE}/ksud'"
fi

if [ "$DO_PRINT_COMMAND" -eq 1 ]; then
  cat <<EOF

Next steps:
  1. Install and start Shizuku.
  2. Open Root My Galaxy and grant Shizuku permission.
  3. Confirm uname -r matches the exact DZF2 string for this phone.
  4. If a previous run failed: adb shell rm -f /data/local/tmp/ksu-payload

EOF
  if [ -n "$SELECTED_PROFILE" ]; then
    echo "Selected profile: ${SELECTED_PROFILE}"
    echo "Staged payload: /data/local/tmp/rmg-s928/${SELECTED_PROFILE}/cve-2026-43499-app.so"
  fi
fi

info "done"
