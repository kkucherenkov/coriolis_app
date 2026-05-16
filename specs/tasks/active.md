# Active tasks

## T-2026-05-16-PHASE-8-STREAM-D — Phase 8 / Stream D — Chat UI (web + mobile)

- Created: 2026-05-16
- Owner: claude
- Branch: `feat/phase-8/stream-d-chat-ui` (not yet cut)
- Spec: [docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md](../../docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md) §Stream D
- Plan: [docs/superpowers/plans/2026-05-16-phase-8-stream-d.md](../../docs/superpowers/plans/2026-05-16-phase-8-stream-d.md) (13 tasks; one block = one PR commit; subagent-driven)
- Goal: ship the full chat surface across web (`@app/ui` + `apps/web`) + mobile (`apps/mobile/lib/features/sessions`) on top of the REST + Centrifugo + Prisma contract delivered in Stream C — broadcast, whispers, edit, soft-delete, block UI, per-session unread cursors, and system messages.
- Spec diff: none (OpenAPI stays at `1.8.0`, AsyncAPI stays at `0.12.0` — Stream C's surface is sufficient).
- Codegen impact: none (no spec change).
- Design impact: 4 new color tokens — `--chat-bubble-author-bg`, `--chat-bubble-other-bg`, `--chat-system-fg`, `--chat-whisper-accent` in `specs/design/tokens/color.json`. `pnpm design:build` regenerates consumers.
- i18n impact: new `chat.*` namespace (~24 keys including 7 system-message keys) in web SFC `<i18n>` blocks + `apps/mobile/lib/i18n/chat_{en,ru,uk}.i18n.json`. `pnpm check:i18n` parity must stay green.
- Task inventory: T-11.5.1.a–i + T-11.6.1.a–b + T-11.6.2.d + T-11.6.3.a + T-11.7.1.a–d from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Sub-blocks (each = one PR commit on the Stream-D branch):
  - [ ] Block 0 — Pre-flight: branch + baseline test sweep
  - [ ] Block 1 — Design tokens (`color.chat.*` × 4) + `pnpm design:build`
  - [ ] Block 2 — Backend system-message subscribers (`MemberJoinedEvent` / `MemberLeftEvent` / `MemberKickedEvent` / `RollPushedEvent` → `PostSystemMessageCommand`) + e2e
  - [ ] Block 3 — `@app/ui` chat atoms × 5 (`AppChatAvatar`, `AppChatConnectionPip`, `AppChatPresenceDot`, `AppChatDayDivider`, `AppChatNewMessagesPill`)
  - [ ] Block 4 — `AppChatMessage` (4 variants + kebab) + `AppChatComposer` (⌘/Ctrl+Enter, counter)
  - [ ] Block 5 — `AppChatTab` + `AppChatTabStrip` (3 visible + overflow) + `AppWhisperPicker`
  - [ ] Block 6 — `AppChatPanel` (primary + docked, auto-scroll, pill)
  - [ ] Block 7 — Web `useSessionChatRealtime` composable + `useChatStore` Pinia store + specs
  - [ ] Block 8 — Mount: player `/app/sessions/[id]` + GM `/app/game-sessions/[id]` + `chat.*` i18n (EN + RU)
  - [ ] Block 9 — Mobile chat widgets + `ChatBloc` + bottom-tab integration + i18n (EN + RU + UK) + golden tests
  - [ ] Block 10 — Block-UI affordance: kebab "Block in this session" + confirm + picker filter (web + mobile)
  - [ ] Block 11 — a11y + reduced-motion sweep (Storybook a11y panel green on 11 components)
  - [ ] Block 12 — Integration regressions (web + mobile) + manual smoke recipe
  - [ ] Block 13 — Archive + Forgejo PR
- Effort estimate: ~7–8 days per Stream D budget in the implementation design (§6).
- Status: in-progress (plan landed; coding not started)
- Blockers: —
- Notes:
  - Backend chat REST + Centrifugo + 3 Prisma tables are already shipped in Stream C (PR #27) — Stream D does not re-touch the spec or the generated clients.
  - Per memory rule [[feedback_block_workflow]]: each block = commit + push + new session. Do NOT continue into the next block in the same context.
  - Mobile has no separate `app_ui` package — chat widgets live under `apps/mobile/lib/features/sessions/presentation/widgets/chat/` (verified during plan research).
  - The deep-link entry below stays blocked on marketing host availability — unrelated to Stream D.

## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.
