# Phase 8 — Player Client + Multiplayer Chat — Implementation Design

**Status:** Design (brainstorming output), pending review
**Authors:** Claude (with Kirill Kucherenkov)
**Inputs:**

- `docs/IMPLEMENTATION_PLAN_PHASE_8.md` — feature breakdown, tasks, schemas
- Design handoff bundle (unzipped to `/tmp/coriolis-handoff/coriolis-app/project/`) — JSX is the spec per project rule #8
- `specs/tasks/done.md` — current ship state at commit `7ee3454`
- Live repo at `main` — current GM route is `/app/sessions/[id]`, `GameSession` has no invite fields, no chat tables

**Scope of this document:** how to ship Phase 8 — sequencing, PR-stream decomposition, JSX-vs-plan reconciliation, resolution of the 6 open product decisions in `IMPLEMENTATION_PLAN_PHASE_8.md` §"Open product decisions", and one chat-panel view-model clarification. Implementation detail per task lives in the plan doc and in the per-stream writing-plans output that follows this design.

---

## 1. Why this design exists

The Phase 8 plan in `docs/IMPLEMENTATION_PLAN_PHASE_8.md` is feature-shaped — Features 11.1–11.8. Shipping it as one PR is unmanageable (~25 working days of code and a Prisma migration on a live `GameSession` table). Five concerns need an explicit answer before we open the first PR:

1. **PR boundaries.** Where to slice so each PR is testable, reviewable, and reversible.
2. **Open product decisions.** The plan lists 6 deliberately-unresolved decisions. Pick before any spec lands.
3. **JSX-vs-plan reconciliation.** Three places where the design handoff JSX deviates from the plan / PRD wording. Per project rule #8, JSX wins — make the deviations explicit so reviewers don't flag them as bugs.
4. **Route move.** The plan assumes GM lives at `/app/game-sessions/*`. In `main` the GM lives at `/app/sessions/*`. Phase 8 puts the player at `/app/sessions/*`. Resolve the rename before anything else.
5. **Chat-panel view model.** `PHASE_8_DESIGN_NOTES.md` §1 says whispers are "interleaved" with broadcast; §2 talks about whisper tabs with unread badges. Surface that this is per-tab interleaving (broadcast + system inside the Session tab; one A↔X thread inside a whisper tab), not one merged stream.

---

## 2. Resolution of the 6 open product decisions

The plan's §"Open product decisions (resolve before T-11.1.1.a)" lists six. Decisions:

| #   | Decision                                       | Resolution                                                                                                                                                                       | Rationale                                                                                                                                                                                                                                          |
| --- | ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | One character per player per session, or many? | **One.** Keep `(gameSessionId, userId)` unique on `GameSessionMembership`.                                                                                                       | Simpler chat attribution, simpler "My character" surface, matches handoff `gm-session.jsx` Crew row layout (one character per member).                                                                                                             |
| 2   | GM spectator mode for whispers?                | **Off. Do not model the flag.**                                                                                                                                                  | Privacy contract is explicit in the plan: "the GM cannot moderate whispers because the GM cannot read them." Adding even an off-by-default flag invites future weakening. If we ever want this, it's a new feature with its own privacy review.    |
| 3   | Player visibility into other players' HP/MP?   | **Out of scope for Phase 8.** Players see other linked-character _names_ only.                                                                                                   | The PRD/Epic H share-link model doesn't extend cleanly to player↔player; that needs its own ticket. The handoff `player-session-desktop.jsx` already renders "Other Players" as name-only rows.                                                    |
| 4   | Invite-link unauth preview contents?           | **Session name + GM display name only.** No member list, no session ID, no liveness signal.                                                                                      | Matches `PHASE_8_DESIGN_NOTES.md` §3. `session-join.jsx` enforces this — failure states (revoked / already-member / not-signed-in) all reuse the same hero shape so the boundary holds.                                                            |
| 5   | Mobile deep-link host?                         | **Defer to Phase 8.5 follow-up.** Web fallback at `/app/sessions/join/:token` works for v1.1.                                                                                    | Universal-links / app-links require a registered host serving `.well-known/apple-app-site-association` + `assetlinks.json`. Marketing host isn't live. Ship without `app_links`; the join page works as a plain web link, and users sign in there. |
| 6   | Whisper history after kick?                    | **Asymmetric per plan-default.** Kicked member loses access (no membership → no token → no GET). Partners keep readable thread. Composer disabled for them on that conversation. | Matches the privacy contract: history visibility = "did I have membership when this was written?" Kicking is forward-only. Designed pattern is well-understood; users won't be surprised.                                                          |

