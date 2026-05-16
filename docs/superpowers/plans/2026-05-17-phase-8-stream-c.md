# Phase 8 / Stream C — Chat Backend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the REST + Centrifugo + Prisma backend for session-scoped chat (broadcast + whispers + per-session block list + read cursors), so Stream D's UI can mount against a stable contract.

**Architecture:**

- New CQRS module `apps/backend/src/modules/chat/` mirroring `memberships/` layout (`commands/`, `queries/`, `domain/`, `infra/`, `http/`, `chat.module.ts`).
- Three new tables (`ChatMessage`, `ChatReadCursor`, `ChatBlock`); two new realtime channel families (`session.<id>.chat`, `session.<id>.member.<membershipId>`).
- Whisper privacy is a transport-layer property: per-member channels carry whispers, not the broadcast channel; visibility filter enforced in queries returns **404** to bystanders (not 403).
- Rate limit is in-memory per-user token bucket (30 msg/min, 5/s burst) — backend is single-node in v1.1; Redis-backed limiter is a follow-up if we shard.

**Tech Stack:** NestJS 11 CQRS, Prisma 7, `class-validator` DTOs, `express-openapi-validator` runtime gate, `@nestjs/cqrs` EventBus + `@EventsHandler`, `CentrifugoService.publish()`, `vitest`.

**Spec versions:**

- OpenAPI: `1.7.0` → `1.8.0` (minor — additive routes + schemas only)
- AsyncAPI: `0.11.0` → `0.12.0` (minor — two new channels)

**Out of scope:** Chat UI (Stream D), system-message handlers for member-join / roll-pushed (Stream D, Feature 11.7), `characterIds` cleanup (Stream E).

---

## Pre-flight

- [ ] Push entry to `specs/tasks/active.md` using the Stream B / Stream A template — title `T-2026-05-17-PHASE-8-STREAM-C`, status `in-progress`, link this plan.
- [ ] Branch off `main`: `git checkout -b feat/phase-8/stream-c-chat-backend`.
- [ ] Verify clean baseline: `pnpm --filter @app/backend test --run` is green and `pnpm spec:validate && pnpm spec:bundle` passes before any edit.

---

## Task 1 — OpenAPI 1.7.0 → 1.8.0 + AsyncAPI 0.11.0 → 0.12.0 + codegen

**Owner agent:** `spec-writer` then `codegen-runner`.

**Files:**

- Modify: `packages/specs/openapi/openapi.yaml` — bump `info.version`, add 10 routes + 8 schemas
- Modify: `packages/specs/asyncapi/centrifugo.yaml` — bump `info.version`, add 2 channels + 3 message payloads
- Auto-regenerated (commit separately): `packages/specs/src/openapi-types.ts`, `packages/api-client-ts/src/generated/**`, `packages/api-client-ts/src/realtime/channels.ts`, `packages/api-client-dart/lib/generated/**`

### Step 1.1 — REST schemas

Add under `#/components/schemas/`:

- `ChatMessageKind` — `enum: [text, system]`
- `ChatMessage`:
  ```yaml
  type: object
  required: [id, gameSessionId, authorMembershipId, targetMembershipId, kind, createdAt]
  properties:
    id: { type: string }
    gameSessionId: { type: string }
    authorMembershipId:
      {
        type: ['string', 'null'],
        description: 'GameSessionMembership.id; null for system messages',
      }
    authorDisplayName: { type: ['string', 'null'], description: 'Denormalised at read time' }
    targetMembershipId:
      { type: ['string', 'null'], description: 'null = broadcast; non-null = whisper' }
    kind: { $ref: '#/components/schemas/ChatMessageKind' }
    body:
      {
        type: ['string', 'null'],
        description: 'null for kind=system; non-empty trimmed text for kind=text',
      }
    systemKey:
      {
        type: ['string', 'null'],
        description: 'i18n key for kind=system, e.g. chat.system.member_joined',
      }
    systemParams: { type: ['object', 'null'], additionalProperties: true }
    createdAt: { type: string, format: date-time }
    editedAt: { type: ['string', 'null'], format: date-time }
    deletedAt: { type: ['string', 'null'], format: date-time }
  ```
- `ChatMessageList`:
  ```yaml
  type: object
  required: [items, nextCursor]
  properties:
    items: { type: array, items: { $ref: '#/components/schemas/ChatMessage' } }
    nextCursor: { type: ['string', 'null'], description: 'Opaque base64url cursor; null = end' }
  ```
- `PostChatMessageRequest`:
  ```yaml
  type: object
  required: [kind, body]
  properties:
    kind: { type: string, enum: [text] } # system rejected from client input
    body: { type: string, minLength: 1, maxLength: 4096 }
    targetMembershipId: { type: ['string', 'null'] }
  ```
- `EditChatMessageRequest`:
  ```yaml
  type: object
  required: [body]
  properties:
    body: { type: string, minLength: 1, maxLength: 4096 }
  ```
- `ChatConversationSummary`:
  ```yaml
  type: object
  required: [conversationKey, kind, unreadCount, lastMessageAt]
  properties:
    conversationKey: { type: string, description: "'broadcast' or a membershipId" }
    kind: { type: string, enum: [broadcast, whisper] }
    partnerMembershipId: { type: ['string', 'null'] }
    partnerDisplayName: { type: ['string', 'null'] }
    partnerCharacterName: { type: ['string', 'null'] }
    lastMessageAt: { type: ['string', 'null'], format: date-time }
    unreadCount: { type: integer, minimum: 0 }
  ```
- `ChatConversationList`:
  ```yaml
  type: object
  required: [items]
  properties:
    items: { type: array, items: { $ref: '#/components/schemas/ChatConversationSummary' } }
  ```
- `MarkReadRequest`:
  ```yaml
  type: object
  required: [lastReadAt]
  properties:
    lastReadAt: { type: string, format: date-time }
  ```
- `ChatBlockRequest`:
  ```yaml
  type: object
  required: [targetMembershipId]
  properties:
    targetMembershipId: { type: string }
  ```
- `ChatBlockSummary`:
  ```yaml
  type: object
  required: [targetMembershipId, createdAt]
  properties:
    targetMembershipId: { type: string }
    targetDisplayName: { type: ['string', 'null'] }
    createdAt: { type: string, format: date-time }
  ```

### Step 1.2 — REST routes

