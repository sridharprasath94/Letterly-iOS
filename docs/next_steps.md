# Next Steps

Prioritised technical debt, missing features, and improvement opportunities.

---

## High Priority

### 1. Add a Unit Test Target

**Status**: No test target exists.  
**Impact**: Any regression in use-case logic goes undetected until manual Simulator testing.  
**Action**: Add `LetterlyTests` XCTest target. Write tests for all ten use cases in `Domain/UseCase/`, starting with `EvaluateGuessUseCase` (most complex logic, highest risk).  
**Effort**: Medium.

### 3. Remove Unused Artefacts

**Status**: Three files exist only as Xcode template leftovers.  
**Files**:
- `Letterly/ViewController.swift` — never used; app is entirely SwiftUI
- `Letterly/SceneDelegate.swift` — SwiftUI App lifecycle handles scenes; this class is never called
- `Letterly/Letterly.xcdatamodeld` — CoreData model with no entities; not linked anywhere in code

**Impact**: Confusing to future contributors; inflates binary size marginally.  
**Action**: Delete all three. Rebuild to confirm nothing breaks.  
**Effort**: Trivial.

### 4. Set Up GitHub Actions CI

**Status**: No automated CI.  
**Impact**: Broken builds can reach `main` undetected.  
**Action**: Create `.github/workflows/build.yml` following the template in `docs/ci_cd.md`. Gate PRs on a passing build.  
**Effort**: Small.

---

## Medium Priority

### 5. Persist Word Timestamps in a Proper Store

**Status**: Word timestamps are stored in `UserDefaults` as a flat `[String: Double]` dictionary that grows indefinitely.  
**Impact**: Over time the dictionary could accumulate thousands of entries from different devices/reinstalls. No pruning mechanism exists.  
**Action**: Prune entries older than 30 days in `WordStore.setTimestamp`. Or migrate to a lightweight SQLite database using GRDB or a simple file.  
**Effort**: Small to Medium.

### 6. Protect the Groq API Key at Runtime

**Status**: The key is read from `Info.plist` at runtime. If someone extracts the IPA, they can read the key.  
**Impact**: Key abuse / unexpected charges.  
**Action**: Proxy hint requests through a lightweight backend (Firebase Function, Supabase Edge Function, Cloudflare Worker). The mobile app calls the proxy; the proxy holds the key.  
**Effort**: Medium.

### 7. Add a Score / Statistics Screen

**Status**: No game statistics are tracked.  
**Potential features**: Win rate per mode, average guesses, current streak, distribution of guess counts (histogram).  
**Action**: Store game results in `UserDefaults` (or SQLite). Add a `StatsView` accessible from `StartView`.  
**Effort**: Medium.

### 8. Add UI Tests

**Status**: No UI test target.  
**Action**: Add `LetterlyUITests` target. Cover the happy path (full game win) and critical error paths (invalid word toast, duplicate word toast, leave-game alert). See `docs/testing_rules.md`.  
**Effort**: Medium.

### 9. Keyboard Auto-Submit on Last Letter

**Status**: The game submits the guess automatically when the last letter is typed (`addLetter` calls `submitGuess()` when `currentCol == wordLength`). This is intentional but not documented and may surprise users.  
**Action**: Consider adding a "Submit" key to the keyboard row, consistent with most Wordle variants. This gives players a chance to review before submitting.  
**Effort**: Small.

---

## Low Priority

### 10. SwiftLint Integration

**Status**: No linter.  
**Action**: Add SwiftLint as a build phase script. Start with the default rule set and disable rules that conflict with existing style.  
**Effort**: Small.

### 11. Snapshot Tests for UI Components

**Status**: No snapshot tests.  
**Action**: Add `swift-snapshot-testing` SPM package. Write snapshots for `LetterTileView` (all states), `BoardView`, `KeyboardView` (empty, partially filled), `HintDialogView`. Run in both light and dark mode.  
**Effort**: Medium.

### 12. Localisation

**Status**: Strings are hardcoded in English. `SWIFT_EMIT_LOC_STRINGS = YES` and `LOCALIZATION_PREFERS_STRING_CATALOGS = YES` are enabled, so the infrastructure is ready.  
**Action**: Extract all user-visible strings into a `Localizable.xcstrings` file. Add at least one additional locale.  
**Effort**: Medium.

### 13. Accessibility Audit

**Status**: No accessibility labels on game-critical elements.  
**Impact**: VoiceOver users cannot play the game.  
**Action**: Add `.accessibilityLabel` to `LetterTileView` (announce letter and state), `KeyboardView` keys, `HintButtonView` (announce remaining count), and `BoardView` rows.  
**Effort**: Small.

### 14. `Main.storyboard` Reference Cleanup

**Status**: `INFOPLIST_KEY_UIMainStoryboardFile = Main` points to a storyboard that exists but is never rendered (SwiftUI `WindowGroup` takes over). This is a minor inconsistency.  
**Action**: Remove `INFOPLIST_KEY_UIMainStoryboardFile` from both build configurations in `project.pbxproj` and delete `Base.lproj/Main.storyboard`.  
**Effort**: Trivial.

### 15. Offline / Network Error Handling for Hints

**Status**: If the device is offline, `GroqAPIService` throws a `URLError` which propagates to `.hintFailed`, showing a generic toast. There is no retry or offline indicator.  
**Action**: Detect `URLError.notConnectedToInternet` specifically and show a more informative message ("No internet connection — hints unavailable").  
**Effort**: Small.
