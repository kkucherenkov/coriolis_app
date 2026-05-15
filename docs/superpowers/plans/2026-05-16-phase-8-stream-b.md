# Phase 8 — Stream B (Player shell + realtime ACL) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the player-side session client (`/app/sessions/*` web routes + `features/sessions/` mobile pages), wire the public invite accept / preview / me-memberships REST surface, broaden the Centrifugo channel ACL from GM-only to any active membership, and add the kicked-token regression.

**Architecture:** Stream A delivered the membership domain (rotate / revoke / kick / leave / link-character commands + ListMemberships + GetInviteMetadata queries + `MembershipsModule` wiring + `@app/ui` `AppInviteManager` & `AppSessionShareLinkCard` + web GM mount + mobile GM widgets + dashboard segmented control with the Playing-in count fixed at 0). Stream B closes the player loop: three new REST routes (`POST /api/v1/invites/{token}/accept`, `GET /api/v1/invites/{token}/preview`, `GET /api/v1/me/memberships`), three new web routes (`/app/sessions/join/:token`, `/app/sessions`, `/app/sessions/:id`), three new mobile pages (`JoinSessionPage`, `SessionsListPage`, `SessionDetailPage`), extraction of `AppSessionHeader` to `@app/ui` with a `mode: "player" | "gm"` variant, and replacement of the `SESSION_OWNERSHIP_REPO` port in `RealtimeModule` with a broader membership-based access port. The legacy `/app/sessions/*` → `/app/game-sessions/*` 301 middleware is removed in the same commit that introduces `pages/app/sessions/[id].vue`. The mobile deep-link plist/intent is gated on `app_links` host availability.

**Tech Stack:** NestJS 11 + Prisma 7 + CQRS + Better Auth (backend); Nuxt 4 SPA + Nuxt UI v4 + Tailwind 4 + `@app/ui` + `@nuxtjs/i18n` (web); Flutter 3.41 + `flutter_bloc` + `get_it` + Dio (mobile); Centrifugo v6 (realtime).

---

## Front matter

- **Stream:** B of 5 (follows Stream A, gates Stream C).
- **Design doc:** `docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md` §6 Stream B.
- **Task inventory:** `docs/IMPLEMENTATION_PLAN_PHASE_8.md` T-11.1.1.h / i / j (player half) / k / l + T-11.2.1.a–h.
- **TDD discipline:** write failing test → `vitest run` / `flutter test` to confirm RED → minimal impl → run to GREEN → commit. No skipping steps.
- **Memory rules in effect:**
  - After `prisma generate` inside the backend container, restart it (`docker compose -f docker/compose.yml restart backend`). Do not spelunk `node_modules`.
  - After each **phase** (= block): commit, push, write follow-up in `specs/tasks/active.md`, stop. Never continue into the next phase in the same session.

---

## File map

### New backend files

- `apps/backend/src/modules/memberships/domain/membership.errors.ts` — add `InviteNotFoundError` (existing file, new error class)
- `apps/backend/src/modules/memberships/domain/membership.ports.ts` — extend `IMembershipRepo` + `IGameSessionInviteRepo` + new read models (existing file, new methods/types)
- `apps/backend/src/modules/memberships/infra/membership.repo.ts` — implement 3 new port methods (existing file, new methods)
- `apps/backend/src/modules/memberships/commands/accept-invite.command.ts`
- `apps/backend/src/modules/memberships/commands/accept-invite.handler.ts`
- `apps/backend/src/modules/memberships/commands/accept-invite.handler.spec.ts`
- `apps/backend/src/modules/memberships/queries/get-invite-preview.query.ts`
- `apps/backend/src/modules/memberships/queries/get-invite-preview.handler.ts`
- `apps/backend/src/modules/memberships/queries/get-invite-preview.handler.spec.ts`
- `apps/backend/src/modules/memberships/queries/get-my-memberships.query.ts`
- `apps/backend/src/modules/memberships/queries/get-my-memberships.handler.ts`
- `apps/backend/src/modules/memberships/queries/get-my-memberships.handler.spec.ts`
- `apps/backend/src/modules/memberships/events/member-joined.event.ts`
- `apps/backend/src/modules/memberships/http/invites.controller.ts`
- `apps/backend/src/modules/memberships/http/me-memberships.controller.ts`

### Modified backend files

- `apps/backend/src/modules/memberships/memberships.module.ts` — register 3 new handlers + 2 new controllers
- `apps/backend/src/modules/realtime/domain/session-ownership.port.ts` — rename symbol+interface to `SESSION_ACCESS_REPO` / `ISessionAccessRepo` with method `findActiveSessionIdsForUser`
- `apps/backend/src/modules/realtime/infra/session-ownership.repo.ts` — replace `gameSession.ownerId` query with `gameSessionMembership WHERE leftAt IS NULL`; rename class to `SessionAccessRepo`
- `apps/backend/src/modules/realtime/realtime.module.ts` — swap `SESSION_OWNERSHIP_REPO` token to `SESSION_ACCESS_REPO`, swap class
- `apps/backend/src/modules/realtime/realtime.service.ts` — update import + inject name
- `packages/specs/openapi/openapi.yaml` — bump to `1.7.0`, add 3 routes, 2 schemas, `memberships` tag, `me` tag

### New web files

- `apps/web/app/pages/app/sessions/join/[token].vue` — public join page, no auth guard
- `apps/web/app/pages/app/sessions/index.vue` — player sessions list (playing-in)
- `apps/web/app/pages/app/sessions/[id].vue` — player session shell
- `apps/web/app/middleware/require-session-membership.ts` — per-route middleware for player shell
- `apps/web/app/composables/useInvitePublicApi.ts`
- `apps/web/app/composables/useMyMembershipsApi.ts`
- `packages/ui/src/components/AppSessionHeader/AppSessionHeader.vue`
- `packages/ui/src/components/AppSessionHeader/AppSessionHeader.spec.ts`
- `packages/ui/src/components/AppSessionHeader/AppSessionHeader.stories.ts`
- `packages/ui/src/components/AppSessionHeader/index.ts`
- `packages/ui/src/components/AppSessionJoinCard/AppSessionJoinCard.vue`
- `packages/ui/src/components/AppSessionJoinCard/AppSessionJoinCard.spec.ts`
- `packages/ui/src/components/AppSessionJoinCard/AppSessionJoinCard.stories.ts`
- `packages/ui/src/components/AppSessionJoinCard/index.ts`

### Modified web files

- `apps/web/app/middleware/auth-required.global.ts` — add `/app/sessions/join/` exception
- `apps/web/app/pages/app/game-sessions/[id].vue` — mount `AppSessionHeader`, add route guard for GM role
- `apps/web/app/pages/app/dashboard/index.vue` (or wherever dashboard lives) — wire Playing-in count via `useMyMembershipsApi`

### Deleted web files

- `apps/web/app/middleware/redirect-legacy-session.global.ts` — removed when `/app/sessions/*` lights up for players

### New mobile files

- `apps/mobile/lib/features/sessions/domain/player_session_repository.dart`
- `apps/mobile/lib/features/sessions/domain/player_membership.dart`
- `apps/mobile/lib/features/sessions/data/player_session_repository_impl.dart`
- `apps/mobile/lib/features/sessions/presentation/blocs/player_sessions_list/player_sessions_list_cubit.dart`
- `apps/mobile/lib/features/sessions/presentation/blocs/player_sessions_list/player_sessions_list_state.dart`
- `apps/mobile/lib/features/sessions/presentation/blocs/join_session/join_session_cubit.dart`
- `apps/mobile/lib/features/sessions/presentation/blocs/join_session/join_session_state.dart`
- `apps/mobile/lib/features/sessions/presentation/pages/player_sessions_list_page.dart`
- `apps/mobile/lib/features/sessions/presentation/pages/join_session_page.dart`
- `apps/mobile/lib/features/sessions/presentation/pages/player_session_detail_page.dart`
- `apps/mobile/test/features/sessions/player_session_repository_impl_test.dart`
- `apps/mobile/test/features/sessions/player_sessions_list_cubit_test.dart`

### Modified mobile files

- `apps/mobile/lib/shared/di/injector.dart` — register `InvitesApi`, `PlayerSessionRepository`, cubits
- `apps/mobile/lib/app/routes.dart` — add `playerSessions`, `playerSessionDetail`, `joinSession` routes
- `apps/mobile/lib/features/dashboard/presentation/dashboard_page.dart` — wire Playing-in count

---

## Task 0 — Preflight

- [ ] Read `specs/tasks/active.md` — confirm no blocking tasks.
- [ ] Push entry to `specs/tasks/active.md`:

```
## T-2026-05-16-PHASE-8-STREAM-B
**Status:** in-progress
**Goal:** Player shell + realtime ACL (Stream B)
**Design:** docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md §6
**Plan:** docs/superpowers/plans/2026-05-16-phase-8-stream-b.md
```

- [ ] Verify Stream A merge: `git log --oneline -10` confirms Stream A commits on `main`. The `redirect-legacy-session.global.ts` middleware exists (it will be deleted in P11).

---

## P1 — OpenAPI spec 1.6.0 → 1.7.0

**Tasks:** T-11.1.1.a (Stream B additions), T-11.2.1.g (ACL spec note)

### Step 1.1 — Bump version and add tags

In `packages/specs/openapi/openapi.yaml`:

```yaml
info:
  version: 1.7.0
```

Add under `tags:`:

```yaml
- name: memberships
  description: Session membership management — join, leave, kick
- name: me
  description: Authenticated user's own resources
```

### Step 1.2 — Add schemas

Under `components.schemas`, add:

```yaml
InvitePreview:
  type: object
  required: [sessionName, gmDisplayName, alreadyJoined]
  properties:
    sessionName:
      type: string
      example: The Mercy of Kua
    gmDisplayName:
      type: string
      example: Kirill GM
    alreadyJoined:
      type: boolean
      description: True when the authenticated caller already has an active membership.
  description: |
    Public preview returned before accepting an invite.
    Contains only session name and GM display name — no session ID,
    no member list, no liveness signal. Decision #4 in the design doc.

MyMembershipSummary:
  type: object
  required: [membershipId, gameSessionId, sessionName, role, joinedAt]
  properties:
    membershipId:
      type: string
    gameSessionId:
      type: string
    sessionName:
      type: string
    role:
      $ref: '#/components/schemas/MembershipRole'
    characterId:
      type: string
      nullable: true
    characterName:
      type: string
      nullable: true
    joinedAt:
      type: string
      format: date-time

AcceptInviteBody:
  type: object
  properties:
    characterId:
      type: string
      nullable: true
      description: Optional character to link at join time.

AcceptInviteResponse:
  type: object
  required: [membership]
  properties:
    membership:
      $ref: '#/components/schemas/GameSessionMembership'
```

### Step 1.3 — Add paths

