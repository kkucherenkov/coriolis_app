# Active tasks

## T-2026-05-17-PHASE-7-DRIFT-SCHEMA-VERIFIER — Real Drift migration tests via `SchemaVerifier`

- Created: 2026-05-17
- Owner: claude
- Spec: PRD §11 Phase 7 — "Offline support (web SW + Flutter SQLite)"; follow-up #2 from T-2026-05-17-PHASE-7-MOBILE-OFFLINE-3.
- Goal: replace the v4 schema "table presence" smoke test in `app_database_test.dart` with real `SchemaVerifier`-based migration tests that prove `onUpgrade` correctly migrates data from every prior version to the current one.
- Acceptance:
  - `drift_dev` is a dev_dependency in `apps/mobile/pubspec.yaml` (it almost certainly already is — confirm first; this task should NOT add a new dependency if it's already present).
  - `apps/mobile/drift_schemas/` directory exists with JSON snapshots for `schema_v1.json`, `schema_v2.json`, `schema_v3.json`, `schema_v4.json`.
  - Generated verifier file (e.g. `apps/mobile/test/shared/cache/generated/schema.dart`) regenerates cleanly via `dart run drift_dev schema generate drift_schemas test/shared/cache/generated`.
  - Real migration tests in `apps/mobile/test/shared/cache/app_database_migration_test.dart`:
    - v1 → v4 (fresh user upgrading through every arm); writes a v1-shape character row at v1, verifies after migration that the row survives and that `PendingMutations`, `ShipsCache`, `GameSessionsCache`, `PlayerMembershipsCache`, `NpcsCache` all exist and are empty.
    - v2 → v4 (PR #21 user).
    - v3 → v4 (PR #22 user).
    - v3 → v4 with a `CharactersCache` row + `PendingMutations` row written at v3 — both must survive the migration to v4 with byte-identical payloads.
  - The old "current schema exposes every cache table at v4" smoke test in `app_database_test.dart` is removed (now covered by the v1→v4 fresh migration test).
- Spec diff: none.
- Codegen impact: no API codegen; new Drift schema-verifier .dart file generated from JSON snapshots in a separate codegen-only commit.
- Design impact: none.
- Tests: ~4 migration tests (one per starting version); smoke test deleted.
- Sub-steps:
  - [ ] Snapshot dump: produce `schema_v1.json` … `schema_v4.json` (hand-write or generate by temporarily editing `AppDatabase` to expose each historical version; document the chosen approach in the commit body).
  - [ ] Generate the verifier file via `drift_dev schema generate`.
  - [ ] Write migration test file; delete the old smoke test.
  - [ ] Verify the test fails when an `onUpgrade` arm is intentionally broken (sanity check; revert before commit).
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
