# Letterly Worker

## Purpose

`letterly-worker` is a Cloudflare Worker that proxies AI hint requests from the Letterly iOS app to the Groq API. It exists to prevent the Groq API key from being shipped inside the app binary.

## Security Rationale

API keys embedded in iOS app binaries are extractable from any IPA. By routing requests through the Worker:

- The iOS app holds only the Worker's public HTTPS URL — not a credential.
- The Groq API key is stored as a Cloudflare Worker secret, inaccessible to clients.
- Rate-limiting, request validation, or key rotation can be applied server-side without app updates.

## System Architecture

```
Letterly (iOS)
  └─ HintAPIService (URLSession POST /hint)
       └─ letterly-worker (Cloudflare)
            (GROQ_API_KEY read from Cloudflare secret store)
                 └─ Groq API (llama-3.1-8b-instant)
```

## API Contract

### `POST /hint`

**Request**

```
Content-Type: application/json
```

Body — same shape as `HintRequest` in the iOS project:

```json
{
  "model": "llama-3.1-8b-instant",
  "messages": [{ "role": "user", "content": "<prompt>" }],
  "max_tokens": 60
}
```

**Response**

The Worker forwards the Groq chat-completions response unchanged:

```json
{
  "choices": [
    { "message": { "role": "assistant", "content": "<hint text>" } }
  ]
}
```

HTTP status mirrors the upstream Groq response (200 on success; 4xx/5xx on error).

## Development

### Prerequisites

- Node.js (LTS)
- npm
- Wrangler CLI (installed via `npm install` in the project)

### Install dependencies

```bash
cd letterly-worker
npm install
```

### Run locally

```bash
npm run dev
# Worker available at http://localhost:8787
```

For local end-to-end testing, set these values in `Configuration/Secrets.xcconfig`:

```
LETTERLY_WORKER_SCHEME = http
LETTERLY_WORKER_HOST = localhost:8787
```

### Run tests

```bash
npm test
```

### Deploy to Cloudflare

```bash
npm run deploy
```

After deploying, update `Configuration/Secrets.xcconfig` with the production values:

```
LETTERLY_WORKER_SCHEME = https
LETTERLY_WORKER_HOST = letterly-worker.<your-subdomain>.workers.dev
```

Update the corresponding GitHub Actions variables (`LETTERLY_WORKER_SCHEME`, `LETTERLY_WORKER_HOST`) for CI.

## Secret Management

`GROQ_API_KEY` is stored as a Cloudflare Worker secret — never in `wrangler.jsonc` or source control.

To set or rotate the key:

```bash
npx wrangler secret put GROQ_API_KEY
```

To verify it is set (without revealing the value):

```bash
npx wrangler secret list
```

## Relationship to the Letterly iOS Project

| iOS project | Worker |
|---|---|
| Reads `LETTERLY_WORKER_SCHEME` + `LETTERLY_WORKER_HOST` from `Info.plist`; assembles URL as `scheme://host` | Exposes public HTTPS endpoint |
| Sends `HintRequest` JSON body | Forwards to Groq, injecting the API key |
| Parses `HintResponse` | Returns Groq response unchanged |

The Worker URL is injected into the iOS app via `Configuration/Secrets.xcconfig`. See `docs/project_setup.md` for iOS setup and `docs/ci_cd.md` for CI configuration.