---

## 3. JSX deviations from plan / PRD — JSX wins

`PHASE_8_DESIGN_NOTES.md` §5 documents three deliberate JSX overrides. The implementation honours JSX (project rule #8). Make these explicit in stream tasks so reviewers don't flag them as drift.

### 3.1 Invite reveal is `role="alertdialog"`, not a toast

Plan (T-11.1.1.g): "On rotate / first generation: a one-shot **toast** reveals the URL with a `Copy` button…"

JSX (`invite-manager.jsx` lines 78–101): the `just-generated` / `just-rotated` states render `role="alertdialog"` with title, `SessionShareLinkCard`, and an explicit "I've copied it — close" button. **No auto-dismiss.**

Reason in JSX: missed-copy consequence is "rotate again and re-distribute to every player." Auto-dismiss raises that risk for zero UX gain.

Implementation: stream-A web task uses `AppModal` (the existing modal primitive) with `role="alertdialog"`, `closeOnBackdrop: false`, `closeOnEsc: false`, and a single primary CTA button.

### 3.2 GM moderation lives in the per-message kebab, not a separate moderation surface

Plan (Feature 11.3 implicit): a moderation panel for GM controls.

JSX (`chat-primitives.jsx` `ChatMessage`): the kebab menu on a broadcast message exposes Delete to the author **or** the session GM, gated by `ownByGm`. Whisper messages never expose third-party Delete (it's design-time impossible — GM can't see whispers).

Implementation: no separate moderation route. Backend `DeleteChatMessageCommand` already encodes "broadcast: author or session GM; whisper: author only" per plan T-11.3.1.a. UI just exposes this via the kebab.

### 3.3 Whisper composer placeholder is dynamic

PRD §6.4: static placeholders `"Message the session" / "Whisper"`.

JSX (`chat-panel.jsx` + `chat-primitives.jsx`): dynamic — `"Message everyone in The Mercy of Kua"` / `"Whisper to Yara Zenith"`.

Reason in JSX: users forget which tab they're typing into mid-thought. Dynamic name is a free continuous reminder.

Implementation: i18n key takes an ICU `{name}` var. Cyrillic length verified in JSX (~340px at 380px docked width).

```
chat.composer.placeholder.broadcast = "Message everyone in {sessionName}"
chat.composer.placeholder.whisper   = "Whisper to {partnerName}"
```

---

## 4. Route move — precondition for every stream

The plan presumes the GM client is already at `/app/game-sessions/*`. In `main`, it lives at `/app/sessions/*`:

- `apps/web/app/pages/app/sessions/index.vue:14` references `/app/sessions/[id]` as its detail target
- `apps/web/app/pages/app/sessions/[id].vue:461` has `<NuxtLink to="/app/sessions" class="page-session-detail__back">`

Phase 8 puts the **player** at `/app/sessions/*`. Resolve by moving GM first.

### 4.1 Web rename

- Move files: `apps/web/app/pages/app/sessions/{index,[id]}.vue` → `apps/web/app/pages/app/game-sessions/{index,[id]}.vue`.
- Grep-and-replace every internal `navigateTo('/app/sessions/...')` and `<NuxtLink to="/app/sessions">` to `/app/game-sessions/...`. Include component-level navigation in `app/components/`.
- Add Nuxt route middleware `app/middleware/redirect-legacy-session.global.ts` that intercepts `/app/sessions/:id` (when not Phase-8-player-mounted yet) and `navigateTo('/app/game-sessions/' + id, { redirectCode: 301 })`. This middleware is removed at the end of Stream B when `/app/sessions/:id` lights up for players.

### 4.2 Mobile rename

- `apps/mobile/lib/features/sessions/` (currently GM) → `lib/features/game_sessions/`.
- All Dart imports updated.
- A new `lib/features/sessions/` feature folder is created in Stream B for the player client.

### 4.3 Naming discipline

The CLAUDE.md "GameSession, never Session" rule applies to **Dart/TS class names and DB tables**. URL paths historically used `/sessions/*`; we're now committing `/game-sessions/*` for GM and `/sessions/*` for player. Document this in `AGENTS.md` so the naming policy stays consistent. _(Note: AGENTS.md edit is part of Stream A.)_

---

## 5. Chat-panel view model — clarification

`PHASE_8_DESIGN_NOTES.md` §1 says whispers and broadcast are "interleaved in the same scrolling list (Discord-style)." §2 talks about whisper tabs with unread badges. The two together are easy to misread as one merged stream.

**The actual model, per JSX `chat-panel.jsx`:** tabs **switch the visible thread**, and "interleaved" refers to what's inside each tab, not across tabs.

| Active tab         | Visible content                                                                                            |
| ------------------ | ---------------------------------------------------------------------------------------------------------- |
| `session`          | Broadcast messages + system messages, in one chronological stream. (System messages are always broadcast.) |
| `whisper-with-<X>` | Only the thread between caller and X (system messages not interleaved here — they're broadcast-only).      |

Consequence for the backend: `ListChatMessagesQuery` handles both via the existing `conversation` param (`broadcast` or `<membershipId>`). No new "merge server-side" query is needed. The web/mobile chat store maintains separate caches per conversation key.

Per-conversation unread counts derived in the existing `GET /chat/conversations` endpoint by counting messages newer than `ChatReadCursor.lastReadAt` for that conversation key.

---

## 6. PR-stream decomposition

Five sequential streams. Each is a landable PR with explicit acceptance.

### Stream A — Foundation (~5 days)

**Goal:** schema, invite endpoints, GM-side invite UI. Players cannot join yet.

**Includes:**

- T-11.1.0.a — route move (web + mobile) per §4
- T-11.1.1.a — OpenAPI: invite-rotate, invite-revoke, invite-metadata, invite-preview, invite-accept, `/me/memberships`, `/members`, member-delete, member-patch
- T-11.1.1.b — `MembershipsModule` (CQRS commands + queries + events)
- T-11.1.1.c — `GameSessionsModule.get` returns `memberships[]`
- T-11.1.1.d — 22-char URL-safe nanoid + SHA-256 hash at rest
- T-11.1.1.e — `AcceptInviteCommand` (idempotent re-accept, character-ownership check, transactional INSERT)
- T-11.1.1.f — Prisma migration: add invite fields to `GameSession`, create `GameSessionMembership`, backfill GM-role membership for every existing `GameSession`
- T-11.1.1.g — `AppInviteManager` panel on GM Overview (`@app/ui` per `invite-manager.jsx`, with `AppSessionShareLinkCard` as a child)
- Dashboard `Running | Playing in` segmented control per `dashboard.jsx`

**Excludes:** player-side join page, chat, realtime ACL widening (still GM-only). The `GameSession.characterIds` field stays in place (cleanup deferred to Stream E).

**Acceptance:**

- All existing `GameSession` rows have a backfilled GM membership.
- GM can hit `Generate invite link` → URL revealed once in `role="alertdialog"`. Rotate invalidates previous hash, Revoke nulls the field.
- Codegen-drift CI green. `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen` clean.
- Storybook a11y addon passes on `AppInviteManager` + `AppSessionShareLinkCard`.

### Stream B — Player shell + realtime ACL (~4 days)

**Goal:** player can open an invite link, pick a character, land on `/app/sessions/:id` and receive realtime DP/encounter events. No chat yet.

**Includes:**

- T-11.1.1.h — web `/app/sessions/join/:token` route → `AppSessionJoinCard` per `session-join.jsx` (four states: valid / revoked / already-member / not-signed-in)
- T-11.1.1.i — web `/app/sessions` (list) and `/app/sessions/:id` (player shell per `player-session-desktop.jsx`)
- T-11.1.1.j — `Leave` action on the player session (member self-delete) and `Kick` on the GM members list
- T-11.1.1.k — mobile `JoinSessionPage`, `SessionsListPage`, `SessionDetailPage` per `player-session-mobile.jsx` (with Chat tab still empty)
- T-11.2.1.a — player shell layout (chat slot = placeholder for Stream D)
- T-11.2.1.b — extract `AppSessionHeader` to `@app/ui`, `mode: "player" | "gm"` variant
- T-11.2.1.c / T-11.2.1.d — route guards both directions
- T-11.2.1.e / T-11.2.1.f — mobile mirror + Dashboard segmented control parity
- T-11.2.1.g / T-11.2.1.h — RealtimeModule ACL: `session.<id>` is now subscribable by any active membership (not just owner); regression test for kicked-token rejection on Centrifugo `subscribe` callback
- T-11.1.1.l — deep-link plist/intent **gated on host availability**. If `app_links` host isn't live, ship the web fallback only and file a follow-up (see decision #5).

**Excludes:** chat surfaces, system messages, block list.

**Acceptance:**

- Cold-open an invite link → preview → pick character → join → land on player shell.
- GM kicks a player → player's token re-issuance after TTL fails ACL.
- Both clients receive `dp.changed` realtime when GM increments DP.
- Route middleware from §4 removed (since `/app/sessions/:id` is now real for players).

### Stream C — Chat backend (~5 days)

**Goal:** REST + Centrifugo contract for chat. UI still placeholder.

**Includes:**

- T-11.3.1.a — OpenAPI: post, list (paginated cursor), get-by-id, edit (5-min window), delete (kind-aware), conversations index, read-cursor mark
- T-11.3.1.b — `ChatModule` (CQRS commands + queries + events including `PostSystemMessageCommand` for handler-emitted system rows)
- T-11.3.1.c — Prisma `ChatMessage` + indexes (`gameSessionId,createdAt` and `gameSessionId,authorId,targetMembershipId,createdAt`)
- T-11.3.1.d — token-bucket rate limit: 30 msg/min, 5/s burst, per user
- T-11.3.1.e — body validation (non-empty trimmed, max 4 KB at spec level)
- T-11.3.1.f — visibility enforcement: third-party reading a whisper returns 404 (not 403 — non-existence over forbidden)
- T-11.4.1.a — AsyncAPI: `session.<id>.chat` + `session.<id>.member.<membershipId>` channel families, payloads `chat.message.posted`/`edited`/`deleted`
- T-11.4.1.b — RealtimeModule ACL for the two new families
- T-11.4.1.c — `ChatMessagePostedEvent` handler routes: broadcast → one channel, whisper → two member channels (single payload), never broadcast for whispers
- T-11.5.1.g — `ChatReadCursor` table + `POST /chat/conversations/:key/read`
- T-11.3.1.g + T-11.4.1.h + T-11.6.3.a integration tests: pagination edge cases, edit-window, whisper privacy (bystander 404 + wire silent + GM 403 on delete + GM 404 on read), broadcast latency < 500ms

**Excludes:** chat UI components, block list, system-message handlers.

**Acceptance:**

- All chat-privacy regression tests green.
- AsyncAPI codegen drift clean — channel constants land in both TS and Dart client packages.
- `express-openapi-validator` runtime passes for every new route.

### Stream D — Chat UI (~7–8 days)

**Goal:** ship the full chat surface across web and mobile.

**Includes (web `@app/ui`, each component = `*.vue + *.stories.ts + *.spec.ts + index.ts` per project rule):**

- `AppChatAvatar` (wraps existing `AppPortrait` + presence pip)
- `AppChatDayDivider` (role="separator", brass hairline + uppercase tracked label)
- `AppChatMessage` (4 variants: broadcast-author, broadcast-other, whisper, system; kebab menu with `ownByMe` / `ownByGm` gating)
- `AppChatComposer` (textarea, char counter, ⌘/Ctrl+Enter, dynamic placeholder)
- `AppChatNewMessagesPill` ("↓ N new messages")
- `AppChatTab` + `AppChatTabStrip` (horizontal scroll, `+N more` overflow chip past 3 visible whisper tabs, `+` button opens `AppWhisperPicker`)
- `AppWhisperPicker` (modal listing other members; client-side filter for callers' own blocked-by-me list)
- `AppChatConnectionPip` (existing `ConnectionPip` upgraded)
- `AppChatPresenceDot` (separate atom from connection pip)
- `AppChatPanel` (composes the above, `mode: 'primary' | 'docked'`)

**Mount points:**

- GM `/app/game-sessions/:id` Overview gets a docked right-rail `AppChatPanel mode="docked"` collapsible behind a header toggle. Persist collapse state via `PATCH /me/settings`.
- Player `/app/sessions/:id` mounts `AppChatPanel mode="primary"` as main column on desktop and as the Chat tab body on mobile.

**Mobile (Flutter `app_ui` mirrors):**

- `ChatPanel`, `ChatTabStrip`, `ChatMessage`, `ChatComposer`, `WhisperPicker` widgets.
- `ChatTab` widget under `lib/features/sessions/presentation/`.
- Bottom-tabs `Chat | Encounter | Me` on `SessionDetailPage` (Chat is leftmost = most-touched, per `PHASE_8_DESIGN_NOTES.md` §4).
- Haptics: `HapticFeedback.selectionClick()` on tab change; `HapticFeedback.lightImpact()` on send.

**Tokens:**

- Add `--chat-bubble-author-bg`, `--chat-bubble-other-bg`, `--chat-system-fg`, `--chat-whisper-accent` to `specs/design/tokens/color.json` (already shipped in the handoff `tokens/color.json` — copy in).
- Run `pnpm design:build`. No hex literals.

**i18n:**

- `chat.*` namespace in `en.json` + `ru.json`. Includes 7 system keys per T-11.7.1.a, the dynamic-placeholder ICU strings, and tab labels.
- ICU plural for `chat.new_messages.pill` (en: `1 message` / `N messages`; ru: full three-form plural per `Intl.PluralRules`).
- `pnpm check:i18n` parity green.

**System messages (Feature 11.7 — folded here):**

- T-11.7.1.a — subscribers for `MemberJoinedEvent`, `MemberLeftEvent`, `MemberKickedEvent`, `RollPushedEvent`. Encounter advance / end stubs only if Epic 9 events exist; otherwise skip without breaking.
- Always emit to broadcast channel only.

**Block list (Feature 11.6.2 — folded here):**

- T-11.6.2.a — `POST/DELETE/GET /game-sessions/:id/blocks`
- T-11.6.2.b — `ChatBlockModule`; `PostChatMessageCommand` with `targetMembershipId` 403 if target blocked author. Error message is generic "this member is not accepting messages" (no leak that _they specifically_ were blocked).
- T-11.6.2.c — Prisma `ChatBlock`
- T-11.6.2.d — kebab "Block in this session" + confirm modal + hidden from picker after block; existing history remains readable.

**Acceptance:**

- Storybook a11y addon green on 11 new components.
- RU + EN parity in `chat.*`.
- Reduced-motion variant for new-messages pill + tab transitions.
- ⌘/Ctrl+Enter submit works in both modes.
- Mobile haptics fire on tab change and send.
- Block prevents new whispers; existing history visible.

### Stream E — Cleanup (~1 day)

**Goal:** remove the deprecated `characterIds` array. Source of truth for "who's at this table" is now `memberships`.

**Includes:**

- T-11.8.1.a — every read site of `characterIds` now reads `memberships[].characterId` (combat tracker's "import linked PCs", crew tab, anywhere else)
- T-11.8.1.b — remove `characterIds` from `GameSession` response schema. Bump OpenAPI minor.
- T-11.8.1.c — Prisma migration: drop `characterIds String[]` column
- T-11.8.1.d — Crew tab sources from `memberships`, empty-state copy "Share your invite link to bring players to the table."

**Acceptance:**

- `rg "characterIds" --type ts --type vue --type dart` returns nothing meaningful (only docs/comments referencing deprecation).
- Migration applies clean on a copy of prod-shaped data.

### Buffer (~3 days)

- i18n parity verification per `pnpm check:i18n`.
- a11y panel sweep per `superpowers:requesting-code-review` discipline.
- Reduced-motion verification on every animated component.
- Full integration test of all phase-specific tests called out in plan §"CI gates this phase must clear": codegen drift, realtime ACL regression, whisper privacy regression.

**Total: 25 working days ≈ 5 weeks.** Matches plan §"Effort sketch".

---

## 7. Test discipline per stream

Streams may use TDD or post-hoc tests, but the following are non-negotiable per stream:

| Stream | Required tests                                                                                                                                                                                      |
| ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A      | Rotate invalidates previous hash; revoke nulls field; idempotent re-accept; character-ownership check; membership uniqueness; Prisma migration backfill verified on existing fixture                |
| B      | Realtime ACL regression (member subscribes, non-member denied, kicked member denied after TTL); join-card four states; deep-link cold-start widget test (mobile, gated on host)                     |
| C      | Pagination edge cases (same-ms disambiguated by id); edit-window expiry; soft-delete visibility split; rate-limiter burst; whisper privacy (bystander 404 + wire silent); broadcast latency < 500ms |
| D      | Storybook a11y panel for 11 new components; RU+EN render; reduced-motion variants; ⌘/Ctrl+Enter submit; block prevents new whispers; mobile haptics                                                 |
| E      | Migration green; no `characterIds` references in implementation code                                                                                                                                |

CI gates that always apply (plan §"CI gates"): `spec:validate`, codegen-drift, `express-openapi-validator` runtime, Stylelint (no hex), `@app/ui` audit (every new component has `*.vue + *.stories.ts + *.spec.ts + index.ts`), `design:audit`, `check:i18n`, Vitest backend+ui+web, TruffleHog, `license-checker`, `flutter analyze lib`.

---

## 8. Risk register

| Risk                                                                                                        | Likelihood           | Impact   | Mitigation                                                                                                                                        |
| ----------------------------------------------------------------------------------------------------------- | -------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Backfill of GM memberships on existing `GameSession` rows fails on prod-shaped data                         | Low                  | High     | Stream-A migration is wrapped in a transaction; rollback path is "drop the table." Verify on a copy first.                                        |
| Realtime ACL widening exposes DP changes to a member who later got kicked, until token TTL expires (≤5 min) | Known                | Low      | Bounded by existing token TTL. Documented in T-11.2.1.h. Acceptable.                                                                              |
| Whisper privacy leak via a misrouted publish                                                                | Critical if realized | Critical | Per-member channels are the security boundary, not server-side filter. ACL regression test runs every PR (plan §"Whisper privacy regression").    |
| `characterIds` removed in Stream E breaks an unanticipated consumer                                         | Medium               | Medium   | Stream E is gated on grep showing zero remaining consumers. Migration ordering: spec + code change merged and deployed first, column drop second. |
| Mobile deep-link binding ships before host is live, breaking universal-link verification on iOS             | Low                  | Medium   | Gated on host availability per decision #5. Web-fallback works unconditionally.                                                                   |
| Storybook a11y panel flakes on `AppChatPanel` due to roving tabindex complexity                             | Medium               | Low      | Component-level a11y tests use targeted assertions, not full-panel snapshots.                                                                     |

---

## 9. What pushes onto `specs/tasks/active.md` next

Per the project's LIFO task stack:

```
T-2026-05-15-PHASE-8-STREAM-A — Phase 8 / Stream A — Foundation
  Includes: T-11.1.0.a (route move), T-11.1.1.{a..g} + dashboard segmented control
  Excludes: chat, player join, realtime ACL widening, mobile deep-link binding (Stream B), characterIds cleanup (Stream E)
  Expected: ~5 working days
  Spec: docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md §6 Stream A
  Tests: per §7 Stream A row
```

Streams B–E are pushed when their predecessor merges.

---

## 10. Out of scope (deferred to Phase 8.5+ or beyond)

Recorded so reviewers don't expect them:

- Rich roll-as-chat-card (`ChatRollCard`) — proposed in handoff but gated to Phase 8.5 per `PHASE_8_DESIGN_NOTES.md` §6.
- Avatar URL flow — initials-in-medallion only.
- Online/offline presence wiring — components designed, backend in Phase 9.
- System-level push notifications.
- GM-side moderation queue (folded into kebab; only revisits if message volume warrants).
- Encounters tab content design.
- Settings & Library surface designs.
- Player↔player share-link for HP/MP visibility.
- Mobile deep-link app_links binding.
- Markdown rendering in chat bodies.