Add under `paths:` (use same `security: [cookieAuth, bearerAuth]` block as `members` routes; reuse `$ref: "#/components/parameters/GameSessionId"`):

| Method | Path                                                                       | Op ID                      | Body                     | Response 200/201                | Notes                                                                                                                               |
| ------ | -------------------------------------------------------------------------- | -------------------------- | ------------------------ | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| POST   | `/game-sessions/{gameSessionId}/chat/messages`                             | `postChatMessage`          | `PostChatMessageRequest` | `ChatMessage` (201)             | 403 `urn:problem-type:CHAT_TARGET_BLOCKED`; 404 `urn:problem-type:CHAT_TARGET_NOT_MEMBER`; 429 `urn:problem-type:CHAT_RATE_LIMITED` |
| GET    | `/game-sessions/{gameSessionId}/chat/messages`                             | `listChatMessages`         | —                        | `ChatMessageList`               | query `conversation: string = "broadcast"`, `cursor: string?`, `limit: int 1..100 = 50`                                             |
| GET    | `/game-sessions/{gameSessionId}/chat/conversations`                        | `listChatConversations`    | —                        | `ChatConversationList`          | member-only                                                                                                                         |
| POST   | `/game-sessions/{gameSessionId}/chat/conversations/{conversationKey}/read` | `markChatConversationRead` | `MarkReadRequest`        | 204                             | path param `conversationKey` URL-encoded; `broadcast` or `membershipId`                                                             |
| GET    | `/chat/messages/{id}`                                                      | `getChatMessage`           | —                        | `ChatMessage`                   | 404 if not visible to caller                                                                                                        |
| PATCH  | `/chat/messages/{id}`                                                      | `editChatMessage`          | `EditChatMessageRequest` | `ChatMessage`                   | 422 `urn:problem-type:CHAT_EDIT_WINDOW_EXPIRED`; 403 if not author                                                                  |
| DELETE | `/chat/messages/{id}`                                                      | `deleteChatMessage`        | —                        | 204                             | kind-aware authz (author always; GM only for broadcast)                                                                             |
| POST   | `/game-sessions/{gameSessionId}/blocks`                                    | `blockMember`              | `ChatBlockRequest`       | 204                             |                                                                                                                                     |
| DELETE | `/game-sessions/{gameSessionId}/blocks/{targetMembershipId}`               | `unblockMember`            | —                        | 204                             |                                                                                                                                     |
| GET    | `/game-sessions/{gameSessionId}/blocks`                                    | `listBlocks`               | —                        | `{ items: ChatBlockSummary[] }` |                                                                                                                                     |

All session-scoped routes use the same `tags: [game-sessions]` as Stream B routes for grouping, except the two `/chat/messages/{id}` direct routes which use `tags: [chat]` (introduce new tag).

### Step 1.3 — AsyncAPI 0.11.0 → 0.12.0

Add to `channels:` in `packages/specs/asyncapi/centrifugo.yaml`:

```yaml
sessionChatChannel:
  address: 'session.{gameSessionId}.chat'
  parameters:
    gameSessionId:
      description: GameSession id.
      location: $message.payload#/gameSessionId
  messages:
    chatMessagePosted:
      $ref: '#/components/messages/ChatMessagePosted'
    chatMessageEdited:
      $ref: '#/components/messages/ChatMessageEdited'
    chatMessageDeleted:
      $ref: '#/components/messages/ChatMessageDeleted'

sessionMemberChannel:
  address: 'session.{gameSessionId}.member.{membershipId}'
  parameters:
    gameSessionId: { description: GameSession id, location: $message.payload#/gameSessionId }
    membershipId:
      { description: GameSessionMembership id, location: $message.payload#/membershipId }
  messages:
    chatMessagePosted: { $ref: '#/components/messages/ChatMessagePosted' }
    chatMessageEdited: { $ref: '#/components/messages/ChatMessageEdited' }
    chatMessageDeleted: { $ref: '#/components/messages/ChatMessageDeleted' }
```

Add to `components.messages`:

```yaml
ChatMessagePosted:
  name: chat.message.posted
  payload: { $ref: '#/components/schemas/ChatMessage' }
ChatMessageEdited:
  name: chat.message.edited
  payload: { $ref: '#/components/schemas/ChatMessage' }
ChatMessageDeleted:
  name: chat.message.deleted
  payload:
    type: object
    required: [id, gameSessionId, deletedAt]
    properties:
      id: { type: string }
      gameSessionId: { type: string }
      targetMembershipId: { type: ['string', 'null'] }
      deletedAt: { type: string, format: date-time }
```

Add `ChatMessage` schema inline under AsyncAPI `components.schemas` (duplicate of REST shape — keep them aligned).

### Step 1.4 — Validate + bundle + codegen

- [ ] Run: `pnpm spec:validate`
- [ ] Run: `pnpm spec:bundle`
- [ ] Run: `pnpm spec:codegen`
- [ ] Verify `packages/api-client-ts/src/realtime/channels.ts` now includes `'session.{gameSessionId}.chat'` and `'session.{gameSessionId}.member.{membershipId}'` in `RealtimeChannel` union + `RealtimeChannelPayloadMap`.
- [ ] Verify Dart `packages/api-client-dart/lib/generated/` has new operation methods (search for `postChatMessage` in `lib/src/api/*.dart`).

### Step 1.5 — Commit

```bash
git add packages/specs/openapi/openapi.yaml packages/specs/asyncapi/centrifugo.yaml
git commit -m "spec(chat): OpenAPI 1.8.0 + AsyncAPI 0.12.0 — chat REST + channels"

git add packages/api-client-ts/src/generated packages/api-client-ts/src/realtime/channels.ts \
        packages/api-client-dart/lib/generated packages/specs/src/openapi-types.ts
git commit -m "chore(codegen): regenerate clients for chat spec (1.8.0 / 0.12.0)"
```

**Exit criteria:** `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen` is a no-op on a clean tree (drift-free).

---

## Task 2 — Prisma migration

**Owner agent:** `backend-engineer`.

**Files:**

- Modify: `apps/backend/prisma/schema.prisma` — add 3 models + relations on `GameSession`, `GameSessionMembership`
- Create: `apps/backend/prisma/migrations/20260517000001_add_chat_tables/migration.sql`

### Step 2.1 — Schema diff

Add to `model GameSession`:

```prisma
chatMessages       ChatMessage[]
chatBlocks         ChatBlock[]
```

