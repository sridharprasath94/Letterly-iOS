# Code Style
<!-- Template: generic Swift 6 / SwiftUI iOS project. Review and adjust the concurrency section for your project's isolation settings. -->

## Language & Version

Swift 6 concurrency model. All new code must be compatible with the project's concurrency settings. Recommended starting point: `SWIFT_APPROACHABLE_CONCURRENCY = YES`, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.

## Naming

- Types: `UpperCamelCase` — `ProfileViewModel`, `FetchUserUseCase`
- Properties and methods: `lowerCamelCase` — `currentIndex`, `submitForm()`
- Enum cases: `lowerCamelCase` — `.success`, `.loading`
- Boolean properties: named as predicates — `isEnabled`, `hasLoadedData`
- Use-case methods: always named `execute(...)` with descriptive parameter labels
- Protocol names: describe capability — `UserRepository`, `AnalyticsRepository`

## File Organisation

One type per file. File name matches the type name exactly.

Use-case files live in `Domain/UseCase/`, named `<Name>UseCase.swift`.  
Model files live in `Domain/Model/`.  
Repository protocols live in `Domain/Repository/`.  
Repository implementations live in `Data/Repository/` or `Data/Local/`.

## Types

Prefer `struct` for models and use cases. Use `class` only when reference semantics are required (`ObservableObject` ViewModels, the DI container).

Prefer `enum` for finite state over `Bool` flags.

Use `actor` for shared mutable state accessed from multiple async contexts.

## Comments

Write no comments by default. Add a comment only when the **why** is non-obvious:

```swift
// Two-pass evaluation: correct positions first so duplicate letters in
// the guess don't consume "present" slots a later correct match would claim.
```

Never describe what the code does — well-named identifiers do that already.

## Formatting

- 4-space indentation (Xcode default)
- Opening brace on the same line
- Trailing commas in multi-line collections
- One blank line between methods; two blank lines between unrelated sections

## SwiftUI Conventions

- Decompose the view body into `private var` computed property helpers rather than deep nesting
- Extract reusable sub-views into `private struct` within the same file when used locally only
- Use `onReceive` for Combine `PassthroughSubject` observation in Views
- Do not store `AnyCancellable` in the ViewModel — observe in the View with `onReceive`

## Async / Concurrency

- Use `async/await` exclusively. No completion handlers.
- Launch async work from `@MainActor` ViewModels via `Task {}` — they inherit the actor context automatically.
- New ViewModels must be `@MainActor`.
- New shared mutable state accessed from multiple async contexts must be an `actor`.
- Never access actor-isolated state from outside without `await`.

## Error Handling

- Domain use cases return typed results (`Result<T, Error>`) rather than throwing, to make the error explicit at the call site.
- Networking errors propagate up through the `Result` chain.
- Never silently swallow errors. Either surface them as a user-visible event or log them.

## Dependency Injection

All dependencies are wired in the DI container. Never:
- Create a new singleton outside the container
- Access the container from inside a use case or repository
- Use `@EnvironmentObject` for the container — pass dependencies explicitly at the call site

## Architecture Rules

- Domain must not import UIKit, SwiftUI, or any Data layer type.
- Data layer must not import Presentation types.
- Presentation accesses Domain only through use-case structs and model types.
- Adding a feature: domain model → repository protocol (if new persistence/network) → use case(s) → repository implementation → wire in DI container → ViewModel → View.

## Persistence Rules

- Persist business state only. Do not persist transient UI state (loading spinners, animation flags, error messages).
- Use `Codable` with `JSONEncoder`/`JSONDecoder` for `UserDefaults` payloads.
- `Character` is not `Codable`; encode as `String` and convert at the boundary.
- Use per-record keys (e.g. `"state_classic"`) rather than a single key for independently managed records.
- Always provide a graceful fallback (return `nil` / default value) when decoding fails.

## What Not To Do

- Do not add `@EnvironmentObject` dependencies without a clear architectural reason
- Do not put one-shot events (alerts, toasts) into `@Published` state — use a `PassthroughSubject`
- Do not write `guard let _ = ...` — use specific variable names
- Do not use `DispatchQueue.main.async` — use `@MainActor` / `Task { @MainActor in ... }`
- Do not hardcode colours as hex literals in Views — define them on model types or in a style enum
- Do not persist `enum` cases by raw integer index — use `String` raw values that survive reordering
