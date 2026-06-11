# Build Rules
<!-- Template: replace <APP_NAME>, <BUNDLE_ID>, <SIMULATOR_DEVICE>, <DEPLOYMENT_TARGET>, <TEAM_ID> -->

All commands are run from the repository root.

## Default Simulator

Use **<SIMULATOR_DEVICE>** for all development builds.

```bash
# List available simulators
xcrun simctl list devices available | grep -E "iPhone|iPad"
```

## Clean Build

```bash
xcodebuild clean \
  -project <APP_NAME>.xcodeproj \
  -scheme <APP_NAME> \
  -configuration Debug

# Or remove DerivedData entirely (faster for a full clean)
rm -rf ~/Library/Developer/Xcode/DerivedData/<APP_NAME>-*
```

## Build — Debug

Standard development build. Only the active architecture is compiled.

```bash
xcodebuild build \
  -project <APP_NAME>.xcodeproj \
  -scheme <APP_NAME> \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=<SIMULATOR_DEVICE>'
```

Expected output ends with `** BUILD SUCCEEDED **`.

## Build — Release

Production build. All architectures compiled.

```bash
xcodebuild build \
  -project <APP_NAME>.xcodeproj \
  -scheme <APP_NAME> \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator'
```

## Archive

```bash
xcodebuild archive \
  -project <APP_NAME>.xcodeproj \
  -scheme <APP_NAME> \
  -configuration Release \
  -archivePath build/<APP_NAME>.xcarchive
```

## Export IPA

```bash
xcodebuild -exportArchive \
  -archivePath build/<APP_NAME>.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist
```

## Dependency Management

Document which package manager(s) are used and any setup commands required.

```bash
# SPM: xcodebuild resolves packages automatically on first build
# CocoaPods: pod install
# Carthage: carthage update --use-xcframeworks
```

## Simulator Commands

```bash
# Boot a simulator
xcrun simctl boot "<SIMULATOR_DEVICE>"

# Open Simulator.app
open -a Simulator

# Install the built app
xcrun simctl install booted \
  "$(xcodebuild -showBuildSettings \
    -project <APP_NAME>.xcodeproj \
    -scheme <APP_NAME> \
    -configuration Debug \
    -destination 'platform=iOS Simulator,name=<SIMULATOR_DEVICE>' \
    | grep ' BUILT_PRODUCTS_DIR' | awk '{print $3}')/<APP_NAME>.app"

# Launch the app
xcrun simctl launch booted <BUNDLE_ID>

# Capture a screenshot
xcrun simctl io booted screenshot screenshot.png

# Terminate the app
xcrun simctl terminate booted <BUNDLE_ID>

# Erase simulator (factory reset)
xcrun simctl erase "<SIMULATOR_DEVICE>"
```

## Build Settings Reference

| Setting | Value |
|---|---|
| `SWIFT_VERSION` | 5 / 6 (project-specific) |
| `IPHONEOS_DEPLOYMENT_TARGET` | `<DEPLOYMENT_TARGET>` |
| `PRODUCT_BUNDLE_IDENTIFIER` | `<BUNDLE_ID>` |
| `DEVELOPMENT_TEAM` | `<TEAM_ID>` |
| `TARGETED_DEVICE_FAMILY` | 1 (iPhone) / 1,2 (iPhone + iPad) |

## Secrets

If the project uses secrets (API keys, tokens):

1. Store secrets in a gitignored xcconfig file (e.g. `Configuration/Secrets.xcconfig`).
2. Provide a template at `Configuration/Secrets.xcconfig.template`.
3. Inject secrets into `Info.plist` via xcconfig entries.
4. Read in code via `Bundle.main.object(forInfoDictionaryKey:)`.
5. On CI, write the xcconfig from a repository secret in a pre-build step.

## Common Build Failures

| Error | Cause | Fix |
|---|---|---|
| Secret key missing | xcconfig file not created | Copy the template and fill in values |
| Module not found | Wrong scheme or configuration | Verify `-scheme` matches exactly |
| Swift concurrency warnings as errors | Strict concurrency mode enabled | Ensure all async code uses `await` and respects actor isolation |
| Provisioning profile not found | Team ID or bundle ID mismatch | Check `DEVELOPMENT_TEAM` and `PRODUCT_BUNDLE_IDENTIFIER` |
