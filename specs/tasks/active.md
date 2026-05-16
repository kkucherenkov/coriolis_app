# Active tasks

## T-2026-05-17-PHASE-7-MOBILE-OFFLINE-4 — NPC offline cache

- Created: 2026-05-17
- Owner: claude
- Spec: PRD §11 Phase 7 — "Offline support (web SW + Flutter SQLite)" · IMPLEMENTATION_PLAN.md Feature 10.2; follow-up #1 from T-2026-05-17-PHASE-7-MOBILE-OFFLINE-3.
- Goal: extend the OFFLINE-3 read-cache pattern to NPCs so the GM combat picker survives a network drop at the table.
- Acceptance:
  - Offline `GET /npcs` falls back to last-cached list via `DioException.connectionError|connectionTimeout|sendTimeout|receiveTimeout`; empty cache returns `[]` (valid list-view offline state); non-network errors propagate.
  - Drift `AppDatabase` `schemaVersion` 3 → 4; `onUpgrade` adds `NpcsCache`.
  - `NpcsCacheInterceptor` write-through on `GET /npcs` 200; iterates `data.items` and writes each `api_client.Npc` to cache; all errors swallowed.
  - DI: `LocalNpcCache` singleton + `CachedNpcRepository` decorator wired in `injector.dart`; `buildDio` installs the interceptor; `configureDependenciesForTesting` accepts the new optional cache.
- Spec diff: none.
- Codegen impact: no.
- Design impact: none.
- Tests: 4 Drift round-trip + 1 mapper + ~5 cached repo + ~5 interceptor + 1 DI integration = ~16 new tests.
- Sub-steps:
  - [ ] Block 1 — Drift schema v4 + `LocalNpcCache` port + `DriftNpcCache` adapter + 4 round-trip tests + schema smoke test bumped to v4
  - [ ] Block 2 — `NpcApiMapper` extraction + `CachedNpcRepository` decorator + `NpcsCacheInterceptor` + DI wiring + ~12 tests
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
