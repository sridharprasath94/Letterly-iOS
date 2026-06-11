# Senior iOS Engineering Workflow

You are acting as a senior iOS engineer with deep expertise in Clean Architecture, SwiftUI, UIKit, and production-grade software delivery. When this skill is invoked, run through every phase below in order. State each phase heading aloud as you enter it so the user can follow along. Do not skip phases. Do not mark work complete until the Completion Criteria phase passes.

This skill applies to any iOS project — SwiftUI, UIKit, or mixed — regardless of architecture style. Adapt the specific layer names to whatever the project uses.

---

## Phase 1 — Requirement Analysis

Read the requirement carefully. Before touching any code, answer these questions explicitly:

**Problem clarity**
- What is the user-facing behaviour that must change?
- Is this a new feature, a behaviour change, or a bug fix?
- Is the requirement unambiguous? If not, stop and ask for clarification before proceeding.

**Scope**
- Which screens or flows are affected?
- Which architectural layers are touched? (e.g. domain models, persistence, networking, view, view model)
- Are there related flows that share the same code path and could regress?

**Risk**
- Is there existing behaviour that this change could silently break?
- Does this change touch shared state, concurrency boundaries, or persistence?
- Is there any data migration required?

**UX implications**
- What does the user see on first use? On error? On re-entry after interruption?
- What happens if the user is mid-flow when the app is force-quit?
- Is there a confirmation, undo, or recovery path that a reasonable user would expect?

---

## Phase 2 — Feature Planning

Write the implementation plan before writing any code. The plan must answer:

**Architecture**
- Which new types will be added, and in which layer?
- Which existing types will be modified, and how does that affect their callers?
- Does anything need to move between layers to preserve the dependency rule? (Presentation must not reach into Data; domain must not import UIKit/SwiftUI except where unavoidable)

**Dependency order**
List files in the order they must be created or modified, respecting the dependency direction: domain models → repository protocols → use cases → data implementations → DI wiring → view model → view.

**Persistence impact**
If this feature reads or writes any persistent store:
- What is the storage mechanism? (UserDefaults, CoreData, file, keychain)
- What is the key or entity name?
- Does this interact with any existing stored data?
- Is there a migration path for users who already have data on disk?

**Migration impact**
- Will existing users encounter a different experience after this change ships?
- If data shape changes (new fields, renamed keys, removed values), how will old data be handled on first launch?
- Graceful degradation is required: a failed decode must fall back to a clean default, never crash.

---

## Phase 3 — Product Review

Stop before writing a single line of implementation code. Ask every question below. If any answer is "no" or "not handled," design that handling before continuing.

**Reversibility**
- Can the user cancel this action before it takes effect?
- Can the user undo this action after it takes effect?

**Recovery**
- Can the user start this flow over from the beginning without losing unrelated data?
- If the app is force-quit mid-flow, what state does the user return to?
- If the persistent store contains corrupt or missing data, does the app recover gracefully to a usable state?

**Re-entry UX**
- If the user leaves this flow and comes back later (same session or after restart), what do they see?
- If in-progress state is saved, is the user offered a choice to resume or start fresh — or is silent restoration the clearly correct behaviour?
- Is the resume/new-choice dialog shown *before* navigation, not after? (Navigating first and then asking is a UX anti-pattern for recovery flows.)

**Edge cases**
- Empty state: what does the user see before any data exists?
- Maximum state: does anything break at realistic upper bounds?
- Concurrent access: if the user navigates rapidly or triggers the same action twice, is the result deterministic?

Document the answers. Any unresolved "no" is a gap that must be addressed in the plan, not left for later.

---

## Phase 4 — Persistence Review

Run this phase for every feature that reads from or writes to any persistent store. If the feature is stateless, skip to Phase 5.

Define each of the following explicitly before writing any persistence code:

**What is persisted?**
List every piece of state that will be written to disk. Business state only — game progress, user preferences, scores, timestamps. Never persist transient UI state: loading flags, animation state, error messages, currently-displayed dialog identifiers.

**What is not persisted?**
List state that is intentionally kept in memory only. Explain why (e.g. "loading indicator — always starts false on launch").

**When is it saved?**
Identify the exact trigger points: after a user action completes, after a network response is processed, on a timer, on app-will-resign-active. Be precise — "whenever state changes" is not an answer.

**When is it restored?**
Identify the exact restoration point: on app launch, when a view appears, when the user taps a specific button. State the expected user experience at each point.

**When is it cleared?**
List every condition that removes the saved data: task completion, explicit user reset, sign-out, uninstall, expiry. Ensure clear happens *before* the new state begins, not after — otherwise the old state can be accidentally restored.

**How does the user start fresh?**
If the user wants to discard saved state and begin again, what is the explicit path? Is there a "Start New" option in a dialog? Is there a reset button in settings? Design this before building the feature; retrofitting it is significantly harder.

**Codability notes (Swift)**
- `Character` is not `Codable`; encode as `String` and convert at the boundary.
- Conform to `Codable` via `extension`, not in the struct body, to preserve synthesised initialisers.
- Use `String` raw values for `enum` cases stored to disk — integer raw values break if cases are reordered.
- Use per-record keys (e.g. one key per user, one key per mode) rather than a single monolithic key.
- Always decode with `try?` and fall back to a default; never let a malformed payload crash the app.

---

## Phase 5 — Implementation

Follow the dependency order established in Phase 2. Implement in this sequence:

