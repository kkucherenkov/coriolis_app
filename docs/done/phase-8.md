# Phase 8 — Player Client + Multiplayer Chat

**Phase:** 8 (v1.1 expansion — first epic after the Beta cut)
**Tag:** `phase-8-complete`
**Source plan:** `docs/IMPLEMENTATION_PLAN_PHASE_8.md` (Epic 11)
**Design spec:** `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md`
**Date:** 2026-05-17

## What shipped

Phase 8 turned the v1 single-shell GM client into a **two-role
experience**. The GM keeps the existing routes under `/app/game-sessions/*`;
players get their own shell at `/app/sessions/*` (web) and a mirrored
`features/sessions/` feature folder on mobile. A GM mints a single
canonical invite link from the session detail page, shares it
out-of-band, and any signed-in user who opens it picks one of their
characters, joins, and starts receiving the session's realtime feed
(DP changes, encounter updates) on the same Centrifugo channel that
already powered the GM client.

On top of that join surface the phase adds **bidirectional chat with
two stream types**: a session-wide **broadcast** for everyone in the
table and **whispers** — MMO-style private DMs between any two
members (including player↔player, GM↔player, and any combination).
Both surfaces are persisted in Postgres, paginated by `(createdAt, id)`
cursor, fan out in real time over Centrifugo, ship with a per-session
**block list** that hides future messages from a blocked member, and
display **system messages** for member-join / member-left /
member-kicked / roll-pushed events inline in the broadcast stream.

The phase closes by removing the legacy `GameSession.characterIds`
array and the `CharacterGameSession` join table — `GameSessionMembership`
is now the single source of truth for "who is at this table",
including the GM (backfilled in the migration). The Crew panel on
the web GM session detail and the mobile session detail / list both
render off memberships now; the "characters assigned" mini-API is
gone from `/api/v1/game-sessions/:id/characters[…]` (OpenAPI bumped
`1.8.0 → 1.9.0` in Stream E).

Five execution streams over ~6 calendar days, all on `main`:

| Stream                              | Scope                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Plan tasks                                                                 | Result                                                                              |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| **A** — Foundation                  | Route move (`/app/sessions/*` → `/app/game-sessions/*`), `GameSessionMembership` model + Prisma migration, invite-token utility, 7 CQRS handlers, 2 `@app/ui` components (`AppInviteManager`, `AppSessionShareLinkCard`), Dashboard `Running ｜ Playing in` segmented control. OpenAPI 1.5.0 → 1.6.0.                                                                                                                                                                                                                           | T-11.1.0.a–c + T-11.1.1.{a,b,c,d,f,g,g.2,m.2} + T-11.1.2                   | Direct-to-main commits, 2026-05-15 → 16.                                            |
| **B** — Player shell + realtime ACL | Player routes `/app/sessions/[id]`, mobile `features/sessions/` mirror, invite-preview + accept routes, `SessionAccessRepo` widened so realtime ACL grants `session.<id>` to **any** active membership (not GM-only), legacy redirect middleware deleted, dashboard "Playing in" count from `GET /api/v1/me/memberships`. OpenAPI 1.6.0 → 1.7.0.                                                                                                                                                                                | T-11.1.1.{h,i,j(player half),k,l} + T-11.2.1.a–h                           | Direct-to-main, 2026-05-16.                                                         |
| **C** — Chat backend                | 10 REST routes under `/api/v1/chat/messages*` + `/api/v1/chat/blocks*` + `/api/v1/me/chat/conversations`; 3 Prisma tables (`ChatMessage`, `ChatReadCursor`, `ChatBlock`) with `(gameSessionId, createdAt)` + `(gameSessionId, authorMembershipId, targetMembershipId, createdAt)` indexes; 2 new Centrifugo channel families (`session.<id>.chat` broadcast + `session.<id>.member.<membershipId>` per-member); in-memory token-bucket rate limiter (30/min, 5/s burst). OpenAPI 1.7.0 → 1.8.0; AsyncAPI 0.11.0 → 0.12.0.       | T-11.3.1.a–g + T-11.4.1.{a,b,c,h} + T-11.5.1.g + T-11.6.2.a–c + T-11.6.3.a | [PR #27](http://code.homelab.local/kkucherenkov/coriolis_app/pulls/27), 2026-05-17. |
| **D** — Chat UI (web + mobile)      | 11 `@app/ui` chat components (atoms + composers + composition root); 4 new `color.chat.*` design tokens; web Pinia store + `useSessionChatRealtime` composable; web mounts on player + GM session detail (player `mode="primary"`, GM `mode="docked"` collapsible right-rail); mobile chat widgets + `ChatBloc` + bottom-nav (Chat ｜ Encounter ｜ Me); 4 backend system-message subscribers (member-joined / left / kicked / roll-pushed); block-UI affordance (web kebab + mobile long-press); i18n parity EN / RU / UK / EL. | T-11.5.1.a–i + T-11.6.1.a–b + T-11.6.2.d + T-11.6.3.a + T-11.7.1.a–d       | [PR #28](http://code.homelab.local/kkucherenkov/coriolis_app/pulls/28), 2026-05-16. |
| **E** — `characterIds` cleanup      | Drop `GameSession.characterIds` array + `CharacterGameSession` join + the two `/game-sessions/:id/characters[…]` routes; backfill GM `membership.characterId` from earliest legacy assignment; web GM "Characters" panel → "Crew" panel from `session.memberships`; mobile parity. OpenAPI 1.8.0 → 1.9.0; AsyncAPI `ChatMessage` / `ChatMessageDeleted` → `RealtimeChatMessage` / `RealtimeChatMessageDeleted` (namespace hygiene, wire-compatible).                                                                            | T-11.8.1.a–d                                                               | [PR #29](http://code.homelab.local/kkucherenkov/coriolis_app/pulls/29), 2026-05-17. |

## Sub-feature summary

| Feature                                       | Story                                                                                                                                                                                 | Status             | Where it landed                                                                                   |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------ | ------------------------------------------------------------------------------------------------- |
| **11.1** Membership + single-invite-link join | GM rotates / revokes one canonical invite; player joins via link + character pick.                                                                                                    | ✅                 | Stream A (foundation) + Stream B (player half: preview, accept, `/me/memberships`).               |
| **11.2** Player session client shell          | Player gets a layout-distinct shell (`/app/sessions/[id]`) with chat-forward focus and the linked character quick-link.                                                               | ✅                 | Stream B.                                                                                         |
| **11.3** Chat backend (data + REST)           | Messages + read cursors + whispers persisted; pagination by base64url `(createdAt, id)` cursor; whisper privacy enforced via `404` (not `403`) on third-party reads.                  | ✅                 | Stream C.                                                                                         |
| **11.4** Chat realtime over Centrifugo        | Broadcast and whispers fan out within 500 ms; per-member channel ACL is the security boundary (whispers never ride the broadcast channel).                                            | ✅                 | Stream C (channels + ACL widening; chat publisher reuses `RealtimeModule`'s `CENTRIFUGO_CLIENT`). |
| **11.5** Chat UI (web + mobile)               | Rolling history, optimistic send, ⌘/Ctrl+Enter, 80 px auto-scroll threshold, new-messages pill, tab strip (3 visible + overflow chip), kebab edit / delete on own messages.           | ✅                 | Stream D.                                                                                         |
| **11.6** Whispers + block list                | Two-member private DMs that persist after either party leaves; per-session block list filters `AppWhisperPicker` and rejects future POSTs (`403`). Existing history remains readable. | ✅                 | Streams C (data + REST) + D (block-UI affordance, picker filter).                                 |
| **11.7** System messages                      | Inline broadcast notices for member-joined, member-left, member-kicked, roll-pushed (encounter-advanced + ended deferred — see follow-ups).                                           | ✅ (4 of 5 events) | Stream D — 4 NestJS event subscribers translate domain events into `PostSystemMessageCommand`.    |
| **11.8** `characterIds` cleanup               | `GameSessionMembership` is the only source of truth; legacy array + join table + two routes removed.                                                                                  | ✅                 | Stream E.                                                                                         |

## Notable decisions

- **`GameSessionMembership` is the canonical "who is at this table"
  contract.** The v1 `GameSession.characterIds` `String[]` was assembled
  at read time from `CharacterGameSession`. Stream A added the
  membership table + GM backfill; Stream E removed the legacy join
  entirely. Crew panels on web + mobile now render directly from
  `session.memberships`, no second roundtrip.

- **Per-member Centrifugo channels for whispers — not server-side
  filtering on a shared channel.** Centrifugo channel ACL is the only
  security boundary that survives a misbehaving client. A whisper
  riding `session.<id>.chat` filtered client-side would still be on
  the wire to every member. The cost (one extra subscribe per
  member) buys non-disclosure as a transport property.

- **`404` over `403` for whisper privacy.** Applied uniformly to
  `GET /chat/messages/:id`, `DELETE /chat/messages/:id`, and
  `GET /chat/messages?conversation=<membershipId>` (which returns
  `items: []`, not `4xx`). Non-existence over forbidden = no leak
  that "you're not allowed to see THIS specific thing".

- **GM has no whisper-moderation bypass.** `DeleteChatMessageCommand`
  rejects whisper deletes from anyone but the author; `GET` of a
  single whisper message returns `404` to non-author/target including
  the GM. The GM owns the session, not its members' conversations.

- **Cursor pagination via base64url-encoded `{createdAt, id}`** with
  strict `(createdAt DESC, id DESC)` ordering — same-millisecond ties
  broken deterministically by `id`. Invalid cursors silently treated
  as "no cursor" (friendlier than `400`; caller detects end via
  `nextCursor === null`).

- **In-memory rate limiter for v1.1, Redis for multi-node.** The chat
  module currently runs a per-user token bucket inside the NestJS
  process (`ChatRateLimiterService`). For single-node homelab this is
  exact; for the multi-node deploy path the Redis-backed variant is
  listed as a follow-up.

- **Phase 8 is post-Beta v1.1 work, not v1 scope.** The `phase-8-complete`
  tag marks the closure of Epic 11; the v1.0 launch follow-ups
  recorded in `docs/done/phase-7.md` § "Deferred / open follow-ups"
  (production hosting, web Sentry, full Grafana dashboards, mobile
  cold-start profile, Lighthouse LCP target tightening) **remain open**
  and are not gated by this tag.

- **Phase 8 added a new architectural layer the v1 plan did not have:
  per-session per-conversation state.** The web Pinia chat store
  carries `messages | cursor | pendingSendIds | isAtBottom |
newMessagesCount` keyed by `(sessionId, conversationId)`. Mobile
  `ChatBloc` mirrors the same surface in event-driven shape. The
  same `useSessionChatRealtime` composable handles both broadcast
  and per-member channels behind one subscribe call.

- **`AppConfirm` primitive landed mid-phase.** Stream A's invite
  revoke flow shipped with `globalThis.confirm()` because the
  codebase had no destructive-action confirm primitive. The
  `AppConfirm` component shipped later in the phase (commit `3f3b63e`)
  and the GM session detail Crew remove flow already uses it; the
  invite revoke and the chat-message delete still call
  `globalThis.confirm` — listed in follow-ups.

- **Auto-format / `chatDockedCollapsed` to `/me/settings`.** Stream D
  persisted the GM docked-collapse preference in `localStorage` to
  unblock landing the panel. The proper destination is the `/me/settings`
  schema (`Me.chatDockedCollapsed: boolean`); the OpenAPI bump landed
  in commits `4a12935` + `69f5695` mid-phase and the web client was
  flipped over (`5f266dc`), but mobile still reads `localStorage` —
  one of the carried-forward Stream D follow-ups.

## Deferred / open follow-ups

These are tracked here (not in `specs/tasks/active.md`) because they
are explicit Phase 8 carry-forwards into the Phase 8.5 backlog:

1. **Deep-link configuration (`T-2026-05-17-DEEP-LINK-SETUP`).**
   Blocked on `APP_LINKS_HOST` env var being provisioned by marketing.
   Web invite-join page works as a plain link without deep-link
   binding — this is the correct v1.1 state per design decision #5.
   Remains in `specs/tasks/active.md` as `blocked`.

2. **Redis-backed chat rate limiter.** Required for multi-node
   deploy; single-node homelab is unaffected. Drop-in replacement
   for `ChatRateLimiterService`.

3. **`globalThis.confirm` → `AppConfirm` on the remaining call sites.**
   Invite revoke (Stream A leftover) and chat-message delete (Stream D).
   Both flows have the primitive available; this is a 5-min sweep.
   **Status:** ✅ Shipped — verified done in prior PRs (no follow-up code change needed).

4. **GM "Kick member" UI on `/app/game-sessions/[id]`.** Backend
   `DELETE /game-sessions/:id/members/:membershipId` shipped in
   Stream A; the GM-side button hasn't been wired yet. Mobile has
   parity-pending.

5. **Edit-message inline affordance polish.** Today `@edit-message`
   prefills the composer; the UX direction is a dedicated banner
   with "Editing message — cancel / save". Inline-edit affordance
   landed for char sheet — porting the pattern is straightforward.

6. **Presence wiring on `AppChatTab`.** The component accepts a
   `presence` prop; the store leaves it `undefined`/`offline`. Hook
   to Centrifugo's `client_id` map when the presence-tracking spec
   lands.

7. **`MarkReadRequest` derives `lastReadAt` from message `createdAt`.**
   Today the mobile repository takes a `messageId` and the impl
   stamps `DateTime.now()` — tightening this avoids cursor drift
   across slow networks.

8. **Web + mobile chat integration tests.** Per-component specs
   shipped (171 new for web, 21 new for mobile in Streams D); a
   route-level Vitest spec mounting `/app/sessions/[id]` against a
   stubbed SDK + Centrifuge client, and a mobile `integration_test/`
   counterpart, are the next layer.

9. **Storybook a11y addon manual sweep.** Per-component a11y assertions
   shipped; the Storybook a11y addon hasn't been booted as part of
   CI yet (deferred — addon scaffolding noted in `quality` job
   today but not yet running against axe-core's full ruleset).

10. **`chatDockedCollapsed` on mobile from `/me/settings`.** Mobile
    side of the localStorage → settings migration (web is done).

    **Status:** Shipped in PR #51.

11. **System messages for `encounter.advanced` and `encounter.ended`.**
    4 of 5 originally-listed events shipped; these two were
    out-of-scope for Stream D and remain follow-ups.
    **Status:** ✅ Shipped in PR #52 — three new domain events
    (`EncounterStartedEvent`, `RoundAdvancedEvent`, `EncounterEndedEvent`),
    emit sites in `UpdateEncounterHandler` and `AdvanceRoundHandler`, three
    new subscribers in `ChatModule`, +11 unit specs, +3 e2e scenarios.

12. **Generic `RealtimeRouter` abstraction.** Chat publisher and DP
    publisher each call `centrifugo.publish` directly. A small
    router would centralize topic naming + payload shape contracts;
    not blocking but reduces drift risk as more channels ship.

None of the above blocks the `phase-8-complete` tag.

## Test totals at phase exit

- Backend: **1097 / 1097** green (Stream-C 1097 baseline; Stream-E
  netted to the same number after deleting 10 assign/unassign specs
  and 7 fixture-builder mock entries).
- `@app/ui`: **1064 / 1064** green (Stream-C ~900 baseline +
  171 new across the 11 chat components in Stream D, then untouched
  by Stream E).
- `@app/web`: **536 / 536** green (Stream-D +13 chat store specs;
  Stream E rewrote one encounters assertion to assert the new
  `crewHeading` / `crewEmpty` copy).
- Mobile (`flutter test`): **451 / 451** green (Stream-D 452 baseline,
  Stream-E netted to 451 after dropping the legacy `assignCharacter`
  cache spec).
- **Cross-stack total: ~3148 tests** green at phase exit.
- Acceptance (Stream E green run on `chore/ci-green-lint-a11y-trivy`
  merged as PR #34, run `#1689` on `main`): `pnpm spec:validate` ✅;
  `pnpm spec:codegen` (drift-free) ✅; `pnpm check:i18n` (parity
  across 4 locales) ✅; backend `tsc --noEmit` ✅; web `nuxt typecheck`
  ✅; `flutter analyze` ✅.

## What "Phase 8 complete" means here

The badge means: Epic 11 (player client + multiplayer chat) shipped
end-to-end across web + mobile + backend; OpenAPI is at `1.9.0` and
AsyncAPI at `0.12.0`; the `characterIds` legacy is gone;
`GameSessionMembership` is the canonical "who is at this table"
contract; the chat surface (broadcast, whispers, blocks, system
messages, read cursors) is persisted, paginated, realtime, and rate-
limited. It does **not** mean: the v1.0 launch follow-ups from
Phase 7 are closed — those remain open and are the operator's first
deployment-pass work.