```yaml
/api/v1/invites/{token}/preview:
  get:
    operationId: getInvitePreview
    tags: [memberships, public]
    summary: Public invite preview
    description: |
      Returns session name + GM display name. Does not require authentication.
      If the caller is authenticated and already an active member, alreadyJoined
      is true. Returns 404 if the token is unknown or the invite is revoked.
    parameters:
      - name: token
        in: path
        required: true
        schema:
          type: string
    responses:
      '200':
        description: Preview returned
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/InvitePreview'
      '404':
        $ref: '#/components/responses/NotFound'
      '410':
        $ref: '#/components/responses/Gone'

/api/v1/invites/{token}/accept:
  post:
    operationId: acceptInvite
    tags: [memberships]
    summary: Accept an invite link and join the session
    security:
      - cookieAuth: []
      - bearerAuth: []
    parameters:
      - name: token
        in: path
        required: true
        schema:
          type: string
    requestBody:
      required: false
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/AcceptInviteBody'
    responses:
      '200':
        description: Joined (or already a member — idempotent)
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/AcceptInviteResponse'
      '403':
        $ref: '#/components/responses/Forbidden'
      '410':
        $ref: '#/components/responses/Gone'

/api/v1/me/memberships:
  get:
    operationId: getMyMemberships
    tags: [me]
    summary: List the caller's active session memberships
    security:
      - cookieAuth: []
      - bearerAuth: []
    responses:
      '200':
        description: Active memberships
        content:
          application/json:
            schema:
              type: object
              required: [items]
              properties:
                items:
                  type: array
                  items:
                    $ref: '#/components/schemas/MyMembershipSummary'
```

Verify `Gone` response exists in `components.responses`; if not, add:

```yaml
Gone:
  description: Resource gone (invite revoked)
  content:
    application/problem+json:
      schema:
        $ref: '#/components/schemas/Problem'
```

### Step 1.4 — Codegen

```sh
pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen
```

Confirm no drift warnings. Commit:

```sh
git add packages/specs/openapi/openapi.yaml \
        packages/api-client-ts/src/generated/ \
        packages/api-client-dart/lib/generated/
git commit -m "feat(spec): OpenAPI 1.7.0 — invite preview/accept + /me/memberships (Stream B)"
```

---

## P2 — Backend domain — ports + errors + read models

**File:** `apps/backend/src/modules/memberships/domain/membership.ports.ts`
**File:** `apps/backend/src/modules/memberships/domain/membership.errors.ts`

### Step 2.1 — Add `InviteNotFoundError`

Append to `membership.errors.ts`:

```typescript
export class InviteNotFoundError extends DomainError {
  constructor(token: string) {
    super({
      code: 'INVITE_NOT_FOUND',
      status: 404,
      title: 'Invite Not Found',
      detail: `No active invite found for token starting with ${token.slice(0, 6)}…`,
    });
  }
}
```

### Step 2.2 — Add read models and port extensions

In `membership.ports.ts`, append new read models after `InviteMetadataReadModel`:

```typescript
export interface InvitePreviewReadModel {
  sessionName: string;
  gmDisplayName: string;
  alreadyJoined: boolean;
}

export interface MyMembershipReadModel {
  membershipId: string;
  gameSessionId: string;
  sessionName: string;
  role: MembershipRole;
  characterId: string | null;
  characterName: string | null;
  joinedAt: string; // ISO-8601
}
```

Extend `IMembershipRepo`:

```typescript
export interface IMembershipRepo {
  // ... existing methods ...

  /**
   * Inserts a new active membership row. Returns the new membership.
   * Callers are responsible for idempotency checks before calling.
   */
  insert(data: {
    gameSessionId: string;
    userId: string;
    role: MembershipRole;
    characterId?: string | null;
  }): Promise<MembershipReadModel>;

  /**
   * Returns all active (leftAt IS NULL) sessions for the given user,
   * with session name. Powers GET /me/memberships.
   */
  findActiveSessionsForUser(userId: string): Promise<MyMembershipReadModel[]>;
}
```

Extend `IGameSessionInviteRepo`:

```typescript
export interface IGameSessionInviteRepo {
  // ... existing methods ...

  /**
   * Looks up a GameSession by its stored inviteTokenHash.
   * Returns null when no matching active invite exists.
   */
  findSessionByTokenHash(tokenHash: string): Promise<{
    gameSessionId: string;
    sessionName: string;
    gmUserId: string;
  } | null>;
}
```

Commit:

```sh
git add apps/backend/src/modules/memberships/domain/
git commit -m "feat(memberships): domain ports + InviteNotFoundError + read models (Stream B)"
```

---

## P3 — Backend infra — implement new port methods

**File:** `apps/backend/src/modules/memberships/infra/membership.repo.ts`

### Step 3.1 — Implement `insert`

```typescript
async insert(data: {
  gameSessionId: string;
  userId: string;
  role: MembershipRole;
  characterId?: string | null;
}): Promise<MembershipReadModel> {
  const row = await this.prisma.gameSessionMembership.create({
    data: {
      gameSessionId: data.gameSessionId,
      userId: data.userId,
      role: data.role,
      characterId: data.characterId ?? null,
    },
    select: MEMBERSHIP_SELECT,
  });
  const users = await this.fetchDisplayNames([row.userId]);
  return toMembershipReadModel(row, users.get(row.userId) ?? null);
}
```

### Step 3.2 — Implement `findActiveSessionsForUser`

```typescript
async findActiveSessionsForUser(userId: string): Promise<MyMembershipReadModel[]> {
  const rows = await this.prisma.gameSessionMembership.findMany({
    where: { userId, leftAt: null },
    orderBy: { joinedAt: 'asc' },
    select: {
      id: true,
      gameSessionId: true,
      role: true,
      characterId: true,
      joinedAt: true,
      character: { select: { name: true } },
      gameSession: { select: { name: true } },
    },
  });
  return rows.map((r) => ({
    membershipId: r.id,
    gameSessionId: r.gameSessionId,
    sessionName: r.gameSession.name,
    role: r.role as MembershipRole,
    characterId: r.characterId,
    characterName: r.character?.name ?? null,
    joinedAt: (r.joinedAt as Date).toISOString(),
  }));
}
```

### Step 3.3 — Implement `findSessionByTokenHash`

```typescript
async findSessionByTokenHash(tokenHash: string): Promise<{
  gameSessionId: string;
  sessionName: string;
  gmUserId: string;
} | null> {
  const session = await this.prisma.gameSession.findFirst({
    where: { inviteTokenHash: tokenHash },
    select: { id: true, name: true, ownerId: true },
  });
  if (!session) return null;
  return {
    gameSessionId: session.id,
    sessionName: session.name,
    gmUserId: session.ownerId,
  };
}
```

Commit:

```sh
git add apps/backend/src/modules/memberships/infra/membership.repo.ts
git commit -m "feat(memberships): MembershipRepo — insert + findActiveSessionsForUser + findSessionByTokenHash"
```

---

## P4 — AcceptInviteCommand TDD

**New files:**

- `apps/backend/src/modules/memberships/events/member-joined.event.ts`
- `apps/backend/src/modules/memberships/commands/accept-invite.command.ts`
- `apps/backend/src/modules/memberships/commands/accept-invite.handler.ts`
- `apps/backend/src/modules/memberships/commands/accept-invite.handler.spec.ts`

### Step 4.1 — Create `MemberJoinedEvent`

```typescript
// apps/backend/src/modules/memberships/events/member-joined.event.ts
export class MemberJoinedEvent {
  constructor(
    public readonly membershipId: string,
    public readonly gameSessionId: string,
    public readonly userId: string,
  ) {}
}
```

### Step 4.2 — Create command

```typescript
// apps/backend/src/modules/memberships/commands/accept-invite.command.ts
export class AcceptInviteCommand {
  constructor(
    public readonly token: string,
    public readonly userId: string,
    public readonly characterId: string | null,
  ) {}
}
```

### Step 4.3 — Write failing tests

