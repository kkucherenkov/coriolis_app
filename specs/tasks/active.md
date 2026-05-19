# Active tasks

## T-2026-05-19-001 — Phase 8.5 follow-up #6 / Block 1: Centrifugo presence (backend + spec)

- Created: 2026-05-19
- Owner: claude
- Spec: `docs/done/phase-8.md` § "Deferred / open follow-ups" #6 — "Presence wiring on `AppChatTab`".
- Goal: make Centrifugo's built-in presence map carry `membershipId` per connected client so the web + mobile chat tab strips can render the existing `AppChatPresenceDot` from real data.
- Scope: **Block 1 of 3** — backend + spec only. Block 2 = web wiring (read `subscription.presence()` + join/leave, plumb to `AppChatTab`). Block 3 = mobile parity (Flutter `centrifuge_dart`). Each block ships on its own branch + PR.
- Acceptance (Block 1):
  - Centrifugo `session` namespace has `presence: true` so any connected client appears in `presence()` results on `session.<id>`.
  - Realtime token JWT carries `info: { memberships: [{ gameSessionId, membershipId }] }`; per-client presence entries expose this via `conn_info`.
  - AsyncAPI describes the presence info schema so generated clients / docs can reason about it.
- Spec diff: `packages/specs/asyncapi/centrifugo.yaml` (presence note + `RealtimeConnectInfo` component). No OpenAPI change — token shape unchanged.
- Codegen impact: yes — AsyncAPI rebundle.
- Design impact: none (Block 2 / Block 3 will use the existing `AppChatPresenceDot` + tab `presence` prop).
- Tests:
  - `apps/backend/src/modules/realtime/realtime.service.spec.ts` — assert `info.memberships` shape and that `sub` / `channels` are unchanged.
- Sub-steps:
  - [ ] Flip `presence: true` on `session` namespace in `docker/centrifugo/config.json` and restart container.
  - [ ] Inject `info.memberships` into the JWT issued by `RealtimeService.issueToken`.
  - [ ] Extend `realtime.service.spec.ts` to cover the new claim.
  - [ ] Document presence on `sessionChannel` in `packages/specs/asyncapi/centrifugo.yaml` (component + channel description).
  - [ ] `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen` → land regenerated artefacts in their own commit.
  - [ ] Precheck (lint + typecheck + backend unit).
  - [ ] Commit, push, open PR; write follow-up T-2026-05-19-002 in `active.md` for Block 2.
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
