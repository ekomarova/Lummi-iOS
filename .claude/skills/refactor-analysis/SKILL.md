---
name: refactor-analysis
description: Read-only refactoring analysis of the whole Lummi codebase. Finds duplicated code, hardcoded values, hacks and weak design, then reports a summary and a table of problems with proposed improvements. Manual use only.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Agent, Bash(git ls-files:*), Bash(git log:*), Bash(wc:*), Bash(swiftlint:*)
---

# Refactor analysis

Analyze the current code of the whole project and report what should be improved. This skill only analyzes. **Never edit, create or delete project files**, and never apply fixes unless the user asks for that in a separate message afterwards.

Optional argument: a folder or file to narrow the scope (`$ARGUMENTS`). With no argument, analyze everything.

## 1. Collect the scope
- List Swift sources with `git ls-files '*.swift'` (skip build output). Include `LummiTests/` and `LummiUITests/`, but treat test code with lighter rules (repetition in tests is often acceptable; flag it only when it is large or hides intent).
- Also read `Resources/*.xcstrings` structure when checking localization, `.swiftlint.yml` and `CLAUDE.md` for the project rules.
- Read every file fully. Do not judge code from names or grep hits alone. For large scopes (more than ~60 files), split by folder across parallel `Explore`/general agents, ask each for findings with `file:line`, then merge and de-duplicate their results yourself.

## 2. What to look for

**A. Duplication (anti-pattern, highest priority)**
- Identical or near-identical blocks, functions, view bodies, modifiers chains, and view models that differ only in a constant or type.
- The same calculation, date/calendar logic, formatting or predicate written in several places.
- Copy-pasted `switch` or `if` ladders over the same enum, parallel arrays or dictionaries that must be kept in sync.
- Similar SwiftUI subviews that could be one parameterized component in `Components/`, repeated `ViewModifier`-worthy modifier stacks, repeated `@Query` or fetch descriptors.
- Report each cluster once with all locations. Suggest a concrete extraction (function, extension, generic, `ViewModifier`, shared component) and where to put it per the project layout.

**B. Hardcoded values and hacks**
- Magic numbers and strings: sizes, paddings, durations, thresholds, hours, limits, keys (`UserDefaults`, `@AppStorage`, notification ids), identifiers, URLs.
- Colors and fonts outside `Theme` / `ThemeManager`, user-facing text outside the String Catalog (both are project rules).
- Workarounds and crutches: `DispatchQueue.main.asyncAfter` delays used to "wait for" state, `sleep`, arbitrary offsets or fudge factors, `// TODO`, `// FIXME`, `// HACK`, `// workaround`, commented-out code, debug-only values leaking into release code, test-only branches in production code, force unwraps or `try!`, `swiftlint:disable`.
- For each one explain what it seems to be compensating for, if you can tell from context, and what the proper solution is (named constant, config, enum, fixing the underlying cause).

**C. Design and quality of current solutions**
- Views that are too large or do logic that belongs in a model or helper; business logic inside views.
- Wrong or heavy property wrappers, needless state, work done in `body`, expensive computation repeated on every render, missing `@MainActor`/concurrency issues.
- SwiftData/CloudKit risks: properties without defaults, non-optional relationships, unique constraints, fetches that scale badly.
- Leaky abstractions, tight coupling, singletons used where injection would help testability, dead code and unused parameters, inconsistent naming or patterns for the same problem.
- Missing accessibility labels, missing `#Preview`, logic without unit tests (per `CLAUDE.md`).
- Only report things that are actually worth changing. Do not pad the report with style nitpicks that SwiftLint already covers; if `swiftlint` output helps, run it and mention only relevant items.

## 3. Verify before reporting
- Every finding must cite `path:line` (or a line range) that you actually read.
- For duplication, confirm the blocks really are equivalent, and note any real difference that would complicate merging.
- For "unused" claims, grep for usages across the whole project first.
- Mark uncertain findings as such rather than presenting guesses as facts.

## 4. Report format
Write the report in the user's language, in this order:

1. **Summary** (3-6 sentences): overall state of the code, the main themes, how many findings per category and severity, and the top 3 things worth doing first.
2. **Table of problems and proposals** with one row per finding, sorted by priority (High, Medium, Low), with these columns:

| # | Category | Severity | Where (`file:line`) | Problem | Proposed improvement | Effort |
|---|----------|----------|---------------------|---------|----------------------|--------|

   - Category: `Duplication`, `Hardcode/Hack`, or `Design`.
   - Severity: High (bug risk or spreads widely), Medium (clear maintainability cost), Low (nice to have).
   - Effort: S / M / L.
   - Group duplicated clusters into one row that lists every location.
3. **Suggested order of work**: a short list of 3-7 steps that groups related findings into sensible refactoring commits and notes dependencies between them.

If nothing significant is found in a category, say so explicitly instead of inventing findings. End by asking which items the user wants to fix; do not start fixing on your own.
