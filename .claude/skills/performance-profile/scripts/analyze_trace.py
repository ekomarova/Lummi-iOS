#!/usr/bin/env python3
"""Summarize an `xctrace export` of the Time Profiler `time-profile` table for one Lummi scenario.

Usage: analyze_trace.py <time-profile.xml> <scenario-name> [--top N]

Prints plain text: where the main thread spent its time, split into app code (this project's own
functions, with the time of everything they call attributed to them), framework time, UI-test
automation overhead and test-data setup. Read-only: it only reads the XML and prints.
"""
import argparse
import collections
import re
import sys
import xml.etree.ElementTree as ET

# Debug builds keep the app's code in Lummi.debug.dylib, Release builds in Lummi.
APP_BINARIES = {"Lummi", "Lummi.debug.dylib", "__preview.dylib"}
# Frames that only exist because a UI test is driving the app, not because of product code.
TEST_OVERHEAD_BINARIES = {"XCTAutomationSupport", "XCTest", "UIAccessibility", "AXRuntime", "XCTestCore"}
# Stacks that belong to filling the in-memory store with test data (`MockDataManager`), not to the product.
TEST_SETUP_MARKERS = ("MockDataManager",)
# Wrappers that carry no information of their own.
NOISE_PREFIXES = ("protocol witness for ", "specialized ", "merged ", "thunk for ", "reabstraction thunk helper ")
CLOSURE_PREFIX = re.compile(r"^(closure #\d+ in )+")
# Entry points that appear at the bottom of every stack and would otherwise swallow all the time.
WRAPPER_FUNCTIONS = {
    "static LummiApp.$main()", "static App.main()", "__debug_main_executable_dylib_entry_point", "start_sim", "main",
}


def parse(path):
    root = ET.parse(path).getroot()
    ids = {e.get("id"): e for e in root.iter() if e.get("id")}

    def resolve(element):
        if element is None:
            return None
        ref = element.get("ref")
        return ids.get(ref) if ref else element

    samples = []
    for row in root.iter("row"):
        time = resolve(row.find("sample-time"))
        thread = resolve(row.find("thread"))
        weight = resolve(row.find("weight"))
        backtrace = resolve(row.find("tagged-backtrace"))
        if time is None or backtrace is None:
            continue
        frames = []
        for frame in backtrace.iter("frame"):
            frame = resolve(frame)
            binary = resolve(frame.find("binary"))
            frames.append((frame.get("name") or "?", binary.get("name") if binary is not None else None))
        samples.append((
            int(time.text),
            thread.get("fmt") if thread is not None else "?",
            int(weight.text) if weight is not None else 1_000_000,
            frames,
        ))
    return samples


def normalize(name):
    """Strip closure/witness/specialization wrappers so one function is counted once."""
    changed = True
    while changed:
        changed = False
        for prefix in NOISE_PREFIXES:
            if name.startswith(prefix):
                name = name[len(prefix):]
                changed = True
        stripped = CLOSURE_PREFIX.sub("", name)
        if stripped != name:
            name = stripped
            changed = True
    return name


def ms(nanoseconds):
    return nanoseconds / 1e6


def is_main(thread):
    return thread.startswith("Main Thread")


def classify(frames):
    """Returns the bucket one main-thread sample belongs to."""
    names = [n for n, _ in frames]
    if any(marker in n for n in names for marker in TEST_SETUP_MARKERS):
        return "test-data setup"
    binaries = {b for _, b in frames}
    if binaries & APP_BINARIES and any(b in APP_BINARIES and n not in WRAPPER_FUNCTIONS for n, b in frames):
        return "app code"
    if binaries & TEST_OVERHEAD_BINARIES:
        return "UI-test automation"
    return "framework / runtime only"


def attributed_app_function(frames):
    """The app function nearest to the leaf: it owns the time spent in everything it calls."""
    for name, binary in frames:  # leaf first
        if binary in APP_BINARIES and name not in WRAPPER_FUNCTIONS:
            return normalize(name)
    return None


