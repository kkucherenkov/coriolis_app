# Product-facing README + screenshots — design

- **Date:** 2026-05-16
- **Status:** approved (user accepted approach C × Desktop+Mobile)
- **Author:** Claude (caveman style)
- **Scope:** Replace dev-only top of `README.md` with product-facing intro
  (hero / screenshots / features) and add `README.ru.md`. Generate
  ~20 screenshots automatically through a Playwright capture script.

## Why

`README.md` today reads like a dev handbook (drift protections, codegen,
CI gates). Visitors landing on the GitHub page can't tell at a glance
_what the product does_. No screenshots exist anywhere in the repo, so
the visual quality of the work is invisible.

Goal: bring product-first content to the top while preserving the
contributor-facing material below. Add a Russian mirror.

## Out of scope

- Mobile-app (Flutter) screenshots — would require an emulator and a
  build artifact. Web-mobile viewport (414×896) captures responsive
  Nuxt only.
- Marketing copy / SEO. README is for GitHub readers.
- Translating dev sections to Russian. `README.ru.md` covers only the
  product portion; tech docs stay English.

## Architecture

### Capture script — `scripts/screenshots/capture.ts`

Standalone Playwright (TypeScript, run via `pnpm tsx`).

1. **Bootstrap:** two browser contexts — `desktop` (1280×800) and
   `mobile` (414×896, `isMobile: true`, `hasTouch: true`).
2. **Public screens** (no auth): `/`, `/login`, `/signup`.
3. **Demo user:** `POST /api/v1/auth/sign-up/email` with
   `email=demo+readme@coriolis.local`, `password`, `name`. Cookies land
   in both contexts.
4. **Seed via API** (using the same cookie jar):
   - `POST /api/v1/characters` → pre-gen Operative
   - `POST /api/v1/ships` → Free Trader
   - `POST /api/v1/npcs` → Pirate Scout
   - `POST /api/v1/game-sessions` → "The Long Night"
   - `POST /api/v1/game-sessions/{id}/dp` → `delta: 3`
   - `POST /api/v1/characters/{id}/rolls` → label "Pilot · Evade", pool 5
   - `POST /api/v1/characters/{id}/share` → returns slug for public view
5. **Authenticated screens:** `/app/dashboard`, `/app/characters`,
   `/app/characters/{id}`, `/app/ships/{id}`, `/app/npcs/{id}`,
   `/app/game-sessions/{id}`.
6. **Public share:** `/shared/character/{slug}` in a fresh (no-auth) context.
7. **Output:** `docs/screenshots/desktop/*.png` + `docs/screenshots/mobile/*.png`.
8. **Cleanup:** best-effort delete demo user. Better Auth exposes no
   self-delete; document this and let the row sit. The script is
   idempotent — re-running it with the same email returns 409, in which
   case the script signs in instead of up.

### Screens captured

| #   | Slug             | Path                       | Auth | Notes                |
| --- | ---------------- | -------------------------- | ---- | -------------------- |
| 1   | landing          | `/`                        | —    | marketing page       |
| 2   | login            | `/login`                   | —    | email + password     |
| 3   | signup           | `/signup`                  | —    | empty form           |
| 4   | dashboard        | `/app/dashboard`           | yes  | post-login           |
| 5   | characters-list  | `/app/characters`          | yes  | one seeded char      |
| 6   | character-sheet  | `/app/characters/{id}`     | yes  | hero of the README   |
| 7   | ship-sheet       | `/app/ships/{id}`          | yes  |                      |
| 8   | npc-editor       | `/app/npcs/{id}`           | yes  |                      |
| 9   | game-session     | `/app/game-sessions/{id}`  | yes  | DP=3, 1 roll visible |
| 10  | shared-character | `/shared/character/{slug}` | —    | public view          |

Each captured twice → 20 PNG. Total ~3–6 MB committed.

### README.md (English) — final structure

```
# Coriolis Companion App
  [badges]
  1-line tagline

## Screenshots                          ← new, HTML <table> grid
  desktop / mobile thumbnails per screen

## Features                             ← new, product-facing
  - Character sheets
  - Ship sheets
  - Dice + Darkness Points
  - Game sessions
  - GM tools
  - Cross-platform
  - Offline
  - i18n

## Why these guardrails                  ← existing
## Architecture at a glance              ← existing
## What's in the box                     ← existing
## Drift protections                     ← existing
## Quick start                           ← existing
## Repository layout                     ← existing
## Scripts reference                     ← existing
## Requirements                          ← existing
## Documentation                         ← existing
## Contributing / Security / License     ← existing
## Acknowledgements                      ← existing
```

### README.ru.md

Russian mirror of: hero + screenshots + features. Tail link:
"Техническая документация: [README.md](README.md) — only English."

## Data flow

```
capture.ts ──► POST /auth/sign-up/email ──► cookie
            ──► POST /characters, /ships, /npcs, /game-sessions
                /dp, /rolls, /share
            ──► page.goto + page.screenshot (10 routes × 2 contexts)
            ──► docs/screenshots/{desktop,mobile}/*.png
```

## Files to create / edit

| Action | Path                                                     |
| ------ | -------------------------------------------------------- |
| edit   | `README.md`                                              |
| create | `README.ru.md`                                           |
| create | `scripts/screenshots/capture.ts`                         |
| create | `scripts/screenshots/README.md`                          |
| create | `docs/screenshots/desktop/*.png` × 10                    |
| create | `docs/screenshots/mobile/*.png` × 10                     |
| edit   | `package.json` (root) — add `screenshots:capture` script |

## Error handling

- **Backend unreachable:** capture script asserts
  `GET /api/v1/health` returns 200 before doing anything; abort with a
  clear stderr message and exit 1.
- **Seeding 4xx:** dump response body + path; abort. Don't proceed to
  screenshots with partial data.
- **Page load timeout:** Playwright default 30s; on failure save a
  `*-error.png` and keep going for remaining screens.
- **Signup 409 (already exists):** fall back to
  `POST /api/v1/auth/sign-in/email` with the same credentials.

## Testing

- Manual: run `pnpm screenshots:capture`, eyeball each PNG.
- Lint: ESLint + Prettier on `capture.ts`.
- Not unit-tested. Script is single-purpose and re-runs in seconds.

## Risks

1. **Mobile-viewport bugs** may show up in the captured PNGs (e.g.
   cut-off menu). Mitigation: note the worst offenders in a follow-up
   task, do not block.
2. **API drift after spec changes** will break the script silently in
   the future. Mitigation: the script type-imports nothing from
   `@app/api-client-ts` — it uses raw `fetch` against documented
   endpoints, so failures will be HTTP 4xx and visible immediately.
3. **Concurrent agent** is editing mobile / deep-link stuff. README
   and `scripts/screenshots/` don't overlap. No coordination needed.

## Acceptance

- 20 PNG present in `docs/screenshots/{desktop,mobile}/`.
- `README.md` renders on github.com with screenshots inline.
- `README.ru.md` exists, links back to README.md.
- `pnpm screenshots:capture` idempotent (second run succeeds).
- All commits pass `pnpm lint` + `pnpm format --check`.