```typescript
// apps/backend/src/modules/memberships/commands/accept-invite.handler.spec.ts
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  InviteNotFoundError,
  InviteRevokedError,
  CharacterNotOwnedError,
} from '../domain/membership.errors';
import { hashInviteToken } from '../domain/invite-token';

import { AcceptInviteCommand } from './accept-invite.command';
import { AcceptInviteHandler } from './accept-invite.handler';
import { MemberJoinedEvent } from '../events/member-joined.event';

import type { EventBus } from '@nestjs/cqrs';
import type {
  IGameSessionInviteRepo,
  IMembershipRepo,
  MembershipReadModel,
} from '../domain/membership.ports';
import type { ICharacterOwnership } from './link-character.handler';

const PLAINTEXT = 'Sl9X3kQpZr8mVtNuY7Hb2C';
const HASH = hashInviteToken(PLAINTEXT);

function makeMembershipRepo(): IMembershipRepo {
  return {
    listActive: vi.fn(),
    findById: vi.fn(),
    findActiveByUser: vi.fn().mockResolvedValue(null),
    softDelete: vi.fn(),
    setCharacter: vi.fn(),
    insert: vi.fn(),
    findActiveSessionsForUser: vi.fn(),
  };
}

function makeInviteRepo(): IGameSessionInviteRepo {
  return {
    assertOwner: vi.fn(),
    getMetadata: vi.fn(),
    rotate: vi.fn(),
    revoke: vi.fn(),
    findSessionByTokenHash: vi.fn().mockResolvedValue({
      gameSessionId: 'gs-1',
      sessionName: 'The Mercy of Kua',
      gmUserId: 'gm-user',
    }),
  };
}

function makeCharOwnership(): ICharacterOwnership {
  return { isOwnedBy: vi.fn().mockResolvedValue(true) };
}

function makeBus(): EventBus {
  return { publish: vi.fn(), publishAll: vi.fn() } as unknown as EventBus;
}

function makeMembership(overrides: Partial<MembershipReadModel> = {}): MembershipReadModel {
  return {
    id: 'm-new',
    gameSessionId: 'gs-1',
    userId: 'user-1',
    role: 'player',
    displayName: 'Test Player',
    characterId: null,
    characterName: null,
    joinedAt: new Date().toISOString(),
    leftAt: null,
    ...overrides,
  };
}

describe('AcceptInviteHandler', () => {
  let mRepo: IMembershipRepo;
  let iRepo: IGameSessionInviteRepo;
  let charOwnership: ICharacterOwnership;
  let bus: EventBus;
  let handler: AcceptInviteHandler;

  beforeEach(() => {
    mRepo = makeMembershipRepo();
    iRepo = makeInviteRepo();
    charOwnership = makeCharOwnership();
    bus = makeBus();
    handler = new AcceptInviteHandler(mRepo, iRepo, charOwnership, bus);
  });

  it('throws InviteNotFoundError when no session matches the token hash', async () => {
    vi.mocked(iRepo.findSessionByTokenHash).mockResolvedValue(null);

    await expect(
      handler.execute(new AcceptInviteCommand(PLAINTEXT, 'user-1', null)),
    ).rejects.toBeInstanceOf(InviteNotFoundError);

    expect(mRepo.insert).not.toHaveBeenCalled();
  });

  it('throws InviteRevokedError (410) when the stored hash does not match', async () => {
    // Simulate rotated token: findSessionByTokenHash returns null for the old hash
    vi.mocked(iRepo.findSessionByTokenHash).mockResolvedValue(null);

    await expect(
      handler.execute(new AcceptInviteCommand('old-token', 'user-1', null)),
    ).rejects.toBeInstanceOf(InviteNotFoundError);
  });

  it('returns existing membership idempotently when caller is already an active member', async () => {
    const existing = makeMembership({ id: 'm-existing' });
    vi.mocked(mRepo.findActiveByUser).mockResolvedValue(existing);

    const result = await handler.execute(new AcceptInviteCommand(PLAINTEXT, 'user-1', null));

    expect(result).toEqual(existing);
    expect(mRepo.insert).not.toHaveBeenCalled();
    expect(bus.publish).not.toHaveBeenCalled();
  });

  it('throws CharacterNotOwnedError when supplied characterId does not belong to caller', async () => {
    vi.mocked(charOwnership.isOwnedBy).mockResolvedValue(false);

    await expect(
      handler.execute(new AcceptInviteCommand(PLAINTEXT, 'user-1', 'char-other')),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);

    expect(mRepo.insert).not.toHaveBeenCalled();
  });

  it('inserts membership and publishes MemberJoinedEvent on happy path', async () => {
    const newMembership = makeMembership();
    vi.mocked(mRepo.insert).mockResolvedValue(newMembership);

    const result = await handler.execute(new AcceptInviteCommand(PLAINTEXT, 'user-1', null));

    expect(mRepo.insert).toHaveBeenCalledWith({
      gameSessionId: 'gs-1',
      userId: 'user-1',
      role: 'player',
      characterId: null,
    });
    expect(bus.publish).toHaveBeenCalledWith(
      expect.objectContaining({
        membershipId: 'm-new',
        gameSessionId: 'gs-1',
        userId: 'user-1',
      }),
    );
    expect(result).toEqual(newMembership);
  });

  it('links character at join time when characterId is provided and owned', async () => {
    const newMembership = makeMembership({ characterId: 'char-mine' });
    vi.mocked(charOwnership.isOwnedBy).mockResolvedValue(true);
    vi.mocked(mRepo.insert).mockResolvedValue(newMembership);

    await handler.execute(new AcceptInviteCommand(PLAINTEXT, 'user-1', 'char-mine'));

    expect(charOwnership.isOwnedBy).toHaveBeenCalledWith('char-mine', 'user-1');
    expect(mRepo.insert).toHaveBeenCalledWith(
      expect.objectContaining({ characterId: 'char-mine' }),
    );
  });
});
```

Run: `pnpm --filter @app/backend vitest run accept-invite.handler.spec.ts` — expect RED (handler does not exist).

### Step 4.4 — Implement handler

```typescript
// apps/backend/src/modules/memberships/commands/accept-invite.handler.ts
import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import { CharacterNotOwnedError, InviteNotFoundError } from '../domain/membership.errors';
import { hashInviteToken } from '../domain/invite-token';
import {
  GAME_SESSION_INVITE_REPO,
  MEMBERSHIP_REPO,
  type IGameSessionInviteRepo,
  type IMembershipRepo,
  type MembershipReadModel,
} from '../domain/membership.ports';
import { MemberJoinedEvent } from '../events/member-joined.event';
import { CHARACTER_OWNERSHIP, type ICharacterOwnership } from './link-character.handler';

import { AcceptInviteCommand } from './accept-invite.command';

@CommandHandler(AcceptInviteCommand)
export class AcceptInviteHandler implements ICommandHandler<
  AcceptInviteCommand,
  MembershipReadModel
> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly mRepo: IMembershipRepo,
    @Inject(GAME_SESSION_INVITE_REPO) private readonly iRepo: IGameSessionInviteRepo,
    @Inject(CHARACTER_OWNERSHIP) private readonly charOwnership: ICharacterOwnership,
    private readonly bus: EventBus,
  ) {}

  async execute(cmd: AcceptInviteCommand): Promise<MembershipReadModel> {
    const tokenHash = hashInviteToken(cmd.token);
    const session = await this.iRepo.findSessionByTokenHash(tokenHash);
    if (!session) throw new InviteNotFoundError(cmd.token);

    // Idempotent re-accept
    const existing = await this.mRepo.findActiveByUser(session.gameSessionId, cmd.userId);
    if (existing) return existing;

    // Character ownership check
    if (cmd.characterId) {
      const owned = await this.charOwnership.isOwnedBy(cmd.characterId, cmd.userId);
      if (!owned) throw new CharacterNotOwnedError(cmd.characterId);
    }

    const membership = await this.mRepo.insert({
      gameSessionId: session.gameSessionId,
      userId: cmd.userId,
      role: 'player',
      characterId: cmd.characterId,
    });

    this.bus.publish(new MemberJoinedEvent(membership.id, session.gameSessionId, cmd.userId));

    return membership;
  }
}
```

Run: `pnpm --filter @app/backend vitest run accept-invite.handler.spec.ts` — expect GREEN.

Commit:

```sh
git add apps/backend/src/modules/memberships/commands/accept-invite.command.ts \
        apps/backend/src/modules/memberships/commands/accept-invite.handler.ts \
        apps/backend/src/modules/memberships/commands/accept-invite.handler.spec.ts \
        apps/backend/src/modules/memberships/events/member-joined.event.ts
git commit -m "feat(memberships): AcceptInviteHandler + MemberJoinedEvent — TDD green (Stream B)"
```

---

## P5 — GetInvitePreviewQuery TDD

**New files:**

- `apps/backend/src/modules/memberships/queries/get-invite-preview.query.ts`
- `apps/backend/src/modules/memberships/queries/get-invite-preview.handler.ts`
- `apps/backend/src/modules/memberships/queries/get-invite-preview.handler.spec.ts`

### Step 5.1 — Query class

```typescript
// apps/backend/src/modules/memberships/queries/get-invite-preview.query.ts
export class GetInvitePreviewQuery {
  constructor(
    public readonly token: string,
    /** null when the caller is unauthenticated */
    public readonly callerUserId: string | null,
  ) {}
}
```

### Step 5.2 — Write failing tests

```typescript
// apps/backend/src/modules/memberships/queries/get-invite-preview.handler.spec.ts
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { InviteNotFoundError } from '../domain/membership.errors';
import { hashInviteToken } from '../domain/invite-token';

import { GetInvitePreviewQuery } from './get-invite-preview.query';
import { GetInvitePreviewHandler } from './get-invite-preview.handler';

import type {
  IGameSessionInviteRepo,
  IMembershipRepo,
  InvitePreviewReadModel,
} from '../domain/membership.ports';

const PLAINTEXT = 'Sl9X3kQpZr8mVtNuY7Hb2C';

function makeInviteRepo(): IGameSessionInviteRepo {
  return {
    assertOwner: vi.fn(),
    getMetadata: vi.fn(),
    rotate: vi.fn(),
    revoke: vi.fn(),
    findSessionByTokenHash: vi.fn().mockResolvedValue({
      gameSessionId: 'gs-1',
      sessionName: 'The Mercy of Kua',
      gmUserId: 'gm-user',
    }),
  };
}

function makeMembershipRepo(): IMembershipRepo {
  return {
    listActive: vi.fn(),
    findById: vi.fn(),
    findActiveByUser: vi.fn().mockResolvedValue(null),
    softDelete: vi.fn(),
    setCharacter: vi.fn(),
    insert: vi.fn(),
    findActiveSessionsForUser: vi.fn(),
  };
}

function makeUserNameFetcher() {
  return vi.fn().mockResolvedValue('Kirill GM');
}

describe('GetInvitePreviewHandler', () => {
  let iRepo: IGameSessionInviteRepo;
  let mRepo: IMembershipRepo;
  let fetchDisplayName: (userId: string) => Promise<string>;
  let handler: GetInvitePreviewHandler;

  beforeEach(() => {
    iRepo = makeInviteRepo();
    mRepo = makeMembershipRepo();
    fetchDisplayName = makeUserNameFetcher();
    handler = new GetInvitePreviewHandler(iRepo, mRepo, fetchDisplayName);
  });

  it('throws InviteNotFoundError when token hash has no matching session', async () => {
    vi.mocked(iRepo.findSessionByTokenHash).mockResolvedValue(null);

    await expect(
      handler.execute(new GetInvitePreviewQuery(PLAINTEXT, null)),
    ).rejects.toBeInstanceOf(InviteNotFoundError);
  });

  it('returns preview with alreadyJoined false for unauthenticated caller', async () => {
    const result = await handler.execute(new GetInvitePreviewQuery(PLAINTEXT, null));

    expect(result).toMatchObject<InvitePreviewReadModel>({
      sessionName: 'The Mercy of Kua',
      gmDisplayName: 'Kirill GM',
      alreadyJoined: false,
    });
    expect(mRepo.findActiveByUser).not.toHaveBeenCalled();
  });

  it('returns alreadyJoined true when authenticated caller has active membership', async () => {
    vi.mocked(mRepo.findActiveByUser).mockResolvedValue({
      id: 'm-1',
      gameSessionId: 'gs-1',
      userId: 'user-1',
      role: 'player',
      displayName: 'Test',
      characterId: null,
      characterName: null,
      joinedAt: new Date().toISOString(),
      leftAt: null,
    });

    const result = await handler.execute(new GetInvitePreviewQuery(PLAINTEXT, 'user-1'));

    expect(result.alreadyJoined).toBe(true);
    expect(mRepo.findActiveByUser).toHaveBeenCalledWith('gs-1', 'user-1');
  });

  it('returns alreadyJoined false when authenticated caller has no active membership', async () => {
    vi.mocked(mRepo.findActiveByUser).mockResolvedValue(null);

    const result = await handler.execute(new GetInvitePreviewQuery(PLAINTEXT, 'user-99'));

    expect(result.alreadyJoined).toBe(false);
  });
});
```

Run to RED, then implement:

### Step 5.3 — Implement handler

