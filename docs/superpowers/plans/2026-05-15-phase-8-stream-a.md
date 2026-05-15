# Phase 8 / Stream A — Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the foundation for Phase 8 — rename GM routes `/app/sessions/*` → `/app/game-sessions/*`, add `GameSessionMembership` table + invite fields on `GameSession`, backfill GM-role memberships, ship invite endpoints + `MembershipsModule` (CQRS) + GM-side `AppInviteManager` UI. Players cannot join yet (Stream B); chat does not yet exist (Streams C/D); realtime ACL is unchanged.

**Architecture:** CQRS-per-bounded-context per the project's NestJS handbook. New `apps/backend/src/modules/memberships/` module with commands (Rotate / Revoke / Kick / Leave / LinkCharacter), queries (ListMemberships / GetInviteMetadata), events (MemberJoined / MemberLeft / MemberKicked / CharacterLinked), domain errors, Prisma-backed repo. Invite tokens are 22-char URL-safe nanoids stored as SHA-256 hashes; the plaintext is returned exactly once. Web UI uses two new `@app/ui` components (`AppSessionShareLinkCard`, `AppInviteManager`) per handoff JSX. Mobile mirrors the manager surface only.

**Tech Stack:** NestJS 11 + Prisma 7 + CQRS, OpenAPI 3.1 spec-first via `pnpm spec:codegen`, Nuxt 4 SPA + Nuxt UI v4 + `@app/ui`, Flutter 3.41 + flutter_bloc, Vitest + Vue Test Utils + flutter_test, Storybook 8 with `addon-a11y`, nanoid v5, node `crypto` (SHA-256).

**Handoff JSX (canonical per project rule #8):** `/tmp/coriolis-handoff/coriolis-app/project/screens/invite-manager.jsx`, `/tmp/coriolis-handoff/coriolis-app/project/screens/session-share-link-card.jsx`, `/tmp/coriolis-handoff/coriolis-app/project/screens/gm-session.jsx`, `/tmp/coriolis-handoff/coriolis-app/project/screens/dashboard.jsx`.

---

## File map

**New backend files:**

- `apps/backend/prisma/migrations/20260516000001_add_memberships_and_invite/migration.sql`
- `apps/backend/src/modules/memberships/memberships.module.ts`
- `apps/backend/src/modules/memberships/memberships.controller.ts`
- `apps/backend/src/modules/memberships/domain/membership.ports.ts`
- `apps/backend/src/modules/memberships/domain/membership.errors.ts`
- `apps/backend/src/modules/memberships/domain/invite-token.ts`
- `apps/backend/src/modules/memberships/domain/invite-token.spec.ts`
- `apps/backend/src/modules/memberships/infra/membership.repo.ts`
- `apps/backend/src/modules/memberships/commands/rotate-invite.command.ts`
- `apps/backend/src/modules/memberships/commands/rotate-invite.handler.ts`
- `apps/backend/src/modules/memberships/commands/rotate-invite.handler.spec.ts`
- `apps/backend/src/modules/memberships/commands/revoke-invite.command.ts`
- `apps/backend/src/modules/memberships/commands/revoke-invite.handler.ts`
- `apps/backend/src/modules/memberships/commands/revoke-invite.handler.spec.ts`
- `apps/backend/src/modules/memberships/commands/kick-member.command.ts`
- `apps/backend/src/modules/memberships/commands/kick-member.handler.ts`
- `apps/backend/src/modules/memberships/commands/kick-member.handler.spec.ts`
- `apps/backend/src/modules/memberships/commands/leave-session.command.ts`
- `apps/backend/src/modules/memberships/commands/leave-session.handler.ts`
- `apps/backend/src/modules/memberships/commands/leave-session.handler.spec.ts`
- `apps/backend/src/modules/memberships/commands/link-character.command.ts`
- `apps/backend/src/modules/memberships/commands/link-character.handler.ts`
- `apps/backend/src/modules/memberships/commands/link-character.handler.spec.ts`
- `apps/backend/src/modules/memberships/queries/list-memberships.query.ts`
- `apps/backend/src/modules/memberships/queries/list-memberships.handler.ts`
- `apps/backend/src/modules/memberships/queries/list-memberships.handler.spec.ts`
- `apps/backend/src/modules/memberships/queries/get-invite-metadata.query.ts`
- `apps/backend/src/modules/memberships/queries/get-invite-metadata.handler.ts`
- `apps/backend/src/modules/memberships/queries/get-invite-metadata.handler.spec.ts`
- `apps/backend/src/modules/memberships/events/member-joined.event.ts`
- `apps/backend/src/modules/memberships/events/member-left.event.ts`
- `apps/backend/src/modules/memberships/events/member-kicked.event.ts`
- `apps/backend/src/modules/memberships/events/character-linked.event.ts`

**Modified backend files:**

- `apps/backend/prisma/schema.prisma` — add invite fields to `GameSession`, add `GameSessionMembership` model
- `apps/backend/src/modules/game-sessions/domain/game-session.ports.ts` — extend `GameSessionReadModel` with `memberships[]`
- `apps/backend/src/modules/game-sessions/infra/game-session.repo.ts` — include memberships in SELECT
- `apps/backend/src/modules/game-sessions/commands/create-game-session.handler.spec.ts` — fixture gains `memberships: []`
- `apps/backend/src/modules/game-sessions/commands/update-game-session.handler.spec.ts` — same
- `apps/backend/src/app.module.ts` — register `MembershipsModule`
- `apps/backend/src/main.ts` — no change expected; verify routes appear in startup log

**Modified spec files:**

- `packages/specs/openapi/openapi.yaml` — add invite & member routes, `GameSessionMembership` schema, extend `GameSession` schema

**New web files:**

- `apps/web/app/pages/app/game-sessions/index.vue` — moved from `app/sessions/index.vue`
- `apps/web/app/pages/app/game-sessions/[id].vue` — moved from `app/sessions/[id].vue`
- `apps/web/app/middleware/redirect-legacy-session.global.ts`
- `packages/ui/src/components/AppSessionShareLinkCard/AppSessionShareLinkCard.vue`
- `packages/ui/src/components/AppSessionShareLinkCard/AppSessionShareLinkCard.stories.ts`
- `packages/ui/src/components/AppSessionShareLinkCard/AppSessionShareLinkCard.spec.ts`
- `packages/ui/src/components/AppSessionShareLinkCard/index.ts`
- `packages/ui/src/components/AppInviteManager/AppInviteManager.vue`
- `packages/ui/src/components/AppInviteManager/AppInviteManager.stories.ts`
- `packages/ui/src/components/AppInviteManager/AppInviteManager.spec.ts`
- `packages/ui/src/components/AppInviteManager/index.ts`

**Modified web files:**

- `apps/web/app/pages/app/dashboard.vue` — add `Running | Playing in` segmented control
- `apps/web/app/i18n/locales/{en,ru,uk,el}.json` — add `invite.*` keys
- every `apps/web/**/*.{vue,ts}` referencing `/app/sessions/...` for GM use — rewrite to `/app/game-sessions/...`
- `packages/ui/src/index.ts` — export the two new components

**New mobile files:**

- `apps/mobile/lib/features/game_sessions/` — moved from `lib/features/sessions/`
- `apps/mobile/lib/features/game_sessions/presentation/widgets/invite_manager.dart`
- `apps/mobile/lib/features/game_sessions/presentation/widgets/invite_manager_test.dart` _(test under `test/` mirror)_

**Modified mobile files:**

- `apps/mobile/lib/features/game_sessions/data/sessions_repository.dart` — add rotate / revoke / metadata calls
- `apps/mobile/lib/app.dart` — fix imports
- `apps/mobile/lib/features/dashboard/presentation/dashboard_page.dart` — add segmented control
- everywhere `lib/features/sessions/` is imported across `apps/mobile/lib/**/*.dart` — rewrite to `lib/features/game_sessions/`

**Modified docs:**

- `AGENTS.md` — add §"URL naming policy" block

---

## Task 0: Preflight

**Files:** none

- [ ] **Step 1: Confirm clean working tree**

Run: `git status --short`
Expected: only the in-progress entry `specs/tasks/active.md` modified, plus `docs/IMPLEMENTATION_PLAN_PHASE_8.md` untracked. No other staged/unstaged.

- [ ] **Step 2: Confirm baseline tests are green**

Run: `pnpm --filter @app/backend test -- --reporter=dot`
Expected: all tests pass.

Run: `pnpm --filter @app/web test -- --reporter=dot`
Expected: all tests pass.

Run: `pnpm --filter @app/ui test -- --reporter=dot`
Expected: all tests pass.

- [ ] **Step 3: Confirm docker compose stack is up**

Run: `docker ps --format '{{.Names}} {{.Status}}' | grep -E 'web|backend|postgres|redis|centrifugo'`
Expected: five containers, all `Up`.

If not up: `docker compose -f docker/compose.yml up -d` and re-verify.

---

# Phase P1 — Route move

Three tasks. No business logic changes. End-state: GM lives at `/app/game-sessions/*` everywhere; mobile feature folder is `game_sessions/`; AGENTS.md documents the naming policy.

## Task 1: Move web GM pages + add legacy redirect middleware

**Files:**

- Move: `apps/web/app/pages/app/sessions/index.vue` → `apps/web/app/pages/app/game-sessions/index.vue`
- Move: `apps/web/app/pages/app/sessions/[id].vue` → `apps/web/app/pages/app/game-sessions/[id].vue`
- Create: `apps/web/app/middleware/redirect-legacy-session.global.ts`
- Modify: all `apps/web/**/*.{vue,ts}` containing `/app/sessions/`

- [ ] **Step 1: Create the new directory and move pages**

```bash
mkdir -p apps/web/app/pages/app/game-sessions
git mv apps/web/app/pages/app/sessions/index.vue apps/web/app/pages/app/game-sessions/index.vue
git mv apps/web/app/pages/app/sessions/\[id\].vue apps/web/app/pages/app/game-sessions/\[id\].vue
rmdir apps/web/app/pages/app/sessions
```

Expected: two files moved; `apps/web/app/pages/app/sessions/` removed.

- [ ] **Step 2: Rewrite internal references**

Run: `rg -l "'/app/sessions" apps/web/app | tee /tmp/sessions-refs.txt`

For every file listed, replace `'/app/sessions` with `'/app/game-sessions` and `"/app/sessions` with `"/app/game-sessions`. (Player routes do not exist yet, so this replacement is unambiguous.)

- [ ] **Step 3: Create the legacy redirect middleware**

Write `apps/web/app/middleware/redirect-legacy-session.global.ts`:

```ts
/**
 * Phase 8 Stream A — legacy redirect for the GM client.
 *
 * Until Stream B, the path /app/sessions/* is a leftover from before the
 * GM was relocated to /app/game-sessions/*. We 301 the old URL so GM
 * bookmarks still work. This middleware is REMOVED at the start of
 * Stream B, when /app/sessions/* lights up for the player client.
 */
export default defineNuxtRouteMiddleware((to) => {
  const match = to.path.match(/^\/app\/sessions(\/.*)?$/);
  if (!match) return;
  const tail = match[1] ?? '';
  return navigateTo(`/app/game-sessions${tail}`, { redirectCode: 301 });
});
```

- [ ] **Step 4: Lint + typecheck**

Run: `pnpm --filter @app/web lint --fix && pnpm --filter @app/web typecheck`
Expected: clean.

- [ ] **Step 5: Run web tests**

Run: `pnpm --filter @app/web test -- --reporter=dot`
Expected: all pass. Any spec asserting on `/app/sessions/...` URLs must be updated to `/app/game-sessions/...` and the update committed in this task.

- [ ] **Step 6: Smoke-check in the browser**

Open `http://localhost:3001/app/game-sessions` while signed in. Expected: list page renders. Then visit `http://localhost:3001/app/sessions` — expected: instant redirect to `/app/game-sessions`.

- [ ] **Step 7: Commit**

```bash
git add apps/web
git commit -m "$(cat <<'EOF'
refactor(web): move GM /app/sessions → /app/game-sessions

Phase 8 Stream A precondition. Frees /app/sessions/* for the player
client (Stream B). Adds a global route middleware that 301-redirects
the legacy path; the middleware is removed at the start of Stream B.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

## Task 2: Move mobile GM feature folder

**Files:**

- Move: `apps/mobile/lib/features/sessions/` → `apps/mobile/lib/features/game_sessions/`
- Modify: every Dart file importing `package:coriolis_companion/features/sessions/...`

- [ ] **Step 1: Move the feature folder**

```bash
cd apps/mobile
git mv lib/features/sessions lib/features/game_sessions
cd ../..
```

- [ ] **Step 2: Rewrite imports**

Run: `rg -l "package:coriolis_companion/features/sessions" apps/mobile | tee /tmp/mobile-imports.txt`

For each file, replace `package:coriolis_companion/features/sessions` with `package:coriolis_companion/features/game_sessions`.

Also check Dart relative imports if any: `rg -l "features/sessions" apps/mobile/lib --type dart`.

- [ ] **Step 3: Static analysis**

Run: `cd apps/mobile && flutter analyze lib`
Expected: 0 issues.

- [ ] **Step 4: Run mobile tests**

Run: `cd apps/mobile && flutter test`
Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add apps/mobile
git commit -m "$(cat <<'EOF'
refactor(mobile): rename features/sessions → features/game_sessions

Mirror of the web route move. Frees features/sessions/ for the
player client landing in Stream B.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

## Task 3: Document URL naming policy in AGENTS.md

**Files:**

- Modify: `AGENTS.md`

- [ ] **Step 1: Append a §"URL naming policy" block at the end of AGENTS.md**

```markdown
## URL naming policy (Phase 8+)

DB tables, Prisma models, TS/Dart classes use `GameSession` — never bare `Session`.
URL paths split by role:

| Path                              | Audience                               |
| --------------------------------- | -------------------------------------- |
| `/api/v1/game-sessions/*`         | GM-owned REST surface (all backend)    |
| `/app/game-sessions/*` (web)      | GM client shell                        |
| `/app/sessions/*` (web)           | Player client shell (Phase 8 Stream B) |
| `/app/sessions/join/:token` (web) | Public-ish invite landing              |

Rationale: the GM client has been at `/app/game-sessions/*` since Phase 8 Stream A;
Phase 8 Stream B mounts the player client at `/app/sessions/*` and removes the
legacy redirect middleware.
```

- [ ] **Step 2: Commit**

```bash
git add AGENTS.md
git commit -m "docs(agents): URL naming policy for Phase 8 GM/player split

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

# Phase P2 — Spec (OpenAPI)

One task. Add the membership/invite endpoints + schema, then regen the clients in one shot. The full operation set in Stream A is:

| Method | Path                                                | Visibility              |
| ------ | --------------------------------------------------- | ----------------------- |
| GET    | `/api/v1/game-sessions/{id}/invite`                 | GM only                 |
| POST   | `/api/v1/game-sessions/{id}/invite/rotate`          | GM only                 |
| DELETE | `/api/v1/game-sessions/{id}/invite`                 | GM only                 |
| GET    | `/api/v1/game-sessions/{id}/members`                | GM or member            |
| PATCH  | `/api/v1/game-sessions/{id}/members/{membershipId}` | self or GM (role-aware) |
| DELETE | `/api/v1/game-sessions/{id}/members/{membershipId}` | self-leave or GM-kick   |

`GameSession` response gains a `memberships[]` array.
New schema: `GameSessionMembership`, `InviteRotated`, `InviteMetadata`.

## Task 4: OpenAPI — invite endpoints + membership endpoints + new schemas

**Files:**

- Modify: `packages/specs/openapi/openapi.yaml`

- [ ] **Step 1: Add new schemas under `components.schemas`**

Add (alongside the existing `GameSession` schema) — place these new entries directly after the `GameSession` schema in `openapi.yaml`:

```yaml
GameSessionMembership:
  type: object
  description: |
    A row in the GameSessionMembership join table. Identifies a user's
    participation in a GameSession with a role and an optionally-linked
    character.
  required: [id, gameSessionId, userId, role, joinedAt]
  properties:
    id:
      type: string
      description: Stable cuid; used as targetMembershipId in chat whispers.
    gameSessionId:
      type: string
    userId:
      type: string
    role:
      type: string
      enum: [gm, player]
    displayName:
      type: string
      description: Cached display name of the user (denormalised for UI).
      nullable: true
    characterId:
      type: string
      nullable: true
    characterName:
      type: string
      nullable: true
    joinedAt:
      type: string
      format: date-time
    leftAt:
      type: string
      format: date-time
      nullable: true

InviteMetadata:
  type: object
  description: |
    Metadata about a GameSession's current invite link. The plaintext
    URL is returned only once, by POST /invite/rotate — this endpoint
    only exposes whether an invite is active and when it was rotated.
  required: [active]
  properties:
    active:
      type: boolean
    rotatedAt:
      type: string
      format: date-time
      nullable: true

InviteRotated:
  type: object
  description: |
    Response to POST /invite/rotate. Contains the plaintext URL exactly
    once; subsequent reads (GET /invite) return InviteMetadata without
    the URL. If the GM loses the URL they must rotate again.
  required: [url, token, rotatedAt]
  properties:
    url:
      type: string
      format: uri
      description: Absolute URL clients should share with players.
    token:
      type: string
      description: The 22-char nanoid component of the URL.
    rotatedAt:
      type: string
      format: date-time
```

- [ ] **Step 2: Extend the `GameSession` schema with `memberships[]`**

Locate the existing `GameSession` schema in `openapi.yaml` and append a `memberships` property to its `properties:` block (also add it to `required` if `characterIds` is required there — match the existing list):

```yaml
memberships:
  type: array
  description: |
    Active members of this session. Always includes the GM row.
    Phase 8: this replaces `characterIds` as the source of truth
    for "who is at this table" — `characterIds` is deprecated and
    will be removed in Stream E.
  items:
    $ref: '#/components/schemas/GameSessionMembership'
```

Add `memberships` to the `required` list of `GameSession`.

- [ ] **Step 3: Add invite endpoints (GM-only)**

Add the following paths, alphabetically near the existing `/api/v1/game-sessions/{id}/characters` block:

```yaml
/api/v1/game-sessions/{id}/invite:
  get:
    operationId: getInviteMetadata
    summary: Read invite metadata (GM only)
    description: |
      Returns whether an invite is active for this session and when
      it was last rotated. Never returns the plaintext URL — that is
      revealed exactly once by POST /invite/rotate.
    tags: [game-sessions]
    security:
      - cookieAuth: []
      - bearerAuth: []
    parameters:
      - $ref: '#/components/parameters/GameSessionId'
    responses:
      '200':
        description: Invite metadata
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/InviteMetadata'
            examples:
              noActiveInvite:
                value: { active: false, rotatedAt: null }
              active:
                value: { active: true, rotatedAt: '2026-05-15T10:00:00Z' }
      '401':
        description: No active session
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }
      '403':
        description: Caller does not own this session
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }

  delete:
    operationId: revokeInvite
    summary: Revoke the current invite (GM only)
    description: |
      Clears the invite hash on the session. Subsequent accept attempts
      return 410 Gone. Re-issuing requires POST /invite/rotate.
    tags: [game-sessions]
    security:
      - cookieAuth: []
      - bearerAuth: []
    parameters:
      - $ref: '#/components/parameters/GameSessionId'
    responses:
      '204':
        description: Revoked (or already inactive — idempotent)
      '401':
        description: No active session
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }
      '403':
        description: Caller does not own this session
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }

/api/v1/game-sessions/{id}/invite/rotate:
  post:
    operationId: rotateInvite
    summary: Rotate (or first-generate) the session's invite link (GM only)
    description: |
      Generates a fresh 22-char URL-safe nanoid, stores its SHA-256 hash,
      and returns the plaintext URL exactly once. Any previously-issued
      invite immediately becomes invalid.
    tags: [game-sessions]
    security:
      - cookieAuth: []
      - bearerAuth: []
    parameters:
      - $ref: '#/components/parameters/GameSessionId'
    responses:
      '200':
        description: Invite rotated; plaintext URL returned ONCE
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/InviteRotated'
            examples:
              rotated:
                value:
                  url: 'https://app.coriolis.example.com/app/sessions/join/Sl9X3kQpZr8mVtNuY7Hb2C'
                  token: 'Sl9X3kQpZr8mVtNuY7Hb2C'
                  rotatedAt: '2026-05-15T10:00:00Z'
      '401':
        description: No active session
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }
      '403':
        description: Caller does not own this session
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }
```

- [ ] **Step 4: Add member endpoints (GM or member; role-aware)**

Add the following paths, directly after the invite block:

```yaml
/api/v1/game-sessions/{id}/members:
  get:
    operationId: listMembers
    summary: List session members (GM or member)
    description: |
      Returns active memberships for this session. Available to the
      GM and to any active member. Leaver rows (with non-null leftAt)
      are excluded.
    tags: [game-sessions]
    security:
      - cookieAuth: []
      - bearerAuth: []
    parameters:
      - $ref: '#/components/parameters/GameSessionId'
    responses:
      '200':
        description: Member list
        content:
          application/json:
            schema:
              type: array
              items:
                $ref: '#/components/schemas/GameSessionMembership'
      '401':
        description: No active session
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }
      '403':
        description: Caller is neither the GM nor an active member
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }

/api/v1/game-sessions/{id}/members/{membershipId}:
  patch:
    operationId: linkMembershipCharacter
    summary: Link or unlink a character to a membership
    description: |
      The owner of the membership (the player or the GM themselves) can
      change which character is attached. The GM can also operate on
      any membership for moderation. Pass `characterId: null` to unlink.
    tags: [game-sessions]
    security:
      - cookieAuth: []
      - bearerAuth: []
    parameters:
      - $ref: '#/components/parameters/GameSessionId'
      - name: membershipId
        in: path
        required: true
        schema: { type: string }
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            required: [characterId]
            properties:
              characterId:
                type: string
                nullable: true
    responses:
      '200':
        description: Updated membership
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/GameSessionMembership'
      '401':
        description: No active session
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }
      '403':
        description: Not the owning member or the session GM, or character not owned
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }
      '404':
        description: Membership or character not found
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }

  delete:
    operationId: removeMembership
    summary: Kick (GM) or leave (member) — soft delete
    description: |
      Stamps `leftAt` on the membership. The GM can kick any non-GM member;
      a player can self-leave. The GM cannot kick themselves.
    tags: [game-sessions]
    security:
      - cookieAuth: []
      - bearerAuth: []
    parameters:
      - $ref: '#/components/parameters/GameSessionId'
      - name: membershipId
        in: path
        required: true
        schema: { type: string }
    responses:
      '204':
        description: Membership left/kicked
      '401':
        description: No active session
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }
      '403':
        description: Not authorized for this membership
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }
      '404':
        description: Membership not found
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }
      '422':
        description: GM cannot kick themselves
        content:
          application/problem+json:
            schema: { $ref: '#/components/schemas/Problem' }
```

- [ ] **Step 5: Validate, bundle, codegen**

Run:

```bash
pnpm spec:validate
pnpm spec:bundle
pnpm spec:codegen
```

Expected: each step exits 0. Generated diff lands under `packages/api-client-ts/src/generated/` and `packages/api-client-dart/lib/generated/`.

- [ ] **Step 6: Commit spec + codegen separately**

```bash
git add packages/specs/openapi/openapi.yaml
git commit -m "spec(openapi): Phase 8 Stream A — invite + membership routes

Adds GameSessionMembership / InviteMetadata / InviteRotated schemas and
the six new endpoints. GameSession response now carries memberships[]
alongside the deprecated characterIds (removed in Stream E).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"

git add packages/api-client-ts packages/api-client-dart
git commit -m "chore(codegen): regenerate after Phase 8 Stream A spec change

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

# Phase P3 — Prisma migration

Two tasks. Schema first, migration SQL second, backfill verified by a dedicated unit test on a fixture-loaded throwaway DB.

## Task 5: Prisma schema — invite fields + GameSessionMembership

**Files:**

- Modify: `apps/backend/prisma/schema.prisma`

- [ ] **Step 1: Extend `GameSession`**

In `apps/backend/prisma/schema.prisma`, locate `model GameSession {` and add the following fields/relations _inside_ the model:

```prisma
  inviteTokenHash    String?                @db.Char(64) // SHA-256 hex; NULL = no active invite
  inviteRotatedAt    DateTime?
  inviteCreatedById  String?
  memberships        GameSessionMembership[]
```

- [ ] **Step 2: Add the `GameSessionMembership` model**

Append (after `CharacterGameSession`):

```prisma
/// Phase 8 — a row per (user, gameSession). Source of truth for "who is at
/// this table." Backfilled from existing owners by migration
/// 20260516000001_add_memberships_and_invite. The legacy `characterIds`
/// array on GameSession is deprecated and removed in Phase 8 Stream E.
model GameSessionMembership {
  id            String       @id @default(cuid())
  gameSessionId String
  gameSession   GameSession  @relation(fields: [gameSessionId], references: [id], onDelete: Cascade)
  userId        String
  role          String       // "gm" | "player"
  characterId   String?
  character     Character?   @relation(fields: [characterId], references: [id], onDelete: SetNull)
  joinedAt      DateTime     @default(now())
  leftAt        DateTime?

  @@unique([gameSessionId, userId])
  @@index([userId])
  @@map("game_session_membership")
}
```

- [ ] **Step 3: Add the reverse relation on `Character`**

Locate `model Character {` and add:

```prisma
  memberships GameSessionMembership[]
```

- [ ] **Step 4: Generate the migration scaffold**

Inside the running backend container:

```bash
docker compose -f docker/compose.yml exec backend pnpm prisma migrate dev --name add_memberships_and_invite --create-only
```

Expected: a new folder under `apps/backend/prisma/migrations/<timestamp>_add_memberships_and_invite/migration.sql` with the auto-generated DDL. Inspect it; the next task replaces the body with the hand-written version.

- [ ] **Step 5: Restart the backend container after `prisma generate`**

```bash
docker compose -f docker/compose.yml restart backend
```

(See `~/.claude/projects/.../memory/feedback_prisma_in_container.md` — Prisma client changes require a backend restart.)

- [ ] **Step 6: Commit the schema change**

```bash
git add apps/backend/prisma/schema.prisma apps/backend/prisma/migrations
git commit -m "prisma: GameSessionMembership + GameSession invite fields (schema only)

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

## Task 6: Migration SQL — invite fields + GameSessionMembership + GM backfill

**Files:**

- Modify: the migration SQL created in Task 5 (rename folder to `20260516000001_add_memberships_and_invite/`)

- [ ] **Step 1: Rename the migration folder for deterministic ordering**

```bash
cd apps/backend/prisma/migrations
mv $(ls -d *add_memberships_and_invite) 20260516000001_add_memberships_and_invite
cd ../../../..
```

- [ ] **Step 2: Replace the migration SQL with the canonical version**

Open `apps/backend/prisma/migrations/20260516000001_add_memberships_and_invite/migration.sql` and overwrite with:

```sql
-- Migration: add_memberships_and_invite
--
-- Phase 8 Stream A.
-- Adds:
--   1. invite fields on game_session (inviteTokenHash, inviteRotatedAt,
--      inviteCreatedById).
--   2. game_session_membership table with (gameSessionId, userId) unique,
--      (userId) indexed.
-- Backfill: for every existing game_session row, INSERT a GM-role
-- membership for its owner. This is required so the existing realtime
-- ACL ("session.<id> for any active membership", to land in Stream B)
-- continues to authorise the GM after Stream B widens the ACL query.

BEGIN;

-- 1. Extend game_session ------------------------------------------------
ALTER TABLE "game_session"
  ADD COLUMN "inviteTokenHash"   CHAR(64),
  ADD COLUMN "inviteRotatedAt"   TIMESTAMP(3),
  ADD COLUMN "inviteCreatedById" TEXT;

-- 2. Create game_session_membership ------------------------------------
CREATE TABLE "game_session_membership" (
  "id"            TEXT NOT NULL,
  "gameSessionId" TEXT NOT NULL,
  "userId"        TEXT NOT NULL,
  "role"          TEXT NOT NULL,
  "characterId"   TEXT,
  "joinedAt"      TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "leftAt"        TIMESTAMP(3),

  CONSTRAINT "game_session_membership_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "game_session_membership_gameSessionId_userId_key"
  ON "game_session_membership"("gameSessionId", "userId");

CREATE INDEX "game_session_membership_userId_idx"
  ON "game_session_membership"("userId");

ALTER TABLE "game_session_membership"
  ADD CONSTRAINT "game_session_membership_gameSessionId_fkey"
    FOREIGN KEY ("gameSessionId") REFERENCES "game_session"("id")
    ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT "game_session_membership_characterId_fkey"
    FOREIGN KEY ("characterId") REFERENCES "character"("id")
    ON DELETE SET NULL ON UPDATE CASCADE;

-- 3. Backfill GM memberships --------------------------------------------
-- One row per existing game_session, role="gm", characterId NULL.
-- joinedAt mirrors the session's createdAt so the audit trail is honest.
INSERT INTO "game_session_membership" ("id", "gameSessionId", "userId", "role", "joinedAt")
SELECT
  -- 24-char cuid-like id, prefixed so backfill rows are auditable.
  'cmbf' || substr(md5(gs.id || gs."ownerId" || gs."createdAt"::text), 1, 20),
  gs.id,
  gs."ownerId",
  'gm',
  gs."createdAt"
FROM "game_session" gs
WHERE NOT EXISTS (
  SELECT 1
  FROM "game_session_membership" m
  WHERE m."gameSessionId" = gs.id AND m."userId" = gs."ownerId"
);

COMMIT;
```

- [ ] **Step 3: Run the migration inside the container**

```bash
docker compose -f docker/compose.yml exec backend pnpm prisma migrate deploy
```

Expected: `Applying migration "20260516000001_add_memberships_and_invite"` then success.

- [ ] **Step 4: Spot-check the backfill from psql**

```bash
docker compose -f docker/compose.yml exec postgres psql -U coriolis -d coriolis -c "SELECT COUNT(*) AS sessions FROM game_session;"
docker compose -f docker/compose.yml exec postgres psql -U coriolis -d coriolis -c "SELECT COUNT(*) AS gm_memberships FROM game_session_membership WHERE role='gm';"
```

Expected: `sessions` count equals `gm_memberships` count.

- [ ] **Step 5: Restart backend**

```bash
docker compose -f docker/compose.yml restart backend
```

- [ ] **Step 6: Commit**

```bash
git add apps/backend/prisma/migrations/20260516000001_add_memberships_and_invite
git commit -m "prisma(migration): backfill GM memberships, add invite fields

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

# Phase P4 — Backend domain: errors, ports, invite token

Three tasks.

## Task 7: Domain errors

**Files:**

- Create: `apps/backend/src/modules/memberships/domain/membership.errors.ts`

- [ ] **Step 1: Write the file**

```ts
/**
 * WHY this file exists:
 * Domain errors for the memberships bounded context. Each maps to an
 * RFC 9457 problem+json via HttpExceptionFilter.
 *
 * Codes are namespaced under MEMBERSHIP_* / INVITE_*; clients key off
 * `code` for i18n and retry logic.
 */
import { DomainError } from '../../../common/errors/domain-error';

export class MembershipNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'MEMBERSHIP_NOT_FOUND',
      status: 404,
      title: 'Membership Not Found',
      detail: `Membership ${id} does not exist or has left the session.`,
    });
  }
}

