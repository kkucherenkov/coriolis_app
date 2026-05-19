# Active tasks

## T-2026-05-19-002 — Phase 8.5 follow-up #6 / Block 2: chat presence (web)

- Created: 2026-05-19
- Status: in-progress
- Owner: claude
- Branch: `feat/realtime-presence-block-2-web`
- Trigger: Block 1 (PR #50) landed backend presence support. This block wires
  the Centrifugo presence API into the web client so `AppChatTab` can show a
  live online dot for whisper partners.
- Scope: **Block 2 of 3** — web only. Block 3 (mobile) ships as a separate follow-up.
- Checklist:
  - [ ] `useSessionPresence` composable (new file next to `useSessionRealtime.ts`)
  - [ ] `RealtimeConnectInfo` local interface + membership-filtered online set
  - [ ] `presence?` field added to store's `ChatTabModel` interface
  - [ ] `[id].vue` — `tabs` derived with presence, `pickableMembers` presence live
  - [ ] Vitest specs covering snapshot, join, leave, multi-client, malformed, stop
  - [ ] `pnpm typecheck`, `pnpm test`, `pnpm lint:fast` all green

## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.