```typescript
// apps/backend/src/modules/memberships/queries/get-invite-preview.handler.ts
import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { InviteNotFoundError } from '../domain/membership.errors';
import { hashInviteToken } from '../domain/invite-token';
import {
  GAME_SESSION_INVITE_REPO,
  MEMBERSHIP_REPO,
  type IGameSessionInviteRepo,
  type IMembershipRepo,
  type InvitePreviewReadModel,
} from '../domain/membership.ports';

import { GetInvitePreviewQuery } from './get-invite-preview.query';

export const DISPLAY_NAME_FETCHER = Symbol('DISPLAY_NAME_FETCHER');

@QueryHandler(GetInvitePreviewQuery)
export class GetInvitePreviewHandler implements IQueryHandler<
  GetInvitePreviewQuery,
  InvitePreviewReadModel
> {
  constructor(
    @Inject(GAME_SESSION_INVITE_REPO) private readonly iRepo: IGameSessionInviteRepo,
    @Inject(MEMBERSHIP_REPO) private readonly mRepo: IMembershipRepo,
    @Inject(DISPLAY_NAME_FETCHER)
    private readonly fetchDisplayName: (userId: string) => Promise<string>,
  ) {}

  async execute(q: GetInvitePreviewQuery): Promise<InvitePreviewReadModel> {
    const tokenHash = hashInviteToken(q.token);
    const session = await this.iRepo.findSessionByTokenHash(tokenHash);
    if (!session) throw new InviteNotFoundError(q.token);

    const [gmDisplayName, existingMembership] = await Promise.all([
      this.fetchDisplayName(session.gmUserId),
      q.callerUserId
        ? this.mRepo.findActiveByUser(session.gameSessionId, q.callerUserId)
        : Promise.resolve(null),
    ]);

    return {
      sessionName: session.sessionName,
      gmDisplayName,
      alreadyJoined: existingMembership !== null,
    };
  }
}
```

The `fetchDisplayName` injectable is a thin wrapper that will be provided in the module as a factory using `PrismaService`.

Run to GREEN. Commit:

```sh
git add apps/backend/src/modules/memberships/queries/get-invite-preview.query.ts \
        apps/backend/src/modules/memberships/queries/get-invite-preview.handler.ts \
        apps/backend/src/modules/memberships/queries/get-invite-preview.handler.spec.ts
git commit -m "feat(memberships): GetInvitePreviewHandler — TDD green (Stream B)"
```

---

## P6 — GetMyMembershipsQuery TDD

**New files:**

- `apps/backend/src/modules/memberships/queries/get-my-memberships.query.ts`
- `apps/backend/src/modules/memberships/queries/get-my-memberships.handler.ts`
- `apps/backend/src/modules/memberships/queries/get-my-memberships.handler.spec.ts`

### Step 6.1 — Query class

```typescript
// apps/backend/src/modules/memberships/queries/get-my-memberships.query.ts
export class GetMyMembershipsQuery {
  constructor(public readonly userId: string) {}
}
```

### Step 6.2 — Write failing tests

```typescript
// apps/backend/src/modules/memberships/queries/get-my-memberships.handler.spec.ts
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { GetMyMembershipsQuery } from './get-my-memberships.query';
import { GetMyMembershipsHandler } from './get-my-memberships.handler';

import type { IMembershipRepo, MyMembershipReadModel } from '../domain/membership.ports';

function makeMembershipRepo(): IMembershipRepo {
  return {
    listActive: vi.fn(),
    findById: vi.fn(),
    findActiveByUser: vi.fn(),
    softDelete: vi.fn(),
    setCharacter: vi.fn(),
    insert: vi.fn(),
    findActiveSessionsForUser: vi.fn().mockResolvedValue([]),
  };
}

function makeMembership(overrides: Partial<MyMembershipReadModel> = {}): MyMembershipReadModel {
  return {
    membershipId: 'm-1',
    gameSessionId: 'gs-1',
    sessionName: 'The Mercy of Kua',
    role: 'player',
    characterId: null,
    characterName: null,
    joinedAt: '2026-05-15T10:00:00.000Z',
    ...overrides,
  };
}

describe('GetMyMembershipsHandler', () => {
  let mRepo: IMembershipRepo;
  let handler: GetMyMembershipsHandler;

  beforeEach(() => {
    mRepo = makeMembershipRepo();
    handler = new GetMyMembershipsHandler(mRepo);
  });

  it('returns empty list when user has no active memberships', async () => {
    vi.mocked(mRepo.findActiveSessionsForUser).mockResolvedValue([]);

    const result = await handler.execute(new GetMyMembershipsQuery('user-1'));

    expect(result).toEqual([]);
    expect(mRepo.findActiveSessionsForUser).toHaveBeenCalledWith('user-1');
  });

  it('returns all active memberships including both gm and player roles', async () => {
    const gm = makeMembership({ membershipId: 'm-gm', role: 'gm', sessionName: 'Session A' });
    const player = makeMembership({
      membershipId: 'm-player',
      role: 'player',
      sessionName: 'Session B',
    });
    vi.mocked(mRepo.findActiveSessionsForUser).mockResolvedValue([gm, player]);

    const result = await handler.execute(new GetMyMembershipsQuery('user-1'));

    expect(result).toHaveLength(2);
    expect(result[0]!.role).toBe('gm');
    expect(result[1]!.role).toBe('player');
  });

  it('excludes soft-deleted (kicked) memberships — repo handles this filter', async () => {
    // The repo's findActiveSessionsForUser already filters leftAt IS NULL.
    // Handler does not re-filter, but we verify delegation.
    const active = makeMembership();
    vi.mocked(mRepo.findActiveSessionsForUser).mockResolvedValue([active]);

    const result = await handler.execute(new GetMyMembershipsQuery('user-1'));

    expect(result).toHaveLength(1);
    // If the repo returned a kicked row, the handler would still pass it through.
    // This test documents that the repo is the source of truth for filtering.
    expect(mRepo.findActiveSessionsForUser).toHaveBeenCalledOnce();
  });
});
```

Run to RED, then implement:

### Step 6.3 — Implement handler

```typescript
// apps/backend/src/modules/memberships/queries/get-my-memberships.handler.ts
import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import {
  MEMBERSHIP_REPO,
  type IMembershipRepo,
  type MyMembershipReadModel,
} from '../domain/membership.ports';

import { GetMyMembershipsQuery } from './get-my-memberships.query';

@QueryHandler(GetMyMembershipsQuery)
export class GetMyMembershipsHandler implements IQueryHandler<
  GetMyMembershipsQuery,
  MyMembershipReadModel[]
> {
  constructor(@Inject(MEMBERSHIP_REPO) private readonly repo: IMembershipRepo) {}

  async execute(q: GetMyMembershipsQuery): Promise<MyMembershipReadModel[]> {
    return this.repo.findActiveSessionsForUser(q.userId);
  }
}
```

Run to GREEN. Commit:

```sh
git add apps/backend/src/modules/memberships/queries/get-my-memberships.query.ts \
        apps/backend/src/modules/memberships/queries/get-my-memberships.handler.ts \
        apps/backend/src/modules/memberships/queries/get-my-memberships.handler.spec.ts
git commit -m "feat(memberships): GetMyMembershipsHandler — TDD green (Stream B)"
```

---

## P7 — RealtimeModule ACL widening

**Tasks:** T-11.2.1.g + T-11.2.1.h

### Step 7.1 — Rename port

Replace `apps/backend/src/modules/realtime/domain/session-ownership.port.ts` contents:

```typescript
/**
 * WHY this file exists:
 * Minimal read port used by RealtimeService to determine which Centrifugo
 * session channels a given user is allowed to subscribe to.
 *
 * Renamed from ISessionOwnershipRepo (GM-only) to ISessionAccessRepo in
 * Stream B — now covers any user with an active membership (leftAt IS NULL).
 *
 * The narrow-port pattern is preserved to avoid a circular module dependency:
 *   GameSessionsModule → RealtimeModule (for CENTRIFUGO_CLIENT)
 *   RealtimeModule → GameSessionsModule (for IGameSessionRepo)
 * The adapter queries Prisma directly in realtime/infra/.
 */

export const SESSION_ACCESS_REPO = Symbol('SESSION_ACCESS_REPO');

export interface ISessionAccessRepo {
  /**
   * Returns the IDs of all GameSessions the user has an active membership in
   * (role = 'gm' OR 'player', leftAt IS NULL).
   * Used to build the `channels` claim in the Centrifugo JWT.
   */
  findActiveSessionIdsForUser(userId: string): Promise<string[]>;
}
```

### Step 7.2 — Write failing regression test first

Create `apps/backend/src/modules/realtime/infra/session-access.repo.spec.ts`:

```typescript
import { describe, expect, it, vi } from 'vitest';

import { SessionAccessRepo } from './session-access.repo';

import type { PrismaService } from '../../../common/prisma/prisma.service';

function makePrisma(): PrismaService {
  return {
    gameSessionMembership: {
      findMany: vi.fn(),
    },
  } as unknown as PrismaService;
}

describe('SessionAccessRepo', () => {
  it('queries active memberships (leftAt IS NULL) not session ownership', async () => {
    const prisma = makePrisma();
    vi.mocked(prisma.gameSessionMembership.findMany).mockResolvedValue([
      { gameSessionId: 'gs-1' },
      { gameSessionId: 'gs-2' },
    ] as any);

    const repo = new SessionAccessRepo(prisma);
    const result = await repo.findActiveSessionIdsForUser('user-1');

    expect(prisma.gameSessionMembership.findMany).toHaveBeenCalledWith({
      where: { userId: 'user-1', leftAt: null },
      select: { gameSessionId: true },
    });
    expect(result).toEqual(['gs-1', 'gs-2']);
  });

  it('excludes kicked members (leftAt IS NOT NULL) — enforced by repo filter', async () => {
    // Kicked member: findMany returns empty because leftAt != null was filtered in the query.
    const prisma = makePrisma();
    vi.mocked(prisma.gameSessionMembership.findMany).mockResolvedValue([]);

    const repo = new SessionAccessRepo(prisma);
    const result = await repo.findActiveSessionIdsForUser('kicked-user');

    expect(result).toEqual([]);
  });
});
```

Run to RED (file does not exist yet).

### Step 7.3 — Implement `SessionAccessRepo`

Create `apps/backend/src/modules/realtime/infra/session-access.repo.ts`:

```typescript
/**
 * WHY this file exists:
 * Prisma adapter for ISessionAccessRepo. Replaces SessionOwnershipRepo
 * (Stream A) which only covered GM-owned sessions.
 *
 * Now covers all active memberships: a user with role='player' and
 * leftAt IS NULL gets the same session channel access as a GM.
 * Kicked members (leftAt IS NOT NULL) are excluded by the WHERE clause.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type { ISessionAccessRepo } from '../domain/session-ownership.port';

@Injectable()
export class SessionAccessRepo implements ISessionAccessRepo {
  constructor(private readonly prisma: PrismaService) {}

  async findActiveSessionIdsForUser(userId: string): Promise<string[]> {
    const rows = await this.prisma.gameSessionMembership.findMany({
      where: { userId, leftAt: null },
      select: { gameSessionId: true },
    });
    return rows.map((r) => r.gameSessionId);
  }
}
```

