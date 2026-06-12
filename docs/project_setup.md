# Project Setup

## Prerequisites

| Requirement | Version |
|---|---|
| Xcode | 26.5 (or later) |
| Swift | 6.3.2 (bundled with Xcode 26.5) |
| iOS Deployment Target | 26.4 |
| macOS | 26.x (Sequoia) |
| Letterly Worker URL | Deployed `letterly-worker` endpoint; see `docs/worker.md` |

No package manager (SPM, CocoaPods, Carthage) is used. The project has zero external dependencies.

## First-Time Setup

### 1. Clone the repository

```bash
git clone https://github.com/sridharprasath94/Letterly.git
cd Letterly
```

### 2. Configure the Worker URL

```bash
cp Configuration/Secrets.xcconfig.template Configuration/Secrets.xcconfig
```

Edit `Configuration/Secrets.xcconfig`:

```
LETTERLY_WORKER_SCHEME = https
LETTERLY_WORKER_HOST = letterly-worker.<your-subdomain>.workers.dev
```

For local development against a running `wrangler dev` instance:

```
LETTERLY_WORKER_SCHEME = http
LETTERLY_WORKER_HOST = localhost:8787
```

`Secrets.xcconfig` is gitignored. It is consumed as the base xcconfig for both Debug and Release build configurations and injected into `Info.plist` at build time. `AppContainer` reads both keys at runtime via `Bundle.main.object(forInfoDictionaryKey:)` and assembles the URL as `scheme://host`.

> **Note:** The Worker URL is intentionally split into two keys. xcconfig treats `//` as a line-comment delimiter, which would silently truncate a full URL value.

The Groq API key is **not** required here — it lives in the Worker's Cloudflare secret store. See `docs/worker.md` for Worker setup and deployment.

### 3. Open in Xcode

```bash
open Letterly.xcodeproj
```

Select the `Letterly` scheme, choose any available iOS 26.x simulator, and press Run (⌘R).

## Project Structure

```
Letterly/
├── Configuration/
│   ├── Secrets.xcconfig          ← gitignored; create from template
│   └── Secrets.xcconfig.template ← version-controlled reference
├── Letterly/
│   ├── LetterlyApp.swift
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift        ← unused; safe to delete
│   ├── ViewController.swift       ← unused; safe to delete
│   ├── DI/
│   │   └── AppContainer.swift
│   ├── Domain/
│   │   ├── Model/
│   │   ├── Repository/
│   │   └── UseCase/
│   ├── Data/
│   │   ├── Local/
│   │   ├── Remote/
│   │   └── Repository/
│   ├── Presentation/
│   │   ├── Start/
│   │   ├── Game/
│   │   │   ├── Components/
│   │   │   ├── GameView.swift
│   │   │   └── GameViewModel.swift
│   │   └── Shared/
│   ├── Assets.xcassets
│   ├── Base.lproj/
│   ├── Letterly.xcdatamodeld      ← empty; unused
│   ├── words_5.txt                ← 5-letter word list
│   ├── words_6.txt                ← 6-letter word list
│   └── words_7.txt                ← 7-letter word list
├── Letterly.xcodeproj/
├── docs/
└── CLAUDE.md
```

## Build Configurations

| Configuration | Use |
|---|---|
| Debug | Development; DWARF debug info; no optimisation |
| Release | Distribution; stripped; optimised |

Both configurations reference `Configuration/Secrets.xcconfig` as their base.

## Scheme

One scheme: **Letterly**. No test targets exist yet.

## Word Lists

The bundled `.txt` files ship with the app. They are loaded into `WordStore` at launch by `AppDelegate`. The README states ~9,626 words across all three files.

## CI / New Machine Notes

- The `Secrets.xcconfig` file must be created before building. On CI, set `LETTERLY_WORKER_SCHEME` and `LETTERLY_WORKER_HOST` as GitHub Actions variables and write the file in a pre-build step (see `docs/ci_cd.md`). No Groq API key is required in the iOS build.
- No `pod install` or `swift package resolve` is needed.
- DerivedData is safe to delete at any time.