1. **Domain models** — new value types, enums, protocols. No UIKit, no SwiftUI, no Data layer imports.
2. **Repository protocols** — if new persistence or network behaviour is required, define the protocol in the domain layer first.
3. **Use cases** — one file per use case, one `execute(...)` method per use case. Pure structs wherever possible.
4. **Data implementations** — implement repository protocols; add persistence or networking code here.
5. **DI wiring** — register new types in the dependency injection container; update any factory methods.
6. **View model** — add `@Published` properties for reactive state; use a `PassthroughSubject` (or equivalent) for one-shot events (alerts, toasts, sheet presentation). Never put one-shot events in `@Published`.
7. **View** — keep thin. Views observe state; they do not contain logic. Extract sub-views into `private struct` helpers; decompose `body` into `private var` computed properties.

**Do not advance to the next layer until the current layer compiles cleanly.**

---

## Phase 6 — Build

Run the project build. The exact command depends on the project; use whatever command the project's `CLAUDE.md` or build docs specify.

**On build failure:**
1. Read the full error message — note the file, line number, and error type.
2. Identify the root cause: type mismatch, missing `await`, actor isolation violation, missing protocol conformance, missing import.
3. Apply the minimum fix.
4. Rebuild.
5. Repeat until `BUILD SUCCEEDED` with zero errors.

Do not proceed to Phase 7 with a broken build under any circumstances.

**Common Swift 6 build failures to check for:**
- Missing `await` on async calls
- `@MainActor`-isolated property accessed from a non-isolated context
- `Sendable` conformance missing on types crossing actor boundaries
- `Character` not conforming to `Codable` (encode as `String`)
- Redundant protocol conformance when a raw-value enum already synthesises it

---

## Phase 7 — Test

Run the test suite if one exists. If no test target exists, note it and follow the manual verification checklist instead.

**For new use cases:** write at least one test per meaningful branch — happy path, empty input, boundary condition, error/failure path.

**For persistence changes:** verify the write → terminate → read round-trip. Do not trust in-process round-trips; they bypass the serialise/deserialise cycle that actually fails on corrupt data.

**For UI changes:** verify in Simulator — the happy path and at least one error or edge-case path.

If a test fails, fix the underlying code. Do not comment out the test or mark it as expected failure unless there is a documented reason.

---

## Phase 8 — Simulator Verification

Install and launch the app on the target simulator. Exercise the full user journey for every changed flow:

1. Start from the app's root screen.
2. Navigate to the affected feature.
3. Trigger the new behaviour.
4. Confirm the expected outcome.
5. Trigger at least one error path and confirm graceful handling.
6. Navigate away and return — confirm re-entry state is correct.

**If the feature involves persistence, also verify:**
- Force-quit the app during the flow. Relaunch. Confirm the restoration state is correct.
- Complete the flow. Relaunch. Confirm saved state was cleared on completion.
- Corrupt or delete the UserDefaults key (or equivalent). Relaunch. Confirm the app starts with a clean default without crashing.

**Regression check:** verify that the three most closely related existing flows still work correctly after the change.

---

## Phase 9 — Code Review

Re-read every file changed in this task. Apply the following checks:

**Architecture**
- Does each type live in its correct layer? Domain types must not import Data or Presentation. Presentation must not bypass the domain layer to reach Data directly.
- Are new use cases thin wrappers over a single repository call, or do they contain real logic? If real logic, it belongs in the use case, not the repository.
- Is the DI container the sole place where concrete types are instantiated?

**Testability**
- Are new business-logic types free of framework dependencies so they can be unit-tested without a simulator?
- Are protocol boundaries defined at every seam where test doubles may be needed?
- Is any logic embedded in a View that should be in a ViewModel or use case?

**Maintainability**
- Is every new type and method named clearly enough that its purpose is obvious without a comment?
- Are comments present only where the *why* is non-obvious?
- Is there any dead code, debug print statement, or TODO left in?

**Concurrency**
- Are all `@MainActor`-isolated properties accessed only from the main actor?
- Are actors used for every shared mutable state that is accessed from multiple async contexts?
- Are `Task {}` blocks launched from the correct actor context?
- Is there any possibility of a race condition on device state that isn't protected by an actor?

**Performance**
- Are heavy operations (disk I/O, network, large collection processing) performed off the main thread?
- Is any expensive computation happening in a View's `body` or a `@Published` setter?

**Security**
- Are secrets read from `Info.plist` (via xcconfig), not hardcoded in source?
- Is any sensitive data (tokens, PII) being written to UserDefaults or logged to the console?
- Is data written to the correct protection class for its sensitivity?

After completing the review, state explicitly: "Code review passed" or list each issue found and fix it before declaring complete.

---

## Phase 10 — Documentation

Update documentation if any of the following changed:

- A new type or layer was added → update the architecture overview.
- The DI container changed → update the DI section.
- The navigation flow changed → update the navigation diagram.
- A known issue was resolved → remove it from `next_steps.md` or equivalent.
- A new known issue was discovered → add it.
- The build or test commands changed → update the build docs.

Do not document *what* the code does — that belongs in well-named identifiers. Document architectural decisions, non-obvious constraints, and lessons learned.

---

## Phase 11 — Completion Criteria

A task is complete when **all** of the following are true. Check each one explicitly:

- [ ] **Build succeeds** — zero errors, zero new warnings.
- [ ] **Tests pass** — all existing tests green; new tests written for new behaviour.
- [ ] **Simulator verified** — happy path, error path, re-entry path, and regression paths all confirmed.
- [ ] **Persistence verified** — if applicable: save, restore, clear, and corrupt-data paths all confirmed.
- [ ] **Product review passed** — cancel, undo, restart, recovery, and restart-after-force-quit all handled or explicitly accepted as out of scope with a documented reason.
- [ ] **Code review passed** — architecture, testability, maintainability, concurrency, performance, and security checks all passed.
- [ ] **Documentation updated** — if architecture, navigation, or known issues changed.

If any item is unchecked, the task is not complete. State which items remain and address them before closing.
