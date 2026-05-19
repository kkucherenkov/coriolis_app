# Active tasks

## T-2026-05-19-006 — Phase 8.5 follow-up #8: chat route-level integration tests (web + mobile)

- Created: 2026-05-19
- Owner: claude
- Goal: Add page/route-level integration tests for the chat surface inside the session-detail page on both web (vitest, happy-dom) and mobile (Flutter `integration_test`). Stubs at SDK + Centrifuge / repository + presence boundaries only — no real network or websocket.
- Spec diff: none — tests-only block.
- Codegen impact: none.
- Sub-steps:
  - [ ] Web: scaffold `apps/web/app/pages/__tests__/game-session-chat-integration.spec.ts` with the four scenarios (mount, broadcast send, whisper switch, presence dot).
  - [ ] Mobile: scaffold `apps/mobile/integration_test/chat_panel_integration_test.dart` (folder + entry) with the three scenarios (boot, send, switch).
  - [ ] Verify web vitest + mobile flutter test green; no spec drift.
  - [ ] Mark Phase 8.5 follow-up #8 shipped in `docs/done/phase-8.md`.
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
