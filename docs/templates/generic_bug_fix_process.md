# Bug Fix Process
<!-- Template: generic iOS Clean Architecture project. No project-specific changes required. -->

Every bug fix follows these steps. Never skip a step.

---

## Step 1 — Reproduce the Bug

Before writing any code, confirm the bug is reproducible:

1. Launch the app in Simulator (or on device if it's device-specific)
2. Follow the exact steps that trigger the bug
3. Note: which screen, which action, what the actual vs expected behaviour is
4. Note whether the bug is deterministic or intermittent

If you cannot reproduce it, stop and ask for more context. Never fix a bug you cannot see.

---

## Step 2 — Identify the Root Cause

Trace the data flow from the UI action to the source of the defect. In a Clean Architecture project the trace follows:

```
User action (View)
  → ViewModel method
    → Use case execute()
      → Repository method
        → Local store / Remote API
```

Read the relevant source files. Use `print` statements or Xcode debugger breakpoints to observe state at runtime if needed. Remove all debug output before committing.

Identify the **exact line** where the incorrect behaviour originates.

---

## Step 3 — Implement the Fix

Apply the **minimum change** needed to correct the behaviour. Do not refactor, rename, or clean up unrelated code in the same commit.

Consider which layer the bug lives in:

- **Use case** — verify the fix does not break sibling use cases with shared inputs
- **ViewModel** — verify all `@Published` state and event publisher sends remain correct
- **Repository** — verify actor isolation is maintained; verify error propagation is preserved
- **View** — verify the fix applies to all relevant states (empty, loading, error, success)

---

## Step 4 — Build the Project

```bash
xcodebuild build \
  -project <APP_NAME>.xcodeproj \
  -scheme <APP_NAME> \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=<SIMULATOR_DEVICE>'
```

Must end with `** BUILD SUCCEEDED **`. Fix any new compile errors before continuing.

---

## Step 5 — Run Tests

```bash
xcodebuild test \
  -project <APP_NAME>.xcodeproj \
  -scheme <APP_NAME> \
  -destination 'platform=iOS Simulator,name=<SIMULATOR_DEVICE>'
```

Until a test target exists: manually verify using the checklist in `docs/testing_rules.md`.

**Write a test that would have caught this bug** and add it to the test target. If there is no test target yet, document the missing test case in `docs/next_steps.md`.

---

## Step 6 — Verify the Fix in Simulator

Repeat the exact reproduction steps from Step 1. Confirm:
- The bug no longer occurs
- The correct behaviour is displayed
- Edge cases around the fix behave correctly

---

## Step 7 — Regression Test Related Flows

Identify all flows that share the changed code path and test them. For a use-case fix, test all callers. For a repository fix, test all use cases that use that repository. For a View fix, test all screen states.

---

## Step 8 — Document the Fix

Commit message format:

```
fix: <one-line description of the bug corrected>

Root cause: <one sentence>
Fix: <one sentence>
```

Example:
```
fix: restore flow skips saved state when all keys are absent

Root cause: load() returned a stale cached value instead of reading
            UserDefaults fresh on each call.
Fix: Remove the in-memory cache; always decode from UserDefaults.
```

If the bug is a known issue in `docs/next_steps.md`, remove it from that list.