def report(samples, scenario, top):
    if not samples:
        print(f"## {scenario}\nNo samples in the trace (the app may not have been attached in time).")
        return
    samples.sort(key=lambda s: s[0])
    start = samples[0][0]
    span = ms(samples[-1][0] - start)
    main = [s for s in samples if is_main(s[1])]
    total_cpu = ms(sum(s[2] for s in samples))
    main_cpu = ms(sum(s[2] for s in main))

    print(f"## {scenario}")
    print(f"trace span {span:.0f} ms, CPU {total_cpu:.0f} ms (main thread {main_cpu:.0f} ms, "
          f"other threads {total_cpu - main_cpu:.0f} ms), {len(samples)} samples")

    # Main thread by bucket
    buckets = collections.Counter()
    for _, _, weight, frames in main:
        buckets[classify(frames)] += weight
    print("\nMain thread by kind of work:")
    for bucket, weight in buckets.most_common():
        print(f"  {ms(weight):7.0f} ms  {bucket}")

    # Timeline of the main thread, 500 ms buckets
    timeline = collections.defaultdict(lambda: [0, 0])
    for time, _, weight, frames in main:
        slot = (time - start) // 500_000_000
        timeline[slot][0] += weight
        if classify(frames) == "app code":
            timeline[slot][1] += weight
    print("\nMain thread timeline (500 ms slots): total ms / app-code ms")
    for slot in sorted(timeline):
        print(f"  {slot * 0.5:4.1f}s  {ms(timeline[slot][0]):6.0f}  {ms(timeline[slot][1]):6.0f}")

    # App functions: inclusive (any frame in the stack) and attributed (nearest to the leaf)
    product = [s for s in main if classify(s[3]) in ("app code",)]
    inclusive = collections.Counter()
    attributed = collections.Counter()
    callee_binaries = collections.defaultdict(collections.Counter)
    for _, _, weight, frames in product:
        seen = set()
        for name, binary in frames:
            if binary in APP_BINARIES and name not in WRAPPER_FUNCTIONS:
                short = normalize(name)
                if short not in seen:
                    inclusive[short] += weight
                    seen.add(short)
        owner = attributed_app_function(frames)
        if owner:
            attributed[owner] += weight
            below_owner = set()  # distinct frameworks under the owner in this sample, counted once each
            for name, binary in frames:  # leaf first, stop at the owner
                if binary in APP_BINARIES:
                    break
                if binary:
                    below_owner.add(binary)
            for binary in below_owner:
                callee_binaries[owner][binary] += weight

    print(f"\nApp functions on the main thread, inclusive (includes callees), top {top}:")
    for name, weight in inclusive.most_common(top):
        print(f"  {ms(weight):7.0f} ms  {name[:140]}")

    print(f"\nTime attributed to the app function nearest the leaf (its own work plus frameworks it calls), top {top}:")
    for name, weight in attributed.most_common(top):
        where = ", ".join(f"{b} {ms(w):.0f}" for b, w in callee_binaries[name].most_common(3))
        suffix = f"   [mostly in: {where}]" if where else ""
        print(f"  {ms(weight):7.0f} ms  {name[:110]}{suffix}")

    # Frameworks, main thread, by nearest-to-leaf non-app binary
    frameworks = collections.Counter()
    for _, _, weight, frames in main:
        for _, binary in frames:
            if binary:
                frameworks[binary] += weight
                break
    print("\nMain-thread leaf time by binary, top 8:")
    for binary, weight in frameworks.most_common(8):
        print(f"  {ms(weight):7.0f} ms  {binary}")

    # Other threads: SwiftUI/AttributeGraph metadata work usually dominates at launch
    others = collections.Counter()
    for _, thread, weight, _ in samples:
        if not is_main(thread):
            others[thread] += weight
    print("\nOther threads (CPU ms):")
    for thread, weight in others.most_common(4):
        print(f"  {ms(weight):7.0f} ms  {thread[:90]}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("xml")
    parser.add_argument("scenario")
    parser.add_argument("--top", type=int, default=12)
    args = parser.parse_args()
    try:
        samples = parse(args.xml)
    except (ET.ParseError, OSError) as error:
        print(f"## {args.scenario}\nCould not read the trace export: {error}")
        return 1
    report(samples, args.scenario, args.top)
    return 0


if __name__ == "__main__":
    sys.exit(main())