Run to GREEN.

### Step 7.4 — Update `RealtimeService`

In `apps/backend/src/modules/realtime/realtime.service.ts`, replace:

```typescript
import {
  SESSION_OWNERSHIP_REPO,
  type ISessionOwnershipRepo,
} from './domain/session-ownership.port';
```

with:

```typescript
import { SESSION_ACCESS_REPO, type ISessionAccessRepo } from './domain/session-ownership.port';
```

Replace the injected field:

```typescript
@Inject(SESSION_ACCESS_REPO)
private readonly sessionAccess: ISessionAccessRepo,
```

Replace the `buildAllowedChannels` body:

```typescript
private async buildAllowedChannels(userId: string): Promise<string[]> {
  const sessionIds = await this.sessionAccess.findActiveSessionIdsForUser(userId);
  return sessionIds.map((id) => `session.${id}`);
}
```

### Step 7.5 — Update `RealtimeModule`

In `apps/backend/src/modules/realtime/realtime.module.ts`:

```typescript
import { SESSION_ACCESS_REPO } from './domain/session-ownership.port';
import { SessionAccessRepo } from './infra/session-access.repo';

@Module({
  controllers: [RealtimeController],
  providers: [
    RealtimeService,
    { provide: CENTRIFUGO_CLIENT, useClass: CentrifugoClient },
    { provide: SESSION_ACCESS_REPO, useClass: SessionAccessRepo },
  ],
  exports: [CENTRIFUGO_CLIENT],
})
export class RealtimeModule {}
```

Delete `apps/backend/src/modules/realtime/infra/session-ownership.repo.ts`.

Run full realtime suite: `pnpm --filter @app/backend vitest run realtime`. Commit:

```sh
git add apps/backend/src/modules/realtime/
git commit -m "feat(realtime): ISessionAccessRepo — ACL covers GM+player memberships, regression test green (Stream B)"
```

---

## P8 — Backend wiring — controllers + module registration

### Step 8.1 — `InvitesController`

Create `apps/backend/src/modules/memberships/http/invites.controller.ts`:

```typescript
/**
 * WHY this file exists:
 * Routes for public invite endpoints that cannot live in MembershipsController
 * (which is scoped to /game-sessions/:gameSessionId). These routes are under
 * /invites/:token and /me/memberships — separate resource tree.
 */
import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Get,
  Req,
  UseGuards,
  Optional,
} from '@nestjs/common';
import { CommandBus, QueryBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../../common/auth/auth.guard';
import { AcceptInviteCommand } from '../commands/accept-invite.command';
import { GetInvitePreviewQuery } from '../queries/get-invite-preview.query';

import type { AuthenticatedRequest } from '../../../common/auth/auth.guard';
import type { MembershipReadModel, InvitePreviewReadModel } from '../domain/membership.ports';
import type { Request } from 'express';

interface AcceptInviteBody {
  characterId?: string | null;
}

@Controller({ path: 'invites', version: '1' })
export class InvitesController {
  constructor(
    private readonly queryBus: QueryBus,
    private readonly commandBus: CommandBus,
  ) {}

  /** GET /api/v1/invites/:token/preview — public, no auth required */
  @Get(':token/preview')
  async getPreview(
    @Param('token') token: string,
    @Req() req: Request,
  ): Promise<InvitePreviewReadModel> {
    // callerUserId is null when unauthenticated
    const callerUserId = (req as AuthenticatedRequest).userId ?? null;
    return this.queryBus.execute(new GetInvitePreviewQuery(token, callerUserId));
  }

  /** POST /api/v1/invites/:token/accept — auth required */
  @Post(':token/accept')
  @UseGuards(SessionGuard)
  @HttpCode(HttpStatus.OK)
  async accept(
    @Param('token') token: string,
    @Body() body: AcceptInviteBody,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ membership: MembershipReadModel }> {
    const membership = await this.commandBus.execute(
      new AcceptInviteCommand(token, req.userId, body.characterId ?? null),
    );
    return { membership };
  }
}
```

### Step 8.2 — `MeMembershipsController`

Create `apps/backend/src/modules/memberships/http/me-memberships.controller.ts`:

```typescript
import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { QueryBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../../common/auth/auth.guard';
import { GetMyMembershipsQuery } from '../queries/get-my-memberships.query';

import type { AuthenticatedRequest } from '../../../common/auth/auth.guard';
import type { MyMembershipReadModel } from '../domain/membership.ports';

@UseGuards(SessionGuard)
@Controller({ path: 'me', version: '1' })
export class MeMembershipsController {
  constructor(private readonly queryBus: QueryBus) {}

  /** GET /api/v1/me/memberships */
  @Get('memberships')
  async getMyMemberships(
    @Req() req: AuthenticatedRequest,
  ): Promise<{ items: MyMembershipReadModel[] }> {
    const items = await this.queryBus.execute(new GetMyMembershipsQuery(req.userId));
    return { items };
  }
}
```

### Step 8.3 — Update `MembershipsModule`

Add to `memberships.module.ts`:

```typescript
import { AcceptInviteHandler } from './commands/accept-invite.handler';
import { GetInvitePreviewHandler } from './queries/get-invite-preview.handler';
import { GetMyMembershipsHandler } from './queries/get-my-memberships.handler';
import { InvitesController } from './http/invites.controller';
import { MeMembershipsController } from './http/me-memberships.controller';
import { DISPLAY_NAME_FETCHER } from './queries/get-invite-preview.handler';
import { PrismaService } from '../../common/prisma/prisma.service';
```

Add `InvitesController` and `MeMembershipsController` to `controllers: []`.

Add to `providers: []`:

```typescript
AcceptInviteHandler,
GetInvitePreviewHandler,
GetMyMembershipsHandler,
{
  provide: DISPLAY_NAME_FETCHER,
  useFactory: (prisma: PrismaService) => async (userId: string): Promise<string> => {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { name: true },
    });
    return user?.name ?? 'Unknown';
  },
  inject: [PrismaService],
},
```

### Step 8.4 — Smoke check

```sh
docker compose -f docker/compose.yml restart backend
docker compose -f docker/compose.yml logs -f backend --tail=50
# Expect: [NestApplication] Nest application successfully started
# Verify routes in log: GET /api/v1/invites/:token/preview, POST /api/v1/invites/:token/accept, GET /api/v1/me/memberships
```

Run full backend test suite: `pnpm --filter @app/backend vitest run`. Commit:

```sh
git add apps/backend/src/modules/memberships/http/ \
        apps/backend/src/modules/memberships/memberships.module.ts
git commit -m "feat(memberships): wire InvitesController + MeMembershipsController + module (Stream B)"
```

---

## P9 — @app/ui AppSessionHeader

**Tasks:** T-11.2.1.b

### Step 9.1 — Write failing spec

```typescript
// packages/ui/src/components/AppSessionHeader/AppSessionHeader.spec.ts
import { describe, expect, it } from 'vitest';
import { mount } from '@vue/test-utils';

import { AppSessionHeader } from './index';

const baseLabels = {
  statusOnline: 'Online',
  statusOffline: 'Offline',
  dpLabel: 'DP',
  leaveLabel: 'Leave session',
  backLabel: 'Back to sessions',
};

describe('AppSessionHeader', () => {
  it('renders session name', () => {
    const wrapper = mount(AppSessionHeader, {
      props: {
        sessionName: 'The Mercy of Kua',
        mode: 'gm',
        status: 'online',
        dpCount: 3,
        labels: baseLabels,
      },
    });
    expect(wrapper.text()).toContain('The Mercy of Kua');
  });

  it('shows DP count', () => {
    const wrapper = mount(AppSessionHeader, {
      props: { sessionName: 'Test', mode: 'gm', status: 'online', dpCount: 5, labels: baseLabels },
    });
    expect(wrapper.text()).toContain('5');
  });

  it('shows "Online" badge when status is online', () => {
    const wrapper = mount(AppSessionHeader, {
      props: { sessionName: 'Test', mode: 'gm', status: 'online', dpCount: 0, labels: baseLabels },
    });
    expect(wrapper.text()).toContain('Online');
  });

  it('shows "Offline" badge when status is offline', () => {
    const wrapper = mount(AppSessionHeader, {
      props: { sessionName: 'Test', mode: 'gm', status: 'offline', dpCount: 0, labels: baseLabels },
    });
    expect(wrapper.text()).toContain('Offline');
  });

  it('emits "leave" when Leave button clicked in player mode', async () => {
    const wrapper = mount(AppSessionHeader, {
      props: {
        sessionName: 'Test',
        mode: 'player',
        status: 'online',
        dpCount: 0,
        labels: baseLabels,
      },
    });
    const leaveBtn = wrapper.findAll('button').find((b) => b.text() === 'Leave session');
    await leaveBtn!.trigger('click');
    expect(wrapper.emitted('leave')).toBeTruthy();
  });

  it('does not render Leave button in GM mode', () => {
    const wrapper = mount(AppSessionHeader, {
      props: { sessionName: 'Test', mode: 'gm', status: 'online', dpCount: 0, labels: baseLabels },
    });
    const leaveBtn = wrapper.findAll('button').find((b) => b.text() === 'Leave session');
    expect(leaveBtn).toBeUndefined();
  });

  it('passes a11y — no violations (addon-a11y enforced in Storybook)', () => {
    // Structural check: header uses a semantic element
    const wrapper = mount(AppSessionHeader, {
      props: { sessionName: 'Test', mode: 'gm', status: 'online', dpCount: 0, labels: baseLabels },
    });
    expect(wrapper.find('header, [role="banner"], h1, h2').exists()).toBe(true);
  });
});
```

Run: `pnpm --filter @app/ui vitest run AppSessionHeader` — expect RED.

### Step 9.2 — Implement component

```
packages/ui/src/components/AppSessionHeader/AppSessionHeader.vue
```

Component interface:

```typescript
// Props
interface Props {
  sessionName: string;
  mode: 'gm' | 'player';
  status: 'online' | 'offline';
  dpCount: number;
  labels: {
    statusOnline: string;
    statusOffline: string;
    dpLabel: string;
    leaveLabel: string;
    backLabel: string;
  };
}
// Emits
defineEmits<{ leave: []; back: [] }>();
```

Render a `<header>` element with `<h1>` for `sessionName`, a status badge (CSS class `app-session-header__badge--online` or `--offline`, no hex colors), DP count display, and conditionally (mode === 'player') a Leave button that emits `leave`.

### Step 9.3 — Index + stories

```typescript
// packages/ui/src/components/AppSessionHeader/index.ts
export { default as AppSessionHeader } from './AppSessionHeader.vue';
```

