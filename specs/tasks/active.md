# Active tasks

## T-2026-05-16-PHASE-7-MOBILE-OFFLINE-1 — Phase 7 / Feature 10.2 block 1 — Drift + character read-cache

- Created: 2026-05-16
- Owner: claude
- Spec: PRD §11 Phase 7 — "Offline support (web SW + Flutter SQLite)" · IMPLEMENTATION_PLAN.md Feature 10.2 (T-10.2.a)
- Plan: [docs/superpowers/plans/2026-05-16-phase-7-mobile-offline-foundation.md](../../docs/superpowers/plans/2026-05-16-phase-7-mobile-offline-foundation.md)
- Goal: a player who loses connectivity at the table can still open any character they had loaded once. Drift-backed local cache + Dio interceptor for write-through + repository decorator for read-fallback.
- Codegen impact: no (no spec changes)
- Sub-steps:
  - [x] Task 1 — add `drift` / `drift_flutter` / `sqlite3_flutter_libs` / `path_provider` / `drift_dev` deps (`0b67829`)
  - [x] Task 2 — `AppDatabase` + `CharactersCache` table + Drift in-memory smoke (`bcf6c9d` + `01c63ef` + `dfc3f8b`)
  - [x] Task 3 — extract `CharacterApiMapper` (`8c89d23`)
  - [x] Task 4 — `LocalCharacterCache` port + `DriftCharacterCache` adapter (`60f160d`)
  - [x] Task 5 — `CachedCharacterRepository` decorator (`ecbbf59`)
  - [x] Task 5b — `CharacterCacheInterceptor` (`a4f6e2d`)
  - [x] Task 6 — DI wiring + test overload (`e5f6a32`)
  - [ ] Task 7 — manual offline smoke on emulator (pending human run)
  - [ ] Task 8 — archive to done.md + push + open PR
- Status: in-review — implementation complete (284/284 mobile tests green, analyzer clean); awaiting manual offline smoke on a device before archive
- Blockers: —
- Follow-up blocks for Phase 7 closeout (file as separate tasks when this block ships):
  - Mobile offline write-queue (mirrors web T-2026-05-11-008)
  - Offline caches for ships / NPCs / game sessions / player sessions
  - Mobile cold-start profile (Feature 10.4.c)
  - `docs/done/phase-7.md` + README beta badge + `phase-7-complete` tag (Feature 10.5.e)

## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.
