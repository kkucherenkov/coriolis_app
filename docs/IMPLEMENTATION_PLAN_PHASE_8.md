# Coriolis Companion App — Implementation Plan, Phase 8 Addendum

**Audience:** Claude Code (and any human reviewer)
**Status:** Proposal — not yet merged into `IMPLEMENTATION_PLAN.md`
**Source documents:** `PRD.md` v2.0, `DESIGN.md` v2.0, the existing `IMPLEMENTATION_PLAN.md` Epics 1–10
**Slot:** appended after Epic 10 (Hardening & Beta) — this is post-v1, the first v1.1-track epic

---

## Why this phase

v1 ships two roles in one shell: the GM owns sessions and the routes under `/app/game-sessions/*`; the player has a sheet but no first-class "I am at this table" experience. The session-channel ACL today only authorizes the **GM** to subscribe — players see DP changes only by side-effect (their push triggered the increment). There is no chat surface anywhere in the app.

Phase 8 closes those gaps:

1. A **player session client** — a distinct UI shell, with its own routes on web and feature folder on mobile, for the user-as-player view.
2. **Invite-link join flow** — one canonical link per session. The GM mints it, shares it once (Discord, group chat, voice channel, whatever), and any player who opens it can pick one of their characters and join.
3. **Bidirectional chat** with two surfaces: a session-wide **broadcast** stream, and **whispers** (MMO-style member ↔ member private DMs, including GM ↔ player and player ↔ player). Both persisted, paginated, realtime over Centrifugo.

The existing GM client at `/app/game-sessions/*` keeps its current layout. Players get `/app/sessions/*`. Same Nuxt build, same Flutter build, same auth, same codegen — only the route trees and shell components diverge.

---

## What does **not** change

- Auth contract (Better Auth bearer + JWT). No new auth flow.
- The `GameSession` model itself — it gains relations and an invite field, not replacement fields.
- Centrifugo as the only realtime carrier. We add channels and broaden ACL; we do **not** introduce a second WebSocket.
- The "GameSession, never Session" naming rule (PRD §7.4). New tables follow the same discipline: `GameSessionMembership`, `ChatMessage`, `ChatBlock`, `ChatReadCursor`.
- The unidirectional model: clients send messages via REST; the backend persists, then publishes to Centrifugo. Nothing in this phase requires clients to publish directly to Centrifugo.

---

# EPIC 11 — Player Client + Multiplayer Chat (Phase 8, ~5 weeks)

**Goal:** Split the session experience into two role-shaped clients — a **player client** that joins a GM's `GameSession` via invite link, and the existing **GM client** that runs it — and add bidirectional chat (broadcast + whispers) over Centrifugo, member-scoped, persisted.

**Exit criteria:**

- A GM rotates an invite link from the session detail page, copies it once, sends it out-of-band.
- A player (signed in) opens the link, sees a session preview, picks one of their own characters, and becomes a `GameSessionMembership` row with role `player`.
- The player lands on `/app/sessions/:id` (web) or the equivalent mobile route. They see the session's current DP, the active encounter (read-only), the chat panel, and a link to their own sheet.
- Broadcast messages are delivered to all members within 500ms via Centrifugo, persist, paginate cleanly on reconnect, and show system messages on join / push / round transitions.
- Whispers between any two members are delivered to **only those two** within 500ms, persist, paginate per conversation, and never appear on the broadcast channel.
- The GM can revoke the invite (or rotate it to invalidate the previous link), kick members, and moderate broadcast messages. Whispers are exempt from GM moderation by design — that's the privacy contract.

---

## Feature 11.1 — Membership + single-invite-link join

**Story 11.1.1** — As a GM, my session has one current invite link. I can rotate it (which immediately invalidates the previous link and generates a new one) or revoke it without replacement.

**Story 11.1.2** — As a player, I can open the current invite link, see a non-PII preview ("Session name, GM display name"), pick one of my own characters, and join.

**Story 11.1.3** — As a GM, I can see the membership list and kick. As a member, I can see the list and leave.

**Tasks:**