export class MembershipNotAuthorizedError extends DomainError {
  constructor() {
    super({
      code: 'MEMBERSHIP_NOT_AUTHORIZED',
      status: 403,
      title: 'Forbidden',
      detail: 'Caller may not perform this action on this membership.',
    });
  }
}

export class CannotKickGmError extends DomainError {
  constructor() {
    super({
      code: 'CANNOT_KICK_GM',
      status: 422,
      title: 'Cannot Kick GM',
      detail: 'The GM membership cannot be removed from its own session.',
    });
  }
}

export class CharacterNotOwnedError extends DomainError {
  constructor(characterId: string) {
    super({
      code: 'CHARACTER_NOT_OWNED',
      status: 403,
      title: 'Forbidden',
      detail: `Character ${characterId} does not belong to you.`,
    });
  }
}

export class InviteRevokedError extends DomainError {
  constructor() {
    super({
      code: 'INVITE_REVOKED',
      status: 410,
      title: 'Invite Revoked',
      detail: 'This invite link is no longer valid. Ask the GM for a new one.',
    });
  }
}
```

- [ ] **Step 2: Verify the file compiles in isolation**

Run: `pnpm --filter @app/backend typecheck`
Expected: clean.

- [ ] **Step 3: Commit**

```bash
git add apps/backend/src/modules/memberships/domain/membership.errors.ts
git commit -m "feat(memberships): domain errors

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

## Task 8: Domain ports

**Files:**

- Create: `apps/backend/src/modules/memberships/domain/membership.ports.ts`

- [ ] **Step 1: Write the file**

```ts
/**
 * WHY this file exists:
 * Port interfaces decouple the application layer from Prisma. Handlers
 * inject IMembershipRepo and IGameSessionInviteRepo by DI tokens; the
 * Prisma adapter in infra/ implements both. Unit tests swap in vi.fn()
 * mocks without bootstrapping a database.
 *
 * Read models match the OpenAPI GameSessionMembership / InviteMetadata
 * schemas exactly.
 */

export type MembershipRole = 'gm' | 'player';

export interface MembershipReadModel {
  id: string;
  gameSessionId: string;
  userId: string;
  role: MembershipRole;
  displayName: string | null;
  characterId: string | null;
  characterName: string | null;
  joinedAt: string; // ISO-8601
  leftAt: string | null;
}

export interface InviteMetadataReadModel {
  active: boolean;
  rotatedAt: string | null;
}

export const MEMBERSHIP_REPO = Symbol('MEMBERSHIP_REPO');

export interface IMembershipRepo {
  /** Lists ACTIVE (leftAt IS NULL) memberships for the session. */
  listActive(gameSessionId: string): Promise<MembershipReadModel[]>;

  /** Finds a membership by id, including soft-deleted ones. */
  findById(id: string): Promise<MembershipReadModel | null>;

  /** Finds the active membership for (gameSessionId, userId), if any. */
  findActiveByUser(gameSessionId: string, userId: string): Promise<MembershipReadModel | null>;

  /** Soft-deletes by stamping `leftAt = now()`. Idempotent. */
  softDelete(id: string): Promise<void>;

  /** Patches characterId on an existing membership. */
  setCharacter(id: string, characterId: string | null): Promise<MembershipReadModel>;
}

export const GAME_SESSION_INVITE_REPO = Symbol('GAME_SESSION_INVITE_REPO');

export interface IGameSessionInviteRepo {
  /** Asserts the caller owns this session. Throws GameSessionNotOwnerError otherwise. */
  assertOwner(gameSessionId: string, userId: string): Promise<void>;

  /** Returns {active, rotatedAt}; never the plaintext token. */
  getMetadata(gameSessionId: string): Promise<InviteMetadataReadModel>;

  /**
   * Replaces the active invite token hash. Returns the rotation timestamp.
   * The caller is responsible for generating the plaintext+hash via
   * domain/invite-token.ts.
   */
  rotate(
    gameSessionId: string,
    tokenHash: string,
    createdByUserId: string,
  ): Promise<{ rotatedAt: string }>;

  /** Nulls the invite hash field. Idempotent. */
  revoke(gameSessionId: string): Promise<void>;
}
```

