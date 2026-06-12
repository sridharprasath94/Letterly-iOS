# Testing Rules

## Current State

**No test target exists.** The Xcode project has a single target (`Letterly`) with no `XCTestCase` files. All verification is currently manual via Simulator.

## Adding a Test Target

When adding tests, create a standard Xcode Unit Test target named `LetterlyTests` and a UI Test target named `LetterlyUITests`. Link them to the main `Letterly` target.

## Recommended Test Coverage

### Unit Tests — Priority Order

These layers have zero external dependencies and are the most testable:

**Domain/UseCase/** — all ten use cases are pure functions or thin async wrappers. Test every branch.

| Use Case | Key test cases |
|---|---|
| `EvaluateGuessUseCase` | Correct position, present wrong position, absent, duplicate letters in guess, duplicate letters in target |
| `CheckGameStatusUseCase` | Win on last guess, lose exactly at maxGuesses, continueGame |
| `CheckDuplicateGuessUseCase` | Case insensitivity, empty guesses list |
| `GetRandomWordUseCase` | Word with `nil` timestamp is returned; word answered < 10 days ago is skipped; all words recently answered returns `nil` |
| `UpdateKeyboardStateUseCase` | Correct overrides present/absent, present overrides absent, absent does not override correct/present |
| `ApplyGuessResultUseCase` | States are applied to correct row only |
| `ClearRowUseCase` | Only the target row is cleared |

**Domain/Model/** — `LetterState` colour values, `GameMode` property correctness, `createBoard` dimensions.

### Integration Tests

**WordStore** — load word lists from bundle, `exists()` returns correct results, timestamp round-trip via `UserDefaults`.

**WordRepositoryImpl** — delegates correctly to `WordStore`.

**HintRepositoryImpl** — mock `HintAPIService` to test prompt construction and error propagation.

### UI Tests

Target the happy path and critical error paths:

- Launch → tap Classic → game board appears with correct 5×6 grid
- Type a valid 5-letter word → tiles update colours
- Type an invalid word → toast "Word not in dictionary" appears
- Type a duplicate word → toast "Word already guessed" appears
- Win game → alert "You won!" appears → "Play Again" resets the board
- Lose game → alert "You lost!" with target word appears
- Back button during active game → "Leave game?" confirmation
- Back button after game ends → returns to StartView directly

### Snapshot Tests

Consider `swift-snapshot-testing` for `LetterTileView`, `BoardView`, and `KeyboardView` in various states (empty, correct, present, absent, dark mode).

## Running Tests (once test target exists)

```bash
# All tests
xcodebuild test \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Unit tests only (when separate scheme or test plan exists)
xcodebuild test \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -testPlan UnitTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# UI tests only
xcodebuild test \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -testPlan UITests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Test Conventions

- Test file names match the type under test: `EvaluateGuessUseCaseTests.swift`
- Use `XCTest`. No third-party test frameworks unless specifically needed.
- Do not mock `WordStore` in unit tests for use-case logic — use protocol stubs instead.
- Use protocol stubs (not mocks) for `WordRepository` and `HintRepository`.
- Each test method tests exactly one behaviour. Name: `test_<subject>_<condition>_<expected>`.

## Manual Verification Checklist

Until a test target exists, verify the following manually after every change:

- [ ] Build succeeds
- [ ] App launches in iPhone 17 Pro simulator
- [ ] StartView shows Classic / Advanced / Expert buttons
- [ ] Tapping Classic opens a 5-column, 6-row board
- [ ] Tapping Advanced opens a 6-column, 7-row board
- [ ] Tapping Expert opens a 7-column, 8-row board
- [ ] Typing letters fills the current row
- [ ] Delete removes the last letter
- [ ] Submitting a complete row triggers evaluation
- [ ] Correct letters show green tiles
- [ ] Present letters show yellow tiles
- [ ] Absent letters show grey tiles
- [ ] Keyboard colours update after each guess
- [ ] Winning shows the "You won!" alert
- [ ] Losing shows the "You lost!" alert with the target word
- [ ] Hint bulb requests a hint from Groq on first tap
- [ ] Hint dialog shows all received hints on subsequent taps
- [ ] Dark mode renders correctly