Add to `model GameSessionMembership`:

```prisma
authoredMessages   ChatMessage[]    @relation("ChatAuthor")
receivedWhispers   ChatMessage[]    @relation("ChatTarget")
chatReadCursors    ChatReadCursor[]
blocksAuthored     ChatBlock[]      @relation("ChatBlocker")
blocksReceived     ChatBlock[]      @relation("ChatBlocked")
```

Append new models at the end of `schema.prisma` (before any `enum` block):

```prisma
model ChatMessage {
  id                  String                 @id @default(cuid())
  gameSessionId       String
  gameSession         GameSession            @relation(fields: [gameSessionId], references: [id], onDelete: Cascade)
  authorMembershipId  String?
  author              GameSessionMembership? @relation("ChatAuthor", fields: [authorMembershipId], references: [id], onDelete: SetNull)
  targetMembershipId  String?
  target              GameSessionMembership? @relation("ChatTarget", fields: [targetMembershipId], references: [id], onDelete: SetNull)
  kind                String                 // "text" | "system"
  body                String?
  systemKey           String?
  systemParams        Json?
  createdAt           DateTime               @default(now())
  editedAt            DateTime?
  deletedAt           DateTime?

  @@index([gameSessionId, createdAt])
  @@index([gameSessionId, authorMembershipId, targetMembershipId, createdAt])
  @@map("chat_message")
}

model ChatReadCursor {
  membershipId    String
  membership      GameSessionMembership @relation(fields: [membershipId], references: [id], onDelete: Cascade)
  conversationKey String
  lastReadAt      DateTime

  @@id([membershipId, conversationKey])
  @@map("chat_read_cursor")
}

model ChatBlock {
  id                  String                @id @default(cuid())
  gameSessionId       String
  gameSession         GameSession           @relation(fields: [gameSessionId], references: [id], onDelete: Cascade)
  blockerMembershipId String
  blocker             GameSessionMembership @relation("ChatBlocker", fields: [blockerMembershipId], references: [id], onDelete: Cascade)
  blockedMembershipId String
  blocked             GameSessionMembership @relation("ChatBlocked", fields: [blockedMembershipId], references: [id], onDelete: Cascade)
  createdAt           DateTime              @default(now())

  @@unique([gameSessionId, blockerMembershipId, blockedMembershipId])
  @@index([gameSessionId, blockedMembershipId])
  @@map("chat_block")
}
```

### Step 2.2 — Generate migration

- [ ] From repo root (backend container is up; see CLAUDE.md):
  ```bash
  docker compose -f docker/compose.yml exec backend pnpm prisma:migrate -- --name add_chat_tables --create-only
  ```
  (`--create-only` writes the SQL without applying — review before applying.)
- [ ] Open the generated `migration.sql`. Confirm:
  - `CREATE TABLE chat_message`, `chat_read_cursor`, `chat_block`
  - Two indexes on `chat_message`
  - Unique + index on `chat_block`
  - All `ON DELETE` clauses match the schema (`CASCADE` for session FK; `SET NULL` for author/target FKs)
  - No stray `BEGIN/COMMIT` lines (Prisma engine wraps each migration).
- [ ] Apply: `docker compose -f docker/compose.yml exec backend pnpm prisma:migrate` (no `--create-only` this time).
- [ ] Restart backend: `docker compose -f docker/compose.yml restart backend` (per `feedback_prisma_in_container.md` memory).
- [ ] Sanity: `docker compose -f docker/compose.yml exec backend pnpm prisma:generate` exits 0.

### Step 2.3 — Commit

```bash
git add apps/backend/prisma/schema.prisma apps/backend/prisma/migrations/20260517000001_add_chat_tables
git commit -m "feat(backend): chat Prisma models — ChatMessage, ChatReadCursor, ChatBlock"
```

**Exit criteria:** `docker compose ... exec backend pnpm prisma migrate status` reports no pending migrations.

---

## Task 3 — ChatModule domain layer

**Owner agent:** `backend-engineer`.

**Files:**

- Create: `apps/backend/src/modules/chat/domain/chat.errors.ts`
- Create: `apps/backend/src/modules/chat/domain/chat.ports.ts` (read models + port interfaces)
- Create: `apps/backend/src/modules/chat/domain/chat.mapper.ts`
- Modify: `apps/backend/src/common/config/app-config.ts` — add `get chat(): ChatConfig`

### Step 3.1 — Errors

Mirror `apps/backend/src/modules/memberships/domain/membership.errors.ts` exactly (extend `DomainError`, each with `status` + `code` + optional `detail`):

| Class                           | Status | Code                                                                                              |
| ------------------------------- | ------ | ------------------------------------------------------------------------------------------------- |
| `ChatMessageNotFoundError`      | 404    | `CHAT_MESSAGE_NOT_FOUND`                                                                          |
| `ChatMessageNotAuthorizedError` | 403    | `CHAT_MESSAGE_NOT_AUTHORIZED`                                                                     |
| `ChatEditWindowExpiredError`    | 422    | `CHAT_EDIT_WINDOW_EXPIRED`                                                                        |
| `ChatBodyEmptyError`            | 422    | `CHAT_BODY_EMPTY`                                                                                 |
| `ChatBodyTooLargeError`         | 413    | `CHAT_BODY_TOO_LARGE`                                                                             |
| `ChatTargetNotMemberError`      | 404    | `CHAT_TARGET_NOT_MEMBER`                                                                          |
| `ChatTargetBlockedError`        | 403    | `CHAT_TARGET_BLOCKED` (detail = generic "not accepting messages" — never leak which side blocked) |
| `ChatRateLimitedError`          | 429    | `CHAT_RATE_LIMITED`                                                                               |
| `ChatNotMemberError`            | 403    | `CHAT_NOT_MEMBER`                                                                                 |

### Step 3.2 — Ports + read models

`chat.ports.ts`:

