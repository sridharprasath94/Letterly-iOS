# Feature Development Checklist

Use this checklist for every new feature. Check each item before moving to the next.

## 1. Analysis

- [ ] Requirement is understood and unambiguous
- [ ] Affected layer(s) identified (Domain / Data / Presentation)
- [ ] Existing code read — no duplicate functionality being added
- [ ] Edge cases identified and documented in the PR description
- [ ] `GameMode` impact assessed — does this affect one mode or all three?

## 2. Domain

- [ ] New model types added to `Domain/Model/` (one file per type) if needed
- [ ] Repository protocol extended in `Domain/Repository/` if new persistence or network behaviour is required
- [ ] New use case(s) added to `Domain/UseCase/` (one file per use case, `execute()` method)
- [ ] Use case inputs and outputs are value types (structs/enums), not classes
- [ ] Domain files import nothing from UIKit, SwiftUI (except `Color` in `LetterState`), or Data layer

## 3. Data

- [ ] Repository protocol implementations updated in `Data/Repository/`
- [ ] New `WordStore` actor methods added if word-storage behaviour changes
- [ ] New Groq API models added to `Data/Remote/HintModels.swift` if prompt changes
- [ ] `HintRepositoryImpl` prompt updated if hint behaviour changes
- [ ] Error propagation preserved — all failures surface through `Result` or `throw`

## 4. Dependency Injection

- [ ] New use case instantiated in `AppContainer.init()`
- [ ] New use case stored as a `let` property on `AppContainer`
- [ ] `makeGameViewModel(mode:)` updated to pass new use case to `GameViewModel` if needed
- [ ] No new singletons created outside `AppContainer`

## 5. Presentation

- [ ] New `@Published` properties added to `GameViewModel` for reactive state
- [ ] New `GameEvent` cases added for one-shot events (win, toast, dialog)
- [ ] `GameView.handleEvent(_:)` updated to handle new events
- [ ] New SwiftUI components added to `Presentation/Game/Components/` (one file per component)
- [ ] Component receives data as `let` properties — not `@ObservedObject` unless necessary
- [ ] View decomposed into `private var` computed properties or `private struct` helpers

## 6. Build Verification

- [ ] `xcodebuild build ... -configuration Debug` succeeds
- [ ] No new warnings introduced
- [ ] `xcodebuild build ... -configuration Release` succeeds

## 7. Testing

- [ ] Unit tests written for all new use cases (when test target exists)
- [ ] Unit tests cover edge cases identified in Analysis
- [ ] All existing tests still pass
- [ ] Manual Simulator verification completed (all three game modes)

## 8. UI Review

- [ ] Light mode layout correct
- [ ] Dark mode layout correct
- [ ] Board renders correctly for word lengths 5, 6, and 7 (if board is affected)
- [ ] Keyboard colours update correctly (if keyboard logic is affected)
- [ ] Dynamic Type does not break layout
- [ ] New text strings are accessible (VoiceOver label set if icon-only)

## 9. Documentation

- [ ] `CLAUDE.md` updated if architecture or key files changed
- [ ] `docs/architecture.md` updated (use-case table, navigation, or data flow)
- [ ] `docs/next_steps.md` updated (remove resolved items, add new known issues)

## 10. Delivery

- [ ] No debug print statements in committed code
- [ ] No TODO comments left in code
- [ ] Commit message follows convention in `docs/workflow.md`
- [ ] PR description explains what changed and why
- [ ] Screenshots or screen recordings attached for visual changes
