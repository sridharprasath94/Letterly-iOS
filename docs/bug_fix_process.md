# Bug Fix Process

Every bug fix follows these steps. Never skip a step.

---

## Step 1 — Reproduce the Bug

Before writing any code, confirm the bug is reproducible:

1. Launch the app in **iPhone 17 Pro** simulator
2. Follow the exact steps that trigger the bug
3. Note: which game mode, which action, what the actual vs expected behaviour is
4. If the bug involves the hint system, note whether Groq returned a response at all

If you cannot reproduce it, stop and ask for more context. Never fix a bug you cannot see.

---

## Step 2 — Identify the Root Cause

Trace the data flow from the UI action to the source of the defect:

```
User action (GameView)
  → GameViewModel method
    → Use case execute()
      → Repository method
        → WordStore / GroqAPIService
```

Read the relevant source files. Use `print` statements or Xcode debugger breakpoints to observe state at runtime if needed. Remove all debug output before committing.

Identify the **exact line** where the incorrect behaviour originates.

---

## Step 3 — Implement the Fix

Apply the **minimum change** needed to correct the behaviour. Do not refactor, rename, or clean up unrelated code in the same commit.

If the fix is in:
- A **use case** — verify the fix does not break any sibling use cases
- **GameViewModel** — verify all `@Published` state and `eventPublisher` sends remain correct
- **WordStore** — verify actor isolation is maintained (all mutations are actor methods)
- **GroqAPIService** / **HintRepositoryImpl** — verify error propagation still reaches `eventPublisher.send(.hintFailed)`

---

## Step 4 — Build the Project

```bash
xcodebuild build \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Must end with `** BUILD SUCCEEDED **`. Fix any new compile errors before continuing.

---

## Step 5 — Run Tests

```bash
xcodebuild test \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Until a test target exists: manually verify using the checklist in `docs/testing_rules.md`.

**Ideally, write a test that would have caught this bug** and add it to the test target. If there is no test target yet, document the missing test case in `docs/next_steps.md`.

---

## Step 6 — Verify the Fix in Simulator

Repeat the exact reproduction steps from Step 1. Confirm:
- The bug no longer occurs
- The correct behaviour is displayed

---

## Step 7 — Regression Test Related Flows

For every bug, identify the flows that share the same code path and test them:

| Bug location | Flows to regression-test |
|---|---|
| `EvaluateGuessUseCase` | All three game modes; duplicate-letter guesses; single-letter repeated target |
| `GameViewModel.submitGuess` | Invalid word toast, duplicate word toast, win alert, lose alert |
| `GameViewModel.requestHint` | First hint, subsequent hint (shows dialog), hint at limit, Groq failure |
| `WordStore` | Random word selection across all three lengths; timestamp persistence after win |
| `GetRandomWordUseCase` | Word returned when no timestamp; word skipped when < 10 days old; `nil` when all recent |
| `HintRepositoryImpl` | Prompt includes previousHints; network error surfaces correctly |

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
fix: duplicate-letter guess incorrectly marks second letter as present

Root cause: Pass 1 of EvaluateGuessUseCase did not mark the target character
as consumed, allowing Pass 2 to match the same position again.
Fix: Replace the matched target character with a sentinel ("*") in Pass 1.
```

If the bug is a known issue from `docs/next_steps.md`, remove it from that list.
