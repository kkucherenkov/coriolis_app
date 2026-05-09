---
description: Add a new API endpoint following the spec-first five-step loop
argument-hint: <method> <path> — e.g. POST /api/v1/characters/:id/duplicate
---

Add the endpoint `$ARGUMENTS` following the non-negotiable five-step loop in `AGENTS.md` §4. Do not deviate.

## Step 1 — Spec

Edit `packages/specs/openapi/openapi.yaml`. Add the path with:

- A clear `operationId` (camelCase, verb-led — `duplicateCharacter`, not `charactersIdDuplicate`)
- Request schema (referenced from `components/schemas`, not inlined)
- Response schemas for 200/201, 400 (validation), 401 (auth), 403 (forbidden), 404 (not found) — all errors as RFC 9457 `application/problem+json`
- Required scopes / roles documented
- Tag matching the domain module (`characters`, `ships`, `game-sessions`, …)

## Step 2 — Validate and regenerate

```bash
pnpm spec:validate
pnpm spec:bundle
pnpm spec:codegen
```

If validation fails, fix the YAML — don't skip ahead.

## Step 3 — Backend

Implement under `apps/backend/src/modules/<domain>/`:

- Mutation? `commands/<verb>-<noun>.command.ts` + `commands/<verb>-<noun>.handler.ts`
- Read? `queries/<noun>-by-<key>.query.ts` + `.handler.ts`
- Side effects across modules? Emit a domain event under `events/`
- Controller method dispatches via `CommandBus.execute()` / `QueryBus.execute()` — no business logic in the controller
- Errors thrown as the boilerplate's domain exceptions; the RFC 9457 filter shapes them
- Auth via the `@Roles(...)` decorator + the JWKS-cached JWT guard
- Vitest unit tests for the handler colocated as `*.spec.ts`

## Step 4 — Clients

Web (`apps/web`): add a composable that calls through `@app/api-client-ts`. Never `$fetch` to a hand-written URL.
Mobile (`apps/mobile`): wire through the generated `app_api_client` in the relevant feature's `data/` layer.

## Step 5 — Codegen commit

The regenerated files in `packages/api-client-ts/src/` and `packages/api-client-dart/lib/src/` go in **their own commit**, separate from your hand-written code. Title: `chore(codegen): regenerate clients for <operationId>`.

## Final checks

- `/precheck` green
- `express-openapi-validator` runtime test exercises the new route with a malformed payload and a well-formed one
- `docs/done/<feature>.md` appended with the PR link once merged
