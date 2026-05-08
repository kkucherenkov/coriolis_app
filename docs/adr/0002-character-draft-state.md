# 0002 — Character draft state via status flag

- **Status:** accepted
- **Date:** 2026-05-08
- **Deciders:** @kirill, @claude
- **Tags:** backend, characters, wizard, epic-5

## Context

Epic 5 (Feature 5.6) introduces a multi-step character-creation wizard. The wizard
allows players to fill in character data incrementally across multiple sessions before
committing to a final character. This creates a need to persist partial character state
server-side — "work in progress" characters that are not yet ready to appear on the
dashboard.

Two implementation shapes were considered:

- **Option A** — Separate resource: `POST /api/v1/characters/draft` creates a distinct
  Draft resource with its own endpoints, quota logic, and eventual promotion endpoint
  that copies data into a real Character row.
- **Option B** — Status flag on the existing Character: a `status: 'draft' | 'active'`
  field on the existing `Character` table distinguishes wizard-in-progress characters
  from completed ones.
- **Option C** — Client-side only: store wizard state in localStorage; only POST to
  `/api/v1/characters` on the final step.

## Decision

**Option B — single `Character` resource with a `status` flag.**

The `Character` table gains a `status CharacterStatus @default(ACTIVE)` column backed
by a `CharacterStatus` enum (`ACTIVE`, `DRAFT`). The OpenAPI wire type adds a
`status: 'draft' | 'active'` property to `Character`, `CharacterCreate`, and
`CharacterUpdate`. The list endpoint defaults to returning only `active` characters
unless the caller passes `?includeDrafts=true`.

### Rationale

1. **No data shape divergence.** The wizard's wire shape is identical to a finished
   character's shape. Every step of the wizard is already a valid (possibly incomplete)
   character — just one the user hasn't published yet. A separate Draft model would
   either duplicate all Character fields or introduce a complex projection step.

2. **Incremental saves are already free.** `PATCH /api/v1/characters/{id}` with partial
   data is the correct mechanism for step-by-step wizard persistence. No new route is
   needed; the wizard just sets `status: 'draft'` on create and patches it forward.

3. **Forging is a single PATCH.** Transitioning a draft to an active character is
   `PATCH /api/v1/characters/{id}` with `{ "status": "active" }`. No data movement,
   no second resource to own, no race condition between a "promote" endpoint and
   concurrent PATCH requests.

4. **Dashboard isolation is a query filter.** `GET /api/v1/characters` already
   returns a filtered list. Adding `WHERE status = 'ACTIVE'` by default keeps the
   dashboard clean with zero client-side changes; the wizard can opt in with
   `?includeDrafts=true` to show the user their in-progress characters separately.

5. **Cleanup is trivial.** Abandoned drafts are purged by a single cron query:
   `DELETE FROM character WHERE status = 'DRAFT' AND updated_at < now() - 30 days`.
   No per-resource quota plumbing, no saga, no orphan detection across tables.

6. **Quota and ownership semantics are unchanged.** Drafts belong to the same owner,
   are protected by the same `CharacterOwnershipGuard`, and count against the same
   Prisma index (`@@index([ownerId])`).

## Consequences

### Positive

- Zero new routes, controllers, or module files for the wizard persistence path.
- Existing `express-openapi-validator` coverage protects the new `status` field
  automatically once the spec is updated.
- The `findActiveById` method in `ICharacterRepo` is renamed / supplemented to
  `findById` (status-agnostic) for the get/update path, while the list path uses
  the `includeDrafts` flag to scope the query. This keeps the separation clean.
- A single cron job (`CleanupAbandonedDraftsJob`) handles garbage collection.

### Negative

- `GET /api/v1/characters/{id}` returns both drafts and actives to the owner
  (because `PATCH` must be able to find the draft to update it). If a future
  requirement arises to hide drafts from a GET by ID, a separate check must be
  added.
- The `active → draft` transition is deliberately rejected (HTTP 422,
  `INVALID_STATUS_TRANSITION`). This prevents accidental demotion of live characters.
  If a future need arises, it must go through an ADR update.
- Drafts that are never forged accumulate until the nightly cron runs. The 30-day
  window is generous; a user could theoretically exhaust the display by creating
  many drafts, but this is a product-level risk to be addressed with a per-user
  draft quota later.

### Neutral

- The Prisma enum is uppercase (`ACTIVE`, `DRAFT`) while the OpenAPI/wire enum is
  lowercase (`active`, `draft`). Mapping happens at the repo boundary, consistent
  with the existing `IconId` pattern.
- The `CharacterList` schema continues to use `Character` items. The `status`
  field is now present on every list item (useful for the wizard UI to distinguish
  draft rows from live rows in a combined `?includeDrafts=true` view).

## Alternatives considered

### Option A — Separate `/api/v1/characters/draft` resource

A distinct `Draft` resource would allow different validation rules for incomplete
characters (e.g., `name` optional during wizard steps). **Rejected** because:

- The wizard's final shape must conform to the Character schema anyway — the
  validation relaxation can be handled by the existing nullable/optional fields
  already in `CharacterCreate`.
- Two resources means two owners, two quota tables, two sets of guards, and a
  promote endpoint that creates a data-movement operation. All of this complexity
  is load-bearing: it cannot be removed without another migration later.
- REST semantics suffer: `/characters/draft/{id}` and `/characters/{id}` refer to
  the same conceptual entity at different lifecycle stages. Clients must track
  which base URL to use.

### Option C — Client-side localStorage only

Store wizard state exclusively in the browser (or Flutter SharedPreferences).
**Rejected** because:

- Cross-device continuity is impossible: starting a wizard on mobile and finishing
  on web requires server persistence.
- The PRD explicitly calls for server-side persistence of wizard state (Epic 5,
  Feature 5.6). Implementing this in localStorage violates the product requirement.
- Recovery after a crash or accidental tab close requires re-entering all data.

## Related

- [`docs/IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md) Epic 5 — Feature 5.6
  (character creation wizard).
- `packages/specs/openapi/openapi.yaml` — `Character`, `CharacterCreate`,
  `CharacterUpdate` schemas; `GET /api/v1/characters` `includeDrafts` parameter.
- `apps/backend/src/modules/characters/domain/character.errors.ts` —
  `InvalidStatusTransitionError`.
- `apps/backend/src/modules/characters/jobs/cleanup-abandoned-drafts.job.ts` —
  30-day draft GC cron.
- `apps/backend/prisma/schema.prisma` — `CharacterStatus` enum, `Character.status`
  column.