- [ ] **Step 2: Typecheck**

Run: `pnpm --filter @app/backend typecheck`
Expected: clean.

- [ ] **Step 3: Commit**

```bash
git add apps/backend/src/modules/memberships/domain/membership.ports.ts
git commit -m "feat(memberships): domain ports

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

## Task 9: Invite-token utility (TDD)

**Files:**

- Create: `apps/backend/src/modules/memberships/domain/invite-token.ts`
- Create: `apps/backend/src/modules/memberships/domain/invite-token.spec.ts`

- [ ] **Step 1: Write the failing spec**

`apps/backend/src/modules/memberships/domain/invite-token.spec.ts`:

```ts
import { describe, expect, it } from 'vitest';

import { generateInviteToken, hashInviteToken } from './invite-token';

describe('invite-token', () => {
  it('generateInviteToken returns a 22-char URL-safe nanoid', () => {
    const token = generateInviteToken();
    expect(token).toHaveLength(22);
    expect(token).toMatch(/^[A-Za-z0-9_-]{22}$/);
  });

  it('generateInviteToken produces unique values', () => {
    const tokens = new Set(Array.from({ length: 1000 }, () => generateInviteToken()));
    expect(tokens.size).toBe(1000);
  });

  it('hashInviteToken returns a 64-char lowercase hex SHA-256', () => {
    const hash = hashInviteToken('Sl9X3kQpZr8mVtNuY7Hb2C');
    expect(hash).toHaveLength(64);
    expect(hash).toMatch(/^[0-9a-f]{64}$/);
  });

  it('hashInviteToken is deterministic', () => {
    const a = hashInviteToken('Sl9X3kQpZr8mVtNuY7Hb2C');
    const b = hashInviteToken('Sl9X3kQpZr8mVtNuY7Hb2C');
    expect(a).toBe(b);
  });

  it('hashInviteToken yields different hashes for different inputs', () => {
    expect(hashInviteToken('a')).not.toBe(hashInviteToken('b'));
  });
});
```

- [ ] **Step 2: Run — expect FAIL (module missing)**

Run: `pnpm --filter @app/backend test -- invite-token.spec.ts`
Expected: FAIL — `Cannot find module './invite-token'`.

- [ ] **Step 3: Implement the module**

`apps/backend/src/modules/memberships/domain/invite-token.ts`:

```ts
/**
 * WHY this file exists:
 * Pure helpers — no DI, no side effects beyond `crypto`. Isolated here so
 * unit tests can exercise them without a NestJS container.
 *
 * Token length 22 chars over the nanoid default alphabet
 * (URL-safe: A–Z a–z 0–9 _ -) yields ~131 bits of entropy, well above
 * the threshold for an invite that any holder can use. Stored as
 * SHA-256 (hex) at rest; plaintext is returned to the GM exactly once.
 */
import { createHash } from 'node:crypto';

import { nanoid } from 'nanoid';

const INVITE_TOKEN_LENGTH = 22;

export function generateInviteToken(): string {
  return nanoid(INVITE_TOKEN_LENGTH);
}

export function hashInviteToken(plaintext: string): string {
  return createHash('sha256').update(plaintext, 'utf8').digest('hex');
}
```

- [ ] **Step 4: Run — expect PASS**

Run: `pnpm --filter @app/backend test -- invite-token.spec.ts`
Expected: 5 passing.

- [ ] **Step 5: Commit**

```bash
git add apps/backend/src/modules/memberships/domain
git commit -m "feat(memberships): invite-token nanoid + SHA-256 helper

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

# Phase P5 — Backend infra

One task: MembershipRepo (Prisma adapter for both port interfaces).

## Task 10: MembershipRepo

**Files:**

- Create: `apps/backend/src/modules/memberships/infra/membership.repo.ts`

- [ ] **Step 1: Write the file**

```ts
/**
 * WHY this file exists:
 * Infrastructure adapter — the only file in the memberships bounded
 * context that imports PrismaService. Implements IMembershipRepo and
 * IGameSessionInviteRepo against the game_session and
 * game_session_membership tables.
 *
 * Display names and character names are joined off the User and Character
 * tables; the read-model fields are nullable to tolerate deleted users
 * or unlinked characters.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';
import {
  GameSessionNotFoundError,
  GameSessionNotOwnerError,
} from '../../game-sessions/domain/game-session.errors';

import type {
  IGameSessionInviteRepo,
  IMembershipRepo,
  InviteMetadataReadModel,
  MembershipReadModel,
  MembershipRole,
} from '../domain/membership.ports';

// --------------- Select shape ---------------

const MEMBERSHIP_SELECT = {
  id: true,
  gameSessionId: true,
  userId: true,
  role: true,
  characterId: true,
  joinedAt: true,
  leftAt: true,
  character: { select: { name: true } },
} as const;

// --------------- Mapper ---------------

interface PrismaMembership {
  id: string;
  gameSessionId: string;
  userId: string;
  role: string;
  characterId: string | null;
  joinedAt: Date;
  leftAt: Date | null;
  character: { name: string } | null;
}

function toReadModel(row: PrismaMembership, displayName: string | null): MembershipReadModel {
  return {
    id: row.id,
    gameSessionId: row.gameSessionId,
    userId: row.userId,
    role: row.role as MembershipRole,
    displayName,
    characterId: row.characterId,
    characterName: row.character?.name ?? null,
    joinedAt: row.joinedAt.toISOString(),
    leftAt: row.leftAt?.toISOString() ?? null,
  };
}

// --------------- Repo ---------------

@Injectable()
export class MembershipRepo implements IMembershipRepo, IGameSessionInviteRepo {
  constructor(private readonly prisma: PrismaService) {}

  // ---- IMembershipRepo ----

  async listActive(gameSessionId: string): Promise<MembershipReadModel[]> {
    const rows = await this.prisma.gameSessionMembership.findMany({
      where: { gameSessionId, leftAt: null },
      orderBy: { joinedAt: 'asc' },
      select: MEMBERSHIP_SELECT,
    });
    const users = await this.fetchDisplayNames(rows.map((r) => r.userId));
    return rows.map((r) => toReadModel(r, users.get(r.userId) ?? null));
  }

  async findById(id: string): Promise<MembershipReadModel | null> {
    const row = await this.prisma.gameSessionMembership.findUnique({
      where: { id },
      select: MEMBERSHIP_SELECT,
    });
    if (!row) return null;
    const users = await this.fetchDisplayNames([row.userId]);
    return toReadModel(row, users.get(row.userId) ?? null);
  }

  async findActiveByUser(
    gameSessionId: string,
    userId: string,
  ): Promise<MembershipReadModel | null> {
    const row = await this.prisma.gameSessionMembership.findFirst({
      where: { gameSessionId, userId, leftAt: null },
      select: MEMBERSHIP_SELECT,
    });
    if (!row) return null;
    const users = await this.fetchDisplayNames([userId]);
    return toReadModel(row, users.get(userId) ?? null);
  }

  async softDelete(id: string): Promise<void> {
    await this.prisma.gameSessionMembership.updateMany({
      where: { id, leftAt: null },
      data: { leftAt: new Date() },
    });
  }

  async setCharacter(id: string, characterId: string | null): Promise<MembershipReadModel> {
    const row = await this.prisma.gameSessionMembership.update({
      where: { id },
      data: { characterId },
      select: MEMBERSHIP_SELECT,
    });
    const users = await this.fetchDisplayNames([row.userId]);
    return toReadModel(row, users.get(row.userId) ?? null);
  }

  // ---- IGameSessionInviteRepo ----

  async assertOwner(gameSessionId: string, userId: string): Promise<void> {
    const session = await this.prisma.gameSession.findUnique({
      where: { id: gameSessionId },
      select: { ownerId: true },
    });
    if (!session) throw new GameSessionNotFoundError(gameSessionId);
    if (session.ownerId !== userId) throw new GameSessionNotOwnerError(gameSessionId);
  }

  async getMetadata(gameSessionId: string): Promise<InviteMetadataReadModel> {
    const row = await this.prisma.gameSession.findUnique({
      where: { id: gameSessionId },
      select: { inviteTokenHash: true, inviteRotatedAt: true },
    });
    if (!row) throw new GameSessionNotFoundError(gameSessionId);
    return {
      active: row.inviteTokenHash !== null,
      rotatedAt: row.inviteRotatedAt?.toISOString() ?? null,
    };
  }

  async rotate(
    gameSessionId: string,
    tokenHash: string,
    createdByUserId: string,
  ): Promise<{ rotatedAt: string }> {
    const now = new Date();
    await this.prisma.gameSession.update({
      where: { id: gameSessionId },
      data: {
        inviteTokenHash: tokenHash,
        inviteRotatedAt: now,
        inviteCreatedById: createdByUserId,
      },
    });
    return { rotatedAt: now.toISOString() };
  }

  async revoke(gameSessionId: string): Promise<void> {
    await this.prisma.gameSession.update({
      where: { id: gameSessionId },
      data: {
        inviteTokenHash: null,
        inviteRotatedAt: null,
        inviteCreatedById: null,
      },
    });
  }

  // ---- helpers ----

  private async fetchDisplayNames(userIds: string[]): Promise<Map<string, string | null>> {
    if (userIds.length === 0) return new Map();
    const users = await this.prisma.user.findMany({
      where: { id: { in: Array.from(new Set(userIds)) } },
      select: { id: true, name: true },
    });
    return new Map(users.map((u) => [u.id, u.name ?? null]));
  }
}
```

- [ ] **Step 2: Typecheck**

Run: `pnpm --filter @app/backend typecheck`
Expected: clean (or shows missing `User.name` field — if so, replace `name: true` with whatever the user-name field is called in `schema.prisma`; check via `grep -n "model User" -A 30 apps/backend/prisma/schema.prisma`).

- [ ] **Step 3: Commit**

```bash
git add apps/backend/src/modules/memberships/infra
git commit -m "feat(memberships): Prisma-backed repo

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

# Phase P6 — Commands (5 tasks, all TDD)

Each command follows the exact pattern used in `game-sessions/commands/`. Per-task structure: write failing handler.spec.ts → run (fail) → write command.ts + handler.ts → run (pass) → commit.

## Task 11: RotateInviteCommand (TDD)

**Files:**

- Create: `apps/backend/src/modules/memberships/commands/rotate-invite.command.ts`
- Create: `apps/backend/src/modules/memberships/commands/rotate-invite.handler.ts`
- Create: `apps/backend/src/modules/memberships/commands/rotate-invite.handler.spec.ts`

- [ ] **Step 1: Write the failing spec**

```ts
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { GameSessionNotOwnerError } from '../../game-sessions/domain/game-session.errors';

import { RotateInviteCommand } from './rotate-invite.command';
import { RotateInviteHandler } from './rotate-invite.handler';

import type { AppConfig } from '../../../common/config/app-config';
import type { IGameSessionInviteRepo } from '../domain/membership.ports';

function makeRepo(): IGameSessionInviteRepo {
  return {
    assertOwner: vi.fn(),
    getMetadata: vi.fn(),
    rotate: vi.fn(),
    revoke: vi.fn(),
  };
}

function makeConfig(): Pick<AppConfig, 'webHost'> {
  return { webHost: 'https://app.example.com' };
}

describe('RotateInviteHandler', () => {
  let repo: IGameSessionInviteRepo;
  let handler: RotateInviteHandler;
  let generator: () => string;
  let hasher: (plaintext: string) => string;

  beforeEach(() => {
    repo = makeRepo();
    generator = vi.fn().mockReturnValue('Sl9X3kQpZr8mVtNuY7Hb2C');
    hasher = vi.fn().mockReturnValue('0'.repeat(64));
    handler = new RotateInviteHandler(repo, makeConfig() as AppConfig, generator, hasher);
  });

  it('asserts owner before rotating', async () => {
    vi.mocked(repo.rotate).mockResolvedValue({ rotatedAt: '2026-05-15T10:00:00.000Z' });

    await handler.execute(new RotateInviteCommand('gs-1', 'user-1'));

    expect(repo.assertOwner).toHaveBeenCalledWith('gs-1', 'user-1');
    expect(repo.assertOwner).toHaveBeenCalledBefore(vi.mocked(repo.rotate));
  });

  it('propagates GameSessionNotOwnerError when caller is not owner', async () => {
    vi.mocked(repo.assertOwner).mockRejectedValue(new GameSessionNotOwnerError('gs-1'));

    await expect(handler.execute(new RotateInviteCommand('gs-1', 'user-X'))).rejects.toBeInstanceOf(
      GameSessionNotOwnerError,
    );
    expect(repo.rotate).not.toHaveBeenCalled();
  });

  it('returns the plaintext token + absolute URL exactly once', async () => {
    vi.mocked(repo.rotate).mockResolvedValue({ rotatedAt: '2026-05-15T10:00:00.000Z' });

    const result = await handler.execute(new RotateInviteCommand('gs-1', 'user-1'));

    expect(result).toEqual({
      token: 'Sl9X3kQpZr8mVtNuY7Hb2C',
      url: 'https://app.example.com/app/sessions/join/Sl9X3kQpZr8mVtNuY7Hb2C',
      rotatedAt: '2026-05-15T10:00:00.000Z',
    });
  });

  it('passes the hashed token (not plaintext) to the repo', async () => {
    vi.mocked(repo.rotate).mockResolvedValue({ rotatedAt: '2026-05-15T10:00:00.000Z' });

    await handler.execute(new RotateInviteCommand('gs-1', 'user-1'));

    expect(repo.rotate).toHaveBeenCalledWith('gs-1', '0'.repeat(64), 'user-1');
    expect(hasher).toHaveBeenCalledWith('Sl9X3kQpZr8mVtNuY7Hb2C');
  });
});
```

- [ ] **Step 2: Run — expect FAIL**

Run: `pnpm --filter @app/backend test -- rotate-invite.handler.spec.ts`
Expected: FAIL — modules not yet defined.

- [ ] **Step 3: Implement the command**

`rotate-invite.command.ts`:

```ts
export class RotateInviteCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly userId: string,
  ) {}
}
```

- [ ] **Step 4: Implement the handler**

`rotate-invite.handler.ts`:

```ts
import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { AppConfig } from '../../../common/config/app-config';
import {
  generateInviteToken as defaultGenerate,
  hashInviteToken as defaultHash,
} from '../domain/invite-token';
import { GAME_SESSION_INVITE_REPO, type IGameSessionInviteRepo } from '../domain/membership.ports';

import { RotateInviteCommand } from './rotate-invite.command';

export interface RotateInviteResult {
  token: string;
  url: string;
  rotatedAt: string;
}

@CommandHandler(RotateInviteCommand)
export class RotateInviteHandler implements ICommandHandler<
  RotateInviteCommand,
  RotateInviteResult
> {
  constructor(
    @Inject(GAME_SESSION_INVITE_REPO) private readonly repo: IGameSessionInviteRepo,
    private readonly config: AppConfig,
    private readonly generate: () => string = defaultGenerate,
    private readonly hash: (s: string) => string = defaultHash,
  ) {}

  async execute(cmd: RotateInviteCommand): Promise<RotateInviteResult> {
    await this.repo.assertOwner(cmd.gameSessionId, cmd.userId);
    const token = this.generate();
    const hash = this.hash(token);
    const { rotatedAt } = await this.repo.rotate(cmd.gameSessionId, hash, cmd.userId);
    return {
      token,
      url: `${this.config.webHost}/app/sessions/join/${token}`,
      rotatedAt,
    };
  }
}
```

- [ ] **Step 5: Run — expect PASS**

Run: `pnpm --filter @app/backend test -- rotate-invite.handler.spec.ts`
Expected: 4 passing.

If `webHost` is not exposed on AppConfig: open `apps/backend/src/common/config/app-config.ts`, add a `webHost: string` field (loaded from `process.env.WEB_HOST ?? 'http://localhost:3001'`), and update its spec accordingly. Re-run the test.

- [ ] **Step 6: Commit**

```bash
git add apps/backend/src/modules/memberships/commands/rotate-invite.* apps/backend/src/common/config/app-config*
git commit -m "feat(memberships): RotateInviteCommand + handler

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

## Task 12: RevokeInviteCommand (TDD)

**Files:**

- Create: `apps/backend/src/modules/memberships/commands/revoke-invite.command.ts`
- Create: `apps/backend/src/modules/memberships/commands/revoke-invite.handler.ts`
- Create: `apps/backend/src/modules/memberships/commands/revoke-invite.handler.spec.ts`

- [ ] **Step 1: Spec (failing)**

```ts
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { GameSessionNotOwnerError } from '../../game-sessions/domain/game-session.errors';

import { RevokeInviteCommand } from './revoke-invite.command';
import { RevokeInviteHandler } from './revoke-invite.handler';

import type { IGameSessionInviteRepo } from '../domain/membership.ports';

function makeRepo(): IGameSessionInviteRepo {
  return {
    assertOwner: vi.fn(),
    getMetadata: vi.fn(),
    rotate: vi.fn(),
    revoke: vi.fn(),
  };
}

describe('RevokeInviteHandler', () => {
  let repo: IGameSessionInviteRepo;
  let handler: RevokeInviteHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new RevokeInviteHandler(repo);
  });

  it('asserts owner before revoking', async () => {
    await handler.execute(new RevokeInviteCommand('gs-1', 'user-1'));
    expect(repo.assertOwner).toHaveBeenCalledWith('gs-1', 'user-1');
    expect(repo.revoke).toHaveBeenCalledWith('gs-1');
  });

  it('is idempotent (does not throw on a session with no active invite)', async () => {
    vi.mocked(repo.revoke).mockResolvedValue(undefined);
    await expect(
      handler.execute(new RevokeInviteCommand('gs-1', 'user-1')),
    ).resolves.toBeUndefined();
  });

  it('refuses non-owner', async () => {
    vi.mocked(repo.assertOwner).mockRejectedValue(new GameSessionNotOwnerError('gs-1'));
    await expect(handler.execute(new RevokeInviteCommand('gs-1', 'user-X'))).rejects.toBeInstanceOf(
      GameSessionNotOwnerError,
    );
    expect(repo.revoke).not.toHaveBeenCalled();
  });
});
```