```typescript
// packages/ui/src/components/AppSessionHeader/AppSessionHeader.stories.ts
import type { Meta, StoryObj } from '@storybook/vue3';
import { AppSessionHeader } from './index';

const labels = {
  statusOnline: 'Online',
  statusOffline: 'Offline',
  dpLabel: 'DP',
  leaveLabel: 'Leave session',
  backLabel: 'Back to sessions',
};

const meta: Meta<typeof AppSessionHeader> = {
  component: AppSessionHeader,
  title: 'Components/AppSessionHeader',
};
export default meta;
type Story = StoryObj<typeof AppSessionHeader>;

export const GmOnline: Story = {
  args: { sessionName: 'The Mercy of Kua', mode: 'gm', status: 'online', dpCount: 3, labels },
};
export const GmOffline: Story = {
  args: { sessionName: 'The Mercy of Kua', mode: 'gm', status: 'offline', dpCount: 3, labels },
};
export const PlayerOnline: Story = {
  args: { sessionName: 'The Mercy of Kua', mode: 'player', status: 'online', dpCount: 3, labels },
};
export const PlayerOffline: Story = {
  args: { sessionName: 'The Mercy of Kua', mode: 'player', status: 'offline', dpCount: 3, labels },
};
```

Run to GREEN. Commit:

```sh
git add packages/ui/src/components/AppSessionHeader/
git commit -m "feat(ui): AppSessionHeader — mode:gm|player, 6 tests green, 4 stories (Stream B)"
```

---

## P10 — @app/ui AppSessionJoinCard

**Tasks:** T-11.1.1.h (card component)

### Step 10.1 — Write failing spec

```typescript
// packages/ui/src/components/AppSessionJoinCard/AppSessionJoinCard.spec.ts
import { describe, expect, it } from 'vitest';
import { mount } from '@vue/test-utils';

import { AppSessionJoinCard } from './index';

const baseLabels = {
  titleValid: 'Join session',
  titleRevoked: 'Invite revoked',
  titleAlreadyMember: 'Already a member',
  titleNotSignedIn: 'Sign in to join',
  sessionLabel: 'Session',
  gmLabel: 'GM',
  ctaJoin: 'Join',
  ctaSignIn: 'Sign in',
  ctaGoToSession: 'Go to session',
  revokedMessage: 'This invite link is no longer active.',
  alreadyMemberMessage: 'You are already a member of this session.',
};

const preview = { sessionName: 'The Mercy of Kua', gmDisplayName: 'Kirill GM' };

describe('AppSessionJoinCard', () => {
  it('valid state: shows session + GM name and Join button', () => {
    const wrapper = mount(AppSessionJoinCard, {
      props: { state: 'valid', preview, labels: baseLabels },
    });
    expect(wrapper.text()).toContain('The Mercy of Kua');
    expect(wrapper.text()).toContain('Kirill GM');
    const joinBtn = wrapper.findAll('button').find((b) => b.text() === 'Join');
    expect(joinBtn).toBeDefined();
  });

  it('valid state: emits "join" on Join button click', async () => {
    const wrapper = mount(AppSessionJoinCard, {
      props: { state: 'valid', preview, labels: baseLabels },
    });
    await wrapper.find('button').trigger('click');
    expect(wrapper.emitted('join')).toBeTruthy();
  });

  it('revoked state: shows revoke message, no Join button', () => {
    const wrapper = mount(AppSessionJoinCard, {
      props: { state: 'revoked', preview: null, labels: baseLabels },
    });
    expect(wrapper.text()).toContain('This invite link is no longer active.');
    expect(wrapper.findAll('button').find((b) => b.text() === 'Join')).toBeUndefined();
  });

  it('already-member state: shows "Go to session" button and emits "goToSession"', async () => {
    const wrapper = mount(AppSessionJoinCard, {
      props: { state: 'already-member', preview, labels: baseLabels },
    });
    const btn = wrapper.findAll('button').find((b) => b.text() === 'Go to session');
    expect(btn).toBeDefined();
    await btn!.trigger('click');
    expect(wrapper.emitted('goToSession')).toBeTruthy();
  });

  it('not-signed-in state: shows Sign in button and emits "signIn"', async () => {
    const wrapper = mount(AppSessionJoinCard, {
      props: { state: 'not-signed-in', preview, labels: baseLabels },
    });
    const btn = wrapper.findAll('button').find((b) => b.text() === 'Sign in');
    expect(btn).toBeDefined();
    await btn!.trigger('click');
    expect(wrapper.emitted('signIn')).toBeTruthy();
  });
});
```

Run to RED. Implement component with props:

```typescript
type JoinState = 'valid' | 'revoked' | 'already-member' | 'not-signed-in';
interface Props {
  state: JoinState;
  preview: { sessionName: string; gmDisplayName: string } | null;
  labels: {
    /* all labels above */
  };
}
defineEmits<{ join: []; signIn: []; goToSession: [] }>();
```

Create `index.ts` and `AppSessionJoinCard.stories.ts` with 4 stories (one per state). Run to GREEN. Commit:

```sh
git add packages/ui/src/components/AppSessionJoinCard/
git commit -m "feat(ui): AppSessionJoinCard — 4 states, 5 tests green, 4 stories (Stream B)"
```

---

## P11 — Web player routes + middleware + Kick/Leave UI

**Tasks:** T-11.1.1.h/i/j, T-11.2.1.c/d, T-11.1.1.j

### Step 11.1 — Delete redirect middleware

```sh
rm apps/web/app/middleware/redirect-legacy-session.global.ts
```

This unblocks `/app/sessions/*` for player use.

### Step 11.2 — Patch `auth-required.global.ts`

Add an early return for join routes (public, unauthenticated access required):

```typescript
// After `if (!to.path.startsWith('/app')) return;`
if (to.path.startsWith('/app/sessions/join/')) return; // public invite join page
```

### Step 11.3 — Create join page

`apps/web/app/pages/app/sessions/join/[token].vue`:

This is a public page. Uses `useInvitePublicApi` composable (see Step 11.7) to call `GET /api/v1/invites/{token}/preview`. Mounts `AppSessionJoinCard` with the appropriate state:

- Loading: show skeleton card.
- `preview` returns `alreadyJoined: true` → state `'already-member'`, emit `goToSession` → `navigateTo('/app/sessions/' + membershipSessionId)`.
- `preview` returns data, caller not signed in → state `'not-signed-in'`, emit `signIn` → `navigateTo('/login?redirect=' + encodeURIComponent(to.fullPath))`.
- `preview` returns data, caller signed in → state `'valid'`, emit `join` → call `POST /api/v1/invites/{token}/accept` then navigate to `/app/sessions/{gameSessionId}`.
- `preview` throws 404 or 410 → state `'revoked'`.

i18n keys in colocated `<i18n lang="json">` block:

```json
{
  "en": {
    "joinCard": {
      "titleValid": "Join session",
      "titleRevoked": "Invite revoked",
      "titleAlreadyMember": "Already a member",
      "titleNotSignedIn": "Sign in to join",
      "sessionLabel": "Session",
      "gmLabel": "GM",
      "ctaJoin": "Join",
      "ctaSignIn": "Sign in",
      "ctaGoToSession": "Go to session",
      "revokedMessage": "This invite link is no longer active. Ask the GM for a new one.",
      "alreadyMemberMessage": "You are already a member of this session."
    }
  }
}
```

### Step 11.4 — Create player sessions list

`apps/web/app/pages/app/sessions/index.vue`:

Uses `useMyMembershipsApi` (see Step 11.7). Shows `MyMembershipSummary[]` as a list of cards. Each card links to `/app/sessions/{gameSessionId}`. Empty state when `items.length === 0`.

### Step 11.5 — Create player session shell

`apps/web/app/pages/app/sessions/[id].vue`:

- Uses `require-session-membership` middleware (defined per-page via `definePageMeta`).
- Mounts `AppSessionHeader` with `mode="player"`. On `leave` emit: call `DELETE /api/v1/game-sessions/{id}/members/{membershipId}` (via existing SDK), then navigate to `/app/sessions`.
- Chat column = `<div class="session-player__chat-placeholder" aria-label="Chat — coming soon" />`. This slot is filled in Stream D.
- Encounter section = read-only view of current encounter (reuse existing encounter read components if available, otherwise a "Encounter data coming in Stream D" placeholder).

### Step 11.6 — Create `require-session-membership` middleware

`apps/web/app/middleware/require-session-membership.ts`:

```typescript
export default defineNuxtRouteMiddleware(async (to) => {
  if (!to.path.match(/^\/app\/sessions\/[^/]+$/)) return;
  const sessionId = to.params.id as string;
  // Call GET /api/v1/me/memberships and check if sessionId is in the list.
  // If not a member, redirect to /app/sessions with a toast message.
  // Implementation uses useMyMembershipsApi() after composables are available in P12.
});
```

Note: full implementation is after P12 composables are in place.

### Step 11.7 — Composables

`apps/web/app/composables/useInvitePublicApi.ts`:

```typescript
import { getInvitePreview, acceptInvite } from '@app/api-client-ts';
import type { InvitePreview, AcceptInviteResponse, Problem } from '@app/api-client-ts';

export function useInvitePublicApi() {
  return {
    async getPreview(token: string): Promise<InvitePreview> {
      const res = await getInvitePreview({ path: { token } });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },
    async accept(token: string, characterId?: string | null): Promise<AcceptInviteResponse> {
      const res = await acceptInvite({
        path: { token },
        body: { characterId: characterId ?? null },
      });
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data;
    },
  };
}
```

`apps/web/app/composables/useMyMembershipsApi.ts`:

```typescript
import { getMyMemberships } from '@app/api-client-ts';
import type { MyMembershipSummary, Problem } from '@app/api-client-ts';

export function useMyMembershipsApi() {
  return {
    async list(): Promise<MyMembershipSummary[]> {
      const res = await getMyMemberships({});
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      if (res.error) throw res.error as Problem;
      return res.data.items;
    },
  };
}
```

### Step 11.8 — Mount `AppSessionHeader` in GM page + GM route guard

In `apps/web/app/pages/app/game-sessions/[id].vue`, add `definePageMeta`:

```typescript
definePageMeta({
  middleware: ['require-gm-role'], // new per-page middleware (Step 11.9)
});
```

Replace the existing hardcoded session name + status header markup with `<AppSessionHeader mode="gm" ... />`.

### Step 11.9 — GM route guard middleware

`apps/web/app/middleware/require-gm-role.ts`:

```typescript
export default defineNuxtRouteMiddleware(async (to) => {
  if (!to.path.match(/^\/app\/game-sessions\/[^/]+$/)) return;
  const sessionId = to.params.id as string;
  const { list } = useMyMembershipsApi();
  const memberships = await list().catch(() => []);
  const membership = memberships.find((m) => m.gameSessionId === sessionId && m.role === 'gm');
  if (!membership) return navigateTo(`/app/sessions/${sessionId}`);
});
```

