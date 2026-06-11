# Testing Rules
<!-- Template: replace <APP_NAME>, <SIMULATOR_DEVICE>, <BUNDLE_ID> -->

## Current State

Document the current test coverage: are there unit tests, UI tests, snapshot tests, or none?

## Adding a Test Target

Create a standard Xcode Unit Test target named `<APP_NAME>Tests` and a UI Test target named `<APP_NAME>UITests`. Link both to the main app target.

## Recommended Test Coverage

### Unit Tests — Priority Order

Test from the inside out. The layers with fewest dependencies are the most testable and give the most value per line of test code.

**Domain/UseCase/** — pure functions or thin async wrappers. Test every branch.

Prioritise:
- Core business logic (evaluation, scoring, state transitions)
- Edge cases: boundary conditions, empty inputs, duplicate values
- Error paths: nil returns, decode failures, network errors

**Domain/Model/** — computed properties, state transitions, factory functions.

**Domain/Repository protocols** — test through concrete implementations with lightweight fakes.

### Integration Tests

- Repository implementations against real storage (in-memory or temp file)
- Network clients: mock `URLSession` to test request construction and error propagation
- Persistence layer: write → read round-trip through the actual store

### UI Tests

Cover the critical user journeys:

- App launch → main screen appears
- Primary user flow (happy path) works end-to-end
- Error states display correct messages
- Navigation: forward, back, dismiss
- Alert confirmation dialogs appear and respond correctly

### Snapshot Tests

Consider `swift-snapshot-testing` for key UI components in multiple states (empty, filled, error, dark mode).

## Running Tests

```bash
# All tests
xcodebuild test \
  -project <APP_NAME>.xcodeproj \
  -scheme <APP_NAME> \
  -destination 'platform=iOS Simulator,name=<SIMULATOR_DEVICE>'

# Unit tests only (when a separate test plan exists)
xcodebuild test \
  -project <APP_NAME>.xcodeproj \
  -scheme <APP_NAME> \
  -testPlan UnitTests \
  -destination 'platform=iOS Simulator,name=<SIMULATOR_DEVICE>'

# UI tests only
xcodebuild test \
  -project <APP_NAME>.xcodeproj \
  -scheme <APP_NAME> \
  -testPlan UITests \
  -destination 'platform=iOS Simulator,name=<SIMULATOR_DEVICE>'
```

## Test Conventions

- File names match the type under test: `MyUseCaseTests.swift`.
- Use `XCTest`. Avoid third-party test frameworks unless there is a specific need.
- Use protocol stubs (not mocks) for repository dependencies.
- One behaviour per test method. Name: `test_<subject>_<condition>_<expected>`.
- Do not test implementation details — test observable outputs.

## Manual Verification Checklist

Until a test target exists, verify the following manually after every change:

- [ ] Build succeeds
- [ ] App launches without crash on `<SIMULATOR_DEVICE>` simulator
- [ ] Primary screen loads and shows expected content
- [ ] Main user flow works end-to-end
- [ ] Error handling displays appropriate feedback
- [ ] Navigation (forward and back) works correctly
- [ ] Confirmation dialogs appear and each action works correctly
- [ ] Dark mode renders without layout issues
- [ ] Any feature-specific behaviour added in this change works as specified

## Persistence Verification

For features involving `UserDefaults`, `CoreData`, or file-based storage:

- [ ] Data survives app termination and relaunch
- [ ] Corrupt or missing data degrades gracefully to a default state
- [ ] Clear/reset operations remove data completely
- [ ] Independent keys/records do not interfere with each other
