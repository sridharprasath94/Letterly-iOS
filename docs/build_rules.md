# Build Rules

All commands are run from the repository root: `/Users/sridharprasath/xcodeProjects/Letterly`

## Default Simulator

Use **iPhone 17 Pro** for all development builds. Substitute any available iOS 26 simulator if needed.

```bash
# List available simulators
xcrun simctl list devices available | grep -E "iPhone|iPad"
```

## Clean Build

Removes DerivedData for this project and rebuilds from scratch.

```bash
xcodebuild clean \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -configuration Debug

# Or remove DerivedData entirely (faster for a full clean)
rm -rf ~/Library/Developer/Xcode/DerivedData/Letterly-*
```

## Build — Debug

Standard development build. Only the active architecture is compiled (`ONLY_ACTIVE_ARCH = YES`).

```bash
xcodebuild build \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Expected output ends with `** BUILD SUCCEEDED **`.

## Build — Release

Production build for archiving or release testing. All architectures are compiled.

```bash
xcodebuild build \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator'
```

## Archive (for App Store distribution)

```bash
xcodebuild archive \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -configuration Release \
  -archivePath build/Letterly.xcarchive
```

## Export IPA

After archiving, export using an `ExportOptions.plist`:

```bash
xcodebuild -exportArchive \
  -archivePath build/Letterly.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist
```

## Dependency Management

No external dependencies. No commands needed.

```bash
# SPM: not used
# CocoaPods: not used
# Carthage: not used
```

## Simulator Commands

```bash
# Boot a simulator
xcrun simctl boot "iPhone 17 Pro"

# Open Simulator.app
open -a Simulator

# Install the built app
xcrun simctl install booted \
  "$(xcodebuild -showBuildSettings \
    -project Letterly.xcodeproj \
    -scheme Letterly \
    -configuration Debug \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    | grep ' BUILT_PRODUCTS_DIR' | awk '{print $3}')/Letterly.app"

# Launch the app
xcrun simctl launch booted com.flash.Letterly

# Capture a screenshot
xcrun simctl io booted screenshot screenshot.png

# Terminate the app
xcrun simctl terminate booted com.flash.Letterly

# Erase simulator (factory reset)
xcrun simctl erase "iPhone 17 Pro"
```

## Build Settings Reference

| Setting | Value |
|---|---|
| `SWIFT_VERSION` | 5.0 (project file) / actual compiler: Swift 6.3.2 |
| `IPHONEOS_DEPLOYMENT_TARGET` | 26.4 |
| `PRODUCT_BUNDLE_IDENTIFIER` | com.flash.Letterly |
| `DEVELOPMENT_TEAM` | 33QM83J9WR |
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | MainActor |
| `SWIFT_APPROACHABLE_CONCURRENCY` | YES |
| `ENABLE_USER_SCRIPT_SANDBOXING` | YES |
| `TARGETED_DEVICE_FAMILY` | 1,2 (iPhone + iPad) |

## Common Build Failures

| Error | Cause | Fix |
|---|---|---|
| `LETTERLY_WORKER_HOST` missing | `Secrets.xcconfig` not created | Run `cp Configuration/Secrets.xcconfig.template Configuration/Secrets.xcconfig` and set `LETTERLY_WORKER_SCHEME` + `LETTERLY_WORKER_HOST` |
| `Module 'Letterly' not found` | Wrong scheme or configuration selected | Verify `-scheme Letterly` is passed |
| Swift concurrency warnings treated as errors | Strict concurrency mode | Ensure all new async code uses `await` and respects actor isolation |
