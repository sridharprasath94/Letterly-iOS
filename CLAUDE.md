# Letterly — Claude Code Reference

## Project Overview

Letterly is a SwiftUI iOS word-puzzle game (Wordle-style) with three difficulty modes. Players guess a hidden word within a fixed number of attempts; each guess returns colour-coded feedback. AI-powered hints are fetched from the Groq REST API (Llama 3.1 8B Instant).

- **Bundle ID**: `com.flash.Letterly`
- **Deployment target**: iOS 26.4
- **Swift**: 6 (swift-driver 6.3.2 / Xcode 26.5)
- **UI framework**: SwiftUI
- **State**: `ObservableObject` + `@Published`
- **One-shot events**: Combine `PassthroughSubject<GameEvent, Never>`
- **Concurrency**: Swift `async/await` + `Actor`
- **Networking**: `URLSession` + `Codable`
- **DI**: Manual — `AppContainer` singleton
- **Persistence**: In-memory `WordStore` actor + `UserDefaults` for word timestamps, game stats, and per-mode in-progress game state (`GameSaveState`)
- **Secrets**: `Configuration/Secrets.xcconfig` (gitignored) → `Info.plist`
- **No external dependencies** (no SPM packages, no CocoaPods)
- **No test target** (tests do not exist yet)

## Architecture

```
Clean Architecture + MVVM

Domain/
  Model/       — Word, LetterTile, LetterState, GameMode, GameStatus, GuessResult
  Repository/  — WordRepository, HintRepository (protocols)
  UseCase/     — 10 pure structs; each has a single execute() method

Data/
  Local/       — WordStore (actor; loads words_5/6/7.txt; timestamps in UserDefaults)
  Remote/      — GroqAPIService, GroqModels
  Repository/  — WordRepositoryImpl, HintRepositoryImpl

Presentation/
  Start/       — StartView (mode selection)
  Game/        — GameView, GameViewModel, Components/
  Shared/      — GameEvent, HintState

DI/
  AppContainer — singleton that owns all repositories and use cases
```

Dependency direction: Presentation → Domain ← Data. Domain has zero framework imports except Foundation/SwiftUI where models need Color.

## Key Files

| File | Role |
|---|---|
| `LetterlyApp.swift` | `@main` entry; attaches `AppDelegate`; presents `StartView` |
| `AppDelegate.swift` | Triggers `WordStore.shared.load()` at launch |
| `DI/AppContainer.swift` | Wires all dependencies; `makeGameViewModel(mode:)` factory |
| `Domain/UseCase/EvaluateGuessUseCase.swift` | Core Wordle algorithm (two-pass correct/present) |
| `Domain/UseCase/GetRandomWordUseCase.swift` | Picks a word not answered in the last 10 days (10 retries) |
| `Data/Local/WordStore.swift` | `actor`; in-memory word lists; UserDefaults timestamps |
| `Data/Remote/GroqAPIService.swift` | `URLSession` call to Groq chat-completions endpoint |
| `Presentation/Game/GameViewModel.swift` | `@MainActor` VM; drives all game state |
| `Presentation/Game/GameView.swift` | Game screen; listens to `eventPublisher` via `onReceive` |
| `Configuration/Secrets.xcconfig` | **gitignored** — contains `GROQ_API_KEY` |

## Game Modes

| Mode | Word length | Max guesses | Max hints |
|---|---|---|---|
| Classic | 5 | 6 | 1 |
| Advanced | 6 | 7 | 2 |
| Expert | 7 | 8 | 3 |

## Development Rules

1. **Never break the build.** Every code change must be followed by a build verification.
2. **Fix compile errors immediately.** Do not leave the project in a broken state.
3. **Fix warnings whenever possible.** The project has strict warning settings enabled.
4. **Follow Clean Architecture.** Domain has no dependencies on Data or Presentation. Use cases are pure value-type structs.
5. **Follow existing coding style.** No comments unless the WHY is non-obvious. No unnecessary abstractions. Concise naming.
6. **Use `async/await` for all asynchronous work.** No completion handlers.
7. **GameViewModel is `@MainActor`.** All UI state mutations happen there automatically.
8. **One-shot events go through `PassthroughSubject`.** Do not put transient events into `@Published` state.
9. **New use cases = new file** in `Domain/UseCase/`. Each use case owns one public `execute()` method.
10. **Wire new dependencies in `AppContainer`.** Do not create singletons elsewhere.

## Persistence Design

When implementing any feature that saves state:

- **Persist business state only.** Game board, guesses, scores, preferences — yes. Loading spinners, animation flags, error messages — no.
- **Provide a graceful fallback.** If saved data cannot be decoded, fall back to a clean default. Never crash on corrupted data.
- **Clear at the right moment.** Saved state must be cleared when it is no longer valid — on game completion, on explicit reset, and before navigating to a fresh session. If clear happens *after* the new session starts, the old state can be accidentally restored.
- **Consider re-entry UX.** Silent automatic restore is only appropriate when the user has no other meaningful choice. When they do have a choice (resume vs start fresh), present a confirmation dialog before navigating — not after. `NavigationLink` navigates immediately; replace it with a `Button` + `navigationDestination(item:)` when a pre-navigation decision is needed.
- **Use per-record keys.** Independent records (e.g. one per game mode) must use independent `UserDefaults` keys so they cannot overwrite each other.
- **`Character` is not `Codable`.** Encode as `String` and convert at the persistence boundary. Add `Codable` conformance via `extension` (not the struct body) to preserve synthesised initialisers.

