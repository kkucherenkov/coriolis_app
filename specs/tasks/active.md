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
  - [x] Block 1 — OpenAPI 1.7.0→1.8.0 + AsyncAPI 0.11.0→0.12.0 + codegen (`6475d00` + `de72ce3`)
  - [x] Block 2 — Prisma migration (ChatMessage + ChatReadCursor + ChatBlock) — `1c376f3` (migration `20260516102812_add_chat_tables`)
  - [x] Block 3 — ChatModule domain (errors, ports, read models, mapper, cursor codec, AppConfig.chat) — `cc74169`
  - [x] Block 4 — ChatModule infra (3 Prisma repos + in-memory rate limiter) — `0de8051`, 21 specs
  - [x] Block 5 — Commands TDD (7: post / edit / delete / post-system / mark-read / block / unblock) — `b2d7a08`, `93fd1e6`, `7326f72`, `d11efde`, `c6c04bf`, `524a2e2`, `bb4ef38`, `46d85a1`
  - [x] Block 6 — Queries TDD (4: list messages / list conversations / get message / list blocks) — `ebec281`, `c26c9e5`, `4cd890f`, `063cf8d`, `46e712f`
  - [x] Block 7 — Realtime events + ChatRealtimePublisher + ACL widening for 3 channel families — `c8799de` + `b257777`
  - [x] Block 8 — Controllers + module wiring (10 REST routes) — `a96017e`
  - [x] Block 9 — Integration + smoke (privacy regression + realtime publisher e2e) — see below
  - [ ] Block 10 — Archive + PR
- Tests at Block 9: backend unit sweep **1097 / 1097 green** (115 files). New chat-module test count = 75 (incl. cursor codec, repos, rate limiter, 7 commands, 4 queries, 6 publisher tests). New e2e specs at `apps/backend/test/integration/chat-privacy.e2e-spec.ts` (7 assertions) + `apps/backend/test/integration/chat-realtime.e2e-spec.ts` (whisper-not-on-broadcast-channel assertion). E2e flakiness from Better Auth IP rate-limit (signUp returns 403 when 4 fresh accounts are created in fast succession across test files) is **pre-existing** — same pattern that the existing `realtime-dp.e2e-spec.ts` works around with a single 2s retry. Same fix is in our chat helpers. The existing `combat-publisher.e2e-spec.ts` + `realtime-dp.e2e-spec.ts` also fail under the current container with WebSocket timeouts — that is a pre-existing infrastructural issue (Centrifugo→backend publish latency), **not introduced by Stream C**.
- Manual smoke recipe (paste into a shell with valid bearer tokens):
  ```sh
  # 1. GM seeds invite + accepts as Player A.
  curl -X POST -H "Authorization: Bearer <GM>" "http://localhost:3010/api/v1/game-sessions/<S>/invite/rotate" | jq .  # → token
  curl -X POST -H "Authorization: Bearer <PA>" "http://localhost:3010/api/v1/invites/<TOKEN>/accept" | jq .          # → membership_A
  # 2. Player A POSTs broadcast.
  curl -X POST -H "Authorization: Bearer <PA>" -H 'Content-Type: application/json' \
    -d '{"kind":"text","body":"hi everyone"}' \
    "http://localhost:3010/api/v1/game-sessions/<S>/chat/messages" | jq .
  # 3. Player A whispers Player B.
  curl -X POST -H "Authorization: Bearer <PA>" -H 'Content-Type: application/json' \
    -d '{"kind":"text","body":"secret","targetMembershipId":"<B_id>"}' \
    "http://localhost:3010/api/v1/game-sessions/<S>/chat/messages" | jq .
  # 4. GM tries DELETE on whisper id → 404 (privacy: GM never sees the message).
  curl -X DELETE -H "Authorization: Bearer <GM>" "http://localhost:3010/api/v1/chat/messages/<W>" -w '%{http_code}\n'
  # 5. Rate limit smoke: 31 POSTs in one minute — 30 succeed, 31st returns 429.
  for i in $(seq 1 31); do
    curl -X POST -H "Authorization: Bearer <PA>" -H 'Content-Type: application/json' \
      -d "{\"kind\":\"text\",\"body\":\"msg $i\"}" \
      "http://localhost:3010/api/v1/game-sessions/<S>/chat/messages" -w "%{http_code} "
  done
  ```

## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.
