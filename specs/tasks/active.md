# Active tasks

## T-2026-05-16-PHASE-8-STREAM-B — Phase 8 / Stream B — Player shell + realtime ACL

- Created: 2026-05-16
- Owner: claude
- Spec: [docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md](../../docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md) §6 Stream B
- Plan: [docs/superpowers/plans/2026-05-16-phase-8-stream-b.md](../../docs/superpowers/plans/2026-05-16-phase-8-stream-b.md) (16-phase TDD blueprint, ~52 steps; execute via `superpowers:subagent-driven-development`)
- Task inventory: [`docs/IMPLEMENTATION_PLAN_PHASE_8.md`](../../docs/IMPLEMENTATION_PLAN_PHASE_8.md) T-11.1.1.h / i / j (player half) / k / l + T-11.2.1.a–h
- Goal: a signed-in player opens an invite link, picks a character, lands on `/app/sessions/:id` (web) or the mirrored mobile page, and starts receiving `dp.changed` / `encounter.updated` realtime events.
- Acceptance:
  - Cold-open an invite link → preview → pick character → join → land on player shell (both clients).
  - GM kicks a player → player's next realtime-token issuance (after TTL ≤5 min) excludes `session.<id>` from the JWT `channels` claim.
  - Both clients receive `dp.changed` realtime when the GM increments DP.
  - Legacy redirect middleware `apps/web/app/middleware/redirect-legacy-session.global.ts` removed in the same commit that lights up `pages/app/sessions/[id].vue`.
  - Web + mobile dashboard "Playing in" segment count is real (was hard-zero after Stream A).
- Spec diff: `packages/specs/openapi/openapi.yaml` — bump 1.6.0 → 1.7.0; add `POST /invites/{token}/accept`, `GET /invites/{token}/preview`, `GET /me/memberships`; add `InvitePreview`, `MyMembershipSummary` schemas.
- Codegen impact: yes — regenerate `packages/api-client-{ts,dart}` (own commit).
- Design impact: two new `@app/ui` components — `AppSessionHeader` (mode: `player` | `gm`) extracted from GM `[id].vue`; `AppSessionJoinCard` (four states: valid / revoked / already-member / not-signed-in). Each with colocated stories + specs per design loop.
- Tests:
  - Backend: handler-spec coverage for `AcceptInvite` (5+ cases), `GetInvitePreview` (3+ cases), `GetMyMemberships` (3+ cases); RealtimeService regression for kicked-token ACL exclusion.
  - Web: vitest + @testing-library/vue specs for both new `@app/ui` components; route-guard middleware tests for player/GM cross-traffic.
  - Mobile: widget tests for `JoinSessionPage` (happy + revoked + already-member), `SessionDetailPage` layout.
  - Smoke (P16): cold-open invite flow end-to-end on web; kicked-token regression curl; both clients receive `dp.changed` over the broadened ACL.
- Sub-steps (one phase = one block = one commit + push + active.md update + STOP):
  - [x] P1 — OpenAPI spec 1.6.0 → 1.7.0 (3 new routes + 2 new schemas) + codegen (488295b + 81ac1ac + 598b732)
  - [x] P2 — Backend domain: errors + ports + read models (394642b)
  - [x] P3 — Backend infra: implement new port methods on `MembershipRepo` (24bd57a)
  - [x] P4 — `AcceptInviteCommand` TDD — 6 tests (38e3bfd)
  - [x] P5 — `GetInvitePreviewQuery` TDD — 4 tests (bd4f68e)
  - [x] P6 — `GetMyMembershipsQuery` TDD — 3 tests (367bde8)
  - [x] P7 — `RealtimeModule` ACL widening + kicked-token regression (4d2e9c8)
  - [x] P8 — Backend wiring: `InvitesController` + `MeMembershipsController` + `MembershipsModule` (9c36d31)
  - [x] P9 — `@app/ui` `AppSessionHeader` — 7 tests, 4 stories (d183856)
  - [x] P10 — `@app/ui` `AppSessionJoinCard` — 5 tests, 4 stories (7175832)
  - [x] P11 — Web player routes + route guards + delete legacy redirect (246950c + bdaaf8d)
  - [x] P12 — Web dashboard "Playing in" wiring (09683cf)
  - [x] P13 — Mobile player parallel feature folder `lib/features/sessions/` (251570e)
  - [x] P14 — Mobile dashboard "Playing in" wiring + DI + routes (5d625a5)
  - [x] P15 — Deep-link gating: APP_LINKS_HOST not configured, follow-up T-2026-05-17-DEEP-LINK-SETUP filed below
  - [ ] P16 — Smoke: end-to-end cold-open invite flow + kicked-token curl regression + `dp.changed` over broadened ACL
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