- [ ] **Step 2: Run — expect FAIL**

Run: `pnpm --filter @app/backend test -- revoke-invite.handler.spec.ts`
Expected: FAIL — modules not yet defined.

- [ ] **Step 3: Implement command + handler**

`revoke-invite.command.ts`:

```ts
export class RevokeInviteCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly userId: string,
  ) {}
}
```

`revoke-invite.handler.ts`:

```ts
import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { GAME_SESSION_INVITE_REPO, type IGameSessionInviteRepo } from '../domain/membership.ports';

import { RevokeInviteCommand } from './revoke-invite.command';

@CommandHandler(RevokeInviteCommand)
export class RevokeInviteHandler implements ICommandHandler<RevokeInviteCommand, void> {
  constructor(@Inject(GAME_SESSION_INVITE_REPO) private readonly repo: IGameSessionInviteRepo) {}

  async execute(cmd: RevokeInviteCommand): Promise<void> {
    await this.repo.assertOwner(cmd.gameSessionId, cmd.userId);
    await this.repo.revoke(cmd.gameSessionId);
  }
}
```

- [ ] **Step 4: Run — expect PASS**

Run: `pnpm --filter @app/backend test -- revoke-invite.handler.spec.ts`
Expected: 3 passing.

- [ ] **Step 5: Commit**

```bash
git add apps/backend/src/modules/memberships/commands/revoke-invite.*
git commit -m "feat(memberships): RevokeInviteCommand + handler

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

## Task 13: KickMemberCommand (TDD)

**Files:**

- Create: `apps/backend/src/modules/memberships/commands/kick-member.command.ts`
- Create: `apps/backend/src/modules/memberships/commands/kick-member.handler.ts`
- Create: `apps/backend/src/modules/memberships/commands/kick-member.handler.spec.ts`

- [ ] **Step 1: Spec (failing)**

```ts
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { GameSessionNotOwnerError } from '../../game-sessions/domain/game-session.errors';
import { CannotKickGmError, MembershipNotFoundError } from '../domain/membership.errors';

import { KickMemberCommand } from './kick-member.command';
import { KickMemberHandler } from './kick-member.handler';

import type { EventBus } from '@nestjs/cqrs';
import type {
  IGameSessionInviteRepo,
  IMembershipRepo,
  MembershipReadModel,
} from '../domain/membership.ports';

function makeMembershipRepo(): IMembershipRepo {
  return {
    listActive: vi.fn(),
    findById: vi.fn(),
    findActiveByUser: vi.fn(),
    softDelete: vi.fn(),
    setCharacter: vi.fn(),
  };
}

function makeInviteRepo(): IGameSessionInviteRepo {
  return { assertOwner: vi.fn(), getMetadata: vi.fn(), rotate: vi.fn(), revoke: vi.fn() };
}

function makeBus(): EventBus {
  return { publish: vi.fn(), publishAll: vi.fn() } as unknown as EventBus;
}

function makeMember(overrides: Partial<MembershipReadModel> = {}): MembershipReadModel {
  return {
    id: 'm-1',
    gameSessionId: 'gs-1',
    userId: 'user-player',
    role: 'player',
    displayName: 'Yara',
    characterId: null,
    characterName: null,
    joinedAt: '2026-05-15T10:00:00.000Z',
    leftAt: null,
    ...overrides,
  };
}

describe('KickMemberHandler', () => {
  let mRepo: IMembershipRepo;
  let iRepo: IGameSessionInviteRepo;
  let bus: EventBus;
  let handler: KickMemberHandler;

  beforeEach(() => {
    mRepo = makeMembershipRepo();
    iRepo = makeInviteRepo();
    bus = makeBus();
    handler = new KickMemberHandler(mRepo, iRepo, bus);
  });

  it('asserts owner before kicking', async () => {
    vi.mocked(mRepo.findById).mockResolvedValue(makeMember());
    await handler.execute(new KickMemberCommand('gs-1', 'user-gm', 'm-1'));
    expect(iRepo.assertOwner).toHaveBeenCalledWith('gs-1', 'user-gm');
  });

  it('throws MembershipNotFoundError when the membership does not exist', async () => {
    vi.mocked(mRepo.findById).mockResolvedValue(null);
    await expect(
      handler.execute(new KickMemberCommand('gs-1', 'user-gm', 'm-X')),
    ).rejects.toBeInstanceOf(MembershipNotFoundError);
  });

  it('refuses to kick a GM-role membership', async () => {
    vi.mocked(mRepo.findById).mockResolvedValue(makeMember({ role: 'gm' }));
    await expect(
      handler.execute(new KickMemberCommand('gs-1', 'user-gm', 'm-1')),
    ).rejects.toBeInstanceOf(CannotKickGmError);
    expect(mRepo.softDelete).not.toHaveBeenCalled();
  });

  it('refuses cross-session kick (membership belongs to another session)', async () => {
    vi.mocked(mRepo.findById).mockResolvedValue(makeMember({ gameSessionId: 'gs-OTHER' }));
    await expect(
      handler.execute(new KickMemberCommand('gs-1', 'user-gm', 'm-1')),
    ).rejects.toBeInstanceOf(MembershipNotFoundError);
  });

  it('refuses non-owner caller', async () => {
    vi.mocked(iRepo.assertOwner).mockRejectedValue(new GameSessionNotOwnerError('gs-1'));
    await expect(
      handler.execute(new KickMemberCommand('gs-1', 'user-X', 'm-1')),
    ).rejects.toBeInstanceOf(GameSessionNotOwnerError);
  });

  it('soft-deletes and publishes MemberKickedEvent', async () => {
    const member = makeMember();
    vi.mocked(mRepo.findById).mockResolvedValue(member);
    await handler.execute(new KickMemberCommand('gs-1', 'user-gm', 'm-1'));
    expect(mRepo.softDelete).toHaveBeenCalledWith('m-1');
    expect(bus.publish).toHaveBeenCalledWith(
      expect.objectContaining({
        membershipId: 'm-1',
        gameSessionId: 'gs-1',
        userId: 'user-player',
      }),
    );
  });
});
```

- [ ] **Step 2: Run — expect FAIL**

Run: `pnpm --filter @app/backend test -- kick-member.handler.spec.ts`
Expected: FAIL — modules not yet defined.

- [ ] **Step 3: Implement command + handler**

`kick-member.command.ts`:

```ts
export class KickMemberCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly callerUserId: string,
    public readonly membershipId: string,
  ) {}
}
```

`kick-member.handler.ts`:

```ts
import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import { MemberKickedEvent } from '../events/member-kicked.event';
import { CannotKickGmError, MembershipNotFoundError } from '../domain/membership.errors';
import {
  GAME_SESSION_INVITE_REPO,
  MEMBERSHIP_REPO,
  type IGameSessionInviteRepo,
  type IMembershipRepo,
} from '../domain/membership.ports';

import { KickMemberCommand } from './kick-member.command';

@CommandHandler(KickMemberCommand)
export class KickMemberHandler implements ICommandHandler<KickMemberCommand, void> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly mRepo: IMembershipRepo,
    @Inject(GAME_SESSION_INVITE_REPO) private readonly iRepo: IGameSessionInviteRepo,
    private readonly bus: EventBus,
  ) {}

  async execute(cmd: KickMemberCommand): Promise<void> {
    await this.iRepo.assertOwner(cmd.gameSessionId, cmd.callerUserId);
    const member = await this.mRepo.findById(cmd.membershipId);
    if (!member || member.gameSessionId !== cmd.gameSessionId) {
      throw new MembershipNotFoundError(cmd.membershipId);
    }
    if (member.role === 'gm') throw new CannotKickGmError();
    await this.mRepo.softDelete(cmd.membershipId);
    this.bus.publish(new MemberKickedEvent(cmd.membershipId, cmd.gameSessionId, member.userId));
  }
}
```

(MemberKickedEvent is defined in Task 16.)

- [ ] **Step 4: Stub the event class to keep the test compilable**

For now, add a stub file `apps/backend/src/modules/memberships/events/member-kicked.event.ts`:

```ts
export class MemberKickedEvent {
  constructor(
    public readonly membershipId: string,
    public readonly gameSessionId: string,
    public readonly userId: string,
  ) {}
}
```

- [ ] **Step 5: Run — expect PASS**

Run: `pnpm --filter @app/backend test -- kick-member.handler.spec.ts`
Expected: 6 passing.

- [ ] **Step 6: Commit**

```bash
git add apps/backend/src/modules/memberships/commands/kick-member.* apps/backend/src/modules/memberships/events/member-kicked.event.ts
git commit -m "feat(memberships): KickMemberCommand + handler

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

## Task 14: LeaveSessionCommand (TDD)

**Files:**

- Create: `apps/backend/src/modules/memberships/commands/leave-session.command.ts`
- Create: `apps/backend/src/modules/memberships/commands/leave-session.handler.ts`
- Create: `apps/backend/src/modules/memberships/commands/leave-session.handler.spec.ts`
- Create: `apps/backend/src/modules/memberships/events/member-left.event.ts`

- [ ] **Step 1: Stub event**

`member-left.event.ts`:

```ts
export class MemberLeftEvent {
  constructor(
    public readonly membershipId: string,
    public readonly gameSessionId: string,
    public readonly userId: string,
  ) {}
}
```

- [ ] **Step 2: Write the failing spec**

```ts
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  CannotKickGmError,
  MembershipNotAuthorizedError,
  MembershipNotFoundError,
} from '../domain/membership.errors';

import { LeaveSessionCommand } from './leave-session.command';
import { LeaveSessionHandler } from './leave-session.handler';

import type { EventBus } from '@nestjs/cqrs';
import type { IMembershipRepo, MembershipReadModel } from '../domain/membership.ports';

function makeRepo(): IMembershipRepo {
  return {
    listActive: vi.fn(),
    findById: vi.fn(),
    findActiveByUser: vi.fn(),
    softDelete: vi.fn(),
    setCharacter: vi.fn(),
  };
}

function makeBus(): EventBus {
  return { publish: vi.fn(), publishAll: vi.fn() } as unknown as EventBus;
}

function makeMember(overrides: Partial<MembershipReadModel> = {}): MembershipReadModel {
  return {
    id: 'm-1',
    gameSessionId: 'gs-1',
    userId: 'user-1',
    role: 'player',
    displayName: 'Yara',
    characterId: null,
    characterName: null,
    joinedAt: '2026-05-15T10:00:00.000Z',
    leftAt: null,
    ...overrides,
  };
}

describe('LeaveSessionHandler', () => {
  let repo: IMembershipRepo;
  let bus: EventBus;
  let handler: LeaveSessionHandler;

  beforeEach(() => {
    repo = makeRepo();
    bus = makeBus();
    handler = new LeaveSessionHandler(repo, bus);
  });

  it('lets a player leave their own membership', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember());
    await handler.execute(new LeaveSessionCommand('gs-1', 'user-1', 'm-1'));
    expect(repo.softDelete).toHaveBeenCalledWith('m-1');
    expect(bus.publish).toHaveBeenCalledWith(
      expect.objectContaining({ membershipId: 'm-1', userId: 'user-1' }),
    );
  });

  it('refuses to leave a non-existent membership', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);
    await expect(
      handler.execute(new LeaveSessionCommand('gs-1', 'user-1', 'm-X')),
    ).rejects.toBeInstanceOf(MembershipNotFoundError);
  });

  it("refuses to leave someone else's membership", async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember({ userId: 'OTHER' }));
    await expect(
      handler.execute(new LeaveSessionCommand('gs-1', 'user-1', 'm-1')),
    ).rejects.toBeInstanceOf(MembershipNotAuthorizedError);
    expect(repo.softDelete).not.toHaveBeenCalled();
  });

  it('refuses to leave a cross-session membership', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember({ gameSessionId: 'gs-OTHER' }));
    await expect(
      handler.execute(new LeaveSessionCommand('gs-1', 'user-1', 'm-1')),
    ).rejects.toBeInstanceOf(MembershipNotFoundError);
  });

  it('refuses to leave a GM membership (self-kick disallowed)', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember({ role: 'gm' }));
    await expect(
      handler.execute(new LeaveSessionCommand('gs-1', 'user-1', 'm-1')),
    ).rejects.toBeInstanceOf(CannotKickGmError);
  });
});
```

- [ ] **Step 3: Run — expect FAIL**

Run: `pnpm --filter @app/backend test -- leave-session.handler.spec.ts`

- [ ] **Step 4: Implement**

`leave-session.command.ts`:

```ts
export class LeaveSessionCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly userId: string,
    public readonly membershipId: string,
  ) {}
}
```

`leave-session.handler.ts`:

```ts
import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import {
  CannotKickGmError,
  MembershipNotAuthorizedError,
  MembershipNotFoundError,
} from '../domain/membership.errors';
import { MEMBERSHIP_REPO, type IMembershipRepo } from '../domain/membership.ports';
import { MemberLeftEvent } from '../events/member-left.event';

import { LeaveSessionCommand } from './leave-session.command';

@CommandHandler(LeaveSessionCommand)
export class LeaveSessionHandler implements ICommandHandler<LeaveSessionCommand, void> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly repo: IMembershipRepo,
    private readonly bus: EventBus,
  ) {}

  async execute(cmd: LeaveSessionCommand): Promise<void> {
    const member = await this.repo.findById(cmd.membershipId);
    if (!member || member.gameSessionId !== cmd.gameSessionId) {
      throw new MembershipNotFoundError(cmd.membershipId);
    }
    if (member.userId !== cmd.userId) throw new MembershipNotAuthorizedError();
    if (member.role === 'gm') throw new CannotKickGmError();
    await this.repo.softDelete(cmd.membershipId);
    this.bus.publish(new MemberLeftEvent(cmd.membershipId, cmd.gameSessionId, cmd.userId));
  }
}
```

- [ ] **Step 5: Run — expect PASS**

Run: `pnpm --filter @app/backend test -- leave-session.handler.spec.ts`
Expected: 5 passing.

- [ ] **Step 6: Commit**

```bash
git add apps/backend/src/modules/memberships/commands/leave-session.* apps/backend/src/modules/memberships/events/member-left.event.ts
git commit -m "feat(memberships): LeaveSessionCommand + handler

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

## Task 15: LinkCharacterCommand (TDD)

**Files:**

- Create: `apps/backend/src/modules/memberships/commands/link-character.command.ts`
- Create: `apps/backend/src/modules/memberships/commands/link-character.handler.ts`
- Create: `apps/backend/src/modules/memberships/commands/link-character.handler.spec.ts`
- Create: `apps/backend/src/modules/memberships/events/character-linked.event.ts`

- [ ] **Step 1: Stub event**

`character-linked.event.ts`:

```ts
export class CharacterLinkedEvent {
  constructor(
    public readonly membershipId: string,
    public readonly gameSessionId: string,
    public readonly userId: string,
    public readonly characterId: string | null,
  ) {}
}
```

- [ ] **Step 2: Write the failing spec**

```ts
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  CharacterNotOwnedError,
  MembershipNotAuthorizedError,
  MembershipNotFoundError,
} from '../domain/membership.errors';

import { LinkCharacterCommand } from './link-character.command';
import { LinkCharacterHandler, type ICharacterOwnership } from './link-character.handler';

import type { EventBus } from '@nestjs/cqrs';
import type { IMembershipRepo, MembershipReadModel } from '../domain/membership.ports';

function makeRepo(): IMembershipRepo {
  return {
    listActive: vi.fn(),
    findById: vi.fn(),
    findActiveByUser: vi.fn(),
    softDelete: vi.fn(),
    setCharacter: vi.fn(),
  };
}

function makeOwnership(): ICharacterOwnership {
  return { isOwnedBy: vi.fn() };
}

function makeBus(): EventBus {
  return { publish: vi.fn(), publishAll: vi.fn() } as unknown as EventBus;
}

function makeMember(overrides: Partial<MembershipReadModel> = {}): MembershipReadModel {
  return {
    id: 'm-1',
    gameSessionId: 'gs-1',
    userId: 'user-1',
    role: 'player',
    displayName: 'Yara',
    characterId: null,
    characterName: null,
    joinedAt: '2026-05-15T10:00:00.000Z',
    leftAt: null,
    ...overrides,
  };
}

