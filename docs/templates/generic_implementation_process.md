# Implementation Process
<!-- Template: generic iOS Clean Architecture project. No project-specific changes required. -->

Every task — regardless of size — follows these steps in order. Do not skip steps. Do not mark a task complete until all steps are done.

---

## Step 1 — Understand the Requirement

Read the requirement carefully. Identify:
- What user-facing behaviour changes?
- Which screens or flows are affected?
- Is this a new feature, a change to existing behaviour, or a bug fix?
- Are there persistence implications? (state that must survive app restart)
- Are there recovery implications? (what happens if the user is interrupted mid-flow)

If the requirement is ambiguous, ask for clarification before writing any code.

---

## Step 2 — Locate Affected Modules

Read the relevant source files before touching anything. Trace the data flow:

```
Entry point (View/ViewModel)
  → Use case execute()
    → Repository protocol
      → Data store / API
```

Use `grep` or the IDE's Find Navigator to locate all callers of a symbol before changing its signature.

---

## Step 3 — Create an Implementation Plan

Write down (in the PR description or task notes):

1. Which types/files will be added?
2. Which types/files will be modified?
3. What is the dependency order? (Domain → Data → Presentation)
4. What are the edge cases? (empty state, corrupt data, interrupted flow, re-entry)
5. What is the UX for error and recovery paths?

For persistence features, also answer:
- What state is business state (must persist) vs transient UI state (must not persist)?
- When is saved state cleared? (completion, reset, explicit user action)
- What is the restore UX? (automatic silent restore vs confirmation dialog)

---

## Step 4 — Implement Changes

Follow the dependency order strictly.

**4a. Domain first**
- Add new model types to `Domain/Model/` if needed (one file per type)
- Add or extend repository protocols in `Domain/Repository/` if new persistence or network behaviour is required
- Add new use-case structs to `Domain/UseCase/` — one file, one `execute()` method per use case

**4b. Data second**
- Implement new repository methods in `Data/Repository/` or `Data/Local/`
- Add new remote API models if the request/response shape changes
- Ensure error propagation returns typed `Result<T, Error>` rather than throwing silently

**4c. Presentation last**
- Wire new use cases in the DI container; update any factory methods
- Add new `@Published` properties to the ViewModel for reactive state
- Use `PassthroughSubject` for one-shot events (alerts, toasts) — not `@Published`
- Build or modify View components; keep Views as thin wrappers over ViewModel state

---

## Step 5 — Build the Project

```bash
xcodebuild build \
  -project <APP_NAME>.xcodeproj \
  -scheme <APP_NAME> \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=<SIMULATOR_DEVICE>'
```

**Stop here if the build fails.** Fix every error before continuing.

---

## Step 6 — Fix Build Issues

For each error:
1. Read the full error message — note the file and line number
2. Understand the root cause (type mismatch, missing `await`, actor isolation violation, protocol conformance gap, etc.)
3. Apply the fix
4. Rebuild
5. Repeat until `** BUILD SUCCEEDED **`

Do not move to step 7 with a broken build.

---

## Step 7 — Run Tests

```bash
xcodebuild test \
  -project <APP_NAME>.xcodeproj \
  -scheme <APP_NAME> \
  -destination 'platform=iOS Simulator,name=<SIMULATOR_DEVICE>'
```

Until a test target exists, use the manual checklist from `docs/testing_rules.md`.

If a test fails, fix it before continuing. Do not skip failing tests.

---

## Step 8 — Launch in Simulator

```bash
xcrun simctl boot "<SIMULATOR_DEVICE>"
xcrun simctl install booted \
  "$(xcodebuild -showBuildSettings \
    -project <APP_NAME>.xcodeproj -scheme <APP_NAME> \
    -configuration Debug \
    -destination 'platform=iOS Simulator,name=<SIMULATOR_DEVICE>' \
    | grep ' BUILT_PRODUCTS_DIR' | awk '{print $3}')/<APP_NAME>.app"
xcrun simctl launch booted <BUNDLE_ID>
```

---

## Step 9 — Verify the Feature

Exercise the full user journey for the changed feature:

- Start from the app's root screen
- Navigate to the affected flow
- Trigger the new or changed behaviour
- Confirm the expected outcome
- Test error paths and edge cases

Also verify that **existing features still work** — regression-test the flows most likely to share code with what you changed.

---

## Step 10 — UX Review

- [ ] Does the feature handle the empty state gracefully?
- [ ] Does the feature handle the error state gracefully?
- [ ] Can the user undo or restart the action?
- [ ] Can the user recover if the app is closed mid-flow?
- [ ] Is there an obvious gap a first-time user would encounter?

Check in both light and dark mode:
- [ ] Layout correct
- [ ] Spacing and alignment consistent with existing UI
- [ ] Text is not truncated under Dynamic Type

---

## Step 11 — Persistence Review (if applicable)

If the feature involves saved state:

- [ ] Business state is persisted; transient UI state is not
- [ ] Corrupt or missing data falls back to a clean default
- [ ] Saved state is cleared at all expected points (completion, reset, uninstall)
- [ ] Multiple independent records (e.g. per-mode) do not interfere
- [ ] The restore path is tested end-to-end

---

## Step 12 — Code Quality Review

Before committing, re-read every file you changed:

- No dead code left behind
- No TODO comments
- No print/debugPrint statements
- All guard/if-let bindings use meaningful names
- New async code uses `await` and respects actor isolation
- New domain types have no Presentation or Data imports

---

## Step 13 — Update Documentation

If you:
- Added a new use case → update the architecture doc
- Added a new repository or data store → update architecture and DI docs
- Changed the navigation flow → update the navigation diagram
- Resolved a known issue → remove it from `docs/next_steps.md`
- Introduced or removed a file → update the project setup guide

---

## Step 14 — Deliver

Commit with a descriptive message following the convention in `docs/workflow.md`. Open a PR with:
- Clear title
- What changed and why
- Screenshots or screen recordings for visual changes
- Test steps for the reviewer
