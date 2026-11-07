---
name: audit
description: Full read-only audit of the project - implementation bugs, security, code quality, licenses, git hygiene and release readiness - ending with a prioritized report. Reports only findings with real impact and says so plainly when there is nothing serious. Manual use only.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Agent, WebSearch, WebFetch, Bash(git ls-files:*), Bash(git check-ignore:*), Bash(git log:*), Bash(git status:*), Bash(git ls-tree:*), Bash(wc:*), Bash(swiftlint:*), Bash(ls:*)
---

# Project audit

Perform a full audit of this project's code (the working directory / repository). Work methodically and cite concrete files and line numbers (`path:line`) wherever possible.

Optional argument: a folder or file to narrow the scope (`$ARGUMENTS`). With no argument, audit everything.

## Hard constraints
- **Read-only.** Do not create, modify or delete any project file. If you want to show a fix, put it in the report as a suggestion (diff or snippet), never as a real change.
- **No assumptions about requirements** that do not follow from the code, README, configs or docs. If something is unclear, list it as an open question instead of inventing an answer.
- **State limits explicitly.** If data for an item is missing (no CI access, no commit history, no production configs, no network for CVE lookups), say so as an analysis limitation. Never skip an item silently.
- **Not applicable is an answer.** If a section does not apply to the project (for example CORS in an app with no server), write "not applicable" with a one-line reason.
- **Verify before reporting.** Read the actual code around each finding. Do not report from grep hits or names alone. Mark uncertain findings as uncertain.
- **Do not invent findings.** An empty section is a valid and good result. If nothing serious is found, write "none found" and stop; do not fill the report with minor points to make it look thorough. A short report on a healthy project is correct.
- **Every finding needs a realistic scenario.** Say what triggers it, who or what is affected (the user, their data, their iCloud, the release) and how likely it is. If you cannot describe a realistic trigger, it is not a finding: drop it, or list it as an open question.
- **Calibrate severity by real impact**, not by how the code looks. A crash path the user can reach, data loss, a leaked secret or a store rejection is serious. Code that merely looks unusual, or a risk that needs an unlikely combination of events, is not.
- **Skip the cosmetic.** Naming, ordering, wording, style that `swiftlint` already covers and small duplication with no sign of diverging are not audit findings. If you want to mention them, do it in one line under "Skipped as cosmetic". Rules from `CLAUDE.md` count only when breaking them has a real effect or the rule is explicit and the violation is clear.
- **Respect deliberate decisions.** If a comment, the README or the code's history explains why something is done a certain way, treat it as intentional. Report it only if the stated reason no longer holds, or you can show it is wrong.
- **Performance claims need numbers.** Without a measurement, a performance concern is a hypothesis: say so, and say how to measure it (the project has manual performance tests and the 5,000-entry launch argument `-UI_TESTING_5K_ENTRIES`; see also the `performance-profile` skill). Do not call something slow because it looks slow.
- For a large codebase (more than ~60 files), split the reading by folder across parallel agents, require `path:line` evidence from each, then merge and de-duplicate their findings yourself.

## Audit tasks

### 1. Gross implementation errors
Logic errors, potential crashes (force unwraps, `try!`, `fatalError`, out-of-range indexing, unchecked casts), race conditions and actor/main-thread violations, retain cycles and resource leaks (memory, file handles, connections, observers, timers, tasks), improper error handling (swallowed errors, `try?` hiding failures, silent fails, overly broad catches), off-by-one errors, date/calendar/time zone mistakes, incorrect async/concurrency use, SwiftData/CloudKit misuse (missing defaults, unsafe migrations, data-loss paths such as clear-data and rollback flows).