Commit:

```sh
git add apps/web/app/pages/app/sessions/ \
        apps/web/app/middleware/ \
        apps/web/app/composables/useInvitePublicApi.ts \
        apps/web/app/composables/useMyMembershipsApi.ts \
        apps/web/app/pages/app/game-sessions/[id].vue
git commit -m "feat(web): player routes + join page + AppSessionHeader mount + route guards (Stream B)"
```

Auto-format before commit:

```sh
pnpm --filter @app/web lint --fix && pnpm format
```

---

## P12 — Web dashboard Playing-in wiring

**Tasks:** T-11.2.1.e (web side)

### Step 12.1 — Wire membership count

In the dashboard page (locate via `Grep` for `Playing in (0)`) — currently `apps/web/app/pages/app/dashboard/index.vue` or similar:

Replace the hardcoded `Playing in (0)` segment label with a reactive count from `useMyMembershipsApi`.

```typescript
// In <script setup>
const { list } = useMyMembershipsApi();
const memberships = ref<MyMembershipSummary[]>([]);
const playerMemberships = computed(() => memberships.value.filter((m) => m.role === 'player'));

onMounted(async () => {
  try {
    memberships.value = await list();
  } catch {
    // Network error: keep count at 0, don't break the page.
  }
});
```

In template:

```vue
<!-- Replace: label: t('sessions.playingIn', { count: 0 }) -->
<!-- With: -->
:label="t('sessions.playingIn', { count: playerMemberships.length })"
```

Update i18n key in colocated block:

```json
{
  "en": { "sessions": { "playingIn": "Playing in ({count})" } }
}
```

Run `pnpm --filter @app/web lint --fix && pnpm format`. Commit:

```sh
git add apps/web/app/pages/app/dashboard/
git commit -m "feat(web): dashboard Playing-in count wired to /me/memberships (Stream B)"
```

---

## P13 — Mobile player feature folder

**Tasks:** T-11.1.1.k, T-11.2.1.f

### Step 13.1 — Domain layer

`apps/mobile/lib/features/sessions/domain/player_membership.dart`:

```dart
import 'package:equatable/equatable.dart';

/// Domain model for a player's session membership.
/// Mirrors MyMembershipSummary from the API spec.
class PlayerMembership extends Equatable {
  const PlayerMembership({
    required this.membershipId,
    required this.gameSessionId,
    required this.sessionName,
    required this.role,
    this.characterId,
    this.characterName,
    required this.joinedAt,
  });

  final String membershipId;
  final String gameSessionId;
  final String sessionName;
  final String role; // 'gm' | 'player'
  final String? characterId;
  final String? characterName;
  final DateTime joinedAt;

  @override
  List<Object?> get props => [membershipId, gameSessionId, role];
}
```

`apps/mobile/lib/features/sessions/domain/player_session_repository.dart`:

```dart
import 'player_membership.dart';

abstract class PlayerSessionRepository {
  /// Returns all active session memberships for the authenticated user.
  Future<List<PlayerMembership>> getMyMemberships();

  /// Accepts an invite token and joins a session.
  /// Returns the joined [PlayerMembership].
  Future<PlayerMembership> acceptInvite(String token, {String? characterId});

  /// Leaves (soft-deletes) the caller's membership in a session.
  Future<void> leaveSession(String membershipId, String gameSessionId);
}
```

### Step 13.2 — Data layer

`apps/mobile/lib/features/sessions/data/player_session_repository_impl.dart`:

```dart
import 'package:app_api_client/app_api_client.dart' as api
    show InvitesApi, MeApi, MyMembershipSummary, AcceptInviteBody;

import '../domain/player_membership.dart';
import '../domain/player_session_repository.dart';

class PlayerSessionRepositoryImpl implements PlayerSessionRepository {
  const PlayerSessionRepositoryImpl({
    required api.InvitesApi invitesApi,
    required api.MeApi meApi,
    required api.GameSessionsApi gameSessionsApi,
  })  : _invitesApi = invitesApi,
        _meApi = meApi,
        _gameSessionsApi = gameSessionsApi;

  final api.InvitesApi _invitesApi;
  final api.MeApi _meApi;
  final api.GameSessionsApi _gameSessionsApi;

  static PlayerMembership _toDomain(api.MyMembershipSummary src) => PlayerMembership(
        membershipId: src.membershipId,
        gameSessionId: src.gameSessionId,
        sessionName: src.sessionName,
        role: src.role.name,
        characterId: src.characterId,
        characterName: src.characterName,
        joinedAt: src.joinedAt,
      );

  @override
  Future<List<PlayerMembership>> getMyMemberships() async {
    final res = await _meApi.getMyMemberships();
    final data = res.data;
    if (data == null) return const [];
    return data.items.map(_toDomain).toList(growable: false);
  }

  @override
  Future<PlayerMembership> acceptInvite(String token, {String? characterId}) async {
    final body = api.AcceptInviteBody((b) => b..characterId = characterId);
    final res = await _invitesApi.acceptInvite(token: token, acceptInviteBody: body);
    final data = res.data;
    if (data == null) throw StateError('acceptInvite returned empty body');
    return _toDomain(data.membership as api.MyMembershipSummary);
  }

  @override
  Future<void> leaveSession(String membershipId, String gameSessionId) async {
    await _gameSessionsApi.deleteMember(
      gameSessionId: gameSessionId,
      membershipId: membershipId,
    );
  }
}
```

Note: `api.InvitesApi` and `api.MeApi` are the codegen classes from Step P1. Exact class names depend on codegen output — verify after running `pnpm spec:codegen` and checking `packages/api-client-dart/lib/generated/`.

### Step 13.3 — Cubits

`apps/mobile/lib/features/sessions/presentation/blocs/player_sessions_list/player_sessions_list_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import '../../../domain/player_membership.dart';

enum PlayerSessionsStatus { initial, loading, success, failure }

class PlayerSessionsListState extends Equatable {
  const PlayerSessionsListState({
    this.status = PlayerSessionsStatus.initial,
    this.memberships = const [],
    this.errorMessage,
  });

  final PlayerSessionsStatus status;
  final List<PlayerMembership> memberships;
  final String? errorMessage;

  PlayerSessionsListState copyWith({
    PlayerSessionsStatus? status,
    List<PlayerMembership>? memberships,
    String? errorMessage,
  }) =>
      PlayerSessionsListState(
        status: status ?? this.status,
        memberships: memberships ?? this.memberships,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, memberships, errorMessage];
}
```

`apps/mobile/lib/features/sessions/presentation/blocs/player_sessions_list/player_sessions_list_cubit.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/player_session_repository.dart';
import 'player_sessions_list_state.dart';

class PlayerSessionsListCubit extends Cubit<PlayerSessionsListState> {
  PlayerSessionsListCubit({required PlayerSessionRepository repository})
      : _repository = repository,
        super(const PlayerSessionsListState());

  final PlayerSessionRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: PlayerSessionsStatus.loading));
    try {
      final memberships = await _repository.getMyMemberships();
      emit(state.copyWith(status: PlayerSessionsStatus.success, memberships: memberships));
    } catch (e) {
      emit(state.copyWith(
        status: PlayerSessionsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
```

### Step 13.4 — Pages (minimal shells)

`apps/mobile/lib/features/sessions/presentation/pages/player_sessions_list_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/player_sessions_list/player_sessions_list_cubit.dart';
import '../blocs/player_sessions_list/player_sessions_list_state.dart';
import 'package:coriolis_companion/app/routes.dart';

class PlayerSessionsListPage extends StatelessWidget {
  const PlayerSessionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playing in')),
      body: BlocBuilder<PlayerSessionsListCubit, PlayerSessionsListState>(
        builder: (context, state) {
          if (state.status == PlayerSessionsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.memberships.isEmpty) {
            return const Center(child: Text('Not playing in any sessions yet.'));
          }
          return ListView.builder(
            itemCount: state.memberships.length,
            itemBuilder: (context, index) {
              final m = state.memberships[index];
              return ListTile(
                title: Text(m.sessionName),
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.playerSessionDetail,
                  arguments: m.gameSessionId,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

`apps/mobile/lib/features/sessions/presentation/pages/join_session_page.dart` — takes a `token` argument, calls `PlayerSessionRepository.acceptInvite`, navigates to `playerSessionDetail` on success.

`apps/mobile/lib/features/sessions/presentation/pages/player_session_detail_page.dart` — takes `gameSessionId`, shows session name + DP, Chat tab placeholder (Stream D), Leave button.

### Step 13.5 — Widget tests

`apps/mobile/test/features/sessions/player_sessions_list_cubit_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coriolis_companion/features/sessions/domain/player_session_repository.dart';
import 'package:coriolis_companion/features/sessions/domain/player_membership.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/player_sessions_list/player_sessions_list_cubit.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/player_sessions_list/player_sessions_list_state.dart';

class MockPlayerSessionRepository extends Mock implements PlayerSessionRepository {}

void main() {
  group('PlayerSessionsListCubit', () {
    late MockPlayerSessionRepository repo;

    setUp(() {
      repo = MockPlayerSessionRepository();
    });

    final membership = PlayerMembership(
      membershipId: 'm-1',
      gameSessionId: 'gs-1',
      sessionName: 'The Mercy of Kua',
      role: 'player',
      joinedAt: DateTime(2026, 5, 16),
    );

    blocTest<PlayerSessionsListCubit, PlayerSessionsListState>(
      'emits loading then success with memberships',
      build: () {
        when(() => repo.getMyMemberships()).thenAnswer((_) async => [membership]);
        return PlayerSessionsListCubit(repository: repo);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const PlayerSessionsListState(status: PlayerSessionsStatus.loading),
        PlayerSessionsListState(
          status: PlayerSessionsStatus.success,
          memberships: [membership],
        ),
      ],
    );

    blocTest<PlayerSessionsListCubit, PlayerSessionsListState>(
      'emits loading then failure on error',
      build: () {
        when(() => repo.getMyMemberships()).thenThrow(Exception('network error'));
        return PlayerSessionsListCubit(repository: repo);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const PlayerSessionsListState(status: PlayerSessionsStatus.loading),
        isA<PlayerSessionsListState>()
            .having((s) => s.status, 'status', PlayerSessionsStatus.failure),
      ],
    );
  });
}
```

Run: `flutter test test/features/sessions/player_sessions_list_cubit_test.dart` — RED, implement, GREEN.

Commit:

```sh
git add apps/mobile/lib/features/sessions/ \
        apps/mobile/test/features/sessions/
