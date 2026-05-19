# Active tasks

## T-2026-05-19-004 — Phase 8.5 follow-up #11: encounter lifecycle system messages (backend)

- Created: 2026-05-19
- Status: in-progress
- Owner: claude
- Branch: `feat/chat-system-encounter-events`
- Goal: Emit `EncounterStartedEvent`, `RoundAdvancedEvent`, `EncounterEndedEvent` from their handlers and subscribe to them in ChatModule to produce system messages in session broadcast chat. i18n already shipped on both clients.
- Scope: Backend only — three new domain events, two handler emit sites, three new subscribers, wiring in ChatModule, unit + e2e specs, doc tick for #3 + #11.
- Checklist:
  - [ ] Create `encounter-started.event.ts`, `round-advanced.event.ts`, `encounter-ended.event.ts`
  - [ ] Emit events from `update-encounter.handler.ts` (setup→active, active→ended)
  - [ ] Emit event from `advance-round.handler.ts`
  - [ ] Add three subscribers to `system-message.subscriber.ts`
  - [ ] Wire subscribers in `chat.module.ts`
  - [ ] Add three `describe` blocks in `system-message.subscriber.spec.ts`
  - [ ] Add three e2e scenarios in `chat-system-messages.e2e-spec.ts`
  - [ ] Tick follow-up #3 and #11 in `docs/done/phase-8.md`
  - [ ] lint / typecheck / test green

## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.