### 2. Security
- Injection: SQL, command, template, XSS, path traversal, unsafe URL or deep-link handling, predicate/format-string injection.
- Secrets in code or in tracked files: API keys, passwords, tokens, private keys, signing identities, team IDs.
- Unsafe deserialization.
- Weak cryptography, or none where it is needed (sensitive data in `UserDefaults` instead of Keychain, missing data protection, insecure random).
- Authentication and authorization problems, broken access control.
- Vulnerable dependencies: read `Package.resolved`, `Podfile.lock`, `Cartfile`, `package.json`, `requirements.txt`, `pom.xml` and similar, and check versions against known CVEs when you can (WebSearch). If you cannot, state it as a limitation.
- Insecure configuration: App Transport Security exceptions, entitlements broader than needed, CORS/cookies/security headers where relevant, `Info.plist` and privacy manifest (`PrivacyInfo.xcprivacy`) correctness, background modes, URL schemes.
- Logging of sensitive data (`print`, `NSLog`, `os_log` with user content).
Give each security finding a severity: high / medium / low.

### 3. Implementation quality and best practices
Report only what has a real cost: something that hides bugs, makes a likely change risky, is visibly wrong for the user, or breaks an explicit project rule with an effect. Leave out taste and minor tidiness. Consider:
SOLID / DRY / KISS where appropriate; project structure and separation of concerns; naming of variables, functions and modules; existence and quality of tests (unit and integration) and coverage of critical paths; edge case handling; language and framework idioms (no "Swift written like another language", correct SwiftUI/SwiftData patterns); code duplication; accessibility and localization completeness where the project sets rules for them (see `CLAUDE.md`, `.swiftlint.yml`). Compare the code against the project's own documented rules and report violations.

### 4. Licenses
- Presence and correctness of the `LICENSE` file at the root, and whether it matches what the README, package manifests and file headers declare.
- License headers in source files, if used, against the declared license.
- Dependency licenses against the project license (for example a permissive project pulling a copyleft dependency). Flag dependencies with an unclear or missing license.
- Also check bundled third-party assets (fonts, icons, images, sounds) for license/attribution.

### 5. Files that should not be committed
Compare files actually tracked by git (`git ls-files`) with `.gitignore` (`git check-ignore`) and report mismatches: environment/secret files (`.env`, `*.xcconfig` with local values), build artifacts, IDE and user files (`xcuserdata`, `.DS_Store`), logs, database dumps, temporary files, private keys and certificates (`*.p12`, `*.mobileprovision`, `*.pem`). Also note ignore rules that are missing for files that are present on disk but untracked. Check history only if `git log` is available and cheap (for example, was a secret file ever tracked); otherwise state the limitation.

### 6. Release readiness
Rate readiness as **not ready / ready with reservations / ready**, based on: critical bugs and vulnerabilities; tests and CI/CD (look for workflows, `codecov.yml`, fastlane); error handling and production logging/crash reporting; configuration for different environments (debug/release, dev/staging/prod, signing setup); documentation (README, deployment or release instructions, CHANGELOG); App Store requirements visible in the repo (privacy manifest, permission usage strings, localization, versioning). Justify the rating with evidence.

## Report format
Write the report in the user's language. Be concise and to the point, no filler. Use exactly this structure:

1. **Summary** (3-5 sentences): overall impression and the release-readiness verdict. Say plainly if the project is in good shape and there is little to fix.
2. **Critical issues**: numbered list; for each one give file and line, description, the scenario that triggers it and who it affects, risk, recommendation. Write "none found" if there are none.
3. **Security issues**: separate list with severity high / medium / low.
4. **Code quality and practices**: grouped by topic, with examples.
5. **Licenses**: mismatches found (or "none found" / "not applicable" with reason).
6. **Git hygiene**: extra tracked files, missing ignore rules (or "none found").
7. **Release readiness**: rating with justification.
8. **Skipped as cosmetic**: one line per item with `file:line` and why it is not worth the time, so the user can overrule you. Write "none" if there were none.
9. **Prioritization table** (only items that passed the checks above; leave it short or empty rather than pad it):

| Priority | # | Item (with `file:line`) | Effort (S/M/L) |
|----------|---|-------------------------|----------------|

   Priorities: **Critical** (blocks release or creates risk of bugs, vulnerabilities, data leaks), **Important** (fix in the next iterations), **Desirable** (quality improvements, refactoring, tech debt).

10. **Overall assessment**: architecture, quality and maturity of the implementation, plus a list of analysis limitations and open questions.

Do not start fixing anything. End by asking which items the user wants to address.