- T-11.1.1.a Spec: add `GameSessionMembership` schema and the membership / invite routes to `packages/specs/openapi/openapi.yaml`:
  - `POST   /api/v1/game-sessions/:id/invite/rotate` (GM only) → `{ token, url, rotatedAt }`. Plaintext token returned **only** in this response. Subsequent reads return metadata (`{ active: true, rotatedAt }`) but never the token again — if the GM loses the link they rotate again.
  - `DELETE /api/v1/game-sessions/:id/invite` (GM only) — revokes without replacement; subsequent `accept` calls 410.
  - `GET    /api/v1/game-sessions/:id/invite` (GM only) → metadata only (`{ active, rotatedAt }`).
  - `GET    /api/v1/invites/:token/preview` (public) → `{ sessionName, gmDisplayName, alreadyJoined }`. Never the session ID, never the membership list.
  - `POST   /api/v1/invites/:token/accept` (auth required; body `{ characterId? }`) → returns `GameSessionMembership` and the parent `GameSession` summary.
  - `GET    /api/v1/me/memberships` → player's joined sessions list (powers `/app/sessions`).
  - `GET    /api/v1/game-sessions/:id/members` (GM **or** member) → list of memberships with `{ id, displayName, role, characterId?, characterName?, joinedAt }`.
  - `DELETE /api/v1/game-sessions/:id/members/:membershipId` — GM kicks; member self-deletes.
  - `PATCH  /api/v1/game-sessions/:id/members/:membershipId` (member or GM) — change linked `characterId`.

  Run `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen`. Codegen-drift CI must stay green.

- T-11.1.1.b Backend: new `MembershipsModule` (CQRS layout per PRD §7.4). Commands: `RotateInviteCommand`, `RevokeInviteCommand`, `AcceptInviteCommand`, `KickMemberCommand`, `LeaveSessionCommand`, `LinkCharacterCommand`. Queries: `GetMyMembershipsQuery`, `ListMembershipsQuery`, `GetInvitePreviewQuery`, `GetInviteMetadataQuery`. Events: `MemberJoinedEvent`, `MemberLeftEvent`, `MemberKickedEvent`, `CharacterLinkedEvent`.

- T-11.1.1.c Backend: extend `GameSessionsModule` so the GM's session detail response includes `memberships[]` (lightweight: `{ id, userId, displayName, role, characterId?, characterName?, joinedAt }`).

- T-11.1.1.d Backend: invite token generator — 22-char URL-safe `nanoid`. Stored hashed (SHA-256) at rest on the `GameSession`; the only place the plaintext exists is the `RotateInviteCommand` response. Lookups by hash.

- T-11.1.1.e Backend: `AcceptInviteCommand` rules:
  - Reject if invite is revoked or rotated (hash mismatch).
  - Reject (200, idempotent) if the user is already an active member of the session — return existing membership. Re-opening the link must be safe.
  - If `characterId` is supplied, validate it belongs to the calling user.
  - `INSERT` the membership row inside a transaction.
  - Emit `MemberJoinedEvent`.

- T-11.1.1.f Backend: Prisma migration. Add invite fields directly to `GameSession`, plus the membership table:

  ```prisma
  model GameSession {
    // ... existing fields ...
    inviteTokenHash    String?     // SHA-256 of the URL-safe nanoid; NULL = no active invite
    inviteRotatedAt    DateTime?
    inviteCreatedById  String?
    memberships        GameSessionMembership[]
    chatMessages       ChatMessage[]
  }

  model GameSessionMembership {
    id                  String      @id @default(cuid())
    gameSessionId       String
    gameSession         GameSession @relation(fields: [gameSessionId], references: [id], onDelete: Cascade)
    userId              String
    role                String      // "gm" | "player"
    characterId         String?
    character           Character?  @relation(fields: [characterId], references: [id], onDelete: SetNull)
    joinedAt            DateTime    @default(now())
    leftAt              DateTime?
    authoredMessages    ChatMessage[] @relation("ChatAuthor")
    receivedWhispers    ChatMessage[] @relation("ChatTarget")

    @@unique([gameSessionId, userId])
    @@index([userId])
  }
  ```

  Backfill: on migration, generate a `gm`-role `GameSessionMembership` for every existing `GameSession` (the owner). The existing `GameSession.characterIds` array is **deprecated** in favor of memberships and dropped in Feature 11.8.

- T-11.1.1.g Web (GM): on `/app/game-sessions/:id` Overview tab, add an `AppInviteManager` panel:
  - "No active invite" empty state with a "Generate invite link" CTA → `RotateInvite` mints the first one.
  - Active state: shows `Active since <rotatedAt>`, plus `Copy link`, `Rotate (invalidate this one)`, `Revoke` actions.
  - On rotate / first generation: a one-shot toast reveals the URL with a `Copy` button, and an explicit warning that this is the only time the URL will be shown. After dismissal the URL is gone from the GM's screen — recovery is "rotate again."