```typescript
export type ConversationKey = 'broadcast' | string; // 'broadcast' or membershipId

export type ChatMessageKind = 'text' | 'system';

export interface ChatMessageReadModel {
  id: string;
  gameSessionId: string;
  authorMembershipId: string | null;
  authorDisplayName: string | null;
  targetMembershipId: string | null;
  kind: ChatMessageKind;
  body: string | null;
  systemKey: string | null;
  systemParams: Record<string, unknown> | null;
  createdAt: string;
  editedAt: string | null;
  deletedAt: string | null;
}

export interface ConversationSummaryReadModel {
  conversationKey: ConversationKey;
  kind: 'broadcast' | 'whisper';
  partnerMembershipId: string | null;
  partnerDisplayName: string | null;
  partnerCharacterName: string | null;
  lastMessageAt: string | null;
  unreadCount: number;
}

export interface ChatBlockSummaryReadModel {
  targetMembershipId: string;
  targetDisplayName: string | null;
  createdAt: string;
}

export interface ListMessagesArgs {
  gameSessionId: string;
  callerMembershipId: string;
  conversation: ConversationKey;
  cursor: string | null;
  limit: number;
}

export const CHAT_MESSAGE_REPO = Symbol('CHAT_MESSAGE_REPO');
export interface IChatMessageRepo {
  insert(data: {
    gameSessionId: string;
    authorMembershipId: string | null;
    targetMembershipId: string | null;
    kind: ChatMessageKind;
    body: string | null;
    systemKey: string | null;
    systemParams: Record<string, unknown> | null;
  }): Promise<ChatMessageReadModel>;

  findById(id: string): Promise<ChatMessageReadModel | null>;
  updateBody(id: string, body: string, editedAt: Date): Promise<ChatMessageReadModel>;
  softDelete(id: string, deletedAt: Date): Promise<ChatMessageReadModel>;
  list(
    args: ListMessagesArgs,
  ): Promise<{ items: ChatMessageReadModel[]; nextCursor: string | null }>;
  listConversations(args: {
    gameSessionId: string;
    callerMembershipId: string;
  }): Promise<ConversationSummaryReadModel[]>;
}

export const CHAT_READ_CURSOR_REPO = Symbol('CHAT_READ_CURSOR_REPO');
export interface IChatReadCursorRepo {
  upsert(args: {
    membershipId: string;
    conversationKey: ConversationKey;
    lastReadAt: Date;
  }): Promise<void>;
  getMap(args: {
    membershipId: string;
    keys: ConversationKey[];
  }): Promise<Map<ConversationKey, Date>>;
}

export const CHAT_BLOCK_REPO = Symbol('CHAT_BLOCK_REPO');
export interface IChatBlockRepo {
  exists(args: {
    gameSessionId: string;
    blockerMembershipId: string;
    blockedMembershipId: string;
  }): Promise<boolean>;
  insert(args: {
    gameSessionId: string;
    blockerMembershipId: string;
    blockedMembershipId: string;
  }): Promise<void>;
  delete(args: {
    gameSessionId: string;
    blockerMembershipId: string;
    blockedMembershipId: string;
  }): Promise<void>;
  listForBlocker(args: {
    gameSessionId: string;
    blockerMembershipId: string;
  }): Promise<ChatBlockSummaryReadModel[]>;
}

export const CHAT_RATE_LIMITER = Symbol('CHAT_RATE_LIMITER');
export interface IChatRateLimiter {
  /** Throws ChatRateLimitedError if the user exceeded 30/min or the 5/s burst. */
  consume(userId: string, now: Date): Promise<void>;
}
```

### Step 3.3 — Mapper

`chat.mapper.ts` exports `toChatMessageReadModel(row: ChatMessageRow, authorDisplayName: string | null): ChatMessageReadModel` — uses the same `MEMBERSHIP_SELECT`-style pattern as `membership.mapper.ts`. Plus a `toConversationSummary(...)` helper that consumes a `(membershipId, lastMessageAt, unreadCount, partner)` tuple.

### Step 3.4 — Cursor codec

Add `apps/backend/src/modules/chat/domain/chat-cursor.ts`:

```typescript
// Base64url-encoded { createdAt: ISO-8601, id: string }. Strict round-trip.
export function encodeCursor(input: { createdAt: string; id: string }): string {
  return Buffer.from(JSON.stringify(input), 'utf8').toString('base64url');
}

export function decodeCursor(input: string): { createdAt: string; id: string } {
  const raw = JSON.parse(Buffer.from(input, 'base64url').toString('utf8'));
  if (typeof raw?.createdAt !== 'string' || typeof raw?.id !== 'string') {
    throw new Error('Invalid cursor');
  }
  return raw;
}
```

Co-located spec `chat-cursor.spec.ts` — 3 tests (round-trip; rejects non-JSON; rejects missing fields).

### Step 3.5 — AppConfig

Modify `apps/backend/src/common/config/app-config.ts` — append:

```typescript
get chat(): ChatConfig {
  return {
    maxBodyBytes: this.numberOrDefault('CHAT_MAX_BODY_BYTES', 4096),
    maxMessagesPerMinute: this.numberOrDefault('CHAT_RATE_LIMIT_PER_MINUTE', 30),
    burst: this.numberOrDefault('CHAT_RATE_LIMIT_BURST', 5),
    editWindowSeconds: this.numberOrDefault('CHAT_EDIT_WINDOW_SECONDS', 300),
  };
}
```

Add `ChatConfig` interface at top of file alongside `CentrifugoConfig`.

### Step 3.6 — Commit

```bash
git add apps/backend/src/modules/chat/domain apps/backend/src/common/config/app-config.ts
git commit -m "feat(backend): chat domain — errors, ports, read models, cursor codec, config"
```

**Exit criteria:** `pnpm --filter @app/backend typecheck` is green; `chat-cursor.spec.ts` passes.

---

## Task 4 — ChatModule infra (Prisma repos + rate limiter)

**Owner agent:** `backend-engineer`.

**Files:**

- Create: `apps/backend/src/modules/chat/infra/chat-message.repo.ts`
- Create: `apps/backend/src/modules/chat/infra/chat-read-cursor.repo.ts`
- Create: `apps/backend/src/modules/chat/infra/chat-block.repo.ts`
- Create: `apps/backend/src/modules/chat/infra/chat-rate-limiter.service.ts`
- Create: each repo's `*.spec.ts` (Prisma-mocked: `vi.fn()` on `prisma.chatMessage.findMany` etc.)

### Step 4.1 — ChatMessageRepo

Implements `IChatMessageRepo`. Selects use `Prisma.ChatMessageSelect` constant `CHAT_MESSAGE_SELECT` analogous to `MEMBERSHIP_SELECT`. Author display-name resolution: include `author: { select: { displayName: true } }` (join through membership → `User`).

`list()` logic:

- For `conversation === 'broadcast'`: `where: { gameSessionId, targetMembershipId: null }`.
- For whisper: `where: { gameSessionId, OR: [ { authorMembershipId: caller, targetMembershipId: partner }, { authorMembershipId: partner, targetMembershipId: caller } ] }`.
- `orderBy: [{ createdAt: 'desc' }, { id: 'desc' }]`.
- Cursor: when present, decode and add `where.AND.push({ OR: [{ createdAt: { lt: cursor.createdAt } }, { createdAt: cursor.createdAt, id: { lt: cursor.id } }] })`.
- Take `limit + 1` to detect "more"; if returned > limit, the last item is dropped from `items` and used as `nextCursor`.

`listConversations()` logic:

- Single SQL via `$queryRaw` is fine; or pure Prisma: distinct `targetMembershipId` from messages where `(authorMembershipId === caller OR targetMembershipId === caller) AND targetMembershipId IS NOT NULL`, then for each partner do `findFirst({ orderBy: createdAt desc })` to get `lastMessageAt` + count `>= caller's lastReadAt` for `unreadCount`. The read-cursor lookup is performed by the caller (query handler), not the repo — repo returns raw partners + lastMessageAt + counts.

### Step 4.2 — ChatReadCursorRepo

`upsert` uses `prisma.chatReadCursor.upsert` keyed on the composite `(membershipId, conversationKey)`. `getMap` runs `findMany({ where: { membershipId, conversationKey: { in: keys } } })` and returns `new Map`.

### Step 4.3 — ChatBlockRepo

Trivial wrappers around `prisma.chatBlock.{count,create,delete,findMany}`. `delete` uses the `@@unique` key (Prisma `where: { gameSessionId_blockerMembershipId_blockedMembershipId: {...} }`).

### Step 4.4 — ChatRateLimiterService

In-memory two-bucket per-user algorithm (single-node v1.1 only; documented as such in a JSDoc):

```typescript
@Injectable()
export class ChatRateLimiterService implements IChatRateLimiter {
  private readonly minute = new Map<string, { count: number; windowStartMs: number }>();
  private readonly burst = new Map<string, { count: number; windowStartMs: number }>();
  constructor(private readonly config: AppConfig) {}

  async consume(userId: string, now: Date): Promise<void> {
    const nowMs = now.getTime();
    const { maxMessagesPerMinute, burst } = this.config.chat;
    this.tick(this.minute, userId, nowMs, 60_000, maxMessagesPerMinute);
    this.tick(this.burst, userId, nowMs, 1_000, burst);
  }

  private tick(
    map: Map<string, { count: number; windowStartMs: number }>,
    key: string,
    nowMs: number,
    windowMs: number,
    limit: number,
  ): void {
    const slot = map.get(key);
    if (!slot || nowMs - slot.windowStartMs >= windowMs) {
      map.set(key, { count: 1, windowStartMs: nowMs });
      return;
    }
    if (slot.count >= limit) {
      throw new ChatRateLimitedError();
    }
    slot.count += 1;
  }
}
```

Spec (`chat-rate-limiter.service.spec.ts`) — 5 tests: under limit OK; at minute limit throws; burst limit independent; window reset after 60s; separate users don't share buckets. Uses `vi.useFakeTimers` for time control or explicit `now` injection (the `consume` signature accepts `now: Date` for this reason).

### Step 4.5 — Commit

```bash
git add apps/backend/src/modules/chat/infra
git commit -m "feat(backend): chat infra — Prisma repos + in-memory rate limiter"
```

**Exit criteria:** spec sweep for `chat/infra/**` is green; typecheck clean.

---

## Task 5 — Commands (TDD)

**Owner agent:** `backend-engineer`.

Each command follows the `memberships/commands/` pattern: command class (data), `@CommandHandler` class, co-located `*.spec.ts` with port mocks. Implement TEST FIRST, then handler. Commit per command.

### 5.1 — PostChatMessageCommand

`PostChatMessageCommand { gameSessionId, userId, authorMembershipId, targetMembershipId, body }` (caller resolves `authorMembershipId` from `userId + gameSessionId` in the controller).

Handler logic:

1. `await rateLimiter.consume(userId, now())`
2. Trim `body`; reject empty → `ChatBodyEmptyError`. Reject `body.length * 4 > maxBodyBytes` cheap check, or `Buffer.byteLength(body, 'utf8') > maxBodyBytes` → `ChatBodyTooLargeError`.
3. If `targetMembershipId`:
   - `findActiveByUser`-style: load target membership via `membershipRepo.findById`; if `null` or `leftAt != null` or `gameSessionId mismatch` → `ChatTargetNotMemberError`.
   - `await blockRepo.exists({ gameSessionId, blockerMembershipId: targetMembershipId, blockedMembershipId: authorMembershipId })` → if true, `ChatTargetBlockedError`. (Authoring side never sees a special block error; generic detail per design.)
4. `const row = await chatRepo.insert({ ...kind: 'text', body: trimmed })`.
5. `eventBus.publish(new ChatMessagePostedEvent(row))`.
6. Return `row`.

Tests (7): success broadcast; success whisper; empty body 422; oversize body 413; non-member target 404; blocked target 403; rate-limited 429.

### 5.2 — EditChatMessageCommand

Logic:

1. Load message → 404 if missing or `deletedAt != null`.
2. Visibility (whisper): caller must be author or target (else 404 — non-existence over forbidden).
3. Authorship: only author can edit → `ChatMessageNotAuthorizedError` if not author.
4. Edit window: `now - createdAt > editWindowSeconds * 1000` → `ChatEditWindowExpiredError`.
5. Body validation (same as post).
6. `await chatRepo.updateBody(id, body, now)`.
7. `eventBus.publish(new ChatMessageEditedEvent(row))`.

Tests (6): success; not found 404; not author 403; window expired 422; empty body 422; whisper bystander 404.

### 5.3 — DeleteChatMessageCommand

Logic:

1. Load message → 404 if missing or already `deletedAt != null`.
2. Visibility check same as edit.
3. Kind-aware authz:
   - `targetMembershipId == null` (broadcast): allow if `caller === author` OR `caller is GM of session`.
   - `targetMembershipId != null` (whisper): allow ONLY if `caller === author`. **No GM bypass branch** — covered by Feature 11.6.1.b acceptance.
4. `chatRepo.softDelete(id, now)`.
5. `eventBus.publish(new ChatMessageDeletedEvent({ id, gameSessionId, targetMembershipId, deletedAt: now }))`.

