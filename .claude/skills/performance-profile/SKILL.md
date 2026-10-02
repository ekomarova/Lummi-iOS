---
name: performance-profile
description: Read-only performance profiling of Lummi's main flows (launch and main screen, calendar, day switching, Insights, All Joys, Trends Month/Year). Records Time Profiler traces on a simulator, then reports where the time goes with fix options rated by implementation complexity. Manual use only.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash(bash .claude/skills/performance-profile/scripts/profile.sh:*), Bash(python3 .claude/skills/performance-profile/scripts/analyze_trace.py:*), Bash(git status:*), Bash(git diff:*), Bash(ls:*)
---

# Performance profile

Profile the app's main flows with Instruments' Time Profiler, find what costs time in **this project's code**, and report fix options. This skill only measures and analyzes. **Never edit, create or delete project files**, never commit, and do not apply fixes unless the user asks for that in a separate message afterwards.

Optional argument: scenario names to profile (`$ARGUMENTS`), for example `trends-month insights`. With no argument, profile all of them.

| Scenario | What is measured | UI test driving it (`LummiUITests/PerformanceUITests.swift`) |
|---|---|---|
| `launch` | app start up to the main screen with today's entries | none: the app is launched directly under the profiler, so the whole start is recorded |
| `calendar` | open the calendar and page back through a year | `test_Perf_OpenCalendarAndScrollBack` |
| `day-switch` | pick past days from the open calendar | `test_Perf_SwitchingSelectedDay` |
| `insights` | open the Insights tab | `test_Perf_OpenInsights` |
| `all-joys` | open "All Joys" from Insights (Month tab) | `test_Perf_OpenAllJoys` |
| `all-joys-all-time` | switch "All Joys" to the All Time tab | `test_Perf_OpenAllJoysAllTime` |
| `all-joys-year` | open a year's page from All Joys > All Time | `test_Perf_OpenAllJoysYear` |
| `trends-month` | open Trends (Month tab) from Insights | `test_Perf_OpenTrendsMonth` |
| `trends-year` | open a year's page from Trends > All Time | `test_Perf_OpenTrendsYear` |

All run on the 5,000-entry in-memory store (`-UI_TESTING_5K_ENTRIES`), never on real user data.

## Hard constraints
- **Read-only for the project.** Everything the run creates (build, traces, exports, reports) goes to a scratch folder **outside the repository**: use the session scratchpad directory if the system prompt gives one, otherwise a new folder under the system temp directory. Never write inside the repo and never pass a folder inside it.
- **Do not run other commands that build or test.** Use only `scripts/profile.sh` and `scripts/analyze_trace.py`. The script restores `Lummi.xcodeproj/project.pbxproj` if `xcodebuild` reordered it; check `git status` at the end and tell the user if anything in the repository changed.
- **Say what the numbers are.** This is a Debug build on a simulator, one launch per scenario, so use it for proportions and relative cost, not absolute timings. Never present an estimate as a measurement.
- **Verify before reporting.** Read the source of every function you put in the report (`path:line`) before naming a cause. Mark uncertain causes as uncertain.
- **State limits.** If a scenario failed to start, was too short to sample, or the build failed, say so and show the log path. Do not skip a scenario silently.

## 1. Run
```
bash .claude/skills/performance-profile/scripts/profile.sh <scratch-folder> [scenario ...]
```
Prerequisite: Python with the `defusedxml` package (`python3 -m pip install defusedxml`, a virtual environment is fine: then pass `PYTHON=<venv>/bin/python`). The script checks this first and stops with the command to run if it is missing.

The first call builds the app and takes a few minutes; each scenario then takes about a minute. `SIM_UDID=<udid>` picks a simulator, `REBUILD=1` forces a rebuild (needed when the sources changed since the last run into the same folder). For a long run use a generous command timeout (up to 10 minutes) or run scenarios one by one.

The script prints one block per scenario (from `scripts/analyze_trace.py`):
- **Main thread by kind of work:** `app code` (this project's functions and the frameworks they call), `framework / runtime only`, `UI-test automation` (XCTest and accessibility queries, not product cost), `test-data setup` (`MockDataManager` filling the store, not product cost).
- **Timeline** in 500 ms slots, to see when the interesting work happens.
- **App functions, inclusive** and **time attributed to the nearest app function** (with the framework it mostly spends the time in, for example SwiftData or Charts).
- **Other threads:** at launch SwiftUI/AttributeGraph type-metadata work on background threads is large and is not caused by app code; do not report it as a finding.

The first launch of each scenario is profiled, so every trace also contains app start and the store being filled. Judge only the part after that (the timeline shows it).

## 2. Analyze
For each scenario:
1. Take the app functions with the largest attributed time in the interesting part of the timeline.
2. Read those functions' source and what they query or compute (`@Query`, fetches, sorting, filtering, work in `body`, repeated calculations, charts).
3. Decide the cause: work done too often, too much data loaded, expensive work on the main thread, or framework cost that app code cannot reduce. Explain it in a sentence with `path:line`.
4. Note what is **not** a problem: a scenario whose app code is a small share of the time is fine, say so.

Ignore items under ~5 ms of attributed time unless they repeat across many rows or screens.

## 3. Report
Start with one line naming the audience as understood ("Written for: the app's developer"), then:

**Summary:** 3-6 lines: which flows are cheap, which are not, and the biggest finding.

**Per-scenario table:** scenario | main-thread app-code ms | top cost (function, `path:line`) | verdict (fine / worth fixing / framework-bound).

**Findings and fix options.** For every finding that is worth fixing:
- the problem, its measured cost, and the scenario(s) it shows up in
- two or three fix options, each with:
  - **Complexity:** low (one file, a few lines, no behaviour change), medium (several files or a new helper/descriptor plus tests), high (changes data flow, models or architecture)
  - **Expected effect:** the share of the measured cost it removes, marked as an estimate
  - **Risk:** what could break, and which tests cover it (name the existing tests, and the new ones needed per `CLAUDE.md`)
- a recommended option and why

Respect the project rules in `CLAUDE.md` when proposing code (no force unwraps, String Catalog, Theme, SwiftData/CloudKit constraints); a proposal that would break them is not a valid option.

**Limits:** Debug build, simulator, single run, the part of the trace you ignored (launch and data setup), any scenario that failed.

Keep it proportionate: no padding with micro-optimizations that do not show up in the profile.