- T-11.1.1.h Web (player): new route `/app/sessions/join/:token`. Renders `AppSessionJoinCard` (preview + character picker + Accept). On 200 redirects to `/app/sessions/:id`. On 410 (revoked / rotated) renders an `AppEmptyState` with "ask your GM for a new link" and a back-to-dashboard CTA.

- T-11.1.1.i Web (player): new routes `/app/sessions` (list of joined sessions) and `/app/sessions/:id` (player session view — wired in Feature 11.2). Both query `/api/v1/me/memberships`.

- T-11.1.1.j Web (GM): on the members list, add `Kick` (with `AppConfirm`). On the player session detail, the user can `Leave` (same modal pattern).

- T-11.1.1.k Mobile: parallel feature folder `apps/mobile/lib/features/sessions/` (player) alongside the existing `game_sessions/` (GM). Pages: `JoinSessionPage` (deep-link target), `SessionsListPage`, `SessionDetailPage`. Cubit / bloc per page.

- T-11.1.1.l Mobile: deep linking. Configure `app_links` so `https://<app-host>/app/sessions/join/:token` opens the app on devices that have it installed. Universal links plist for iOS, intent filter for Android.

- T-11.1.1.m Tests:
  - Backend: rotate invalidates the previous hash; revoke nullifies the field; idempotent re-accept returns the same membership row; character-ownership check; membership uniqueness.
  - Web component spec: `AppSessionJoinCard` for the four invite states (valid, rotated, revoked, already a member).
  - Mobile widget test for the join flow including a deep-link cold start.

---

## Feature 11.2 — Player session client shell

**Story 11.2.1** — As a player who has joined a session, opening `/app/sessions/:id` shows me a session shell that is layout-distinct from the GM shell: chat-forward, with DP and the active encounter as read-only side panels and a quick link to my linked character.

**Tasks:**