Tests (7): author deletes own broadcast; GM deletes player's broadcast; non-GM non-author 403; author deletes own whisper; GM cannot delete whisper (404 visibility-wise, but as the GM has no visibility, the request returns 404, not 403 — assert 404 here); whisper bystander 404; already-deleted 404.

### 5.4 — PostSystemMessageCommand (internal-only)

NOT exposed via HTTP. Consumed by Stream D event handlers (Feature 11.7). Stream C ships the command + handler stub so the contract is available.

Logic: insert `kind: 'system', body: null, systemKey, systemParams`; emit `ChatMessagePostedEvent`. No rate limit. No blocking. `targetMembershipId` is always `null`.

Tests (2): success; rejects `targetMembershipId != null` (defensive — system messages are always broadcast).

### 5.5 — MarkConversationReadCommand

Logic:

1. Validate caller membership in session (`findActiveByUser`) → `ChatNotMemberError` 403 if absent.
2. If `conversationKey !== 'broadcast'`: validate the keyed membership is in same session (else `ChatTargetNotMemberError` 404).
3. `readCursorRepo.upsert({ membershipId: callerMembershipId, conversationKey, lastReadAt })`.

Tests (4): broadcast OK; whisper key OK; non-member 403; invalid key 404.

### 5.6 — BlockMemberCommand + UnblockMemberCommand

`BlockMember`: validate both memberships in same session; refuse self-block (`ChatMessageNotAuthorizedError` reused with detail "cannot block yourself" — or new `ChatCannotBlockSelfError` 422 if you prefer separate code); `blockRepo.insert` (idempotent — catch `P2002` unique violation, no-op).

`UnblockMember`: `blockRepo.delete`; idempotent (no error if no row).

Tests: 3 each (success; not member of session 403; self-block 422 OR no-op idempotent on unblock).

### 5.7 — Commit cadence

One commit per command after its tests are green:

```bash
git add apps/backend/src/modules/chat/commands/post-chat-message.*
git commit -m "feat(backend): PostChatMessageCommand — broadcast + whisper + block/rate-limit guards"
# … repeat for the other 6 commands
```

**Exit criteria:** all 7 command spec files green; `pnpm --filter @app/backend test --run` shows full handler-spec coverage.

---

## Task 6 — Queries (TDD)

**Owner agent:** `backend-engineer`. May run in parallel with Task 5 (no overlap).

### 6.1 — ListChatMessagesQuery

`ListChatMessagesQuery { gameSessionId, callerUserId, conversation, cursor, limit }`.

Handler:

1. Resolve caller's active membership id (via `membershipRepo.findActiveByUser`). Absent → `ChatNotMemberError` 403.
2. If `conversation !== 'broadcast'`: validate partner membership in same session; if missing → return `{ items: [], nextCursor: null }` (treat unknown partner as empty result; design note: chose empty over 404 for list reads to avoid leaking presence). Document this decision inline.
3. Delegate to `chatRepo.list({ ...callerMembershipId, conversation, cursor: decoded, limit: clamp(limit ?? 50, 1, 100) })`.

Tests (5): broadcast pagination; whisper pagination; same-ms tie-break by id; non-member 403; unknown partner → empty.

### 6.2 — ListConversationsQuery

Handler:

1. Resolve caller's membership (else 403).
2. `chatRepo.listConversations({ gameSessionId, callerMembershipId })` returns partners with `lastMessageAt` and `unreadCount` derived against the per-conversation read cursor (the query handler also pulls `readCursorRepo.getMap` and applies subtraction).
3. Always prepend the broadcast row (synthetic conversation: key `'broadcast'`, kind `'broadcast'`, no partner; `unreadCount` derived from broadcast read cursor).

Tests (4): includes broadcast; lists distinct whisper partners; respects read cursor; non-member 403.

### 6.3 — GetChatMessageQuery

Handler: load by id → enforce visibility:

- `kind === 'system'` or `targetMembershipId === null`: caller must be member of `gameSessionId`. Else 404.
- Whisper: caller must be author OR target. Else **404** (the bystander cannot distinguish "not allowed" from "doesn't exist" — privacy contract).

Tests (4): broadcast visible to member; broadcast 404 to non-member; whisper visible to author; whisper 404 to bystander (and 404 to a GM who is not author/target).

### 6.4 — ListBlocksQuery

Handler: resolve caller's membership; `blockRepo.listForBlocker`.

Tests (2): owns list; non-member 403.

### 6.5 — Commit cadence

```bash
git add apps/backend/src/modules/chat/queries/list-chat-messages.*
git commit -m "feat(backend): ListChatMessagesQuery — cursor pagination + whisper scoping"
# … 3 more commits
```

**Exit criteria:** all 4 query specs green.

---

## Task 7 — Realtime: events + publisher + ACL widening

**Owner agent:** `backend-engineer`.

**Files:**

- Create: `apps/backend/src/modules/chat/events/chat-message-posted.event.ts`
- Create: `apps/backend/src/modules/chat/events/chat-message-edited.event.ts`
- Create: `apps/backend/src/modules/chat/events/chat-message-deleted.event.ts`
- Create: `apps/backend/src/modules/chat/events/chat-realtime.publisher.ts` (3× `@EventsHandler`)
- Create: `apps/backend/src/modules/chat/events/chat-realtime.publisher.spec.ts`
- Modify: `apps/backend/src/modules/realtime/realtime.service.ts` — widen `buildAllowedChannels`
- Modify: `apps/backend/src/modules/realtime/infra/session-access.repo.ts` — add `findMembershipsForUser(userId)` returning `[{ gameSessionId, membershipId }]`
- Modify: `apps/backend/src/modules/realtime/domain/session-ownership.port.ts` — port addition
- Modify spec: `apps/backend/src/modules/realtime/realtime.service.spec.ts` — kicked-token + chat-ACL regressions

### Step 7.1 — Events

```typescript
export class ChatMessagePostedEvent {
  constructor(public readonly message: ChatMessageReadModel) {}
}
export class ChatMessageEditedEvent {
  constructor(public readonly message: ChatMessageReadModel) {}
}
export class ChatMessageDeletedEvent {
  constructor(
    public readonly payload: {
      id: string;
      gameSessionId: string;
      targetMembershipId: string | null;
      deletedAt: string;
    },
  ) {}
}
```

### Step 7.2 — Publisher