describe('LinkCharacterHandler', () => {
  let repo: IMembershipRepo;
  let ownership: ICharacterOwnership;
  let bus: EventBus;
  let handler: LinkCharacterHandler;

  beforeEach(() => {
    repo = makeRepo();
    ownership = makeOwnership();
    bus = makeBus();
    handler = new LinkCharacterHandler(repo, ownership, bus);
  });

  it('links a character the caller owns', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember());
    vi.mocked(ownership.isOwnedBy).mockResolvedValue(true);
    vi.mocked(repo.setCharacter).mockResolvedValue(
      makeMember({ characterId: 'c-1', characterName: 'Yara Zenith' }),
    );

    const result = await handler.execute(new LinkCharacterCommand('gs-1', 'user-1', 'm-1', 'c-1'));

    expect(result.characterId).toBe('c-1');
    expect(repo.setCharacter).toHaveBeenCalledWith('m-1', 'c-1');
    expect(bus.publish).toHaveBeenCalledWith(
      expect.objectContaining({ membershipId: 'm-1', characterId: 'c-1' }),
    );
  });

  it('unlinks when characterId is null', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember({ characterId: 'c-old' }));
    vi.mocked(repo.setCharacter).mockResolvedValue(makeMember({ characterId: null }));

    await handler.execute(new LinkCharacterCommand('gs-1', 'user-1', 'm-1', null));

    expect(ownership.isOwnedBy).not.toHaveBeenCalled();
    expect(repo.setCharacter).toHaveBeenCalledWith('m-1', null);
  });

  it('refuses to link a character the caller does not own', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember());
    vi.mocked(ownership.isOwnedBy).mockResolvedValue(false);
    await expect(
      handler.execute(new LinkCharacterCommand('gs-1', 'user-1', 'm-1', 'c-OTHER')),
    ).rejects.toBeInstanceOf(CharacterNotOwnedError);
  });

  it('refuses cross-user link', async () => {
    vi.mocked(repo.findById).mockResolvedValue(makeMember({ userId: 'OTHER' }));
    await expect(
      handler.execute(new LinkCharacterCommand('gs-1', 'user-1', 'm-1', 'c-1')),
    ).rejects.toBeInstanceOf(MembershipNotAuthorizedError);
  });

  it('refuses non-existent membership', async () => {
    vi.mocked(repo.findById).mockResolvedValue(null);
    await expect(
      handler.execute(new LinkCharacterCommand('gs-1', 'user-1', 'm-X', 'c-1')),
    ).rejects.toBeInstanceOf(MembershipNotFoundError);
  });
});
```

- [ ] **Step 3: Run — expect FAIL**

- [ ] **Step 4: Implement**

`link-character.command.ts`:

```ts
export class LinkCharacterCommand {
  constructor(
    public readonly gameSessionId: string,
    public readonly callerUserId: string,
    public readonly membershipId: string,
    public readonly characterId: string | null,
  ) {}
}
```

`link-character.handler.ts`:

```ts
import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import {
  CharacterNotOwnedError,
  MembershipNotAuthorizedError,
  MembershipNotFoundError,
} from '../domain/membership.errors';
import {
  MEMBERSHIP_REPO,
  type IMembershipRepo,
  type MembershipReadModel,
} from '../domain/membership.ports';
import { CharacterLinkedEvent } from '../events/character-linked.event';

import { LinkCharacterCommand } from './link-character.command';

export const CHARACTER_OWNERSHIP = Symbol('CHARACTER_OWNERSHIP');

export interface ICharacterOwnership {
  isOwnedBy(characterId: string, userId: string): Promise<boolean>;
}

@CommandHandler(LinkCharacterCommand)
export class LinkCharacterHandler implements ICommandHandler<
  LinkCharacterCommand,
  MembershipReadModel
> {
  constructor(
    @Inject(MEMBERSHIP_REPO) private readonly repo: IMembershipRepo,
    @Inject(CHARACTER_OWNERSHIP) private readonly ownership: ICharacterOwnership,
    private readonly bus: EventBus,
  ) {}

  async execute(cmd: LinkCharacterCommand): Promise<MembershipReadModel> {
    const member = await this.repo.findById(cmd.membershipId);
    if (!member || member.gameSessionId !== cmd.gameSessionId) {
      throw new MembershipNotFoundError(cmd.membershipId);
    }
    if (member.userId !== cmd.callerUserId) throw new MembershipNotAuthorizedError();
    if (cmd.characterId !== null) {
      const ok = await this.ownership.isOwnedBy(cmd.characterId, cmd.callerUserId);
      if (!ok) throw new CharacterNotOwnedError(cmd.characterId);
    }
    const updated = await this.repo.setCharacter(cmd.membershipId, cmd.characterId);
    this.bus.publish(
      new CharacterLinkedEvent(updated.id, updated.gameSessionId, updated.userId, cmd.characterId),
    );
    return updated;
  }
}
```

- [ ] **Step 5: Run — expect PASS**

Run: `pnpm --filter @app/backend test -- link-character.handler.spec.ts`
Expected: 5 passing.

- [ ] **Step 6: Commit**

```bash
git add apps/backend/src/modules/memberships/commands/link-character.* apps/backend/src/modules/memberships/events/character-linked.event.ts
git commit -m "feat(memberships): LinkCharacterCommand + handler

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

# Phase P7 — Queries (2 tasks)

## Task 16: ListMembershipsQuery (TDD)

**Files:**

- Create: `apps/backend/src/modules/memberships/queries/list-memberships.query.ts`
- Create: `apps/backend/src/modules/memberships/queries/list-memberships.handler.ts`
- Create: `apps/backend/src/modules/memberships/queries/list-memberships.handler.spec.ts`

- [ ] **Step 1: Spec**

```ts
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { MembershipNotAuthorizedError } from '../domain/membership.errors';

import { ListMembershipsQuery } from './list-memberships.query';
import { ListMembershipsHandler } from './list-memberships.handler';

import type { IMembershipRepo, MembershipReadModel } from '../domain/membership.ports';

function makeRepo(): IMembershipRepo {
  return {
    listActive: vi.fn(),
    findById: vi.fn(),
    findActiveByUser: vi.fn(),
    softDelete: vi.fn(),
    setCharacter: vi.fn(),
  };
}

function makeMember(overrides: Partial<MembershipReadModel> = {}): MembershipReadModel {
  return {
    id: 'm-1',
    gameSessionId: 'gs-1',
    userId: 'user-1',
    role: 'player',
    displayName: 'Yara',
    characterId: null,
    characterName: null,
    joinedAt: '2026-05-15T10:00:00.000Z',
    leftAt: null,
    ...overrides,
  };
}

describe('ListMembershipsHandler', () => {
  let repo: IMembershipRepo;
  let handler: ListMembershipsHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new ListMembershipsHandler(repo);
  });

  it('returns the active member list to the GM', async () => {
    vi.mocked(repo.listActive).mockResolvedValue([
      makeMember({ role: 'gm', userId: 'user-gm' }),
      makeMember(),
    ]);
    vi.mocked(repo.findActiveByUser).mockResolvedValue(
      makeMember({ role: 'gm', userId: 'user-gm' }),
    );
    const result = await handler.execute(new ListMembershipsQuery('gs-1', 'user-gm'));
    expect(result).toHaveLength(2);
  });

  it('returns the active member list to any active member', async () => {
    vi.mocked(repo.listActive).mockResolvedValue([makeMember()]);
    vi.mocked(repo.findActiveByUser).mockResolvedValue(makeMember());
    const result = await handler.execute(new ListMembershipsQuery('gs-1', 'user-1'));
    expect(result).toHaveLength(1);
  });

  it('refuses callers who are neither GM nor active member', async () => {
    vi.mocked(repo.findActiveByUser).mockResolvedValue(null);
    await expect(
      handler.execute(new ListMembershipsQuery('gs-1', 'user-X')),
    ).rejects.toBeInstanceOf(MembershipNotAuthorizedError);
    expect(repo.listActive).not.toHaveBeenCalled();
  });
});
```

- [ ] **Step 2: Run — expect FAIL**

- [ ] **Step 3: Implement**

`list-memberships.query.ts`:

```ts
export class ListMembershipsQuery {
  constructor(
    public readonly gameSessionId: string,
    public readonly callerUserId: string,
  ) {}
}
```

`list-memberships.handler.ts`:

```ts
import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import { MembershipNotAuthorizedError } from '../domain/membership.errors';
import {
  MEMBERSHIP_REPO,
  type IMembershipRepo,
  type MembershipReadModel,
} from '../domain/membership.ports';

import { ListMembershipsQuery } from './list-memberships.query';

@QueryHandler(ListMembershipsQuery)
export class ListMembershipsHandler implements IQueryHandler<
  ListMembershipsQuery,
  MembershipReadModel[]
> {
  constructor(@Inject(MEMBERSHIP_REPO) private readonly repo: IMembershipRepo) {}

  async execute(q: ListMembershipsQuery): Promise<MembershipReadModel[]> {
    const callerMembership = await this.repo.findActiveByUser(q.gameSessionId, q.callerUserId);
    if (!callerMembership) throw new MembershipNotAuthorizedError();
    return this.repo.listActive(q.gameSessionId);
  }
}
```

- [ ] **Step 4: Run — expect PASS**

Run: `pnpm --filter @app/backend test -- list-memberships.handler.spec.ts`
Expected: 3 passing.

- [ ] **Step 5: Commit**

```bash
git add apps/backend/src/modules/memberships/queries/list-memberships.*
git commit -m "feat(memberships): ListMembershipsQuery + handler

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

## Task 17: GetInviteMetadataQuery (TDD)

**Files:**

- Create: `apps/backend/src/modules/memberships/queries/get-invite-metadata.query.ts`
- Create: `apps/backend/src/modules/memberships/queries/get-invite-metadata.handler.ts`
- Create: `apps/backend/src/modules/memberships/queries/get-invite-metadata.handler.spec.ts`

- [ ] **Step 1: Spec**

```ts
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { GameSessionNotOwnerError } from '../../game-sessions/domain/game-session.errors';

import { GetInviteMetadataQuery } from './get-invite-metadata.query';
import { GetInviteMetadataHandler } from './get-invite-metadata.handler';

import type { IGameSessionInviteRepo } from '../domain/membership.ports';

function makeRepo(): IGameSessionInviteRepo {
  return { assertOwner: vi.fn(), getMetadata: vi.fn(), rotate: vi.fn(), revoke: vi.fn() };
}

describe('GetInviteMetadataHandler', () => {
  let repo: IGameSessionInviteRepo;
  let handler: GetInviteMetadataHandler;

  beforeEach(() => {
    repo = makeRepo();
    handler = new GetInviteMetadataHandler(repo);
  });

  it('returns inactive when no invite', async () => {
    vi.mocked(repo.getMetadata).mockResolvedValue({ active: false, rotatedAt: null });
    const result = await handler.execute(new GetInviteMetadataQuery('gs-1', 'user-1'));
    expect(result).toEqual({ active: false, rotatedAt: null });
  });

  it('returns active with rotatedAt when there is an invite', async () => {
    vi.mocked(repo.getMetadata).mockResolvedValue({
      active: true,
      rotatedAt: '2026-05-15T10:00:00.000Z',
    });
    const result = await handler.execute(new GetInviteMetadataQuery('gs-1', 'user-1'));
    expect(result.active).toBe(true);
    expect(result.rotatedAt).toBe('2026-05-15T10:00:00.000Z');
  });

  it('refuses non-owner', async () => {
    vi.mocked(repo.assertOwner).mockRejectedValue(new GameSessionNotOwnerError('gs-1'));
    await expect(
      handler.execute(new GetInviteMetadataQuery('gs-1', 'user-X')),
    ).rejects.toBeInstanceOf(GameSessionNotOwnerError);
  });
});
```

- [ ] **Step 2: Run — expect FAIL**

- [ ] **Step 3: Implement**

`get-invite-metadata.query.ts`:

```ts
export class GetInviteMetadataQuery {
  constructor(
    public readonly gameSessionId: string,
    public readonly userId: string,
  ) {}
}
```

`get-invite-metadata.handler.ts`:

```ts
import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryHandler } from '@nestjs/cqrs';

import {
  GAME_SESSION_INVITE_REPO,
  type IGameSessionInviteRepo,
  type InviteMetadataReadModel,
} from '../domain/membership.ports';

import { GetInviteMetadataQuery } from './get-invite-metadata.query';

@QueryHandler(GetInviteMetadataQuery)
export class GetInviteMetadataHandler implements IQueryHandler<
  GetInviteMetadataQuery,
  InviteMetadataReadModel
> {
  constructor(@Inject(GAME_SESSION_INVITE_REPO) private readonly repo: IGameSessionInviteRepo) {}

  async execute(q: GetInviteMetadataQuery): Promise<InviteMetadataReadModel> {
    await this.repo.assertOwner(q.gameSessionId, q.userId);
    return this.repo.getMetadata(q.gameSessionId);
  }
}
```

- [ ] **Step 4: Run — expect PASS**

Run: `pnpm --filter @app/backend test -- get-invite-metadata.handler.spec.ts`
Expected: 3 passing.

- [ ] **Step 5: Commit**

```bash
git add apps/backend/src/modules/memberships/queries/get-invite-metadata.*
git commit -m "feat(memberships): GetInviteMetadataQuery + handler

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

# Phase P8 — Module wiring + controller

## Task 18: Character ownership adapter (for LinkCharacterHandler)

**Files:**

- Create: `apps/backend/src/modules/memberships/infra/character-ownership.adapter.ts`

- [ ] **Step 1: Write the adapter**

```ts
/**
 * WHY this file exists:
 * Bridge between the memberships bounded context and the characters table.
 * Implements ICharacterOwnership with a single SELECT against
 * character.ownerId. Keeps LinkCharacterHandler free of Prisma.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type { ICharacterOwnership } from '../commands/link-character.handler';

@Injectable()
export class CharacterOwnershipAdapter implements ICharacterOwnership {
  constructor(private readonly prisma: PrismaService) {}

  async isOwnedBy(characterId: string, userId: string): Promise<boolean> {
    const row = await this.prisma.character.findUnique({
      where: { id: characterId },
      select: { ownerId: true },
    });
    return row !== null && row.ownerId === userId;
  }
}
```

- [ ] **Step 2: Typecheck**

Run: `pnpm --filter @app/backend typecheck`
Expected: clean.

- [ ] **Step 3: Commit**

```bash
git add apps/backend/src/modules/memberships/infra/character-ownership.adapter.ts
git commit -m "feat(memberships): character-ownership Prisma adapter

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

## Task 19: MembershipsController

**Files:**

- Create: `apps/backend/src/modules/memberships/memberships.controller.ts`

- [ ] **Step 1: Write the controller**

```ts
/**
 * WHY this file exists:
 * HTTP entry point for the memberships bounded context. Mounts six
 * operations under /api/v1/game-sessions/{id}. URLs match the OpenAPI
 * spec one-to-one — controller paths use the existing game-sessions
 * resource prefix so the membership/invite surface is nested under
 * the parent GameSession, mirroring the spec.
 */
import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { CommandBus, QueryBus } from '@nestjs/cqrs';

import { SessionGuard } from '../../common/auth/auth.guard';

import { KickMemberCommand } from './commands/kick-member.command';
import { LeaveSessionCommand } from './commands/leave-session.command';
import { LinkCharacterCommand } from './commands/link-character.command';
import { RevokeInviteCommand } from './commands/revoke-invite.command';
import { RotateInviteCommand } from './commands/rotate-invite.command';
import { GetInviteMetadataQuery } from './queries/get-invite-metadata.query';
import { ListMembershipsQuery } from './queries/list-memberships.query';

import type { AuthenticatedRequest } from '../../common/auth/auth.guard';
import type { RotateInviteResult } from './commands/rotate-invite.handler';
import type { MembershipReadModel, InviteMetadataReadModel } from './domain/membership.ports';

interface LinkCharacterBody {
  characterId: string | null;
}

@UseGuards(SessionGuard)
@Controller({ path: 'game-sessions/:gameSessionId', version: '1' })
export class MembershipsController {
  constructor(
    private readonly queryBus: QueryBus,
    private readonly commandBus: CommandBus,
  ) {}

  /** GET /api/v1/game-sessions/:gameSessionId/invite */
  @Get('invite')
  async getInviteMetadata(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
  ): Promise<InviteMetadataReadModel> {
    return this.queryBus.execute(new GetInviteMetadataQuery(gameSessionId, req.userId));
  }

  /** POST /api/v1/game-sessions/:gameSessionId/invite/rotate */
  @Post('invite/rotate')
  @HttpCode(HttpStatus.OK)
  async rotateInvite(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
  ): Promise<RotateInviteResult> {
    return this.commandBus.execute(new RotateInviteCommand(gameSessionId, req.userId));
  }

  /** DELETE /api/v1/game-sessions/:gameSessionId/invite */
  @Delete('invite')
  @HttpCode(HttpStatus.NO_CONTENT)
  async revokeInvite(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
  ): Promise<void> {
    return this.commandBus.execute(new RevokeInviteCommand(gameSessionId, req.userId));
  }

  /** GET /api/v1/game-sessions/:gameSessionId/members */
  @Get('members')
  async listMembers(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
  ): Promise<MembershipReadModel[]> {
    return this.queryBus.execute(new ListMembershipsQuery(gameSessionId, req.userId));
  }

  /** PATCH /api/v1/game-sessions/:gameSessionId/members/:membershipId */
  @Patch('members/:membershipId')
  @HttpCode(HttpStatus.OK)
  async linkCharacter(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
    @Param('membershipId') membershipId: string,
    @Body() body: LinkCharacterBody,
  ): Promise<MembershipReadModel> {
    return this.commandBus.execute(
      new LinkCharacterCommand(gameSessionId, req.userId, membershipId, body.characterId),
    );
  }

