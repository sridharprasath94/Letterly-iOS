# Development Workflow
<!-- Template: generic iOS project. No project-specific changes required. -->

## Feature Development

```
Requirement
  │
  ▼
Analysis — understand which layer(s) are affected; read existing code first
  │
  ▼
Design — define new models, protocol changes, use-case signatures;
         consider UX, recovery flows, edge cases, persistence implications
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
Simulator Verification — launch app, exercise the feature end-to-end
  │
  ▼
UX Review — does the feature handle errors, empty states, and recovery?
  │
  ▼
Persistence Review — if state is saved, verify restore and clear paths
  │
  ▼
Documentation — update architecture docs if structure changed
  │
  ▼
Delivery — commit with descriptive message; open PR
```

## Bug Fix Workflow

```
Bug Report
  │
  ▼
Reproduce — confirm the bug in Simulator before writing any code
  │
  ▼
Root Cause — identify the exact file and line where the defect originates
  │
  ▼
Fix — apply the minimum targeted change
  │
  ▼
Build — verify no new compile errors
  │
  ▼
Test — run existing tests; add a new test that would have caught the bug
  │
  ▼
Regression — exercise all flows that share the changed code path
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
Delivery — note in PR that this is a pure refactor (no behaviour change)
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
feat: persist in-progress game state across app restarts
fix: prevent empty state when all items have been recently viewed
refactor: extract confirmation alert into reusable helper
test: add unit tests for evaluation logic edge cases
```

## Pull Request Checklist

Before marking a PR ready for review:

- [ ] Build succeeds (Debug configuration)
- [ ] No new warnings introduced
- [ ] Manual Simulator verification completed
- [ ] Tests pass (or new tests added for new/changed behaviour)
- [ ] Architecture docs updated if structure changed
- [ ] PR description explains *why* the change was made, not just *what*
- [ ] Screenshots or recordings attached for visual changes

## Product Review

Before marking a feature complete, ask:

- Can the user undo or reverse this action?
- Can the user start over without losing other data?
- Can the user recover if the app is closed mid-flow?
- Is there an obvious UX gap a first-time user would hit?

If the answer to any of these is "no" and the feature warrants it, address it before shipping.