## Feature Development Considerations

Before writing any code for a new feature:

- **Consider the user experience.** What does the user see on first use? On error? On re-entry after interruption?
- **Consider recovery flows.** What happens if the user is force-quit mid-flow? If they navigate away and return? If they tap the wrong button?
- **Consider edge cases.** Empty state, maximum values, corrupt data, concurrent access.
- **Consider persistence implications.** Does this feature create state that must survive restart? When should that state be cleared?

## Product Review

Before marking a feature complete, ask:

- Can the user undo or reverse this action?
- Can the user start fresh without losing unrelated progress?
- Can the user recover if the app is closed mid-flow?
- Is there an obvious UX gap a first-time user would encounter?

If the answer to any of these is "no" and the feature warrants it, address the gap before shipping.

## Build Verification Rules

After every code change, execute these steps in order:

```bash
cd /Users/sridharprasath/xcodeProjects/Letterly

# 1. Build
xcodebuild build \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  | xcpretty || xcodebuild build \
      -project Letterly.xcodeproj \
      -scheme Letterly \
      -configuration Debug \
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# 2. Fix any compile errors
# 3. Rebuild until clean
```

**Never report a task complete while the project has compile errors.**

## Testing Rules

There is currently **no test target**. When a test target is added, run after every build:

```bash
# Unit tests
xcodebuild test \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Until tests exist, manually verify the modified screen in Simulator.

## Simulator Verification

After every successful build:

```bash
# Boot simulator
xcrun simctl boot "iPhone 17 Pro"

# Install
xcrun simctl install booted \
  $(xcodebuild -showBuildSettings \
    -project Letterly.xcodeproj \
    -scheme Letterly \
    -configuration Debug \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    | grep ' BUILT_PRODUCTS_DIR' | awk '{print $3}')/Letterly.app

# Launch
xcrun simctl launch booted com.flash.Letterly
```

Verify:
- App launches without crash
- Start screen shows three mode buttons
- If a saved game exists for a mode, tapping it shows the Resume / New Game dialog
- Tapping a mode with no saved game opens a fresh game board immediately
- Letters can be typed and deleted
- Hint button is present and shows correct count
- Navigation back from active game shows "Leave game?" alert
- Force-quitting and relaunching restores the in-progress game for the same mode

## UI Review Checklist

After any UI change:
- [ ] Layout is correct in light mode
- [ ] Layout is correct in dark mode
- [ ] Dynamic Type does not break layout
- [ ] VoiceOver labels are meaningful
- [ ] Board tiles align correctly for all three word lengths (5, 6, 7)
- [ ] Keyboard colours update correctly after each guess

## Known Issues / Tech Debt

See `docs/next_steps.md` for prioritised list.

Quick summary:
- `ViewController.swift` is unused (Xcode template artefact)
- `Letterly.xcdatamodeld` is empty (CoreData added by template, not used)
- `SceneDelegate.swift` is unused (SwiftUI App lifecycle handles scenes)
- No test target exists
- `GetRandomWordUseCase` returns `nil` after 10 failed retries (game hangs silently)
- Word timestamps in `UserDefaults` are never pruned
- `GameSaveState` per-mode keys grow indefinitely if user never completes a game

## Secret Key Setup (new machine / CI)

```bash
cp Configuration/Secrets.xcconfig.template Configuration/Secrets.xcconfig
# Edit Secrets.xcconfig and set GROQ_API_KEY = <your key>
```

## Reference Docs

- `docs/architecture.md` — full architecture detail
- `docs/project_setup.md` — machine setup and first build
- `docs/build_rules.md` — all xcodebuild commands
- `docs/testing_rules.md` — testing strategy and commands
- `docs/code_style.md` — naming and style guide
- `docs/workflow.md` — feature / bug-fix / refactor workflows
- `docs/implementation_process.md` — step-by-step implementation checklist
- `docs/bug_fix_process.md` — bug fix process
- `docs/ci_cd.md` — CI/CD recommendations
- `docs/release_process.md` — App Store release steps
- `docs/feature_development_checklist.md` — per-feature checklist
- `docs/next_steps.md` — technical debt and improvements
- `docs/templates/` — reusable generic versions of the above docs for new iOS projects


# Autonomous Execution Policy

For every implementation task:

## Mandatory Steps

1. Analyze requirement.
2. Create implementation plan.
3. Implement changes.
4. Build project.
5. Fix compile errors.
6. Rebuild until BUILD SUCCEEDED.
7. Run all relevant tests.
8. Launch simulator.
9. Install app.
10. Launch app.
11. Verify modified functionality.
12. Verify no regression in related flows.
13. Perform self code review.
14. Update documentation if required.
15. Commit changes.
16. Create PR description.

Never stop after implementation.

A task is only complete when all verification steps succeed.