Single class with three `@EventsHandler(...)` decorators (one class can implement multiple — declare three separate classes in the file if cleaner).

Routing rule:

- `targetMembershipId === null` ⇒ `centrifugo.publish('session.<id>.chat', payload)`.
- `targetMembershipId !== null` AND `authorMembershipId !== null` ⇒ publish twice: `session.<id>.member.<authorMembershipId>` AND `session.<id>.member.<targetMembershipId>`. Same payload object.
- Whispers NEVER hit `session.<id>.chat`.
- Each publish wrapped in try/catch — log + swallow (matches `update-dp.handler.ts` non-fatal pattern).

### Step 7.3 — ACL widening

`session-ownership.port.ts` addition:

```typescript
export interface UserMembership {
  gameSessionId: string;
  membershipId: string;
}
export interface ISessionAccessRepo {
  findActiveSessionIdsForUser(userId: string): Promise<string[]>; // existing
  findActiveMembershipsForUser(userId: string): Promise<UserMembership[]>; // new
}
```

`session-access.repo.ts` — new method:

```typescript
async findActiveMembershipsForUser(userId: string): Promise<UserMembership[]> {
  const rows = await this.prisma.gameSessionMembership.findMany({
    where: { userId, leftAt: null },
    select: { id: true, gameSessionId: true },
  });
  return rows.map((r) => ({ gameSessionId: r.gameSessionId, membershipId: r.id }));
}
```

`realtime.service.ts` — replace `buildAllowedChannels`:

```typescript
private async buildAllowedChannels(userId: string): Promise<string[]> {
  const memberships = await this.sessionAccess.findActiveMembershipsForUser(userId);
  const channels: string[] = [];
  for (const m of memberships) {
    channels.push(`session.${m.gameSessionId}`);
    channels.push(`session.${m.gameSessionId}.chat`);
    channels.push(`session.${m.gameSessionId}.member.${m.membershipId}`);
  }
  return channels;
}
```

### Step 7.4 — Tests

`realtime.service.spec.ts` — add:

- Active member of two sessions ⇒ JWT `channels` claim has 6 entries (3 per session).
- Kicked member's next token ⇒ session no longer present in any of the three channel families.
- Member of session A is NOT issued any `session.B.*` channel.

`chat-realtime.publisher.spec.ts` — 5 tests:

- Broadcast → 1 publish call, channel matches `session.<id>.chat`.
- Whisper → 2 publish calls, distinct member channels, same payload identity.
- Whisper to self (author === target) → 1 publish (dedupe).
- Edit on broadcast → 1 publish, channel `session.<id>.chat`.
- Centrifugo throwing → publisher does not rethrow (caller — the command handler — has already returned 201).

### Step 7.5 — Commit

```bash
git add apps/backend/src/modules/chat/events \
        apps/backend/src/modules/realtime/realtime.service.ts \
        apps/backend/src/modules/realtime/realtime.service.spec.ts \
        apps/backend/src/modules/realtime/infra/session-access.repo.ts \
        apps/backend/src/modules/realtime/domain/session-ownership.port.ts
git commit -m "feat(backend): chat realtime — events + publisher + ACL widening for chat + member channels"
```

**Exit criteria:** publisher spec + realtime regression spec green.

---

## Task 8 — Controllers + module wiring

**Owner agent:** `backend-engineer`.

**Files:**

- Create: `apps/backend/src/modules/chat/http/chat-messages.controller.ts` — `@Controller('game-sessions/:gameSessionId/chat')`
- Create: `apps/backend/src/modules/chat/http/chat-message.controller.ts` — `@Controller('chat/messages')` (single-message routes)
- Create: `apps/backend/src/modules/chat/http/chat-conversations.controller.ts` — `@Controller('game-sessions/:gameSessionId/chat/conversations')` (covers list + `/:key/read`)
- Create: `apps/backend/src/modules/chat/http/chat-blocks.controller.ts` — `@Controller('game-sessions/:gameSessionId/blocks')`
- Create: `apps/backend/src/modules/chat/http/dto/*` — `class-validator` request DTOs mirroring spec
- Create: `apps/backend/src/modules/chat/chat.module.ts`
- Modify: `apps/backend/src/app.module.ts` — register `ChatModule`

### Step 8.1 — DTOs (class-validator)

```typescript
// post-chat-message.dto.ts
export class PostChatMessageDto {
  @IsString() @IsIn(['text']) kind!: 'text';
  @IsString() @MinLength(1) @MaxLength(4096) body!: string;
  @IsOptional() @IsString() targetMembershipId?: string;
}
```

Similar for `EditChatMessageDto`, `MarkReadDto { @IsISO8601() lastReadAt }`, `ChatBlockDto { @IsString() targetMembershipId }`.

### Step 8.2 — Controllers

Pattern (mirror `memberships.controller.ts` exactly):

```typescript
@Controller('game-sessions/:gameSessionId/chat')
export class ChatMessagesController {
  constructor(
    private readonly commandBus: CommandBus,
    private readonly queryBus: QueryBus,
    @Inject(MEMBERSHIP_REPO) private readonly memberships: IMembershipRepo,
  ) {}

  @Post('messages')
  @HttpCode(HttpStatus.CREATED)
  async post(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
    @Body() dto: PostChatMessageDto,
  ): Promise<ChatMessageReadModel> {
    const membership = await this.memberships.findActiveByUser(gameSessionId, req.userId);
    if (!membership) throw new ChatNotMemberError();
    return this.commandBus.execute(
      new PostChatMessageCommand(
        gameSessionId,
        req.userId,
        membership.id,
        dto.targetMembershipId ?? null,
        dto.body,
      ),
    );
  }

  @Get('messages')
  async list(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
    @Query('conversation') conversation: string = 'broadcast',
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: string,
  ) {
    const limitN = limit !== undefined ? Number.parseInt(limit, 10) : 50;
    return this.queryBus.execute(
      new ListChatMessagesQuery(gameSessionId, req.userId, conversation, cursor ?? null, limitN),
    );
  }
}
```

Same shape for the other three controllers.

### Step 8.3 — Module composition

