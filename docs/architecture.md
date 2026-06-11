# Architecture

## Overview

Letterly follows **Clean Architecture + MVVM**. The three primary layers — Domain, Data, Presentation — are physically separated into matching folders. Dependency arrows point inward: Presentation depends on Domain, Data depends on Domain, Domain depends on nothing.

```
┌──────────────────────────────────┐
│         Presentation             │
│  StartView  GameView  Components │
│         GameViewModel            │
└────────────┬─────────────────────┘
             │ uses protocols from
┌────────────▼─────────────────────┐
│             Domain               │
│   Models  Repositories  UseCases │
└────────────▲─────────────────────┘
             │ implements protocols
┌────────────┴─────────────────────┐
│              Data                │
│  WordStore  GroqAPIService       │
│  WordRepositoryImpl              │
│  HintRepositoryImpl              │
└──────────────────────────────────┘
```

## Domain Layer

Pure Swift. No framework imports except Foundation (for `Date`) and SwiftUI in `LetterState` (for `Color` — a minor coupling worth noting).

### Models

| Type | Kind | Purpose |
|---|---|---|
| `Word` | struct | Represents a dictionary word with an optional last-answered timestamp |
| `LetterTile` | struct | A single cell on the game board — holds `Character?` and `LetterState` |
| `LetterState` | enum | `.empty`, `.correct`, `.present`, `.absent` — drives tile and keyboard colours |
| `GameMode` | enum | `.classic`, `.advanced`, `.expert` — encapsulates word length, max guesses, max hints |
| `GameStatus` | enum | `.win`, `.lose`, `.continueGame` |
| `GuessResult` | struct | Output of `EvaluateGuessUseCase` — carries guess string and per-letter states |

### Repository Protocols

```swift
protocol WordRepository {
    func getRandomWord(length: Int) async -> Word?
    func getWord(value: String) async -> Word?
    func updateWord(_ word: Word) async
    func exists(_ value: String) async -> Bool
}

protocol HintRepository {
    func getHint(word: String, previousHints: [String]) async -> Result<String, Error>
}
```

### Use Cases

Each use case is a value-type struct with a single `execute()` method.

| Use Case | Inputs | Output | Notes |
|---|---|---|---|
| `GetRandomWordUseCase` | `GameMode` | `Word?` | Retries up to 10 times to avoid recently-answered words |
| `CheckWordExistsUseCase` | `String` | `Bool` | Delegates to `WordRepository.exists` |
| `EvaluateGuessUseCase` | guess, target | `GuessResult` | Two-pass Wordle algorithm (correct positions first, then present) |
| `ApplyGuessResultUseCase` | board, row, states | `[[LetterTile]]` | Returns new board with states applied to the given row |
| `CheckGameStatusUseCase` | guesses, target, maxGuesses | `GameStatus` | Win if last guess == target; lose if guess count >= max |
| `CheckDuplicateGuessUseCase` | guess, guesses | `Bool` | Case-insensitive containment check |
| `ClearRowUseCase` | board, row | `[[LetterTile]]` | Resets all tiles in the row to empty |
| `UpdateKeyboardStateUseCase` | keyboard, guess, states | `[Character: LetterState]` | Applies precedence: correct > present > absent |
| `UpdateWordTimestampUseCase` | word, mode | `Void` | Persists the current date as last-answered for the word |
| `GetHintUseCase` | word, previousHints | `Result<String, Error>` | Passes through to `HintRepository` |

## Data Layer

### WordStore (actor)

`WordStore` is a Swift `actor` that owns the in-memory word lists loaded from bundled `.txt` files at app launch. Timestamps for answered words are persisted in `UserDefaults` under the key `"word_timestamps"` as a `[String: Double]` dictionary (word → Unix timestamp).

```
AppDelegate.application(_:didFinishLaunchingWithOptions:)
  └─ Task { await WordStore.shared.load() }
       └─ Reads words_5.txt, words_6.txt, words_7.txt from Bundle
          Stores in [Int: [String]] keyed by length
```

### GroqAPIService

Thin `URLSession` wrapper around `https://api.groq.com/openai/v1/chat/completions`. Uses `async throws`, `JSONEncoder`/`JSONDecoder`, and `Codable` models (`GroqRequest`, `GroqMessage`, `GroqResponse`, `GroqChoice`). Model: `llama-3.1-8b-instant`, max tokens: 60.

### Repository Implementations

`WordRepositoryImpl` bridges `WordStore` (actor) to the `WordRepository` protocol.
`HintRepositoryImpl` builds the hint prompt (avoiding repeated hints) and calls `GroqAPIService`.

## Presentation Layer

### Navigation

```
LetterlyApp (@main)
  └─ WindowGroup
       └─ StartView
            └─ NavigationStack
                 └─ NavigationLink → GameView(viewModel:)
```

`StartView` iterates `GameMode.allCases` to generate mode buttons. Each `NavigationLink` creates a `GameViewModel` via `AppContainer.shared.makeGameViewModel(mode:)`.

### GameViewModel

`@MainActor` `ObservableObject`. Owns all mutable game state via `@Published`. One-shot events (win, lose, invalid word, duplicate, hint) are broadcast through `PassthroughSubject<GameEvent, Never>` (`eventPublisher`) rather than being stored in state, preventing repeated-alert bugs when SwiftUI re-evaluates the view body.

**State machine:**

```
startGame()
  ↓ (async: picks word, builds board)
addLetter(_:)  /  removeLetter()
  ↓ when currentCol == wordLength
submitGuess()  [async]
  ├─ duplicate? → clear row, send .duplicateWord
  ├─ not in dict? → clear row, send .invalidWord
  └─ valid
       ├─ evaluate → apply to board + keyboard
       ├─ .win  → update timestamp, send .gameWon
       └─ .lose → send .gameLost(target:)
requestHint()
  └─ async Groq call → send .hintReceived / .hintFailed
resetGame()
  └─ clear state, call startGame()
```

### Game Components

| Component | Role |
|---|---|
| `BoardView` | Renders `[[LetterTile]]` as a VStack of HStacks |
| `LetterTileView` | Single tile; border changes when a letter is typed |
| `KeyboardView` | QWERTY layout; per-key colour driven by `[Character: LetterState]` |
| `HintButtonView` | Bulb icon with remaining-hint count; shows spinner while loading |
| `HintDialogView` | Modal overlay listing all received hints; "Get Next Hint" button |

## Dependency Injection

`AppContainer` is a manually wired singleton. It is initialised once (private `init()`) and exposed via `AppContainer.shared`. `StartView` holds a reference and calls `makeGameViewModel(mode:)` per navigation link. No third-party DI framework is used.

## Concurrency Model

- All ViewModel state mutations are on `MainActor` (class is annotated `@MainActor`).
- `WordStore` is an `actor`; all calls to it are `await`ed.
- `GroqAPIService.getChatCompletion` is `async throws`.
- `Task {}` blocks are launched inside `GameViewModel` methods; they inherit `MainActor` context from the surrounding class.

## Unused Artefacts

These files exist but serve no purpose and are candidates for removal:

- `ViewController.swift` — Xcode template boilerplate; app never navigates to it
- `SceneDelegate.swift` — Scene lifecycle is handled by SwiftUI App; this file is empty
- `Letterly.xcdatamodeld` — CoreData model added by template; no entities defined, not used
- `Base.lproj/Main.storyboard` — Referenced by `INFOPLIST_KEY_UIMainStoryboardFile` but not rendered since SwiftUI `WindowGroup` takes over
