# Active tasks

## T-2026-05-16-PHASE-8-STREAM-E — Phase 8 / Stream E — Cleanup of deprecated `characterIds`

- Created: 2026-05-16
- Owner: claude
- Branch: `feat/phase-8/stream-e-cleanup-characterIds`
- Spec: [docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md](../../docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md) §Stream E
- Task inventory: T-11.8.1.a–d from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Goal: make `GameSessionMembership` the single source of truth for "who is at this table" — strip the legacy `characterIds` array + `CharacterGameSession` join table + the GM-only assign/unassign endpoints; web/mobile Crew tab sources rows from `memberships[]`.
- Acceptance:
  - `rg "characterIds" apps/backend/src apps/web/app apps/mobile/lib` returns nothing meaningful (only docs/comments referencing prior deprecation).
  - OpenAPI `GameSession` schema no longer carries `characterIds`. OpenAPI minor bumped.
  - `POST /api/v1/game-sessions/:id/characters` + `DELETE /api/v1/game-sessions/:id/characters/:characterId` removed.
  - Web GM "Characters" panel rewritten to render `memberships[]`. Empty-state copy: "Share your invite link to bring players to the table."
  - Web GM sessions list count from `memberships.length`, not `characterIds.length`.
  - Mobile session detail + list mirrors the web behaviour.
  - Prisma migration: backfill GM membership's `characterId` from the join table (first character per session if any), then drop `character_game_session` table.
  - Codegen-drift CI green; all test sweeps green.
- Spec diff: OpenAPI 1.8.0 → 1.9.0 (GameSession.characterIds removed; 2 operations removed; AssignCharacterToSession schema removed). AsyncAPI unchanged.
- Codegen impact: yes — regenerate `api-client-{ts,dart}` in its own commit.
- Design impact: none (no new tokens or components).
- Tests:
  - Backend unit specs for assign/unassign handlers deleted; remaining specs purged of `characterIds` fixture field.
  - `GameSessionAccessService.isMember` rewritten to consult memberships (existing membership-based test in encounters module still applies).
  - Migration runs clean on local DB; backfill verified manually.
- Sub-steps (one block = one commit):
  - [ ] Block 1 — Branch + active.md entry
  - [ ] Block 2 — OpenAPI 1.8.0 → 1.9.0 + codegen (own commit)
  - [ ] Block 3 — Backend strip: handlers/commands/ports/controller routes, `GameSessionRepo` mapping, `GameSessionAccessService` rewritten to memberships, fixtures
  - [ ] Block 4 — Web rewire: `useGameSessionsApi`, GM session detail Characters panel, sessions list count, `EncounterPanel` / `CombatTracker` source PCs from memberships
  - [ ] Block 5 — Mobile rewire: `GameSession` entity, mapper, sessions list/detail, combat fixture
  - [ ] Block 6 — Prisma migration: backfill GM membership.characterId → drop `character_game_session` table + relation
  - [ ] Block 7 — Acceptance grep + full test sweep + archive + PR
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
