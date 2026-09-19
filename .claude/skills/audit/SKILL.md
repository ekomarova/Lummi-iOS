---
name: audit
description: Full read-only audit of the project - implementation bugs, security, code quality, licenses, git hygiene and release readiness - ending with a prioritized report. Manual use only.
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

1. **Summary** (3-5 sentences): overall impression and the release-readiness verdict.
2. **Critical issues**: numbered list; for each one give file and line, description, risk, recommendation.
3. **Security issues**: separate list with severity high / medium / low.
4. **Code quality and practices**: grouped by topic, with examples.
5. **Licenses**: mismatches found (or "none found" / "not applicable" with reason).
6. **Git hygiene**: extra tracked files, missing ignore rules (or "none found").
7. **Release readiness**: rating with justification.
8. **Prioritization table**:

| Priority | # | Item (with `file:line`) | Effort (S/M/L) |
|----------|---|-------------------------|----------------|

   Priorities: **Critical** (blocks release or creates risk of bugs, vulnerabilities, data leaks), **Important** (fix in the next iterations), **Desirable** (quality improvements, refactoring, tech debt).
9. **Overall assessment**: architecture, quality and maturity of the implementation, plus a list of analysis limitations and open questions.

Do not start fixing anything. End by asking which items the user wants to address.
