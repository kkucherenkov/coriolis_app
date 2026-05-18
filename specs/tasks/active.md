# Active tasks

## T-2026-05-18-006 — Mobile chat edit-message inline banner parity

- Created: 2026-05-18
- Owner: claude
- Branch: `feat/mobile-chat-edit-banner`
- Trigger: Phase 8.5 follow-up #5 from `docs/done/phase-8.md` — web already
  has the "Editing message — cancel / save" banner above the chat composer
  (`AppChatComposer.vue:120-140` + state in
  `apps/web/app/pages/app/game-sessions/[id].vue:280-317`). Mobile parity
  was the gap: `chat_panel.dart:191` has `onEdit: () { TODO: show inline
  edit UI in a follow-up. }` and the `ChatMessageEditRequested` event is
  defined but never dispatched from the UI.
- Goal: mobile chat surfaces the same banner-driven edit-message flow as
  web — tapping `Edit` on a kebab menu opens a banner above the composer
  with the original body as preview, the textfield prefilled, the Send
  icon flips to a Save check, and a `Cancel` clears it. Switching tabs
  auto-cancels (mirrors `apps/web/.../[id].vue:310-317`). Backend
  `PATCH /api/v1/chat/messages/:id` is already wired through
  `ChatRepository.editMessage` — no spec / backend changes.
- Spec diff: none — backend endpoint already in spec.
- Codegen impact: no.
- Sub-steps:
  - [x] add `editingMessageId` (`String?`) + `editingPreview` (`String`) to
        `ChatReady` state; extend `copyWith` with a `clearEditing` flag
        (mirrors `clearKickBusy` pattern from T-2026-05-18-005)
  - [x] add `ChatEditStarted(messageId, body)` + `ChatEditCancelled` events
        to `chat_event.dart`
  - [x] register the two new handlers in `ChatBloc`; on edit-start prefill
        composer + populate state; on edit-cancel clear; in `_onEdit`
        (existing `ChatMessageEditRequested` handler) clear editing state
        before the API call so the banner closes optimistically; in
        `_onConversationSelected` clear editing state whenever the key
        changes
  - [x] thread `isEditing`, `editingPreview`, `onCancelEdit` props into
        `ChatComposer`; render a banner above the textfield with the
        preview line + a `Cancel` button; flip the Send `Icons.send` →
        `Icons.check` and the tooltip "Send" → "Save" while editing
  - [x] wire `chat_panel.dart`: `onEdit` dispatches `ChatEditStarted`;
        `onSubmit` checks `state.editingMessageId` and dispatches
        `ChatMessageEditRequested` vs `ChatMessageSendRequested`
  - [x] add 4 i18n keys to `chat_{en,ru}.i18n.json`:
        `composer.editing`, `composer.editing_cancel`, plus matching
        Send/Save tooltips (`composer.send` / `composer.save`) — regen
        with `dart run slang`
  - [x] bloc_test: edit-start populates state + composer; edit-cancel
        clears; edit-submit happy path clears state + patches message in
        place; tab-switch auto-cancels (6 cases in
        `apps/mobile/test/features/sessions/presentation/blocs/chat/chat_bloc_edit_banner_test.dart`)
  - [x] widget tests in `chat_composer_test.dart`: banner hidden by
        default, banner renders with label + preview + check icon when
        editing, Cancel button taps onCancelEdit, tooltip flips to Save
- Status: ready-for-review
- Blockers: —
- Verification:
  - `flutter test test/features/sessions/presentation/blocs/chat/chat_bloc_edit_banner_test.dart` → 6/6 pass.
  - `flutter test test/features/sessions/presentation/widgets/chat/chat_composer_test.dart` → 8/8 pass.
  - `flutter test` (full suite) → **464/464** pass (was 454 before, +10
    new cases).
  - `flutter analyze` clean on every file this task touched (25 pre-existing
    infos in unrelated combat-tracker test files remain — same baseline
    as PR #48).
  - `pnpm check:i18n` — `mobile: 2 locale(s) × 505 key(s)` (was 501,
    +4 new keys).
  - `pnpm format` clean.

## T-2026-05-17-DEEP-LINK-SETUP — Deep-link configuration (mobile + web)

- Created: 2026-05-16
- Status: blocked — waiting on marketing host availability
- Goal: Configure `app_links` (mobile) + `apple-app-site-association` / `assetlinks.json` (web) so that tapping an invite URL on a phone opens the native app instead of the browser.
- Gate: `APP_LINKS_HOST` env var must be live (currently unset across the monorepo — `grep -r APP_LINKS_HOST apps/ docker/` returned zero matches).
- Design ref: `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` decision #5 ("defer until host available").
- Unblocks: T-11.1.1.l from `docs/IMPLEMENTATION_PLAN_PHASE_8.md`.
- Notes: The web invite-join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5. When the marketing host is provisioned: add iOS Universal Links manifest, Android App Links assetlinks.json, and `app_links` mobile package wiring.
