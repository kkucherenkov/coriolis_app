# Active tasks

## T-2026-05-08-011 — Implement CharactersModule backend (Story 3.2.1)

- Created: 2026-05-08
- Owner: claude
- Spec: [docs/IMPLEMENTATION_PLAN.md Feature 3.2 Story 3.2.1](../../docs/IMPLEMENTATION_PLAN.md)
- Goal: Stand up the full NestJS CharactersModule with CQRS commands, queries, ownership guards, nested ItemsModule and TalentsModule, and Prisma schema for Coriolis domain models so the `/api/v1/characters` contract is satisfied end-to-end.
- Acceptance:
  - POST /api/v1/characters creates a character owned by the authenticated user and returns the Character DTO with derived stats
  - GET /api/v1/characters returns a paginated, owner-scoped list
  - GET/PATCH/DELETE /api/v1/characters/:id works for the owner; non-owner gets 403
  - POST /api/v1/characters/:id/duplicate creates a copy named "<original> (copy)" with zeroed experience
  - GET /api/v1/characters/:id/export returns the same Character DTO
  - POST /api/v1/characters/:id/items, PATCH /api/v1/items/:id, DELETE /api/v1/items/:id manage inventory
  - POST /api/v1/characters/:id/talents, PATCH /api/v1/talents/:id, DELETE /api/v1/talents/:id manage talents
  - All errors are RFC 9457 application/problem+json
- Sub-steps:
  - [x] Push task to active.md
  - [x] Create branch feat/phase-1/characters-module
  - [x] Add Prisma domain models (Character, Item, Talent, Relationship, CriticalInjury)
  - [x] Implement CharactersModule (domain, commands, queries, events, infra, controller)
  - [x] Implement nested ItemsModule and TalentsModule
  - [x] Write vitest handler specs (105 tests, 20 files, all green)
  - [x] Register CharactersModule in app.module.ts
  - [x] Run typecheck and tests
- Status: in-progress
- Blockers: —
- Notes: derived stats (hp.max/mp.max/encumbrance.max) returned as placeholders 14/10/5 with TODO(rules-engine, T-3.2.2) comments. Encumbrance current = 0 placeholder pending rules-engine. Item.data is a JSON column for the discriminated union.

## T-2026-05-08-013 — Implement AppChip Coriolis primitive

- Created: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md §Epic 2.1.c
- Sub-steps: complete (28 specs, 14 stories, typecheck/test/stylelint green)
- Status: in-progress
- Blockers: —

## T-2026-05-08-014 — Build AppProgress Coriolis primitive

- Created: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.f
- Sub-steps: complete (linear variant only; circular deferred)
- Status: in-progress
- Blockers: —

## T-2026-05-08-012 — AppSwitch Coriolis primitive

- Created: 2026-05-08
- Owner: claude
- Epic: 2.1.e
- Sub-steps: complete
- Status: in-progress
- Blockers: —
