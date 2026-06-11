# Development Workflow

## Feature Development

```
Requirement
  │
  ▼
Analysis — understand which layer(s) are affected; read existing code first
  │
  ▼
Design — define new models, protocol changes, use-case signatures
  │
  ▼
Implementation — Domain first, then Data, then Presentation
  │
  ▼
Build — xcodebuild; fix all errors before continuing
  │
  ▼
Test — run tests (or manual checklist if no test target)
  │
  ▼
Simulator Verification — launch app, exercise the new feature end-to-end
  │
  ▼
UI Review — light mode, dark mode, different word lengths
  │
  ▼
Documentation — update CLAUDE.md or docs/ if architecture changed
  │
  ▼
Delivery — commit with descriptive message; open PR
```

## Bug Fix Workflow

```
Bug Report
  │
  ▼
Reproduce — confirm the bug is reproducible in Simulator
  │
  ▼
Root Cause — identify the exact file and line where the defect originates
  │
  ▼
Fix — apply the minimal targeted change
  │
  ▼
Build — verify no new compile errors
  │
  ▼
Test — run existing tests; add a new test that covers the bug
  │
  ▼
Regression — exercise all flows related to the changed code
  │
  ▼
Delivery — commit; reference the bug in the commit message
```

## Refactor Workflow

```
Analysis — document the before-state; define the goal
  │
  ▼
Refactor — change structure without changing behaviour
  │
  ▼
Build — must succeed before proceeding
  │
  ▼
Test — all existing tests must still pass
  │
  ▼
Simulator Verification — visually confirm nothing regressed
  │
  ▼
Delivery — commit; note in PR that this is a pure refactor (no behaviour change)
```

## Branching Strategy

| Branch type | Name pattern | Target |
|---|---|---|
| Feature | `feature/<short-description>` | `main` |
| Bug fix | `fix/<short-description>` | `main` |
| Refactor | `refactor/<short-description>` | `main` |
| Release | `release/<version>` | `main` |

Work in short-lived branches. Merge via PR with at least one review.

## Commit Message Convention

```
<type>: <imperative summary in 50 chars or less>

Optional body explaining WHY, not WHAT.
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`.

Examples:
```
feat: add streak counter to GameView header
fix: prevent duplicate hints from Groq when previousHints is empty
refactor: extract ToastView into its own file
test: add unit tests for EvaluateGuessUseCase duplicate-letter edge cases
```

## Pull Request Checklist

Before marking a PR ready for review:

- [ ] Build succeeds (Debug configuration)
- [ ] No new warnings introduced (fix them if possible)
- [ ] Manual Simulator verification completed
- [ ] Tests pass (or new tests added for new/changed behaviour)
- [ ] `CLAUDE.md` updated if architecture changed
- [ ] PR description explains *why* the change was made, not just *what*
