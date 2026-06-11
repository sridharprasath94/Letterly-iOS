# Code Style

## Language & Version

Swift 6 concurrency model. All new code must be compatible with `SWIFT_APPROACHABLE_CONCURRENCY = YES` and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.

## Naming

- Types: `UpperCamelCase` — `GameViewModel`, `EvaluateGuessUseCase`
- Properties and methods: `lowerCamelCase` — `currentRow`, `submitGuess()`
- Enum cases: `lowerCamelCase` — `.correct`, `.continueGame`
- Boolean properties: named as predicates — `isEnabled`, `hasReceivedHints`
- Use-case methods: always named `execute(...)` with descriptive parameter labels
- Protocol names: describe capability — `WordRepository`, `HintRepository`

## File Organisation

One type per file. File name matches the type name exactly.

Use-case files live in `Domain/UseCase/`, named `<Name>UseCase.swift`.
Model files live in `Domain/Model/`.
Components live in `Presentation/Game/Components/`.

## Types

Prefer `struct` for models and use cases. Use `class` only when reference semantics are required (`ObservableObject` ViewModels, `AppContainer`).

Prefer `enum` for finite state over `Bool` flags.

Use `actor` for shared mutable state that is accessed from multiple async contexts (`WordStore`).

## Comments

Write no comments by default. Add a comment only when the **why** is non-obvious:

```swift
// Two-pass: correct positions first so duplicated letters in the guess
// don't consume "present" slots that a later correct match would claim.
```

Never write comments describing what the code does — the code and names already do that.

## Formatting

- 4-space indentation (Xcode default)
- Opening brace on the same line
- Trailing commas in multi-line collections
- One blank line between methods; two blank lines between unrelated sections

## SwiftUI Conventions

- View body decomposed into computed property helpers (`private var header: some View`) rather than deep nesting
- Extract reusable sub-views into `private struct` within the same file when used only locally
- Use `onReceive` for Combine `PassthroughSubject` observation, not `sink` stored in the VM
- Do not store `AnyCancellable` in the ViewModel — use `onReceive` in the View instead

## Async / Concurrency

- Use `async/await` exclusively. No completion handlers.
- Launch async work from `GameViewModel` methods via `Task {}` — they inherit `@MainActor` context automatically.
- All `WordStore` interactions are `await`ed at the call site. Never access `wordsByLength` from outside the actor.
- New ViewModels must be `@MainActor`.
- New shared mutable state accessed from async contexts must be an `actor`.

## Error Handling

- Domain use cases return typed results (`Result<T, Error>`) rather than throwing, to make the error explicit at the call site.
- Networking errors from `GroqAPIService` propagate up through the `Result` chain in `HintRepositoryImpl`.
- Never silently swallow errors. Either surface them as a `GameEvent` or log them.

## Dependency Injection

All dependencies are wired in `AppContainer`. Never:
- Create a new singleton outside `AppContainer`
- Access `AppContainer.shared` from inside a use case or repository
- Use `@EnvironmentObject` for `AppContainer` — pass it explicitly at the call site

## Architecture Rules

- Domain must not import UIKit, SwiftUI (except `Color` in `LetterState` — existing coupling), or any Data layer type.
- Data layer must not import Presentation types.
- Presentation accesses Domain only through use-case structs and model types.
- New features: add domain models → add repository protocol (if persistence/network needed) → add use case(s) → implement repository → wire in `AppContainer` → build ViewModel/View.

## What Not To Do

- Do not add `@EnvironmentObject` dependencies without a clear architectural reason
- Do not put one-shot events (win/lose/toast) into `@Published` state — use `eventPublisher`
- Do not write `guard let _ = ...` — use specific variable names
- Do not use `DispatchQueue.main.async` — use `@MainActor` / `Task { @MainActor in ... }`
- Do not hard-code colours as literals in Views — use `LetterState.backgroundColor` / `LetterState.keyboardBackgroundColor`
