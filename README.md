# Letterly iOS

**Letterly** is a modern iOS word puzzle game inspired by popular word-guessing games. The project focuses on clean architecture, maintainable code structure, and scalable feature development.

Players must guess a hidden word within a limited number of attempts. After each guess, the game provides visual feedback for every letter, indicating whether the letter is correct, present in the word, or absent.

The project emphasizes **clean game logic separation, testability, and structured UI rendering**.

---

## Game Modes

**Classic Mode**
5‑letter words with 6 attempts and 1 hint available.

**Advanced Mode**
6‑letter words with 7 attempts and 2 hints available.

**Expert Mode**
7‑letter words with 8 attempts and 3 hints available.

---

## Features

- Word guessing puzzle gameplay
- Multiple difficulty modes
- Visual feedback for each guessed letter
- Interactive keyboard with dynamic coloring
- Duplicate word detection
- Dictionary validation (9,626 words across all modes)
- Game win / loss detection
- AI-powered hint system via Groq (Llama 3.1)
- Distinct hints — previously given hints are never repeated
- Hint revisit — tap the bulb to review all received hints
- Dark and light mode support
- Clean and responsive SwiftUI UI

---

## Architecture

The project follows a **Clean Architecture + MVVM** approach to keep the codebase modular and easy to maintain.

The structure separates the application into three primary layers:

**Domain Layer**
Contains the core business logic with no dependency on any framework. Includes models (`Word`, `LetterTile`, `LetterState`, `GameMode`), repository protocols, and all use cases.

**Data Layer**
Implements the repository protocols. Word storage is handled via a bundled text file loaded into an in-memory actor (`WordStore`) with timestamps persisted in `UserDefaults`. The Groq API is called using `URLSession` with `async/await` and `Codable` models.

**Presentation Layer**
Built entirely with SwiftUI. Uses `ObservableObject` + `@Published` to mirror the reactive state pattern. One-shot UI events (game won, lost, hint received) are delivered via Combine's `PassthroughSubject`, avoiding the repeated-dialog bug that arises from putting events in state.

---

## Project Structure

```
Letterly/
├── Domain/
│   ├── Model/          # Word, LetterTile, LetterState, GameMode, GameStatus
│   ├── Repository/     # WordRepository, HintRepository (protocols)
│   └── UseCase/        # GetRandomWord, EvaluateGuess, CheckGameStatus, GetHint...
├── Data/
│   ├── Local/          # WordStore (actor + UserDefaults)
│   ├── Remote/         # GroqAPIService, GroqModels
│   └── Repository/     # WordRepositoryImpl, HintRepositoryImpl
├── Presentation/
│   ├── Start/          # StartView
│   └── Game/
│       ├── GameView.swift
│       ├── GameViewModel.swift
│       └── Components/ # BoardView, LetterTileView, KeyboardView, HintButtonView, HintDialogView
├── DI/
│   └── AppContainer.swift
├── Configuration/
│   ├── Secrets.xcconfig          # gitignored — add your keys here
│   └── Secrets.xcconfig.template # copy this and rename to Secrets.xcconfig
├── words_5.txt
├── words_6.txt
└── words_7.txt
```

---

## Tech Stack

| Concern | Solution |
|---|---|
| UI | SwiftUI |
| State | `ObservableObject` + `@Published` |
| Events | Combine `PassthroughSubject` |
| Async | Swift `async/await` + `Actor` |
| Networking | `URLSession` + `Codable` |
| DI | Manual — `AppContainer` singleton |
| Word storage | In-memory actor + `UserDefaults` |
| AI hints | Groq REST API (Llama 3.1) |
| Secrets | `.xcconfig` (gitignored) |

---

## Hint System

Each game mode provides a limited number of AI-generated hints powered by the [Groq API](https://groq.com) (Llama 3.1 8B Instant model).

- **First tap** on the bulb requests a new hint directly
- **Subsequent taps** open a dialog showing all received hints, with an option to get the next one
- Previously given hints are passed to the model to ensure each hint is distinct
- When all hints are used, the bulb stays tappable for revisiting the hint history

---

## Setup

### Prerequisites

- Xcode 16+
- iOS 17+ deployment target
- A free [Groq API key](https://console.groq.com)

### API Key Configuration

1. Copy the template:
   ```bash
   cp Configuration/Secrets.xcconfig.template Configuration/Secrets.xcconfig
   ```
2. Open `Secrets.xcconfig` and fill in your key:
   ```
   GROQ_API_KEY = your_key_here
   ```
3. The key is injected into `Info.plist` at build time via the xcconfig base configuration — it is never committed to source control.

### Build

Open `Letterly.xcodeproj` in Xcode and run on simulator or device.

---

## Android Counterpart

This project is the iOS mirror of [Letterly Android](https://github.com/sridharprasath94/Letterly-Android). Both share the same word lists, game rules, hint prompts, and Clean Architecture + MVVM structure, adapted to their respective platform idioms.
