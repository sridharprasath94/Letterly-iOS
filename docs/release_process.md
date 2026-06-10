# Release Process

## Versioning

| Setting | Location | Current |
|---|---|---|
| `MARKETING_VERSION` | `project.pbxproj` | 1.0 |
| `CURRENT_PROJECT_VERSION` (build number) | `project.pbxproj` | 1 |

Increment `MARKETING_VERSION` (e.g. 1.0 → 1.1) for user-visible releases.  
Increment `CURRENT_PROJECT_VERSION` for every App Store submission.

## Pre-Release Checklist

- [ ] All features for this version are merged to `main`
- [ ] Build succeeds in Release configuration
- [ ] All tests pass (when test target exists)
- [ ] App launches and all three game modes work in Release build on Simulator
- [ ] App tested on a physical device (at least iPhone)
- [ ] `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` updated
- [ ] `Secrets.xcconfig` contains a valid production `GROQ_API_KEY`
- [ ] `Secrets.xcconfig` is **not** committed to git
- [ ] App icon is present in `Assets.xcassets/AppIcon.appiconset` for all required sizes
- [ ] Privacy manifest / usage descriptions reviewed if new permissions were added

## Build for Release

```bash
# Clean
xcodebuild clean \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -configuration Release

# Archive
xcodebuild archive \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -configuration Release \
  -archivePath build/Letterly.xcarchive \
  -allowProvisioningUpdates

# Export
xcodebuild -exportArchive \
  -archivePath build/Letterly.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist \
  -allowProvisioningUpdates
```

## ExportOptions.plist (App Store)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>33QM83J9WR</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

## App Store Connect Upload

Option A — Xcode Organizer: Open `Letterly.xcarchive` in the Organizer (Window → Organizer), click "Distribute App", follow the wizard.

Option B — `altool` / `xcrun notarytool`:

```bash
xcrun altool --upload-app \
  -f build/export/Letterly.ipa \
  -t ios \
  -u your@apple.id \
  -p "@keychain:AC_PASSWORD"
```

Option C — Fastlane deliver (recommended for repeatability).

## Post-Release

- [ ] Tag the release commit: `git tag v1.0.0 && git push --tags`
- [ ] Create a GitHub release with release notes
- [ ] Monitor crash reports in Xcode Organizer / Crashlytics (if added)
- [ ] Increment `CURRENT_PROJECT_VERSION` in `project.pbxproj` immediately after submission to avoid re-using the same build number