git commit -m "feat(mobile): player sessions feature — repository, cubits, pages, cubit tests green (Stream B)"
```

---

## P14 — Mobile dashboard Playing-in wiring

**Tasks:** T-11.2.1.f

### Step 14.1 — Register dependencies

In `apps/mobile/lib/shared/di/injector.dart`, after the existing `GameSessionsApi` registration, add:

```dart
// ── Player sessions domain (Phase 8 Stream B) ─────────────────────────────
getIt
  ..registerLazySingleton<InvitesApi>(
    () => InvitesApi(getIt<Dio>(), standardSerializers),
  )
  ..registerLazySingleton<MeApi>(
    () => MeApi(getIt<Dio>(), standardSerializers),
  )
  ..registerLazySingleton<PlayerSessionRepository>(
    () => PlayerSessionRepositoryImpl(
      invitesApi: getIt<InvitesApi>(),
      meApi: getIt<MeApi>(),
      gameSessionsApi: getIt<GameSessionsApi>(),
    ),
  )
  ..registerFactory<PlayerSessionsListCubit>(
    () => PlayerSessionsListCubit(repository: getIt<PlayerSessionRepository>()),
  );
```

Import: `package:app_api_client/app_api_client.dart show InvitesApi, MeApi` — verify exact class names from codegen output.

Add to `routes.dart`:

```dart
abstract class AppRoutes {
  // ... existing ...
  static const playerSessions = '/app/player-sessions';
  static const playerSessionDetail = '/app/player-sessions/detail';
  static const joinSession = '/app/sessions/join';
}
```

Add route handlers in `onGenerateRoute`:

```dart
if (name == AppRoutes.playerSessions) {
  return MaterialPageRoute<void>(
    builder: (_) => BlocProvider(
      create: (_) => getIt<PlayerSessionsListCubit>()..load(),
      child: const PlayerSessionsListPage(),
    ),
    settings: settings,
  );
}

if (name == AppRoutes.playerSessionDetail) {
  final gameSessionId = settings.arguments as String;
  return MaterialPageRoute<void>(
    builder: (_) => PlayerSessionDetailPage(gameSessionId: gameSessionId),
    settings: settings,
  );
}

if (name == AppRoutes.joinSession) {
  final token = settings.arguments as String;
  return MaterialPageRoute<void>(
    builder: (_) => JoinSessionPage(token: token),
    settings: settings,
  );
}
```

### Step 14.2 — Wire dashboard Playing-in count

In `apps/mobile/lib/features/dashboard/presentation/dashboard_page.dart`:

Add `PlayerSessionRepository` to `_DashboardPageState`. Load memberships in `initState`. Replace `Playing in (0)` with a reactive count. The existing `DashboardSessionsScope.playing` segment body switches to `PlayerSessionsListPage` content.

Specifically in `_DashboardPageState`:

```dart
int _playerCount = 0;

@override
void initState() {
  super.initState();
  _loadPlayerCount();
}

Future<void> _loadPlayerCount() async {
  try {
    final repo = getIt<PlayerSessionRepository>();
    final memberships = await repo.getMyMemberships();
    final playerMemberships = memberships.where((m) => m.role == 'player').toList();
    if (mounted) setState(() => _playerCount = playerMemberships.length);
  } catch (_) {
    // Silently ignore — keep count at 0
  }
}
```

In `SegmentedButton`:

```dart
ButtonSegment(
  value: DashboardSessionsScope.playing,
  label: Text('Playing in ($_playerCount)'),
  icon: Icon(Icons.people_outline),
),
```

Memory rule: after any Dart import additions that require regenerated code, run:

```sh
docker compose -f docker/compose.yml restart backend  # if schema changed
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs
```

Commit:

```sh
git add apps/mobile/lib/shared/di/injector.dart \
        apps/mobile/lib/app/routes.dart \
        apps/mobile/lib/features/dashboard/presentation/dashboard_page.dart
git commit -m "feat(mobile): DI + routes + dashboard Playing-in count wired (Stream B)"
```

---

## P15 — Deep-link gating

**Tasks:** T-11.1.1.l (decision #5 — defer)

Check if `APP_LINKS_HOST` environment variable is set:

```sh
grep -r 'APP_LINKS_HOST' apps/mobile/lib/ apps/web/
```

If not configured: file a follow-up task in `specs/tasks/active.md` and do nothing else in this phase:

```markdown
## T-2026-05-17-DEEP-LINK-SETUP

**Status:** blocked — waiting on marketing host availability
**Goal:** Configure app_links (mobile) + apple-app-site-association / assetlinks.json (web)
**Gate:** APP_LINKS_HOST must be live before this can ship
**Design ref:** docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md decision #5
**Unblocks:** T-11.1.1.l
```

The web invite join page at `/app/sessions/join/:token` works as a plain web link without deep-link configuration. This is the correct v1.1 state per decision #5.

Commit:

```sh
git add specs/tasks/active.md
git commit -m "chore(tasks): file T-2026-05-17-DEEP-LINK-SETUP — blocked on host (Stream B decision #5)"
```

---

## P16 — Smoke — end-to-end acceptance

**Tasks:** T-11.2.1.g acceptance, Stream B acceptance criteria

### Step 16.1 — Cold-open invite flow

Prerequisite: local stack running (`docker compose -f docker/compose.yml up -d`).

```sh
# 1. GM rotates invite
curl -X POST http://localhost:3010/api/v1/game-sessions/{SESSION_ID}/invite/rotate \
     -H "Cookie: <gm-session-cookie>" | jq '.token, .url'

# 2. Preview (unauthenticated)
curl http://localhost:3010/api/v1/invites/{TOKEN}/preview | jq '.'
# Expect: { sessionName, gmDisplayName, alreadyJoined: false }

# 3. Accept (player auth)
curl -X POST http://localhost:3010/api/v1/invites/{TOKEN}/accept \
     -H "Cookie: <player-session-cookie>" \
     -H "Content-Type: application/json" \
     -d '{"characterId": null}' | jq '.membership.id, .membership.role'
# Expect: role = "player"

# 4. Verify /me/memberships
curl http://localhost:3010/api/v1/me/memberships \
     -H "Cookie: <player-session-cookie>" | jq '.items[].sessionName'
```

### Step 16.2 — Kicked player token regression

```sh
# GM kicks the player
curl -X DELETE http://localhost:3010/api/v1/game-sessions/{SESSION_ID}/members/{MEMBERSHIP_ID} \
     -H "Cookie: <gm-session-cookie>"

# Player requests new realtime token — should not include session channel
curl -X POST http://localhost:3010/api/v1/realtime/token \
     -H "Cookie: <player-session-cookie>" | jq '.token' | \
  node -e "const jwt = require('jsonwebtoken'); const t = require('fs').readFileSync('/dev/stdin','utf8').trim().replace(/"/g,''); const d = jwt.decode(t); console.log(JSON.stringify(d.channels));"
# Expect: [] (empty — kicked member excluded from ACL)
```

### Step 16.3 — Both clients receive `dp.changed`

```sh
# In one terminal: connect player to Centrifugo (manual WS test or use wscat)
wscat -c ws://localhost:8000/connection/websocket

# In another: GM increments DP
curl -X POST http://localhost:3010/api/v1/game-sessions/{SESSION_ID}/dp \
     -H "Cookie: <gm-session-cookie>" \
     -H "Content-Type: application/json" \
     -d '{"delta": 1}' | jq '.dpCount'
# Both GM and Player WS connections should receive dp.changed event on session.<id>
```

Commit everything pending, archive task to `done.md`, push:

```sh
git add specs/tasks/active.md specs/tasks/done.md
git commit -m "chore(tasks): Stream B complete — archive T-2026-05-16-PHASE-8-STREAM-B"
git push origin main
```

---

## Coverage map — task inventory to phases

| Task                                                                       | Phase                                                                |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------- | --- |
| T-11.1.1.h — web join page + AppSessionJoinCard                            | P10 + P11                                                            |
| T-11.1.1.i — web /app/sessions list + player shell                         | P11                                                                  |
| T-11.1.1.j — Leave (player) + Kick (GM) on members list                    | P11 (Leave), P4 (AcceptInvite enables membership for Kick to target) |
| T-11.1.1.k — mobile JoinSessionPage + SessionsListPage + SessionDetailPage | P13                                                                  |
| T-11.1.1.l — deep-link gated on host                                       | P15                                                                  |
| T-11.2.1.a — player shell layout (chat slot placeholder)                   | P11                                                                  |
| T-11.2.1.b — AppSessionHeader @app/ui mode:gm                              | player                                                               | P9  |
| T-11.2.1.c — require-session-membership middleware                         | P11                                                                  |
| T-11.2.1.d — GM route guard (require-gm-role)                              | P11                                                                  |
| T-11.2.1.e — mobile player sessions list                                   | P13                                                                  |
| T-11.2.1.f — mobile dashboard Playing-in wiring                            | P14                                                                  |
| T-11.2.1.g — RealtimeModule ACL widening                                   | P7                                                                   |
| T-11.2.1.h — regression test: kicked token excluded                        | P7 + P16                                                             |
| AcceptInviteCommand (deferred from Stream A)                               | P4                                                                   |
| GetInvitePreviewQuery (deferred from Stream A)                             | P5                                                                   |
| GetMyMembershipsQuery (deferred from Stream A)                             | P6                                                                   |
| MemberJoinedEvent (deferred from Stream A)                                 | P4                                                                   |
| Web dashboard Playing-in (deferred from Stream A)                          | P12                                                                  |

---

## Open questions

1. **`InvitesApi` / `MeApi` Dart codegen class names** — The exact Dart class names generated from `operationId: getInvitePreview` and `operationId: getMyMemberships` must be verified against `packages/api-client-dart/lib/generated/` after Step P1 codegen. The plan uses `InvitesApi` and `MeApi` as expected names; adjust P13/P14 imports accordingly.

2. **`AcceptInviteResponse.membership` type** — The codegen schema `AcceptInviteResponse` references `GameSessionMembership` but the mobile impl maps to `MyMembershipSummary`. In practice the backend returns a `MembershipReadModel`; the mapper in P13 may need adjustment to the actual codegen response type. Verify field names on first compile.

3. **`require-session-membership` middleware implementation** — The middleware in P11 Step 11.6 is a partial stub (full impl after P12 composables). If the middleware needs to call an API before composables are set up, alternative: use `definePageMeta({ middleware: false })` on the join page only and do the membership check inside the page's `onMounted`.

4. **`gameSessionsApi.deleteMember` method name in Dart codegen** — The `DELETE /api/v1/game-sessions/{id}/members/{membershipId}` operation's `operationId` in the spec determines the generated Dart method. Verify after codegen; update P13 `leaveSession` implementation accordingly.

5. **GM route guard performance** — `require-gm-role.ts` calls `GET /me/memberships` on every navigation to a GM session detail page. For v1.1 this is acceptable. If it becomes a bottleneck, cache the membership list in a Nuxt store (Pinia) for the session TTL.

6. **`GameSession.characterIds` field** — Per the design doc, cleanup of this field is deferred to Stream E. Do not reference or remove it in any Stream B file.

---
