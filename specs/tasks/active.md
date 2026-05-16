# Active tasks

## T-2026-05-17-PHASE-8-STREAM-C — Phase 8 / Stream C — Chat backend (REST + Centrifugo + block list + read cursors)

- Created: 2026-05-17
- Status: in-progress
- Owner: claude
- Branch: `feat/phase-8/stream-c-chat-backend`
- Spec: [docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md](../../docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md) §Stream C
- Plan: [docs/superpowers/plans/2026-05-17-phase-8-stream-c.md](../../docs/superpowers/plans/2026-05-17-phase-8-stream-c.md) (10 tasks, subagent-driven)
- Task inventory: T-11.3.1.a–g + T-11.4.1.a–c + T-11.4.1.h + T-11.5.1.g + T-11.6.2.a–c + T-11.6.3.a from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Goal: ship the REST + Centrifugo + Prisma backend for session-scoped chat (broadcast + whispers + per-session block list + read cursors), so Stream D's UI can mount against a stable contract.
- Exclude: chat UI (Stream D); system-message handlers for member-join/roll-pushed (Stream D / Feature 11.7); `characterIds` cleanup (Stream E).
- Sub-blocks (tracked via TodoWrite #1–#10; one block = one PR commit):
  - [ ] Block 1 — OpenAPI 1.7.0→1.8.0 + AsyncAPI 0.11.0→0.12.0 + codegen
  - [ ] Block 2 — Prisma migration (ChatMessage + ChatReadCursor + ChatBlock)
  - [ ] Block 3 — ChatModule domain (errors, ports, read models, mapper, cursor codec, AppConfig.chat)
  - [ ] Block 4 — ChatModule infra (3 Prisma repos + in-memory rate limiter)
  - [ ] Block 5 — Commands TDD (7: post / edit / delete / post-system / mark-read / block / unblock)
  - [ ] Block 6 — Queries TDD (4: list messages / list conversations / get message / list blocks)
  - [ ] Block 7 — Realtime events + ChatRealtimePublisher + ACL widening for 3 channel families
  - [ ] Block 8 — Controllers + module wiring (10 REST routes)
  - [ ] Block 9 — Integration + smoke (whisper privacy, realtime privacy, rate-limit burst)
  - [ ] Block 10 — Archive + PR

## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.