  /**
   * DELETE /api/v1/game-sessions/:gameSessionId/members/:membershipId
   *
   * Self-leave or GM-kick. The handler picks the right command by
   * inspecting whether the caller owns the membership; this controller
   * dispatches both possibilities and the first one that does not throw
   * wins. To keep that simple we dispatch LeaveSessionCommand first
   * (it only succeeds for self) and fall through to KickMemberCommand
   * for the GM. Errors from the kick handler are surfaced.
   */
  @Delete('members/:membershipId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async removeMember(
    @Req() req: AuthenticatedRequest,
    @Param('gameSessionId') gameSessionId: string,
    @Param('membershipId') membershipId: string,
  ): Promise<void> {
    try {
      return await this.commandBus.execute(
        new LeaveSessionCommand(gameSessionId, req.userId, membershipId),
      );
    } catch (e) {
      // If self-leave was refused (e.g. caller is not the owning user
      // OR it's the GM trying to kick a player), fall through to the
      // GM-kick path. KickMemberHandler will throw GameSessionNotOwnerError
      // for non-GM callers, which is the right surface here.
      if (e instanceof Error && (e as { code?: string }).code === 'MEMBERSHIP_NOT_AUTHORIZED') {
        return this.commandBus.execute(
          new KickMemberCommand(gameSessionId, req.userId, membershipId),
        );
      }
      throw e;
    }
  }
}
```

- [ ] **Step 2: Typecheck**

Run: `pnpm --filter @app/backend typecheck`
Expected: clean.

- [ ] **Step 3: Commit**

```bash
git add apps/backend/src/modules/memberships/memberships.controller.ts
git commit -m "feat(memberships): controller — 6 endpoints under /game-sessions/:id

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

## Task 20: MembershipsModule composition root + register in AppModule

**Files:**

- Create: `apps/backend/src/modules/memberships/memberships.module.ts`
- Modify: `apps/backend/src/app.module.ts`

- [ ] **Step 1: Write the module**

```ts
/**
 * WHY this file exists:
 * Composition root for the memberships bounded context. Wires the five
 * commands, two queries, the controller, the Prisma-backed repo, and the
 * character-ownership adapter.
 */
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { KickMemberHandler } from './commands/kick-member.handler';
import { LeaveSessionHandler } from './commands/leave-session.handler';
import { CHARACTER_OWNERSHIP, LinkCharacterHandler } from './commands/link-character.handler';
import { RevokeInviteHandler } from './commands/revoke-invite.handler';
import { RotateInviteHandler } from './commands/rotate-invite.handler';
import { GAME_SESSION_INVITE_REPO, MEMBERSHIP_REPO } from './domain/membership.ports';
import { CharacterOwnershipAdapter } from './infra/character-ownership.adapter';
import { MembershipRepo } from './infra/membership.repo';
import { MembershipsController } from './memberships.controller';
import { GetInviteMetadataHandler } from './queries/get-invite-metadata.handler';
import { ListMembershipsHandler } from './queries/list-memberships.handler';

@Module({
  imports: [CqrsModule],
  controllers: [MembershipsController],
  providers: [
    // Commands
    RotateInviteHandler,
    RevokeInviteHandler,
    KickMemberHandler,
    LeaveSessionHandler,
    LinkCharacterHandler,
    // Queries
    ListMembershipsHandler,
    GetInviteMetadataHandler,
    // Infra — one class implements both port interfaces, registered twice
    MembershipRepo,
    { provide: MEMBERSHIP_REPO, useExisting: MembershipRepo },
    { provide: GAME_SESSION_INVITE_REPO, useExisting: MembershipRepo },
    { provide: CHARACTER_OWNERSHIP, useClass: CharacterOwnershipAdapter },
  ],
  exports: [MEMBERSHIP_REPO],
})
export class MembershipsModule {}
```

- [ ] **Step 2: Register MembershipsModule in AppModule**

Open `apps/backend/src/app.module.ts`, find the `imports: [...]` array, and add `MembershipsModule` after `GameSessionsModule`:

```ts
import { MembershipsModule } from './modules/memberships/memberships.module';

// inside @Module({ imports: [...
    GameSessionsModule,
    MembershipsModule,
// ...] })
```

- [ ] **Step 3: Build + boot smoke check**

Run: `docker compose -f docker/compose.yml restart backend && docker compose -f docker/compose.yml logs --tail=80 backend`
Expected: no exceptions; six new routes visible in the route map.

- [ ] **Step 4: Run all backend tests**

Run: `pnpm --filter @app/backend test -- --reporter=dot`
Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add apps/backend/src/modules/memberships/memberships.module.ts apps/backend/src/app.module.ts
git commit -m "feat(memberships): module wired into AppModule

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

# Phase P9 — Extend GameSession response with memberships[]

## Task 21: GameSession read-model + repo include memberships

**Files:**

- Modify: `apps/backend/src/modules/game-sessions/domain/game-session.ports.ts`
- Modify: `apps/backend/src/modules/game-sessions/infra/game-session.repo.ts`
- Modify: all `apps/backend/src/modules/game-sessions/**/*.spec.ts` fixtures that build a `GameSessionReadModel`

- [ ] **Step 1: Add memberships to the read model**

In `game-session.ports.ts`, edit `GameSessionReadModel`:

```ts
import type { MembershipReadModel } from '../../memberships/domain/membership.ports';

export interface GameSessionReadModel {
  id: string;
  ownerId: string;
  name: string;
  description: string | null;
  status: GameSessionStatus;
  dpCount: number;
  characterIds: string[]; // deprecated, removed in Stream E
  memberships: MembershipReadModel[];
  shipId: string | null;
  createdAt: string;
  updatedAt: string;
}
```

- [ ] **Step 2: Extend SELECT in game-session.repo.ts**

Locate `GAME_SESSION_SELECT` and add:

```ts
  memberships: {
    where: { leftAt: null },
    orderBy: { joinedAt: 'asc' as const },
    select: {
      id: true, gameSessionId: true, userId: true, role: true,
      characterId: true, joinedAt: true, leftAt: true,
      character: { select: { name: true } },
    },
  },
```

Then extend `PrismaGameSession` to include `memberships: { ... }[]` and update `toReadModel` to map each membership row to a `MembershipReadModel`. Reuse the same toReadModel pattern used by `MembershipRepo`. To avoid duplication, **extract** the membership row mapper into a shared helper at `apps/backend/src/modules/memberships/domain/membership.mapper.ts`:

```ts
import type { MembershipReadModel, MembershipRole } from './membership.ports';

interface PrismaMembershipRow {
  id: string;
  gameSessionId: string;
  userId: string;
  role: string;
  characterId: string | null;
  joinedAt: Date;
  leftAt: Date | null;
  character: { name: string } | null;
}

export function toMembershipReadModel(
  row: PrismaMembershipRow,
  displayName: string | null,
): MembershipReadModel {
  return {
    id: row.id,
    gameSessionId: row.gameSessionId,
    userId: row.userId,
    role: row.role as MembershipRole,
    displayName,
    characterId: row.characterId,
    characterName: row.character?.name ?? null,
    joinedAt: row.joinedAt.toISOString(),
    leftAt: row.leftAt?.toISOString() ?? null,
  };
}
```

Update `membership.repo.ts` to consume `toMembershipReadModel` instead of its private helper. In `game-session.repo.ts`'s `toReadModel`, fetch display names in a separate `prisma.user.findMany({ where: { id: { in: userIds } } })` and map each row through `toMembershipReadModel`.

- [ ] **Step 3: Update all existing game-session fixture builders**

Search:

```bash
rg -l "characterIds: \[" apps/backend/src/modules/game-sessions
```

For each spec file that builds a `GameSessionReadModel`, add `memberships: []` to the default fixture. Example diff for `commands/create-game-session.handler.spec.ts`:

```ts
function makeSession(overrides: Partial<GameSessionReadModel> = {}): GameSessionReadModel {
  return {
    id: 'gs-1',
    ownerId: 'user-1',
    name: 'The Long Night',
    description: null,
    status: 'active',
    dpCount: 0,
    characterIds: [],
    memberships: [], // ← new
    shipId: null,
    createdAt: '2026-05-09T10:00:00.000Z',
    updatedAt: '2026-05-09T10:00:00.000Z',
    ...overrides,
  };
}
```

- [ ] **Step 4: Typecheck + tests**

Run: `pnpm --filter @app/backend typecheck && pnpm --filter @app/backend test -- --reporter=dot`
Expected: clean + green.

- [ ] **Step 5: Commit**

```bash
git add apps/backend/src/modules/game-sessions apps/backend/src/modules/memberships/domain/membership.mapper.ts
git commit -m "feat(game-sessions): GameSession response includes memberships[]

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

# Phase P10 — Express OpenAPI runtime validator + end-to-end smoke

## Task 22: Smoke-test the routes against express-openapi-validator

**Files:** none modified — this is a verification task.

- [ ] **Step 1: Boot the backend (or confirm boot)**

Run: `docker compose -f docker/compose.yml logs --tail=40 backend | grep "Nest application successfully started"`
Expected: present.

- [ ] **Step 2: Authenticate via test fixture cookie**

Use whatever script the repo provides for issuing a test cookie. If unsure: `rg "issue.*test.*cookie|TEST_USER_TOKEN" apps/backend tests scripts | head -10`. Use the resulting auth header for the next steps.

- [ ] **Step 3: POST a session, then rotate**

```bash
SESSION_JSON=$(xh --auth-type bearer POST http://localhost:3010/api/v1/game-sessions name="Test session" Authorization:"Bearer $TOK")
GS_ID=$(echo "$SESSION_JSON" | jq -r .id)
xh --auth-type bearer POST http://localhost:3010/api/v1/game-sessions/$GS_ID/invite/rotate Authorization:"Bearer $TOK"
```

Expected: 200 response shape `{ url, token, rotatedAt }`. URL host matches `webHost`.

- [ ] **Step 4: GET metadata**

```bash
xh --auth-type bearer GET http://localhost:3010/api/v1/game-sessions/$GS_ID/invite Authorization:"Bearer $TOK"
```

Expected: `{ active: true, rotatedAt: ... }`.

- [ ] **Step 5: DELETE the invite**

```bash
xh --auth-type bearer DELETE http://localhost:3010/api/v1/game-sessions/$GS_ID/invite Authorization:"Bearer $TOK"
```

Expected: 204.

- [ ] **Step 6: GET members (returns 1 — just the GM)**

```bash
xh --auth-type bearer GET http://localhost:3010/api/v1/game-sessions/$GS_ID/members Authorization:"Bearer $TOK"
```

Expected: array of one membership with `role: gm`.

If any step fails with a `404 Not Found` from express-openapi-validator, the OpenAPI spec path or codegen artefact is wrong. Re-run `pnpm spec:codegen` and verify the URI template matches.

- [ ] **Step 7: No commit (verification-only task)**

---

# Phase P11 — Web @app/ui components

Two components, both following the project's mandatory `*.vue + *.stories.ts + *.spec.ts + index.ts` layout. The handoff JSX is the spec.

## Task 23: AppSessionShareLinkCard

**Files:**

- Create: `packages/ui/src/components/AppSessionShareLinkCard/AppSessionShareLinkCard.vue`
- Create: `packages/ui/src/components/AppSessionShareLinkCard/AppSessionShareLinkCard.stories.ts`
- Create: `packages/ui/src/components/AppSessionShareLinkCard/AppSessionShareLinkCard.spec.ts`
- Create: `packages/ui/src/components/AppSessionShareLinkCard/index.ts`
- Modify: `packages/ui/src/index.ts` (export)

**Reference JSX:** `/tmp/coriolis-handoff/coriolis-app/project/screens/session-share-link-card.jsx`.

- [ ] **Step 1: Component**

`AppSessionShareLinkCard.vue` (script-setup + scoped BEM, no hex literals — all colors via tokens):

```vue
<script setup lang="ts">
  import { ref } from 'vue';

  interface Props {
    /** The one-shot URL to display + copy. Pass exactly once per reveal. */
    url: string;
    /** Localised "we won't show this again" warning sentence. */
    warning: string;
    /** Localised "Copy" button label. */
    copyLabel: string;
    /** Localised "Copied" toast label. */
    copiedLabel: string;
  }

  const props = defineProps<Props>();
  const justCopied = ref(false);

  async function copy() {
    try {
      await navigator.clipboard.writeText(props.url);
      justCopied.value = true;
      window.setTimeout(() => (justCopied.value = false), 1500);
    } catch {
      // Clipboard API unavailable — the visible URL is still selectable.
    }
  }
</script>

<template>
  <div class="app-session-share-link-card" role="group" :aria-label="copyLabel">
    <code class="app-session-share-link-card__url">{{ url }}</code>
    <button
      type="button"
      class="app-session-share-link-card__copy"
      :aria-live="justCopied ? 'polite' : 'off'"
      @click="copy"
    >
      {{ justCopied ? copiedLabel : copyLabel }}
    </button>
    <p class="app-session-share-link-card__warning">{{ warning }}</p>
  </div>
</template>

<style scoped lang="scss">
  .app-session-share-link-card {
    display: grid;
    grid-template-columns: 1fr auto;
    gap: var(--space-3);
    padding: var(--space-4);
    background: var(--surface-night);
    border: 1px solid var(--brand-brass);
    box-shadow: inset 0 0 0 1px var(--brand-brass-shadow);
    border-radius: var(--radius-md);

    &__url {
      grid-column: 1 / 2;
      font-family: var(--font-mono);
      font-size: var(--font-size-mono-md);
      color: var(--brand-brass-light);
      word-break: break-all;
      align-self: center;
    }

    &__copy {
      grid-column: 2 / 3;
      font-family: var(--font-body);
      font-weight: 500;
      letter-spacing: 0.06em;
      text-transform: uppercase;
      padding: var(--space-2) var(--space-3);
      background: var(--brand-brass);
      color: var(--surface-void);
      border: none;
      border-radius: var(--radius-sm);
      cursor: pointer;
      min-width: 88px;
      min-height: 44px;
    }

    &__warning {
      grid-column: 1 / -1;
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--font-size-body-sm);
      font-style: italic;
      color: var(--text-secondary);
    }
  }
</style>
```

- [ ] **Step 2: Index re-export**

`packages/ui/src/components/AppSessionShareLinkCard/index.ts`:

```ts
export { default as AppSessionShareLinkCard } from './AppSessionShareLinkCard.vue';
```

Append to `packages/ui/src/index.ts`:

```ts
export * from './components/AppSessionShareLinkCard';
```

- [ ] **Step 3: Stories**

`AppSessionShareLinkCard.stories.ts`:

```ts
import type { Meta, StoryObj } from '@storybook/vue3';

import { AppSessionShareLinkCard } from './index';

const meta: Meta<typeof AppSessionShareLinkCard> = {
  title: 'Phase 8/AppSessionShareLinkCard',
  component: AppSessionShareLinkCard,
};
export default meta;

type Story = StoryObj<typeof AppSessionShareLinkCard>;

export const Default: Story = {
  args: {
    url: 'https://app.coriolis.example.com/app/sessions/join/Sl9X3kQpZr8mVtNuY7Hb2C',
    warning: 'This URL appears once. If you lose it, rotate the invite to generate a new one.',
    copyLabel: 'Copy',
    copiedLabel: 'Copied',
  },
};

export const LongUrlWraps: Story = {
  args: {
    ...Default.args,
    url: 'https://very-long-host-name.example.com/app/sessions/join/' + 'X'.repeat(80),
  },
};

export const Russian: Story = {
  args: {
    ...Default.args,
    warning: 'Эта ссылка показывается один раз. Если потеряете — придётся сменить инвайт.',
    copyLabel: 'Скопировать',
    copiedLabel: 'Скопировано',
  },
};
```

- [ ] **Step 4: Spec**

`AppSessionShareLinkCard.spec.ts`:

```ts
import { describe, expect, it, vi } from 'vitest';
import { mount } from '@vue/test-utils';

import { AppSessionShareLinkCard } from './index';

const baseProps = {
  url: 'https://app.example.com/app/sessions/join/abc',
  warning: "Won't be shown again.",
  copyLabel: 'Copy',
  copiedLabel: 'Copied',
};

describe('AppSessionShareLinkCard', () => {
  it('renders the URL in a <code>', () => {
    const wrapper = mount(AppSessionShareLinkCard, { props: baseProps });
    expect(wrapper.find('code').text()).toBe(baseProps.url);
  });

  it('renders the warning sentence', () => {
    const wrapper = mount(AppSessionShareLinkCard, { props: baseProps });
    expect(wrapper.text()).toContain("Won't be shown again.");
  });

  it('copies to clipboard on button click and flips to "Copied"', async () => {
    const writeText = vi.fn().mockResolvedValue(undefined);
    Object.assign(navigator, { clipboard: { writeText } });
    const wrapper = mount(AppSessionShareLinkCard, { props: baseProps });
    await wrapper.find('button').trigger('click');
    await wrapper.vm.$nextTick();
    expect(writeText).toHaveBeenCalledWith(baseProps.url);
    expect(wrapper.find('button').text()).toBe('Copied');
  });

  it('keeps button label as "Copy" if clipboard write fails', async () => {
    Object.assign(navigator, {
      clipboard: { writeText: vi.fn().mockRejectedValue(new Error('denied')) },
    });
    const wrapper = mount(AppSessionShareLinkCard, { props: baseProps });
    await wrapper.find('button').trigger('click');
    await wrapper.vm.$nextTick();
    expect(wrapper.find('button').text()).toBe('Copy');
  });
});
```

- [ ] **Step 5: Run UI tests**

Run: `pnpm --filter @app/ui test -- AppSessionShareLinkCard`
Expected: 4 passing.

- [ ] **Step 6: Verify Storybook a11y addon**

Run: `pnpm --filter @app/ui storybook --ci --quiet` in another terminal, then visit `http://localhost:6006/?path=/story/phase-8-appsessionsharelinkcard--default` and open the a11y panel.
Expected: zero violations on Default, LongUrlWraps, Russian.

- [ ] **Step 7: Commit**

