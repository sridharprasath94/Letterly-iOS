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
- **Persistence**: In-memory `WordStore` actor + `UserDefaults` for timestamps
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
- Tapping a mode opens the game board
- Letters can be typed and deleted
- Hint button is present and shows correct count
- Navigation back from active game shows "Leave game?" alert

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
