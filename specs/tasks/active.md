# Active tasks

## T-2026-05-20-003 — Phase 8.5 follow-up #12: backend RealtimeRouter abstraction

- Created: 2026-05-20
- Status: in-progress
- Goal: Introduce `RealtimeRouter` injectable that centralises channel-name construction and payload envelopes. Refactor `ChatRealtimePublisher`, `CentrifugoCombatPublisher`, `UpdateDpHandler`, and `RollPushedDpHandler` to delegate to it. Add unit spec for the router.
- Scope: `apps/backend` only — no spec changes, no client changes.
- [ ] Create branch `feat/backend-realtime-router`
- [ ] Commit 1: `RealtimeRouter` + channel helpers + unit spec
- [ ] Commit 2: refactor `ChatRealtimePublisher` to delegate
- [ ] Commit 3: refactor `CentrifugoCombatPublisher` to delegate
- [ ] Commit 4: refactor `UpdateDpHandler` + `RollPushedDpHandler` to delegate
- [ ] Commit 5: docs tick + task move

## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.
