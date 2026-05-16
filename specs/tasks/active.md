# Active tasks

## T-2026-05-17-PHASE-7-MOBILE-OFFLINE-3 — Phase 7 / Feature 10.2 / extension — Offline read-caches for ships, game-sessions, player-memberships

- Created: 2026-05-17
- Owner: claude
- Spec: PRD §11 Phase 7 — "Offline support (web SW + Flutter SQLite)" · IMPLEMENTATION_PLAN.md Feature 10.2 (follow-up to T-10.2.a)
- Goal: extend the character read-cache pattern to the other entities a player or GM needs at the table (ship sheet, game-session view, "playing in" membership list), so a temporary network drop at the table doesn't blank the UI.
- Acceptance:
  - Offline `GET /ships/{id}` falls back to last-cached payload via `DioException.connectionError|connectionTimeout|sendTimeout|receiveTimeout`; 4xx/5xx propagate unchanged.
  - Offline `GET /game-sessions/{id}` same fallback contract; DP / character / invite mutations invalidate the cached row on remote success.
  - Offline `GET /me/memberships` returns last-cached list; `acceptInvite` and `leaveSession` invalidate the cache on success.
  - Drift `AppDatabase` `schemaVersion` bumped 2 → 3 with `onUpgrade` that adds `ShipsCache`, `GameSessionsCache`, `PlayerMembershipsCache`.
  - All cache I/O errors swallowed by interceptors (never break network response flow).
  - **No NPCs cache in this iteration** — deferred to follow-up; NPCs feature exposes only `listNpcs` for the combat picker, low offline value.
- Spec diff: none.
- Codegen impact: no.
- Design impact: none (banner + state UI already shipped in OFFLINE-2).
- Tests:
  - Block 1 — ~12 round-trip Drift tests (4 per cache × 3 caches), migration 2→3 test.
  - Blocks 2–4 — ~28 mocktail tests (decorator read-fallback + write-invalidation per repo, interceptor write-through).
  - Block 5 — ~3 DI integration tests; full mobile sweep must stay green (currently 333/333).
- Sub-steps:
  - [ ] Block 1 — Drift schema + 3 Local*Cache ports + 3 Drift adapters + adapter tests
  - [ ] Block 2 — `ShipApiMapper` extraction + `CachedShipRepository` + `ShipCacheInterceptor` + tests
  - [ ] Block 3 — `GameSessionApiMapper` extraction + `CachedSessionRepository` + `GameSessionCacheInterceptor` + tests
  - [ ] Block 4 — `CachedPlayerSessionRepository` + `PlayerMembershipsCacheInterceptor` + tests
  - [ ] Block 5 — DI rewire (`injector.dart` + `buildDio` + `configureDependenciesForTesting`) + integration test
- Status: in-progress
- Blockers: —

## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.
