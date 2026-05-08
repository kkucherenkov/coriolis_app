# Active tasks

---

## T-2026-05-08-003 — UsersModule backend (T-4.1.1.b)

**Status:** in-progress
**Branch:** `feat/phase-1/me-endpoint-backend`
**Epic:** 4 — Auth Vertical Extensions
**Feature:** 4.1 — Display name & profile

### Description

Implement `UsersModule` under `apps/backend/src/modules/users/` with CQRS
layout. Adds `displayName` and `deletedAt` to Prisma `User` model, wires
`additionalFields` in Better Auth config, and exposes `GET /api/v1/me` and
`PATCH /api/v1/me` per the OpenAPI spec.

### Checklist

- [x] Push this entry to `active.md`
- [x] Add `displayName` and `deletedAt` to `apps/backend/prisma/schema.prisma`
- [x] Wire `additionalFields` in Better Auth config (`auth.service.ts`)
- [x] Create `apps/backend/src/modules/users/domain/user.ports.ts`
- [x] Create `apps/backend/src/modules/users/domain/user.errors.ts`
- [x] Create `apps/backend/src/modules/users/queries/get-me.query.ts`
- [x] Create `apps/backend/src/modules/users/queries/get-me.handler.ts`
- [x] Create `apps/backend/src/modules/users/commands/update-me.command.ts`
- [x] Create `apps/backend/src/modules/users/commands/update-me.handler.ts`
- [x] Create `apps/backend/src/modules/users/infra/user.repo.ts`
- [x] Create `apps/backend/src/modules/users/users.controller.ts`
- [x] Create `apps/backend/src/modules/users/users.module.ts`
- [x] Register `UsersModule` in `app.module.ts`
- [x] Write handler spec files
- [ ] Run `pnpm --filter @app/backend prisma:generate`
- [ ] Run `pnpm --filter @app/backend typecheck`
- [ ] Run `pnpm --filter @app/backend test`
- [ ] Move entry to `done.md` after PR merges
