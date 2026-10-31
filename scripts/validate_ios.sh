#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v xcodebuild >/dev/null || ! command -v xcrun >/dev/null; then
    echo "Requires macOS with full Xcode selected. iOS validation was not run." >&2
    exit 2
fi
if [[ -z "${GRADUFIT_SIMULATOR_ID:-}" ]]; then
    echo "Choose an available iPhone UDID from: xcrun simctl list devices available" >&2
    echo "Then run: GRADUFIT_SIMULATOR_ID=<UDID> bash scripts/validate_ios.sh" >&2
    exit 2
fi

mkdir -p build
run_id="$(date -u +%Y%m%dT%H%M%SZ)-$$"
xcodebuild -project GraduFit.xcodeproj -scheme GraduFit \
    -destination "platform=iOS Simulator,id=$GRADUFIT_SIMULATOR_ID" \
    -derivedDataPath DerivedData \
    -resultBundlePath "build/GraduFit-$run_id.xcresult" \
    CODE_SIGNING_ALLOWED=NO build test

device_state="$(xcrun simctl list devices booted)"
if [[ "$device_state" != *"$GRADUFIT_SIMULATOR_ID"* ]]; then
    xcrun simctl boot "$GRADUFIT_SIMULATOR_ID"
fi
xcrun simctl bootstatus "$GRADUFIT_SIMULATOR_ID" -b
xcrun simctl install "$GRADUFIT_SIMULATOR_ID" DerivedData/Build/Products/Debug-iphonesimulator/GraduFit.app
xcrun simctl launch "$GRADUFIT_SIMULATOR_ID" com.gradufit.GraduFit
echo "Build/test results: build/GraduFit-$run_id.xcresult"
echo "UI tests retain collapsed, expanded, and accessibility screenshots in the result bundle."
echo "App launched for manual inspection. Compare against docs/visual-review.md before proceeding."