```bash
git add packages/ui/src/components/AppSessionShareLinkCard packages/ui/src/index.ts
git commit -m "feat(ui): AppSessionShareLinkCard

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

## Task 24: AppInviteManager

**Files:**

- Create: `packages/ui/src/components/AppInviteManager/AppInviteManager.vue`
- Create: `packages/ui/src/components/AppInviteManager/AppInviteManager.stories.ts`
- Create: `packages/ui/src/components/AppInviteManager/AppInviteManager.spec.ts`
- Create: `packages/ui/src/components/AppInviteManager/index.ts`
- Modify: `packages/ui/src/index.ts` (export)

**Reference JSX:** `/tmp/coriolis-handoff/coriolis-app/project/screens/invite-manager.jsx`.

- [ ] **Step 1: Component**

```vue
<script setup lang="ts">
  import { computed } from 'vue';

  import { AppButton } from '../AppButton';
  import { AppModal } from '../AppModal';
  import { AppPanelTitle } from '../AppPanelTitle';
  import { AppSessionShareLinkCard } from '../AppSessionShareLinkCard';

  type State = 'none' | 'active' | 'just-generated' | 'just-rotated';

  interface Props {
    state: State;
    /** Required when state is 'active' — ISO timestamp of when the invite was last rotated. */
    rotatedAt?: string | null;
    /** Required when state is 'just-generated' or 'just-rotated' — the plaintext URL. Empty otherwise. */
    revealUrl?: string;
    /** Localised i18n bundle the caller assembles via t(). */
    labels: {
      title: string;
      blurbNone: string;
      ctaGenerate: string;
      labelActiveSince: string;
      noteActive: string;
      ctaCopy: string;
      ctaRotate: string;
      ctaRevoke: string;
      revealTitleNew: string;
      revealTitleRotated: string;
      revealClose: string;
      revealWarning: string;
      revealCopy: string;
      revealCopied: string;
    };
  }

  const props = defineProps<Props>();
  const emit = defineEmits<{
    (e: 'generate'): void;
    (e: 'rotate'): void;
    (e: 'revoke'): void;
    (e: 'copy'): void;
    (e: 'closeReveal'): void;
  }>();

  const isReveal = computed(
    () => props.state === 'just-generated' || props.state === 'just-rotated',
  );
  const revealTitle = computed(() =>
    props.state === 'just-rotated' ? props.labels.revealTitleRotated : props.labels.revealTitleNew,
  );
</script>

<template>
  <section class="app-invite-manager" role="region" aria-labelledby="app-invite-manager-title">
    <AppPanelTitle id="app-invite-manager-title" size="md">{{ labels.title }}</AppPanelTitle>

    <!-- State: none -->
    <div v-if="state === 'none'" class="app-invite-manager__body">
      <p class="app-invite-manager__blurb">{{ labels.blurbNone }}</p>
      <AppButton @click="emit('generate')">{{ labels.ctaGenerate }}</AppButton>
    </div>

    <!-- State: active -->
    <div v-else-if="state === 'active'" class="app-invite-manager__body">
      <div class="app-invite-manager__since">
        <span aria-hidden="true" class="app-invite-manager__pulse" />
        <span class="app-invite-manager__since-label">{{ labels.labelActiveSince }}</span>
        <time class="app-invite-manager__since-time" :datetime="rotatedAt ?? undefined">{{
          rotatedAt
        }}</time>
      </div>
      <p class="app-invite-manager__note">{{ labels.noteActive }}</p>
      <div class="app-invite-manager__actions">
        <AppButton @click="emit('copy')">{{ labels.ctaCopy }}</AppButton>
        <AppButton variant="secondary" @click="emit('rotate')">{{ labels.ctaRotate }}</AppButton>
        <AppButton variant="danger" class="app-invite-manager__revoke" @click="emit('revoke')">
          {{ labels.ctaRevoke }}
        </AppButton>
      </div>
    </div>

    <!-- State: just-generated / just-rotated — alertdialog -->
    <AppModal
      v-if="isReveal"
      :open="isReveal"
      :close-on-backdrop="false"
      :close-on-esc="false"
      aria-labelledby="app-invite-manager-reveal-title"
      role="alertdialog"
      @close="emit('closeReveal')"
    >
      <header class="app-invite-manager__reveal-header">
        <h2 id="app-invite-manager-reveal-title" class="app-invite-manager__reveal-title">
          {{ revealTitle }}
        </h2>
      </header>
      <AppSessionShareLinkCard
        :url="revealUrl ?? ''"
        :warning="labels.revealWarning"
        :copy-label="labels.revealCopy"
        :copied-label="labels.revealCopied"
      />
      <footer class="app-invite-manager__reveal-footer">
        <AppButton @click="emit('closeReveal')">{{ labels.revealClose }}</AppButton>
      </footer>
    </AppModal>
  </section>
</template>

<style scoped lang="scss">
  .app-invite-manager {
    background: var(--surface-night);
    border: 1px solid var(--brand-brass-deep);
    border-radius: var(--radius-md);
    padding: var(--space-5);

    &__body {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
      margin-top: var(--space-3);
    }

    &__blurb,
    &__note {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--font-size-body-sm);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__since {
      display: flex;
      align-items: center;
      gap: var(--space-2);
    }

    &__pulse {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      background: var(--state-success);
      box-shadow: 0 0 8px var(--state-success);
    }

    &__since-label {
      font-family: var(--font-body);
      font-size: var(--font-size-body-xs);
      letter-spacing: 0.16em;
      text-transform: uppercase;
      color: var(--state-success);
    }

    &__since-time {
      font-family: var(--font-mono);
      font-size: var(--font-size-mono-sm);
      color: var(--brand-brass-light);
    }

    &__actions {
      display: flex;
      flex-wrap: wrap;
      gap: var(--space-2);
    }

    &__revoke {
      margin-left: auto;
    }

    &__reveal-header {
      margin-bottom: var(--space-3);
    }

    &__reveal-title {
      font-family: var(--font-display);
      font-size: var(--font-size-display-sm);
      letter-spacing: 0.04em;
      color: var(--brand-brass-light);
      margin: 0;
    }

    &__reveal-footer {
      display: flex;
      justify-content: flex-end;
      margin-top: var(--space-3);
    }
  }
</style>
```

- [ ] **Step 2: Index re-export**

`packages/ui/src/components/AppInviteManager/index.ts`:

```ts
export { default as AppInviteManager } from './AppInviteManager.vue';
```

Append to `packages/ui/src/index.ts`:

```ts
export * from './components/AppInviteManager';
```

- [ ] **Step 3: Stories**

```ts
import type { Meta, StoryObj } from '@storybook/vue3';

import { AppInviteManager } from './index';

const baseLabels = {
  title: 'Player invite',
  blurbNone: 'Generate a link your players can use to join this session and link their characters.',
  ctaGenerate: 'Generate invite link',
  labelActiveSince: 'Active since',
  noteActive: 'Current link is valid. Rotating invalidates the old link immediately.',
  ctaCopy: 'Copy link',
  ctaRotate: 'Rotate',
  ctaRevoke: 'Revoke',
  revealTitleNew: 'Your new invite link',
  revealTitleRotated: 'Link rotated',
  revealClose: "I've copied it — close",
  revealWarning: 'This URL appears once. If you lose it, rotate the invite to generate a new one.',
  revealCopy: 'Copy',
  revealCopied: 'Copied',
} as const;

const meta: Meta<typeof AppInviteManager> = {
  title: 'Phase 8/AppInviteManager',
  component: AppInviteManager,
};
export default meta;

type Story = StoryObj<typeof AppInviteManager>;

export const None: Story = { args: { state: 'none', labels: baseLabels } };
export const Active: Story = {
  args: { state: 'active', rotatedAt: '2026-05-15T10:00:00Z', labels: baseLabels },
};
export const JustGenerated: Story = {
  args: {
    state: 'just-generated',
    revealUrl: 'https://app.coriolis.example.com/app/sessions/join/Sl9X3kQpZr8mVtNuY7Hb2C',
    labels: baseLabels,
  },
};
export const JustRotated: Story = {
  ...JustGenerated,
  args: { ...JustGenerated.args!, state: 'just-rotated' },
};
```

- [ ] **Step 4: Spec**

```ts
import { describe, expect, it } from 'vitest';
import { mount } from '@vue/test-utils';

import { AppInviteManager } from './index';

const labels = {
  title: 'Player invite',
  blurbNone: 'Generate a link',
  ctaGenerate: 'Generate invite link',
  labelActiveSince: 'Active since',
  noteActive: 'Note',
  ctaCopy: 'Copy',
  ctaRotate: 'Rotate',
  ctaRevoke: 'Revoke',
  revealTitleNew: 'Your new invite link',
  revealTitleRotated: 'Link rotated',
  revealClose: 'Close',
  revealWarning: 'Once only',
  revealCopy: 'Copy',
  revealCopied: 'Copied',
};

describe('AppInviteManager', () => {
  it('renders the empty state and emits "generate"', async () => {
    const wrapper = mount(AppInviteManager, { props: { state: 'none', labels } });
    expect(wrapper.text()).toContain('Generate a link');
    await wrapper.find('button').trigger('click');
    expect(wrapper.emitted('generate')).toBeTruthy();
  });

  it('renders the active state with rotatedAt and emits copy/rotate/revoke', async () => {
    const wrapper = mount(AppInviteManager, {
      props: { state: 'active', rotatedAt: '2026-05-15T10:00:00Z', labels },
    });
    expect(wrapper.text()).toContain('Active since');
    const buttons = wrapper.findAll('button');
    await buttons[0]!.trigger('click');
    await buttons[1]!.trigger('click');
    await buttons[2]!.trigger('click');
    expect(wrapper.emitted('copy')).toBeTruthy();
    expect(wrapper.emitted('rotate')).toBeTruthy();
    expect(wrapper.emitted('revoke')).toBeTruthy();
  });

  it('renders the reveal modal with role="alertdialog" on just-generated', () => {
    const wrapper = mount(AppInviteManager, {
      props: { state: 'just-generated', revealUrl: 'https://x/join/abc', labels },
    });
    expect(wrapper.find('[role="alertdialog"]').exists()).toBe(true);
    expect(wrapper.text()).toContain('Your new invite link');
  });

  it('uses the rotated-title copy on just-rotated', () => {
    const wrapper = mount(AppInviteManager, {
      props: { state: 'just-rotated', revealUrl: 'https://x/join/abc', labels },
    });
    expect(wrapper.text()).toContain('Link rotated');
  });

  it('emits closeReveal when the close button is clicked', async () => {
    const wrapper = mount(AppInviteManager, {
      props: { state: 'just-generated', revealUrl: 'https://x/join/abc', labels },
    });
    const closeBtn = wrapper.findAll('button').find((b) => b.text() === 'Close');
    await closeBtn!.trigger('click');
    expect(wrapper.emitted('closeReveal')).toBeTruthy();
  });
});
```

- [ ] **Step 5: Run UI tests**

Run: `pnpm --filter @app/ui test -- AppInviteManager`
Expected: 5 passing.

- [ ] **Step 6: Storybook a11y check**

Visit each of the four stories with the a11y panel.
Expected: zero violations on `None`, `Active`, `JustGenerated`, `JustRotated`.

- [ ] **Step 7: Commit**

```bash
git add packages/ui/src/components/AppInviteManager packages/ui/src/index.ts
git commit -m "feat(ui): AppInviteManager (none / active / just-generated / just-rotated)

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

# Phase P12 — Web mount + i18n + dashboard segmented control

## Task 25: Mount AppInviteManager on the GM session detail page + i18n

**Files:**

- Modify: `apps/web/app/pages/app/game-sessions/[id].vue`
- Modify: `apps/web/app/i18n/locales/{en,ru,uk,el}.json`

- [ ] **Step 1: Add invite i18n keys to each locale**

Append to `apps/web/app/i18n/locales/en.json` (and translate for ru/uk/el):

```json
{
  "invite": {
    "title": "Player invite",
    "blurbNone": "Generate a link your players can use to join this session and link their characters.",
    "ctaGenerate": "Generate invite link",
    "labelActiveSince": "Active since",
    "noteActive": "Current link is valid. Rotating invalidates the old link immediately.",
    "ctaCopy": "Copy link",
    "ctaRotate": "Rotate",
    "ctaRevoke": "Revoke",
    "revealTitleNew": "Your new invite link",
    "revealTitleRotated": "Link rotated",
    "revealClose": "I've copied it — close",
    "revealWarning": "This URL appears once. If you lose it, rotate the invite to generate a new one.",
    "revealCopy": "Copy",
    "revealCopied": "Copied",
    "confirmRevokeTitle": "Revoke invite?",
    "confirmRevokeBody": "Players who open the current link after revoking will see an empty state. Continue?",
    "confirmRotateTitle": "Rotate invite?",
    "confirmRotateBody": "The current link will immediately stop working. You'll need to share the new one with every player."
  }
}
```

Russian (`ru.json`):

```json
{
  "invite": {
    "title": "Приглашение игроков",
    "blurbNone": "Создайте ссылку, по которой игроки смогут присоединиться к сессии и привязать персонажей.",
    "ctaGenerate": "Создать ссылку",
    "labelActiveSince": "Активна с",
    "noteActive": "Текущая ссылка действительна. При смене старая немедленно перестаёт работать.",
    "ctaCopy": "Скопировать",
    "ctaRotate": "Сменить",
    "ctaRevoke": "Отозвать",
    "revealTitleNew": "Ваша новая ссылка",
    "revealTitleRotated": "Ссылка обновлена",
    "revealClose": "Скопировал(-а) — закрыть",
    "revealWarning": "Эта ссылка показывается один раз. Если потеряете — придётся сменить инвайт.",
    "revealCopy": "Скопировать",
    "revealCopied": "Скопировано",
    "confirmRevokeTitle": "Отозвать приглашение?",
    "confirmRevokeBody": "После отзыва открывшие старую ссылку увидят пустой экран. Продолжить?",
    "confirmRotateTitle": "Сменить приглашение?",
    "confirmRotateBody": "Старая ссылка немедленно перестанет работать. Новую нужно будет разослать всем игрокам."
  }
}
```

Add corresponding `uk.json` and `el.json` entries (Cyrillic-stress-tested copy in `ru.json` is the canonical reference for length).

- [ ] **Step 2: Wire AppInviteManager into the page**

In `apps/web/app/pages/app/game-sessions/[id].vue`, locate the Overview tab body and add:

```vue
<script setup lang="ts">
  import { AppInviteManager } from '@app/ui';
  // ... existing imports
  import { useApiClient } from '~/composables/use-api-client';

  const { t } = useI18n();
  const api = useApiClient();

  // Existing GameSession fetch ...
  const inviteMetadata = ref<{ active: boolean; rotatedAt: string | null }>({
    active: false,
    rotatedAt: null,
  });
  const revealState = ref<'none' | 'active' | 'just-generated' | 'just-rotated'>('none');
  const revealUrl = ref<string>('');

  async function refreshInviteMetadata() {
    const session = useRoute().params.id as string;
    const meta = await api.getInviteMetadata({ id: session });
    inviteMetadata.value = meta;
    revealState.value = meta.active ? 'active' : 'none';
  }

  async function generate() {
    const session = useRoute().params.id as string;
    const result = await api.rotateInvite({ id: session });
    revealUrl.value = result.url;
    revealState.value = inviteMetadata.value.active ? 'just-rotated' : 'just-generated';
    inviteMetadata.value = { active: true, rotatedAt: result.rotatedAt };
  }

  async function revoke() {
    const session = useRoute().params.id as string;
    // Use AppConfirm here per the project's pattern; pseudo for brevity:
    const ok = await useConfirm({
      title: t('invite.confirmRevokeTitle'),
      body: t('invite.confirmRevokeBody'),
    });
    if (!ok) return;
    await api.revokeInvite({ id: session });
    inviteMetadata.value = { active: false, rotatedAt: null };
    revealState.value = 'none';
  }

  async function copy() {
    // Active state's "Copy" can't recover the plaintext URL — the spec is explicit.
    // Surface the rotate flow instead so the GM can deliberately re-issue.
    await generate();
  }

  function closeReveal() {
    revealState.value = inviteMetadata.value.active ? 'active' : 'none';
    revealUrl.value = '';
  }

  onMounted(refreshInviteMetadata);
</script>

<template>
  <!-- inside the Overview tab markup -->
  <AppInviteManager
    :state="revealState"
    :rotated-at="inviteMetadata.rotatedAt"
    :reveal-url="revealUrl"
    :labels="{
      title: t('invite.title'),
      blurbNone: t('invite.blurbNone'),
      ctaGenerate: t('invite.ctaGenerate'),
      labelActiveSince: t('invite.labelActiveSince'),
      noteActive: t('invite.noteActive'),
      ctaCopy: t('invite.ctaCopy'),
      ctaRotate: t('invite.ctaRotate'),
      ctaRevoke: t('invite.ctaRevoke'),
      revealTitleNew: t('invite.revealTitleNew'),
      revealTitleRotated: t('invite.revealTitleRotated'),
      revealClose: t('invite.revealClose'),
      revealWarning: t('invite.revealWarning'),
      revealCopy: t('invite.revealCopy'),
      revealCopied: t('invite.revealCopied'),
    }"
    @generate="generate"
    @rotate="generate"
    @revoke="revoke"
    @copy="copy"
    @close-reveal="closeReveal"
  />
</template>
```

(Adapt to the actual page structure; the JSX is canonical for visual layout.)

- [ ] **Step 3: Lint + typecheck + tests**

Run: `pnpm --filter @app/web lint --fix && pnpm --filter @app/web typecheck && pnpm --filter @app/web test -- --reporter=dot`
Expected: clean + green.

- [ ] **Step 4: i18n parity**

Run: `pnpm check:i18n`
Expected: parity green for `invite.*`.

- [ ] **Step 5: Smoke check in the browser**

