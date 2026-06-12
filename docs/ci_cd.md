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

The iOS build requires `LETTERLY_WORKER_SCHEME` and `LETTERLY_WORKER_HOST` (the deployed Worker endpoint). These are not credentials — store them as GitHub Actions **variables** (not secrets) and write the xcconfig in a pre-build step:

```yaml
- name: Create Secrets.xcconfig
  run: |
    printf 'LETTERLY_WORKER_SCHEME = %s\nLETTERLY_WORKER_HOST = %s\n' \
      "${{ vars.LETTERLY_WORKER_SCHEME }}" \
      "${{ vars.LETTERLY_WORKER_HOST }}" \
      > Configuration/Secrets.xcconfig
```

> **Note:** The URL is split into SCHEME + HOST because `//` is the xcconfig line-comment delimiter and would silently truncate a full URL value.

Alternatively, override build settings directly:

```bash
xcodebuild build \
  -project Letterly.xcodeproj \
  -scheme Letterly \
  -configuration Debug \
  -destination '...' \
  LETTERLY_WORKER_SCHEME="https" \
  LETTERLY_WORKER_HOST="$LETTERLY_WORKER_HOST"
```

The Groq API key is stored as a Cloudflare Worker secret and is never part of the iOS build pipeline. See `docs/worker.md` for Worker deployment and secrets.

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
