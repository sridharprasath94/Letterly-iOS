# CI/CD

## Current State

No CI/CD pipeline exists. Builds and tests are run manually on the developer's machine.

## Recommended Pipeline

The following describes a GitHub Actions pipeline suited to this project's structure.

### Triggers

- Push to `main`
- Pull request targeting `main`

### Jobs

#### 1. Build

```yaml
- name: Build
  run: |
    xcodebuild build \
      -project Letterly.xcodeproj \
      -scheme Letterly \
      -configuration Debug \
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
      | xcpretty && exit ${PIPESTATUS[0]}
```

#### 2. Test (once test target exists)

```yaml
- name: Test
  run: |
    xcodebuild test \
      -project Letterly.xcodeproj \
      -scheme Letterly \
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
      | xcpretty && exit ${PIPESTATUS[0]}
```

#### 3. Archive (release branch or tag only)

```yaml
- name: Archive
  run: |
    xcodebuild archive \
      -project Letterly.xcodeproj \
      -scheme Letterly \
      -configuration Release \
      -archivePath build/Letterly.xcarchive
```

### Secret Management

The `GROQ_API_KEY` must be injected before building. Add it as a GitHub Actions secret and write the xcconfig in a pre-build step:

```yaml
- name: Create Secrets.xcconfig
  run: |
    echo "GROQ_API_KEY = ${{ secrets.GROQ_API_KEY }}" \
      > Configuration/Secrets.xcconfig
```

Alternatively, override the build setting directly:

```bash
xcodebuild build \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -configuration Debug \
  -destination '...' \
  GROQ_API_KEY="$GROQ_API_KEY"
```

### Recommended Runner

Use `macos-15` (or latest macOS runner with Xcode 26.x available). Check GitHub's available runner images for the correct macOS + Xcode version pairing.

```yaml
runs-on: macos-15
```

Select the correct Xcode version:

```yaml
- name: Select Xcode
  run: sudo xcode-select -s /Applications/Xcode_26.5.app
```

### Caching

Cache DerivedData to speed up incremental builds:

```yaml
- name: Cache DerivedData
  uses: actions/cache@v4
  with:
    path: ~/Library/Developer/Xcode/DerivedData
    key: ${{ runner.os }}-deriveddata-${{ hashFiles('Letterly.xcodeproj/project.pbxproj') }}
    restore-keys: |
      ${{ runner.os }}-deriveddata-
```

## Code Signing (Distribution)

For App Store distribution, configure automatic signing with a Distribution certificate and provisioning profile stored as GitHub secrets. Use `xcodebuild -exportArchive` with an `ExportOptions.plist`.

Recommended tool: **Fastlane Match** for certificate and profile management across machines and CI.

## Recommended Tools

| Tool | Purpose |
|---|---|
| `xcpretty` | Human-readable `xcodebuild` output |
| `xcbeautify` | Alternative to xcpretty with better colour output |
| Fastlane | Automate App Store uploads, Match for code signing |
| SwiftLint | Lint Swift code style on CI |
| Danger | Automated PR checks (size, test coverage, etc.) |

## Immediate CI Priority

1. Add a `LetterlyTests` unit test target
2. Set up GitHub Actions with the build job above
3. Gate PRs on passing build
4. Add the test job when tests exist