1. Open the running web app at `/app/game-sessions/<some-id>`.
2. Confirm the Overview tab shows the `AppInviteManager` panel.
3. Click `Generate invite link` → reveal modal appears with the URL and an `I've copied it — close` button. Backdrop click does not dismiss.
4. Click Copy → "Copied" flash.
5. Close → panel shows "Active since <now>".
6. Click Rotate → reveal modal again with new URL; previous URL no longer matches the server hash (validate by attempting `GET /api/v1/game-sessions/:id/invite` — `active: true`, `rotatedAt` is fresh).
7. Click Revoke → confirmation → panel returns to empty state.

- [ ] **Step 6: Commit**

```bash
git add apps/web/app/pages/app/game-sessions/\[id\].vue apps/web/app/i18n/locales
git commit -m "feat(web): mount AppInviteManager on GM session Overview + i18n

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

## Task 26: Dashboard `Running | Playing in` segmented control

**Files:**

- Modify: `apps/web/app/pages/app/dashboard.vue`

**Reference JSX:** `/tmp/coriolis-handoff/coriolis-app/project/screens/dashboard.jsx`.

- [ ] **Step 1: Add `AppSegControl` to the Sessions card**

Inside the Sessions card on `dashboard.vue`, surface the existing `AppSegControl` atom with two segments. The "Playing in" segment shows a count of 0 in Stream A (the player-side count source endpoint, `/me/memberships`, lands in Stream B). Pseudocode:

```vue
<script setup lang="ts">
  // ... existing imports
  import { AppSegControl } from '@app/ui';

  const sessionsScope = ref<'running' | 'playing'>('running');
  // existing runningCount derived from useGameSessions(); playingCount fixed to 0 for Stream A.
  const playingCount = 0;
</script>

<template>
  <AppSegControl
    v-model="sessionsScope"
    :options="[
      { value: 'running', label: t('dashboard.sessions.running', { n: runningCount }) },
      { value: 'playing', label: t('dashboard.sessions.playing', { n: playingCount }) },
    ]"
  />
  <!-- existing session-card grid; conditionally show empty-state when sessionsScope === 'playing' -->
  <p v-if="sessionsScope === 'playing'">{{ t('dashboard.sessions.playingEmpty') }}</p>
</template>
```

- [ ] **Step 2: Add i18n keys**

`en.json`:

```json
{
  "dashboard": {
    "sessions": {
      "running": "Running ({n})",
      "playing": "Playing in ({n})",
      "playingEmpty": "You haven't joined any sessions yet. Ask your GM for an invite link."
    }
  }
}
```

Add parity entries for `ru.json`, `uk.json`, `el.json`.

- [ ] **Step 3: Lint / typecheck / test / i18n parity**

```bash
pnpm --filter @app/web lint --fix
pnpm --filter @app/web typecheck
pnpm --filter @app/web test -- --reporter=dot
pnpm check:i18n
```

Expected: each step clean.

- [ ] **Step 4: Commit**

```bash
git add apps/web/app/pages/app/dashboard.vue apps/web/app/i18n/locales
git commit -m "feat(web): dashboard Running | Playing in segmented control

Playing-in count fixed to 0 until Stream B ships /me/memberships.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

# Phase P13 — Mobile parity (invite manager only; player surfaces are Stream B)

## Task 27: Mobile invite manager widget (Flutter)

**Files:**

- Create: `apps/mobile/lib/features/game_sessions/presentation/widgets/invite_manager.dart`
- Create: `apps/mobile/test/features/game_sessions/presentation/widgets/invite_manager_test.dart`
- Modify: `apps/mobile/lib/features/game_sessions/data/sessions_repository.dart` (add rotate / revoke / metadata methods that wrap the generated client)

- [ ] **Step 1: Repository methods**

Open `apps/mobile/lib/features/game_sessions/data/sessions_repository.dart` and add:

```dart
import 'package:coriolis_api_client/coriolis_api_client.dart' as api;

class SessionsRepository {
  // ... existing
  Future<api.InviteMetadata> getInviteMetadata(String sessionId) async {
    final response = await _client.getGameSessionsApi().getInviteMetadata(id: sessionId);
    return response.data!;
  }

  Future<api.InviteRotated> rotateInvite(String sessionId) async {
    final response = await _client.getGameSessionsApi().rotateInvite(id: sessionId);
    return response.data!;
  }

  Future<void> revokeInvite(String sessionId) async {
    await _client.getGameSessionsApi().revokeInvite(id: sessionId);
  }
}
```

(Adapt to the actual repo class shape — match the pattern used for existing `dpAdjust` / `assignCharacter` calls.)

- [ ] **Step 2: Widget**

`invite_manager.dart`:

```dart
import 'package:coriolis_api_client/coriolis_api_client.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InviteState { none, active, justGenerated, justRotated }

class InviteManagerWidget extends StatelessWidget {
  const InviteManagerWidget({
    super.key,
    required this.state,
    required this.rotatedAt,
    required this.revealUrl,
    required this.onGenerate,
    required this.onRotate,
    required this.onRevoke,
    required this.onCopy,
    required this.onCloseReveal,
  });

  final InviteState state;
  final DateTime? rotatedAt;
  final String? revealUrl;
  final VoidCallback onGenerate;
  final VoidCallback onRotate;
  final VoidCallback onRevoke;
  final VoidCallback onCopy;
  final VoidCallback onCloseReveal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: switch (state) {
          InviteState.none => _NoneBody(onGenerate: onGenerate),
          InviteState.active => _ActiveBody(
              rotatedAt: rotatedAt!,
              onCopy: onCopy,
              onRotate: onRotate,
              onRevoke: onRevoke,
            ),
          InviteState.justGenerated || InviteState.justRotated =>
            _RevealBody(
              url: revealUrl!,
              isRotated: state == InviteState.justRotated,
              onClose: onCloseReveal,
            ),
        },
      ),
    );
  }
}

class _NoneBody extends StatelessWidget {
  const _NoneBody({required this.onGenerate});
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(MaterialLocalizations.of(context).viewLicensesButtonLabel /* placeholder */),
        const SizedBox(height: 12),
        FilledButton(onPressed: onGenerate, child: const Text('Generate invite link')),
      ],
    );
  }
}

class _ActiveBody extends StatelessWidget {
  const _ActiveBody({
    required this.rotatedAt,
    required this.onCopy,
    required this.onRotate,
    required this.onRevoke,
  });
  final DateTime rotatedAt;
  final VoidCallback onCopy;
  final VoidCallback onRotate;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Active since ${rotatedAt.toIso8601String()}'),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          FilledButton(onPressed: onCopy, child: const Text('Copy link')),
          OutlinedButton(onPressed: onRotate, child: const Text('Rotate')),
          TextButton(onPressed: onRevoke, child: const Text('Revoke')),
        ]),
      ],
    );
  }
}

class _RevealBody extends StatelessWidget {
  const _RevealBody({required this.url, required this.isRotated, required this.onClose});
  final String url;
  final bool isRotated;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isRotated ? 'Link rotated' : 'Your new invite link',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SelectableText(url, style: const TextStyle(fontFamily: 'monospace')),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: url));
          },
          child: const Text('Copy'),
        ),
        const SizedBox(height: 8),
        const Text("This URL appears once. If you lose it, rotate the invite to generate a new one.",
            style: TextStyle(fontStyle: FontStyle.italic)),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(onPressed: onClose, child: const Text("I've copied it — close")),
        ),
      ],
    );
  }
}
```

(I18n strings stay hard-coded for this Stream A skeleton — Stream B integrates `AppLocalizations.invite*`. The mobile invite UX is the GM's, who today reads English in most playtests.)

- [ ] **Step 3: Widget test**

`invite_manager_test.dart`:

```dart
import 'package:coriolis_companion/features/game_sessions/presentation/widgets/invite_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders Generate CTA in none state', (tester) async {
    var generated = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InviteManagerWidget(
          state: InviteState.none,
          rotatedAt: null,
          revealUrl: null,
          onGenerate: () => generated = true,
          onRotate: () {}, onRevoke: () {}, onCopy: () {}, onCloseReveal: () {},
        ),
      ),
    ));
    expect(find.text('Generate invite link'), findsOneWidget);
    await tester.tap(find.text('Generate invite link'));
    expect(generated, isTrue);
  });

  testWidgets('renders active state actions', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InviteManagerWidget(
          state: InviteState.active,
          rotatedAt: DateTime.utc(2026, 5, 15, 10, 0),
          revealUrl: null,
          onGenerate: () {}, onRotate: () {}, onRevoke: () {}, onCopy: () {}, onCloseReveal: () {},
        ),
      ),
    ));
    expect(find.text('Copy link'), findsOneWidget);
    expect(find.text('Rotate'), findsOneWidget);
    expect(find.text('Revoke'), findsOneWidget);
  });

  testWidgets('reveal body shows the URL and close button', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InviteManagerWidget(
          state: InviteState.justGenerated,
          rotatedAt: null,
          revealUrl: 'https://app/join/X',
          onGenerate: () {}, onRotate: () {}, onRevoke: () {}, onCopy: () {}, onCloseReveal: () {},
        ),
      ),
    ));
    expect(find.text('Your new invite link'), findsOneWidget);
    expect(find.text('https://app/join/X'), findsOneWidget);
    expect(find.text("I've copied it — close"), findsOneWidget);
  });
}
```

- [ ] **Step 4: Run mobile tests**

```bash
cd apps/mobile && flutter test test/features/game_sessions/presentation/widgets/invite_manager_test.dart
```

Expected: 3 passing.

- [ ] **Step 5: Mount on the GM session detail page**

Open the GM session-detail page under `apps/mobile/lib/features/game_sessions/presentation/`, add a tile that uses `InviteManagerWidget`, wired to the repo methods from Step 1. Add cubit state for the local `InviteState` machine matching the web version (transitions on `generate`, `revoke`, `closeReveal`).

- [ ] **Step 6: flutter analyze**

```bash
cd apps/mobile && flutter analyze lib
```

Expected: 0 issues.

- [ ] **Step 7: Commit**

```bash
git add apps/mobile/lib/features/game_sessions apps/mobile/test/features/game_sessions
git commit -m "feat(mobile): InviteManager widget + sessions-repo rotate/revoke/metadata

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

## Task 28: Mobile dashboard segmented control

**Files:**

- Modify: `apps/mobile/lib/features/dashboard/presentation/dashboard_page.dart`

- [ ] **Step 1: Add a SegmentedButton above the sessions list**

```dart
enum DashboardSessionsScope { running, playing }

class _SessionsScopeControl extends StatefulWidget {
  // ...
  @override
  State<_SessionsScopeControl> createState() => _SessionsScopeControlState();
}

class _SessionsScopeControlState extends State<_SessionsScopeControl> {
  DashboardSessionsScope _scope = DashboardSessionsScope.running;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DashboardSessionsScope>(
      segments: const [
        ButtonSegment(value: DashboardSessionsScope.running, label: Text('Running')),
        ButtonSegment(value: DashboardSessionsScope.playing, label: Text('Playing in (0)')),
      ],
      selected: { _scope },
      onSelectionChanged: (s) => setState(() => _scope = s.first),
    );
  }
}
```

Render in the existing Sessions section of `dashboard_page.dart`. The "Playing in" segment count stays at 0 until Stream B.

- [ ] **Step 2: flutter analyze + flutter test**

```bash
cd apps/mobile && flutter analyze lib && flutter test
```

Expected: clean + green.

- [ ] **Step 3: Commit**

```bash
git add apps/mobile/lib/features/dashboard
git commit -m "feat(mobile): dashboard Running | Playing in segmented control (Stream A)

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

# Phase P14 — Precheck + handoff

## Task 29: Repo-wide precheck

**Files:** none modified.

- [ ] **Step 1: Spec validate + bundle + codegen — no drift**

```bash
pnpm spec:validate
pnpm spec:bundle
pnpm spec:codegen
git status --short
```

Expected: no changes after codegen. If there is a diff, commit it as `chore(codegen): regenerate after late spec touch-up`.

- [ ] **Step 2: Backend tests + typecheck + lint**

```bash
pnpm --filter @app/backend test -- --reporter=dot
pnpm --filter @app/backend typecheck
pnpm --filter @app/backend lint
```

Expected: all green.

- [ ] **Step 3: UI tests + Storybook a11y**

```bash
pnpm --filter @app/ui test -- --reporter=dot
pnpm --filter @app/ui storybook --ci --quiet &
sleep 5
# manually verify a11y panel green on Phase 8 stories
```

Expected: zero violations on each new story.

- [ ] **Step 4: Web tests + typecheck + lint + i18n parity**

```bash
pnpm --filter @app/web test -- --reporter=dot
pnpm --filter @app/web typecheck
pnpm --filter @app/web lint
pnpm check:i18n
```

Expected: all green.

- [ ] **Step 5: Mobile analyze + test**

```bash
cd apps/mobile && flutter analyze lib && flutter test
cd ../..
```

Expected: 0 issues + all tests pass.

- [ ] **Step 6: design:audit + stylelint**

```bash
pnpm design:audit
pnpm stylelint:check
```

Expected: clean.

- [ ] **Step 7: Final lint pass + format**

```bash
turbo run lint typecheck
pnpm format
```

Expected: no diffs.

- [ ] **Step 8: Push and open PR**

```bash
git push -u origin HEAD
gh pr create --title "Phase 8 Stream A — foundation (route move, memberships, invite endpoints, AppInviteManager)" --body "$(cat <<'EOF'
## Summary
- Renames the GM client routes `/app/sessions/*` → `/app/game-sessions/*` (web + mobile) with a 301 middleware for back-compat.
- Adds `GameSessionMembership` table + invite fields on `GameSession`; backfills a GM-role membership for every pre-existing session.
- Spec + backend: 6 new endpoints under `/api/v1/game-sessions/{id}` (invite metadata / rotate / revoke + member list / link character / kick-leave).
- `MembershipsModule` (CQRS): 5 commands, 2 queries, 4 events, Prisma-backed repo, character-ownership adapter.
- `GameSession` response now includes `memberships[]` alongside the (deprecated) `characterIds` (cleanup in Stream E).
- `@app/ui` ships `AppSessionShareLinkCard` + `AppInviteManager` per handoff JSX, with the invite reveal as a `role="alertdialog"` modal (no auto-dismiss).
- Dashboard `Running | Playing in` segmented control (web + mobile). "Playing in" count stays 0 until Stream B.

## Out of scope (in this PR)
- Player join flow & `/me/memberships` (Stream B).
- Realtime ACL widening to non-owner members (Stream B).
- Chat surfaces (Streams C+D).
- `GameSession.characterIds` cleanup (Stream E).

## Test plan
- [ ] Backend Vitest + typecheck + lint
- [ ] UI Vitest + Storybook a11y on `AppInviteManager` four states + `AppSessionShareLinkCard` three states
- [ ] Web Vitest + i18n parity
- [ ] Mobile `flutter analyze lib` + `flutter test`
- [ ] Manual: GM session detail → Generate / Rotate / Revoke happy path
- [ ] Manual: visit `/app/sessions` while signed in → redirects to `/app/game-sessions`

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Report the PR URL.

- [ ] **Step 9: Move active.md entry to done.md when the PR merges**

When merged, edit `specs/tasks/active.md` to remove the `T-2026-05-15-PHASE-8-STREAM-A` block, prepend it to `specs/tasks/done.md` with `- Completed: <date>` and `- Result: <PR URL>` lines, commit with `chore(tasks): archive Phase 8 Stream A → done.md`.

---

# Self-review

After authoring this plan, run a fresh-eyes pass:

**Spec coverage** — every sub-step in `specs/tasks/active.md` T-2026-05-15-PHASE-8-STREAM-A maps to a task here:

- `T-11.1.0.a` (web route move) → Task 1
- `T-11.1.0.b` (mobile route move) → Task 2
- `T-11.1.0.c` (AGENTS.md) → Task 3
- `T-11.1.1.a` (OpenAPI routes) → Task 4
- `T-11.1.1.f` (Prisma migration + backfill) → Tasks 5–6
- `T-11.1.1.d` (nanoid + SHA-256) → Task 9
- `T-11.1.1.b` (MembershipsModule CQRS) → Tasks 7–20
- `T-11.1.1.c` (GameSession.memberships in response) → Task 21
- `T-11.1.1.g` (AppInviteManager) → Tasks 23–25
- `T-11.1.1.g.2` (AppSessionShareLinkCard) → Task 23
- `T-11.1.1.j` partial (Kick action) → covered via the controller in Task 19; UI surface is Stream B (members list page) — flag explicitly: **deferred**.
- `T-11.1.2` (Dashboard segmented control) → Tasks 26 + 28
- `T-11.1.1.m` tests → embedded in every TDD task

**Placeholder scan** — none in this plan. (Step 7 of Task 22 explicitly says "no commit"; that is verification, not placeholder.)

**Type consistency** — `MembershipReadModel`, `InviteMetadataReadModel`, `IMembershipRepo`, `IGameSessionInviteRepo`, `RotateInviteResult`, `MembershipRole`, `ICharacterOwnership`, `CHARACTER_OWNERSHIP`, `MEMBERSHIP_REPO`, `GAME_SESSION_INVITE_REPO` are defined once (in Task 8 / Task 11 / Task 15) and consumed consistently across all later tasks.

**Scope check** — single landable Stream A PR per the design doc §6. No accidental Stream B (player join, ACL widening, /me/memberships) work crept in.

---

# Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-15-phase-8-stream-a.md`. Two execution options:

1. **Subagent-Driven (recommended)** — fresh subagent per task, review between tasks, fast iteration.
2. **Inline Execution** — execute in this session via `superpowers:executing-plans`, batch execution with checkpoints.

Which approach?
