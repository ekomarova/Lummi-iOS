---
name: refactor-analysis
description: Read-only refactoring analysis of the whole Lummi codebase. Finds duplicated code, hardcoded values, hacks and weak design, rates each finding by what the user would notice and by performance impact, skips purely cosmetic ones, then reports a summary and a table of problems with proposed improvements. Manual use only.
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

## 3. Rate the value of each finding
Finding a problem is not a reason to fix it. Before a candidate goes into the main table, answer these questions about it, from the code you read:

- **User impact.** Would the user of the app notice the fix?
  - `Visible`: it changes what they see, feel or get (layout, behavior, speed, correctness, accessibility, text in their language).
  - `Indirect`: they would not notice the fix, but it removes a real risk for them (a crash, lost or duplicated data, iCloud sync, a screen that can disagree with another one).
  - `None`: only the code changes.
- **Performance impact.** Does the code do work that matters, and how often?
  - `None`, `Unclear`, `Likely` or `Measured`. Judge by how often it runs (once per launch, per tap, per render, per scroll frame), how much data it touches (the 5,000-entry scenario is the project's reference load) and whether it runs on the main thread.
  - A performance claim without a number is a hypothesis. Say so, and say how to measure it: the existing manual tests (`LummiTests/TrendsPerformanceTests`, `LummiTests/JoyEntryStorePerformanceTests`, `LummiUITests/PerformanceUITests`, launch argument `-UI_TESTING_5K_ENTRIES`) or the `performance-profile` skill. Never propose a performance change for code that runs rarely or on small data without an estimate that it matters.
- **Risk and upkeep.** Is there a real chance of a bug, or have copies of the code already diverged or spread to three or more places? Or is it just two similar short blocks that are easy to read as they are?
- **Cost.** Compare the effort and the chance of breaking something with the value above. If the cost is higher than the value, say "not worth it".

A finding is **actionable** only if at least one of these is true: the user would notice the fix; it has a real, plausible performance cost; it is a bug, data-loss or sync risk; it breaks a rule from `CLAUDE.md`; or it removes duplication that already diverged or spread to three or more places. A comment that is misleading (it describes a design that no longer exists) is actionable too, because it is cheap to fix and wrong text costs the next reader time.

Everything else is **cosmetic**: renaming, reordering, moving a file, a constant used once, two identical short blocks with no sign of diverging, comment wording that is merely awkward. Do not put cosmetic findings in the main table and do not spend time proposing designs for them. Mention each one in a single line in the "Skipped as cosmetic" list, so the user can overrule you.

If a comment explains why the code is written the way it is, treat that as a deliberate decision. Report it only if the stated reason no longer holds, or you can show that it is wrong.

## 4. Verify before reporting
- Every finding must cite `path:line` (or a line range) that you actually read.
- For duplication, confirm the blocks really are equivalent, and note any real difference that would complicate merging.
- For "unused" claims, grep for usages across the whole project first.
- Mark uncertain findings as such rather than presenting guesses as facts. This applies most to performance and to CloudKit behavior, which cannot be tested without a signed iCloud entitlement.

## 5. Report format
Write the report in the user's language, in this order:

1. **Summary** (3-6 sentences): overall state of the code, the main themes, how many findings are actionable per category and severity, how many were skipped as cosmetic, and the top 3 things worth doing first.
2. **Table of problems and proposals** with one row per actionable finding, sorted by priority (High, Medium, Low), with these columns:

| # | Category | Severity | Where (`file:line`) | Problem | User impact | Performance | Proposed improvement | Effort |
|---|----------|----------|---------------------|---------|-------------|-------------|----------------------|--------|

   - Category: `Duplication`, `Hardcode/Hack`, or `Design`.
   - Severity follows the value from section 3: High (bug, data or sync risk, or visibly affects the user, or spreads widely), Medium (a real cost in speed or maintainability), Low (small but real, for example a misleading comment).
   - User impact: `Visible`, `Indirect` or `None`, with a few words on what the user would notice.
   - Performance: `None`, `Unclear`, `Likely` or `Measured`. For `Unclear` and `Likely` add how to measure it. For `Measured` give the number.
   - Effort: S / M / L.
   - Group duplicated clusters into one row that lists every location.
3. **Skipped as cosmetic**: one line per skipped item with `file:line` and the reason it is not worth the time. Say "none" if there were none.
4. **Suggested order of work**: a short list of 3-7 steps that groups related findings into sensible refactoring commits and notes dependencies between them. Put anything that needs a measurement first, because the measurement may remove the item.

If nothing significant is found in a category, say so explicitly instead of inventing findings. An honest "nothing here is worth the time" is a good result. End by asking which items the user wants to fix; do not start fixing on your own.