- T-11.2.1.a Web: `apps/web/app/pages/app/sessions/[id].vue`. Layout, single-column on mobile / two-column on desktop:
  - **Header:** session name, GM display name, DP counter (read-only on player side — no `+/−` controls), connection status dot.
  - **Primary surface:** chat panel (Feature 11.5).
  - **Secondary panel** (collapsible on mobile, sidebar on desktop): "My character" card (link to sheet), "Active encounter" card (read-only summary of the current `Encounter`'s round + active combatant when one is running), "Other players" list (display names + linked character names — not their HP/MP unless explicitly shared).

- T-11.2.1.b Web: extract `AppSessionHeader` to `@app/ui` so both `/app/sessions/:id` (player view) and `/app/game-sessions/:id` (GM view) consume it. Variant prop: `mode: "player" | "gm"` toggles whether DP shows the spend-with-reason controls.

- T-11.2.1.c Web: route guard — `/app/sessions/:id` requires a membership row (any role). 403 on no membership; 404 on no session. The GM accessing `/app/sessions/:id` is a soft redirect to `/app/game-sessions/:id` (their authoritative shell).

- T-11.2.1.d Web: `/app/game-sessions/:id` route guard — requires `role === "gm"` on the membership. A player who somehow lands there gets a soft redirect to `/app/sessions/:id`.

- T-11.2.1.e Mobile: `SessionDetailPage` mirrors the web player layout, single-column with bottom-tabs: **Chat** | **Encounter** | **Me**. Bloc subscribes to membership, session summary, encounter, chat history.

- T-11.2.1.f Mobile: GM sessions vs player sessions in the dashboard list — segmented control "Running" / "Playing in" on `/app/sessions` mobile and the corresponding web list. Counts in segment labels.

- T-11.2.1.g Realtime ACL update — broaden the `RealtimeModule` channel-token endpoint:
  - `session.<id>` → subscribable by **any active membership**, not just the owner. (The v1 channel that already carries `dp.changed`, `encounter.updated`, `combatant.updated`, `roll.pushed`. Phase 8 expands who is allowed to listen.)
  - Per-session ACL check moves from `gameSession.ownerId === user.id` to `membership exists where (gameSessionId, userId) and leftAt IS NULL`.

- T-11.2.1.h Update existing `RealtimeModule` tests for the new ACL. Add a regression: a kicked member's old token, used after kick, must fail re-subscription on Centrifugo's `subscribe` callback (token TTL ≤ 5 min already bounds the blast radius).

---

## Feature 11.3 — Chat backend (data model + REST)

**Story 11.3.1** — As a session member, my chat messages persist server-side, paginate per conversation, and survive disconnect. Whispers live on the same table; visibility is enforced server-side so only author and target ever see them.

**Tasks:**

- T-11.3.1.a Spec: `ChatMessage` schema and routes:
  - `POST  /api/v1/game-sessions/:id/chat/messages` body `{ kind: "text", body, targetMembershipId? }` → `ChatMessage`.
    - `targetMembershipId` omitted ⇒ broadcast.
    - `targetMembershipId` present ⇒ whisper. Server validates the target is an active member of the same session.
    - Member-only.
  - `GET   /api/v1/game-sessions/:id/chat/messages?conversation=&cursor=&limit=` → cursor-paginated, newest-first.
    - `conversation=broadcast` (default) → `targetMembershipId IS NULL`.
    - `conversation=<membershipId>` → whispers strictly between caller and that membership: `(authorId = me AND target = X) OR (authorId = X AND target = me)`.
    - `cursor` is base64url of `{ createdAt, id }`. `limit` defaults to 50, max 100.
  - `GET   /api/v1/game-sessions/:id/chat/conversations` → list of whisper partners the caller has exchanged messages with: `[{ membershipId, displayName, characterName?, lastMessageAt, unreadCount }]`. Used to render the DM tab list.
  - `GET   /api/v1/chat/messages/:id` — single-message fetch (permalink / edit-form rehydration). Whisper visibility rule applies.
  - `PATCH /api/v1/chat/messages/:id` body `{ body }` → 200 only if author **and** message is < 5 min old. Stamps `editedAt`. Works for both broadcast and whispers.
  - `DELETE /api/v1/chat/messages/:id` — different rule by kind:
    - Broadcast message: **author or session GM**.
    - Whisper message: **author only**. The GM cannot moderate whispers because the GM cannot read them — that's the privacy contract.

- T-11.3.1.b Backend: `ChatModule`. Commands: `PostChatMessageCommand`, `EditChatMessageCommand`, `DeleteChatMessageCommand`, `PostSystemMessageCommand` (internal-only — used by event handlers; always broadcast, never whisper). Queries: `ListChatMessagesQuery`, `ListConversationsQuery`, `GetChatMessageQuery`. Events: `ChatMessagePostedEvent` (carries `targetMembershipId` so the realtime publisher knows which channel(s) to publish to), `ChatMessageEditedEvent`, `ChatMessageDeletedEvent`.

- T-11.3.1.c Prisma:

  ```prisma
  model ChatMessage {
    id                  String      @id @default(cuid())
    gameSessionId       String
    gameSession         GameSession @relation(fields: [gameSessionId], references: [id], onDelete: Cascade)
    authorId            String?     // GameSessionMembership.id, NULL for system messages
    author              GameSessionMembership? @relation("ChatAuthor", fields: [authorId], references: [id], onDelete: SetNull)
    targetMembershipId  String?     // NULL = broadcast; non-NULL = whisper
    target              GameSessionMembership? @relation("ChatTarget", fields: [targetMembershipId], references: [id], onDelete: SetNull)
    kind                String      // "text" | "system"
    body                String?     // NULL for kind=system (use systemKey)
    systemKey           String?     // i18n key, e.g. "chat.system.member_joined"
    systemParams        Json?       // params for the i18n key
    createdAt           DateTime    @default(now())
    editedAt            DateTime?
    deletedAt           DateTime?

    @@index([gameSessionId, createdAt])                              // broadcast pagination
    @@index([gameSessionId, authorId, targetMembershipId, createdAt]) // whisper pagination
  }
  ```

  Notes: `authorId` and `targetMembershipId` are both nullable so kicked members' message history survives the FK with `onDelete: SetNull`. System messages are always broadcast; the spec rejects `kind: "system"` from client input.

- T-11.3.1.d Backend: rate limit the `POST` endpoint per-user — token bucket, 30 messages / minute, 5 / second burst. Same limit applies whether broadcast or whisper. Body cap 4 KB at the spec level.

- T-11.3.1.e Backend: validation. Body required and non-empty after trimming. Body stored as opaque text; rendering is plain text in v1 (Markdown deferred — the safety review for user-controlled Markdown is its own ticket).

- T-11.3.1.f Backend: visibility rule, enforced in `ListChatMessagesQuery` and `GetChatMessageQuery` — a row with non-null `targetMembershipId` is visible **only** to its author and target. Any other member receives 404. The GM is _not_ an exception.

- T-11.3.1.g Tests: pagination correctness on cursor edge cases (same-millisecond messages disambiguated by id), edit-window expiry, soft-delete visibility split, rate-limiter burst behavior, whisper visibility (a third member querying a whisper between two others gets 404 on direct read and never sees it in any listing).

---

## Feature 11.4 — Chat realtime over Centrifugo

**Story 11.4.1** — As a session member, when another member posts a broadcast message, my client renders it within 500ms without polling. When someone whispers me, only my client and the author's client receive the realtime event.

**Tasks:**

- T-11.4.1.a Spec: edit `packages/specs/asyncapi/centrifugo.yaml`. Add two new channel families:
  - **Broadcast chat:** `session.<gameSessionId>.chat`. Payloads `chat.message.posted`, `chat.message.edited`, `chat.message.deleted`, where the message has `targetMembershipId === null`.
  - **Per-member private:** `session.<gameSessionId>.member.<membershipId>`. Same three payloads, but for whispers where this member is author or target. Each member subscribes only to their own private channel.

  Run `pnpm spec:codegen` — channel constants land in `packages/api-client-ts/src/realtime/channels.ts` and the Dart equivalent.

- T-11.4.1.b Backend: extend `RealtimeModule` ACL:
  - `session.<id>.chat` → any active membership of the session.
  - `session.<id>.member.<membershipId>` → only the user who owns that membership. (No GM exception.)

- T-11.4.1.c Backend: `ChatMessagePostedEvent` handler routes by `targetMembershipId`:
  - Broadcast (`null`) → publish once to `session.<id>.chat`.
  - Whisper → publish twice: once to `session.<id>.member.<authorId>`, once to `session.<id>.member.<targetMembershipId>`. Single payload, two channels. **Do not** publish a whisper to `session.<id>.chat`.
  - Same routing for edit and delete events.

- T-11.4.1.d Channel topology rationale (decision recorded). Three channel families per session:
  - `session.<id>` — game-state events (DP, encounter, combatant, roll). Existing.
  - `session.<id>.chat` — broadcast chat. New.
  - `session.<id>.member.<membershipId>` — whisper traffic + future per-member private system messages. New.

  Why split chat from `session.<id>`? Chat traffic is much higher-volume than DP/combat events; per-channel disconnect/resubscribe in Centrifugo recovers one stream without thrashing the other; a future spectator widget can subscribe to game-state alone.

  Why per-member channels for whispers (rather than one filtered server-side)? Centrifugo channel ACL **is** the security boundary. If whispers rode the broadcast chat channel and were filtered client-side, the bodies would still be on the wire to all members. Per-member channels make non-disclosure a transport-layer property.

- T-11.4.1.e Web: extend the Centrifugo Pinia store to manage three subscriptions per session: `session.<id>`, `session.<id>.chat`, and `session.<id>.member.<myMembershipId>`. All three torn down on route leave.

- T-11.4.1.f Mobile: same pattern in `core/realtime/`. The bloc emits chat-state events split by conversation key (`broadcast` or `<partnerMembershipId>`).

- T-11.4.1.g Reconciliation: on (re)subscribe, the client triggers `GET /chat/messages?conversation=broadcast&limit=50` and `GET /chat/conversations` for whisper bootstrapping, then merges any subsequent realtime messages by id (idempotent). De-dupe key is `id`. Per-conversation backfill (`GET /chat/messages?conversation=<membershipId>`) happens lazily when the user opens that DM tab.

- T-11.4.1.h Integration tests:
  - Two members + one bystander. A → B whisper. Assert A and B both receive the realtime payload; bystander's WebSocket sees nothing on any channel; bystander's REST query for that conversation returns 404.
  - Broadcast smoke test: A posts broadcast; B and bystander both receive on `session.<id>.chat`; latency assertion < 500ms.

---

## Feature 11.5 — Chat UI components (web + mobile)

**Story 11.5.1** — As a session member on web or mobile, I can read the rolling broadcast history, scroll back, post broadcast messages, see my open whisper conversations as tabs, start a new whisper, switch between conversations, and edit / delete my own recent messages.

**Tasks:**

- T-11.5.1.a `@app/ui` — new components, each with `*.vue + *.stories.ts + *.spec.ts + index.ts` per the rule:
  - `AppChatPanel` — full panel; props `mode: "primary" | "docked"`. Owns the conversation tabs at top and the active conversation's scroll + composer.
  - `AppChatTabs` — the tab strip: "Session" (broadcast) is always first, followed by each open whisper conversation, plus a `+` button that opens `AppWhisperPicker`. Tabs show unread-count badges.
  - `AppWhisperPicker` — modal listing the session's other members; tapping one opens (or focuses) that DM tab.
  - `AppChatMessage` — single message row. Props for author, kind, body, edited / deleted state, `targetMembershipId` (so whispers can carry a subtle "private" affordance).
  - `AppChatComposer` — textarea + send button + character count. Submits on `⌘/Ctrl+Enter` per DESIGN §10. Carries the active conversation context (broadcast vs whisper-with-X).
  - `AppChatDayDivider` — date heading inserted between messages crossing a UTC date boundary in the user's locale.

- T-11.5.1.b Tokens: add `--chat-bubble-author-bg`, `--chat-bubble-other-bg`, `--chat-system-fg`, `--chat-whisper-accent` to `specs/design/tokens/*.json`, derived from existing brass / indigo palette. Whispers get a distinct accent stripe so they're never visually confused with broadcast. Run `pnpm design:build`. No hex literals.

- T-11.5.1.c Web GM: on `/app/game-sessions/:id`, mount `<AppChatPanel mode="docked" />` as a right-side sidebar, collapsible behind an `AppButton` icon. Persist collapse state via the existing `/me` settings PATCH.

- T-11.5.1.d Web player: on `/app/sessions/:id`, mount `<AppChatPanel mode="primary" />` as the main column on desktop and as the active tab body on mobile breakpoints.

- T-11.5.1.e Mobile player: `ChatTab` widget under `lib/features/sessions/presentation/`. Same scroll / composer / day-divider pattern. Uses `app_ui` widgets that mirror the web `@app/ui` components. Whisper tabs render as horizontally-scrollable chips above the message list, since vertical screen real estate is precious.

- T-11.5.1.f Auto-scroll behavior: when the user is within 80px of the bottom, new messages auto-scroll into view. When they have scrolled up, an `AppToast`-style "↓ N new messages" pill appears, tap to jump to bottom. Per-conversation; switching tabs preserves each conversation's scroll position. Reduced-motion variant: instant jump, no smooth scroll.

- T-11.5.1.g Unread tracking — each membership keeps a `lastReadAt` timestamp **per conversation**.
  - New endpoint: `POST /api/v1/game-sessions/:id/chat/conversations/:key/read` body `{ lastReadAt }` (`key` is `broadcast` or a `membershipId`).
  - New table:
    ```prisma
    model ChatReadCursor {
      membershipId    String
      membership      GameSessionMembership @relation(fields: [membershipId], references: [id], onDelete: Cascade)
      conversationKey String  // "broadcast" or "<otherMembershipId>"
      lastReadAt      DateTime
      @@id([membershipId, conversationKey])
    }
    ```
  - Spec + codegen + Prisma migration. The `unreadCount` on `GET /chat/conversations` is derived: count of messages newer than `lastReadAt` in that conversation.

- T-11.5.1.h i18n: every UI string in chat goes through `t()` (web) or `context.t.*` (mobile). Add `chat.*` namespace to en.json + ru.json. `pnpm check:i18n` passes.

- T-11.5.1.i a11y: `AppChatMessage` has `role="article"` with an accessible name `"<author> at <time>: <body>"` (whispers prefix the name with "Private message from <author>"). Composer has a labeled textarea, send is a labeled button, the active conversation tab has `aria-selected="true"`. Storybook `addon-a11y` panel passes for all six new components — non-negotiable per Quality Gate §12.

---

## Feature 11.6 — Whispers (member ↔ member private DMs)

Most of the whisper machinery is in Features 11.3–11.5. This feature ties the **end-to-end story** together and adds the whisper-specific concerns that don't fit elsewhere — the GM-cannot-moderate contract and per-session blocking.

**Story 11.6.1** — As any member of a session (player or GM), I can send a private message to any other active member of the same session, see it appear in real time in our shared DM thread, and edit or delete my own messages within the standard 5-minute window.

**Story 11.6.2** — As a recipient of unwanted whispers, I can block another member from whispering me for the duration of the session.

**Tasks:**

- T-11.6.1.a (Already covered in 11.3 / 11.4 / 11.5) — verify end-to-end:
  - Whispers cross GM ↔ player, player ↔ player, and GM ↔ GM (for the unlikely co-GM future).
  - Scope is per-session: leaving (or being kicked) immediately revokes the per-member channel token (TTL bound), and the partner's DM tab marks the conversation as "no longer active" — they can still read history but the composer is disabled.

- T-11.6.1.b The GM moderation exemption is explicit in code and in the UI:
  - Backend: `DeleteChatMessageCommand` on a whisper rejects if the caller is not the author. No GM bypass branch.
  - UI: the GM's "Delete" affordance on broadcast messages is absent on whispers (the GM never sees whispers in the first place; this exemption is purely defense-in-depth on the rare path where a whisper id leaks via URL).

- T-11.6.2.a Spec: per-session block list.
  - `POST   /api/v1/game-sessions/:id/blocks` body `{ targetMembershipId }` → 204
  - `DELETE /api/v1/game-sessions/:id/blocks/:targetMembershipId` → 204
  - `GET    /api/v1/game-sessions/:id/blocks` → list of memberships the caller has blocked

- T-11.6.2.b Backend: `ChatBlockModule`. `PostChatMessageCommand` with `targetMembershipId` rejects (403) if the _target_ has blocked the _author_. The author sees a generic "this member is not accepting messages" error — never confirmation that they specifically were blocked. (Standard anti-harassment pattern.)

- T-11.6.2.c Prisma:

  ```prisma
  model ChatBlock {
    id                  String   @id @default(cuid())
    gameSessionId       String
    blockerMembershipId String
    blockedMembershipId String
    createdAt           DateTime @default(now())
    @@unique([gameSessionId, blockerMembershipId, blockedMembershipId])
  }
  ```

- T-11.6.2.d UI: a "Block in this session" action on the partner's DM tab kebab menu. Confirmation modal. Once blocked, their tab is hidden from the picker; existing history remains readable. Unblock via session settings.

- T-11.6.3.a End-to-end test scenarios in CI:
  - Whisper round-trip: A → B latency < 500ms, body never on bystander C's wire (assertion via Centrifugo client log inspection in the test harness).
  - GM cannot delete a whisper: `DELETE /chat/messages/:whisperId` from a GM token → 403.
  - GM cannot read a whisper: `GET /chat/messages/:whisperId` from a GM token → 404.
  - Block prevents new whispers but does not retroactively delete history.

---

## Feature 11.7 — System messages

**Story 11.7.1** — As a session member, I see lightweight system messages in the broadcast chat stream when meaningful events happen: a member joined, a member left, a roll was pushed, a new round started, an encounter ended.

**Tasks:**

- T-11.7.1.a Backend: subscribe `MemberJoinedEvent`, `MemberLeftEvent`, `MemberKickedEvent`, `RollPushedEvent`, `EncounterAdvancedEvent`, `EncounterEndedEvent` (the last two land in Epic 9 — wire iff that epic is in scope; otherwise stub). Each handler issues `PostSystemMessageCommand` with a stable `systemKey` and a small `systemParams` JSON payload. **System messages are always broadcast** — they ride `session.<id>.chat`, never per-member channels.

  Initial system keys:
  - `chat.system.member_joined` — params `{ memberName }`
  - `chat.system.member_left` — params `{ memberName }`
  - `chat.system.member_kicked` — params `{ memberName }`
  - `chat.system.roll_pushed` — params `{ memberName, dpDelta }`
  - `chat.system.encounter_started` — params `{ encounterName }`
  - `chat.system.round_advanced` — params `{ round }`
  - `chat.system.encounter_ended` — params `{ encounterName }`

  Block / unblock events are **not** system-messaged — that would defeat the privacy of the block.

- T-11.7.1.b Translations: add the seven keys above to `en.json` and `ru.json`. Confirm Cyrillic strings render with the existing Forum / Inter / JetBrains Mono subsets (PRD §6.4.1.b discipline).

- T-11.7.1.c Web + mobile rendering: `AppChatMessage` with `kind === "system"` skips the bubble treatment, renders as a centered, italic, low-contrast line using `--chat-system-fg`. Reduced-motion variant: identical (no animation in either mode for system messages).

- T-11.7.1.d Test: post a roll via the dice roller while linked to a session, assert one `chat.system.roll_pushed` row appears in broadcast with the correct DP delta in `systemParams`.

---

## Feature 11.8 — Cleanup of the deprecated `characterIds` array

**Story 11.8.1** — As a developer, the `GameSession.characterIds` Postgres array is no longer the source of truth for "who is at this table" — `GameSessionMembership` is.

**Tasks:**

- T-11.8.1.a Backend: every read site that consumed `characterIds` reads `memberships[].characterId` instead. The Combat tracker's "import linked PCs" UX in Epic 9 now iterates active memberships of role `player` with a non-null `characterId`.

- T-11.8.1.b Spec: remove `characterIds` from `GameSession` response schema; bump the OpenAPI minor version. Codegen.

- T-11.8.1.c Prisma migration: drop the `characterIds String[]` column. Migration runs only after T-11.8.1.a + T-11.8.1.b are merged and deployed.

- T-11.8.1.d Web GM: the existing "Crew" tab on the session detail (`gm-session.jsx`) now sources its rows from `memberships`, not `characterIds`. Add an empty-state for sessions with no players yet ("Share your invite link to bring players to the table").

---

## Open product decisions (resolve before T-11.1.1.a)

These are deliberately not pre-decided. Pick before the spec lands.

1. **One character per player per session, or many?** The schema above implies _one_: `(gameSessionId, userId)` is unique on `GameSessionMembership`. If you want a player to bring multiple PCs, drop the unique constraint and key the membership on `(gameSessionId, userId, characterId)`. Recommendation: stay with **one** for v1.1 — simpler chat attribution, simpler "my character" surface.

2. **GM "spectator" mode for whispers** — should a GM have an opt-in switch to read all whispers for moderation? This violates the privacy contract above and is **off by default** in this plan. If you want it, model as a per-session feature flag (`GameSession.gmSeesWhispers boolean`) that is visibly displayed to all members in the chat header — never silent.

3. **Player visibility into other players' HP/MP.** The PRD says GMs can read player live sheets if shared (Epic H). Mirroring that for player ↔ player would need extending the `ShareLink` model with a session scope. Recommendation: **out of scope for Phase 8** — players see other linked-character _names_ in this phase, nothing more.

4. **Invite-link unauth preview.** The plan exposes a public preview (`/api/v1/invites/:token/preview`) that returns only session name and GM display name — no member list, no session ID. Confirm this matches your privacy posture.

5. **Mobile deep-link host.** Universal links / app links require a registered HTTPS host that serves `.well-known/apple-app-site-association` and `assetlinks.json`. If the marketing host isn't live yet, links work as plain web links at `/app/sessions/join/:token` and the user signs in there. Mobile deep-link binding can ship in a follow-up.

6. **Whisper history visibility after kick.** When a member is kicked, their whisper partners can still read the historical thread. The kicked member loses access (no membership = no token = no GET). Confirm this asymmetry is acceptable, or specify "kick deletes whisper history" if not.

---

## Effort sketch

Single full-stack engineer at the same pace as the rest of the plan:

| Feature                                                                | Days                            |
| ---------------------------------------------------------------------- | ------------------------------- |
| 11.1 Membership + single-invite flow                                   | 4                               |
| 11.2 Player session client shell                                       | 4                               |
| 11.3 Chat backend (broadcast + whisper data + REST)                    | 4                               |
| 11.4 Chat realtime (3 channel families, per-member ACL)                | 3                               |
| 11.5 Chat UI (tabs, picker, unread cursors)                            | 5                               |
| 11.6 Whispers end-to-end + block list                                  | 2                               |
| 11.7 System messages                                                   | 1                               |
| 11.8 `characterIds` cleanup                                            | 1                               |
| Buffer (i18n parity, a11y, reduced-motion variants, integration tests) | 3                               |
| **Total**                                                              | **~27 working days (≈5 weeks)** |

---

## CI gates this phase must clear

The same set as every other epic — no exceptions:

`spec:validate`, `codegen-drift`, `express-openapi-validator` runtime, Stylelint (no hex), `@app/ui` audit (every new component has `*.vue + *.stories.ts + *.spec.ts + index.ts` and a `specs/design/README.md` entry), `design:audit`, `check:i18n` (en / ru parity for every new `chat.*` and `sessions.*` key), Vitest (backend + ui + web), TruffleHog, `license-checker`.

Phase-specific tests that **must** be in the suite:

- **AsyncAPI codegen drift** — new chat / per-member channel constants in committed generated files for both TS and Dart.
- **Realtime ACL regression** — `session.<id>`, `session.<id>.chat`, and `session.<id>.member.<X>` channel-token issuance is denied for non-members and for members other than X (for the per-member channel), granted for the right caller, denied again after kick within the next token TTL.
- **Whisper privacy regression** — bystander cannot see a whisper via REST (404), via Centrifugo (no payload on the wire), or via GM moderation endpoints (403 on delete, 404 on read). This test runs every PR.