```typescript
@Module({
  imports: [CqrsModule, MembershipsModule], // exports MEMBERSHIP_REPO
  controllers: [
    ChatMessagesController,
    ChatMessageController,
    ChatConversationsController,
    ChatBlocksController,
  ],
  providers: [
    // commands
    PostChatMessageHandler,
    EditChatMessageHandler,
    DeleteChatMessageHandler,
    PostSystemMessageHandler,
    MarkConversationReadHandler,
    BlockMemberHandler,
    UnblockMemberHandler,
    // queries
    ListChatMessagesHandler,
    ListConversationsHandler,
    GetChatMessageHandler,
    ListBlocksHandler,
    // events
    ChatRealtimePublisher,
    // infra
    ChatMessageRepo,
    ChatReadCursorRepo,
    ChatBlockRepo,
    ChatRateLimiterService,
    { provide: CHAT_MESSAGE_REPO, useExisting: ChatMessageRepo },
    { provide: CHAT_READ_CURSOR_REPO, useExisting: ChatReadCursorRepo },
    { provide: CHAT_BLOCK_REPO, useExisting: ChatBlockRepo },
    { provide: CHAT_RATE_LIMITER, useExisting: ChatRateLimiterService },
  ],
})
export class ChatModule {}
```

### Step 8.4 — Register

`app.module.ts`: append `ChatModule` to the `imports` array next to `MembershipsModule`.

### Step 8.5 — Verify

```bash
docker compose -f docker/compose.yml restart backend
docker compose -f docker/compose.yml logs --tail=200 backend | grep -E 'Mapped|RouterExplorer'
```

Expect 10 new routes mapped under `/api/v1`. Hit each unauthenticated to confirm 401 (not 404). Confirm `express-openapi-validator` rejects a malformed POST body with 400 + problem+json.

### Step 8.6 — Commit

```bash
git add apps/backend/src/modules/chat/http apps/backend/src/modules/chat/chat.module.ts apps/backend/src/app.module.ts
git commit -m "feat(backend): wire ChatModule — 10 routes + controllers + composition root"
```

**Exit criteria:** Nest startup log shows all 10 new routes; unauth probe returns 401 with `application/problem+json`.

---

## Task 9 — Integration tests + smoke

**Owner agent:** `backend-engineer`.

**Files:**

- Create: `apps/backend/test/integration/chat-privacy.e2e-spec.ts`
- Create: `apps/backend/test/integration/chat-realtime.e2e-spec.ts` (parallel to `realtime-dp.e2e-spec.ts` — pubs on `session.<id>.chat`, sub via local-signed JWT)
- Update: `apps/backend/test/integration/realtime-dp.e2e-spec.ts` if its kick-regression assertions need adjusting for the new channel families

### Step 9.1 — Privacy regression

Test scenarios (use `request(app.getHttpServer())` style or direct supertest against booted Nest module):

1. Two members `A`, `B`, one bystander `C` in same session. `A → B` whisper.
2. `GET /chat/messages/{whisperId}` as `A` → 200.
3. `GET /chat/messages/{whisperId}` as `B` → 200.
4. `GET /chat/messages/{whisperId}` as `C` → 404 + problem+json.
5. `GET /chat/messages/{whisperId}` as GM (not author/target) → 404.
6. `DELETE /chat/messages/{whisperId}` as GM → 404 (not 403, by design — GM has no visibility).
7. `GET /chat/messages?conversation={Bmembership}` as `C` → 200 with `items: []` (no presence leak).

### Step 9.2 — Realtime privacy

Mirror `realtime-dp.e2e-spec.ts` setup. Subscribe two Centrifugo clients (A, C); A's JWT issued for session+member-A; C's JWT issued for session+member-C. `POST` a whisper A→B (via fetch against `/api/v1/...`, using Bearer test token). Assert:

- A receives one message on `session.<id>.member.<A>`.
- C receives NOTHING on any channel within a 1s window.
- B's slot would receive (not subscribed in this harness — skip and document in test comment).

### Step 9.3 — Rate-limit burst

Unit-level, but assert via the rate limiter service spec: 30 in a minute OK; 31st throws `ChatRateLimitedError`; 5 in same second OK; 6th throws.

### Step 9.4 — Edit window

Unit-level, in `EditChatMessageHandler.spec.ts` already covered by Task 5.

### Step 9.5 — Full sweep

```bash
docker compose -f docker/compose.yml exec backend pnpm test --run
pnpm --filter @app/backend typecheck
pnpm lint
```

All green.

### Step 9.6 — Manual smoke recipe

Document in PR description (and capture as comments in `chat-privacy.e2e-spec.ts`):

```sh
# 1. GM seeds invite + accepts as Player.
# 2. Player POSTs broadcast — both clients receive on session.<id>.chat.
# 3. Player A POSTs whisper to Player B — A + B receive on their per-member channels; GM client (subbed to session.<id>.chat) sees NOTHING.
# 4. GM tries DELETE on whisper id — 404.
# 5. Bystander C POSTs 31 messages in a minute — 30 succeed, 31st returns 429.
```

### Step 9.7 — Commit

```bash
git add apps/backend/test/integration/chat-privacy.e2e-spec.ts apps/backend/test/integration/chat-realtime.e2e-spec.ts
git commit -m "test(backend): chat privacy + realtime e2e regressions"
```

**Exit criteria:** Full backend test sweep green (~1020+ tests); typecheck + lint clean.

---

## Task 10 — Archive + PR

**Owner agent:** main agent (no subagent).

- [ ] Move `T-2026-05-17-PHASE-8-STREAM-C` entry from `specs/tasks/active.md` to top of `specs/tasks/done.md` with PR link, commit list, test counts, and any open follow-ups (e.g., Redis-backed rate limiter; chat search; reactions).
- [ ] `git push -u origin feat/phase-8/stream-c-chat-backend`
- [ ] Open Forgejo PR via `gh pr create` (per CLAUDE.md — `gh` is available; Forgejo at `code.homelab.local`).
- [ ] Final commit: `chore(tasks): archive Stream C`.

---

## Self-review checklist (run before dispatching to subagents)

1. **Spec coverage** — every bullet in `docs/IMPLEMENTATION_PLAN_PHASE_8.md` §11.3 + §11.4 + §11.5.g + §11.6.2 has a task above. ✅
2. **No placeholders** — every step shows the exact code or command. ✅
3. **Type consistency** — `ChatMessageReadModel`, `ConversationKey`, port names match across Tasks 3/4/5/6/8. ✅
4. **Deferred to Stream D** — UI components, system-event subscribers (Feature 11.7), chat tokens (`--chat-bubble-*`), block-UI affordance. Explicitly NOT in this plan.
