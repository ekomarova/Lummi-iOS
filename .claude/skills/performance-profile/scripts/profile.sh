#!/bin/bash
# Records a Time Profiler trace of each Lummi performance scenario on a simulator and prints a summary.
#
# Usage: profile.sh <workdir> [scenario ...]      (no scenario, or "all", runs every scenario)
#   <workdir>  a scratch folder OUTSIDE the repository; the build, traces and reports go there.
#   scenarios: launch calendar day-switch insights all-joys all-joys-all-time all-joys-year trends-month trends-year
# Environment: SIM_UDID=<udid> picks the simulator, REBUILD=1 forces a fresh build,
#   PYTHON=<python> picks the interpreter for the trace analysis (default python3; it needs the defusedxml package).
#
# Read-only for the project: it never edits sources. `xcodebuild` may reorder lines in
# Lummi.xcodeproj/project.pbxproj; if that file was clean before the run it is restored afterwards.
# Each scenario drives the manual-only UI performance test of the same name (tests in
# LummiUITests/PerformanceUITests.swift) with the 5,000-entry in-memory store, and profiles its first launch.
# "launch" needs no UI test: the app is started directly under the profiler, so the very first instruction is recorded.

set -u

if [ $# -lt 1 ]; then
    echo "usage: profile.sh <workdir> [scenario ...]" >&2
    exit 2
fi

PYTHON="${PYTHON:-python3}"
"$PYTHON" -c 'import defusedxml' 2> /dev/null || {
    echo "the trace analysis needs defusedxml: $PYTHON -m pip install defusedxml (a virtual environment is fine; then PYTHON=<venv>/bin/python)" >&2
    exit 2
}

REPO="$(git rev-parse --show-toplevel)" || exit 2
SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK="$1"; shift
PBXPROJ="Lummi.xcodeproj/project.pbxproj"

case "$WORK" in
    "$REPO"|"$REPO"/*) echo "workdir must be outside the repository ($REPO)" >&2; exit 2 ;;
esac

scenario_test() {
    case "$1" in
        launch)       echo "-" ;;  # started directly under the profiler, no UI test
        calendar)     echo "test_Perf_OpenCalendarAndScrollBack" ;;
        day-switch)   echo "test_Perf_SwitchingSelectedDay" ;;
        insights)     echo "test_Perf_OpenInsights" ;;
        all-joys)     echo "test_Perf_OpenAllJoys" ;;
        all-joys-all-time) echo "test_Perf_OpenAllJoysAllTime" ;;
        all-joys-year)     echo "test_Perf_OpenAllJoysYear" ;;
        trends-month) echo "test_Perf_OpenTrendsMonth" ;;
        trends-year)  echo "test_Perf_OpenTrendsYear" ;;
        *) return 1 ;;
    esac
}
ALL_SCENARIOS="launch calendar day-switch insights all-joys all-joys-all-time all-joys-year trends-month trends-year"

SCENARIOS="${*:-all}"
[ "$SCENARIOS" = "all" ] && SCENARIOS="$ALL_SCENARIOS"
for scenario in $SCENARIOS; do
    scenario_test "$scenario" > /dev/null || { echo "unknown scenario: $scenario (known: $ALL_SCENARIOS)" >&2; exit 2; }
done

mkdir -p "$WORK/results" || exit 2
cd "$REPO" || exit 2

# Simulator: SIM_UDID, else a booted iPhone, else the first available iPhone.
UDID="${SIM_UDID:-$(xcrun simctl list devices available -j | python3 -c '
import json, sys
devices = [d for runtime in json.load(sys.stdin)["devices"].values() for d in runtime if "iPhone" in d["name"]]
devices.sort(key=lambda d: d["state"] != "Booted")
print(devices[0]["udid"] if devices else "")
')}"
[ -n "$UDID" ] || { echo "no iPhone simulator available" >&2; exit 2; }
echo "simulator: $UDID ($(xcrun simctl list devices available | grep "$UDID" | sed 's/^ *//'))"

git diff --quiet -- "$PBXPROJ"; PBXPROJ_WAS_CLEAN=$?   # 0 = clean

# Build once (Debug, so symbols are readable). Absolute numbers are Debug/simulator numbers.
XCTESTRUN="$(ls "$WORK"/dd/Build/Products/*.xctestrun 2>/dev/null | head -1)"
if [ -z "$XCTESTRUN" ] || [ "${REBUILD:-0}" = "1" ]; then
    echo "building (log: $WORK/build.log) ..."
    xcodebuild build-for-testing -scheme Lummi -destination "platform=iOS Simulator,id=$UDID" \
        -derivedDataPath "$WORK/dd" > "$WORK/build.log" 2>&1 || { echo "build failed, see $WORK/build.log" >&2; exit 1; }
    XCTESTRUN="$(ls "$WORK"/dd/Build/Products/*.xctestrun | head -1)"
fi

# Bundle identifiers come from the built products, so nothing project- or account-specific is written in this script.
PRODUCTS="$WORK/dd/Build/Products/Debug-iphonesimulator"
bundle_id() { /usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$1/Info.plist" 2> /dev/null; }
BUNDLE_ID="$(bundle_id "$PRODUCTS/Lummi.app")"
RUNNER_ID="$(bundle_id "$PRODUCTS/LummiUITests-Runner.app")"
[ -n "$BUNDLE_ID" ] || { echo "cannot read the app's bundle identifier from $PRODUCTS/Lummi.app" >&2; exit 1; }

# Stops the app and the UI-test runner so the next scenario starts clean.
stop_app() {
    xcrun simctl terminate "$UDID" "$BUNDLE_ID" > /dev/null 2>&1
    [ -n "$RUNNER_ID" ] && xcrun simctl terminate "$UDID" "$RUNNER_ID" > /dev/null 2>&1
    return 0
}

# The simulator has to be running for xctrace to launch or attach to anything.
xcrun simctl bootstatus "$UDID" -b > /dev/null 2>&1

find_app_pid() {
    ps -axo pid,command | awk -v u="$UDID" 'index($0, "CoreSimulator/Devices/" u) && index($0, "/Lummi.app/Lummi") {print $1; exit}'
}

export_and_analyze() {
    local scenario="$1" out="$2"
    xcrun xctrace export --input "$out.trace" \
        --xpath '/trace-toc/run[@number="1"]/data/table[@schema="time-profile"]' > "$out.xml" 2> "$out.export.log"
    "$PYTHON" "$SKILL_DIR/analyze_trace.py" "$out.xml" "$scenario" | tee "$out.txt"
    echo
}

# App start up to the first screen: launched by the profiler itself (attaching later would miss most of it).
run_launch() {
    local out="$WORK/results/launch"
    rm -rf "$out.trace" "$out.xml" "$out.txt"
    stop_app
    xcrun xctrace record --template 'Time Profiler' --device "$UDID" --time-limit 12s --output "$out.trace" \
        --launch -- "$PRODUCTS/Lummi.app" -UI_TESTING_5K_ENTRIES > "$out.xctrace.log" 2>&1
    stop_app
    if [ ! -d "$out.trace" ]; then
        echo "## launch"; echo "The profiler could not launch the app (see $out.xctrace.log)."; echo
        return 1
    fi
    export_and_analyze launch "$out"
}

run_scenario() {
    local scenario="$1" test out xcode_pid pid
    [ "$scenario" = "launch" ] && { run_launch; return $?; }
    test="$(scenario_test "$scenario")"
    out="$WORK/results/$scenario"
    rm -rf "$out.trace" "$out.xml" "$out.txt"

    TEST_RUNNER_RUN_PERFORMANCE_TESTS=1 xcodebuild test-without-building -xctestrun "$XCTESTRUN" \
        -destination "platform=iOS Simulator,id=$UDID" -parallel-testing-enabled NO \
        -only-testing:"LummiUITests/PerformanceUITests/$test" > "$out.test.log" 2>&1 &
    xcode_pid=$!

    pid=""
    for _ in $(seq 1 1800); do
        pid="$(find_app_pid)"
        [ -n "$pid" ] && break
        kill -0 "$xcode_pid" 2>/dev/null || break
        sleep 0.1
    done
    if [ -z "$pid" ]; then
        echo "## $scenario"; echo "The app never started under the UI test (see $out.test.log)."; echo
        kill "$xcode_pid" 2>/dev/null; wait "$xcode_pid" 2>/dev/null
        return 1
    fi

    # Ends when the app exits (the UI test terminates it after the first measured iteration) or at the limit.
    xcrun xctrace record --template 'Time Profiler' --device "$UDID" --attach "$pid" \
        --time-limit 60s --output "$out.trace" > "$out.xctrace.log" 2>&1

    # Only the first launch is profiled, so stop the remaining iterations of the test.
    kill "$xcode_pid" 2>/dev/null; wait "$xcode_pid" 2>/dev/null
    stop_app

    export_and_analyze "$scenario" "$out"
}

FAILED=0
for scenario in $SCENARIOS; do
    run_scenario "$scenario" || FAILED=1
done

if [ "$PBXPROJ_WAS_CLEAN" = "0" ] && ! git diff --quiet -- "$PBXPROJ"; then
    git checkout -- "$PBXPROJ" && echo "(restored $PBXPROJ, which xcodebuild had reordered)"
fi
echo "results: $WORK/results"
exit $FAILED
