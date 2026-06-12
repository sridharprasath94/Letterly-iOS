# Implementation Process

Every future task — regardless of size — follows these steps in order. Do not skip steps. Do not mark a task complete until all steps are done.

---

## Step 1 — Understand the Requirement

Read the requirement carefully. Identify:
- What user-facing behaviour changes?
- Which game mode(s) are affected?
- Is this a new feature, a change to existing behaviour, or a bug fix?

If the requirement is ambiguous, ask for clarification before writing any code.

---

## Step 2 — Locate Affected Modules

Read the relevant source files before touching anything. Trace the data flow:

```
GameMode → Use Case → Repository → Data Store / API
                    ↓
              GameViewModel → GameView → Component
```

Use `grep` or Xcode's Find Navigator to locate all callers of a symbol before renaming or changing its signature.

---

## Step 3 — Create an Implementation Plan

Write down (in the PR description or as a comment to the task):

1. Which types/files will be added?
2. Which types/files will be modified?
3. What is the dependency order? (Domain before Data before Presentation)
4. Are there any edge cases that need special handling?

---

## Step 4 — Implement Changes

Follow the dependency order:

**4a. Domain first**
- Add new model types to `Domain/Model/` if needed
- Add or extend repository protocols in `Domain/Repository/` if new persistence/network behaviour is required
- Add new use-case structs to `Domain/UseCase/` — one file per use case

**4b. Data second**
- Implement new repository methods in `Data/Repository/`
- Add new persistence logic to `WordStore` if needed (as actor methods)
- Add new API models to `Data/Remote/HintModels.swift` if the Groq prompt shape changes

**4c. Presentation last**
- Wire new use cases in `AppContainer.swift` (`makeGameViewModel` factory if needed)
- Add new `@Published` properties or `GameEvent` cases to `GameViewModel` if needed
- Build new View components in `Presentation/Game/Components/` or modify existing ones

---

## Step 5 — Build the Project

```bash
xcodebuild build \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

**Stop here if the build fails.** Fix every error before continuing.

---

## Step 6 — Fix Build Issues

For each error:
1. Read the full error message — include the file and line number
2. Understand the root cause (type mismatch, missing `await`, actor isolation violation, etc.)
3. Apply the fix
4. Rebuild
5. Repeat until `** BUILD SUCCEEDED **`

Do not move to step 7 with a broken build.

---

## Step 7 — Run Tests

```bash
xcodebuild test \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Until a test target exists, use the manual checklist from `docs/testing_rules.md`.

If a test fails, fix it before continuing. Do not skip failing tests.

---

## Step 8 — Launch in Simulator

```bash
xcrun simctl boot "iPhone 17 Pro"
xcrun simctl launch booted com.flash.Letterly
```

Or run directly from Xcode (⌘R) targeting the simulator.

---

## Step 9 — Verify the Feature

Exercise the full user journey for the changed feature:

- Start from the `StartView`
- Navigate to the affected game mode
- Trigger the new or changed behaviour
- Confirm the expected outcome

Also verify that **existing features still work**:
- The other two game modes
- Win / lose flows
- Hint system
- Back navigation with "Leave game?" alert

---

## Step 10 — UI Review

Check in both light and dark mode:

- [ ] Layout correct
- [ ] Spacing and alignment consistent with existing UI
- [ ] Text is not truncated
- [ ] Colours match the established palette (Wordle green #6AAA64, yellow #C9B458, grey #787C7E)
- [ ] Board tiles render for all three word lengths (5, 6, 7 columns)
- [ ] Keyboard fits without overflow on iPhone 17 Pro screen

---

## Step 11 — Code Quality Review

Before committing, re-read every file you changed:

- No dead code left behind
- No TODO comments
- No print/debugPrint statements
- All `guard`/`if let` bindings use meaningful names
- New async code uses `await` and respects actor isolation
- New domain types are free of Presentation/Data imports

---

## Step 12 — Update Documentation

If you:
- Added a new use case → update the use-case table in `docs/architecture.md`
- Added a new dependency → update `AppContainer` section and `CLAUDE.md`
- Changed the navigation flow → update the navigation diagram in `docs/architecture.md`
- Introduced a new file or removed an old one → update `docs/project_setup.md`
- Resolved a known issue → remove it from `docs/next_steps.md`

---

## Step 13 — Deliver

Commit with a descriptive message following the convention in `docs/workflow.md`. Open a PR with:
- Clear title
- What changed and why
- Screenshots or screen recordings for visual changes
- Test steps for the reviewer
