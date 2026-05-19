# Active tasks

## T-2026-05-19-003 — Phase 8.5 follow-up #6 / Block 3: chat presence (mobile)

- Created: 2026-05-19
- Status: in-progress
- Owner: claude
- Branch: `feat/realtime-presence-block-3-mobile`
- Goal: Wire Centrifugo presence into the mobile chat UI — new `AppChatPresenceDot` atom in `packages/ui_flutter`, a `ChatPresenceService` interface + impl in `apps/mobile`, `ChatBloc` presence stream wiring, and `ChatTabStrip` dot rendering.
- Depends-on: PR #50 (Block 1 — backend flips presence on, JWT carries `info` claim).

### Checklist

- [x] `packages/ui_flutter/lib/src/widgets/app_chat_presence_dot/app_chat_presence_dot.dart` — atom with `AppChatPresence` enum
- [x] Export from `packages/ui_flutter/lib/src/widgets/widgets.dart`
- [x] `packages/ui_flutter/test/widgets/app_chat_presence_dot_test.dart` — widget tests (5 tests)
- [x] `apps/mobile/lib/features/sessions/domain/chat_presence_service.dart` — interface
- [x] `apps/mobile/lib/features/sessions/data/chat_presence_service_impl.dart` — Centrifugo impl
- [x] `apps/mobile/lib/features/sessions/presentation/blocs/chat/chat_event.dart` — `ChatPresenceUpdated`
- [x] `apps/mobile/lib/features/sessions/presentation/blocs/chat/chat_state.dart` — `onlineMembershipIds` in `ChatReady`
- [x] `apps/mobile/lib/features/sessions/presentation/blocs/chat/chat_bloc.dart` — wire presence stream
- [x] `apps/mobile/lib/features/sessions/presentation/widgets/chat/chat_tab_strip.dart` — render dot
- [x] `apps/mobile/lib/features/sessions/presentation/widgets/chat/chat_panel.dart` — forward `onlineMembershipIds`
- [x] Tests: presence service (15), bloc presence (4), tab strip presence (4); updated existing bloc tests

## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.
