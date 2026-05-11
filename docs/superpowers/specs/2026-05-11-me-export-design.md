# JSON export — `GET /api/v1/me/export`

**Status:** Design — approved 2026-05-11 (brainstorm), pending user review of this written spec.
**Phase:** 7 — Hardening (entry-point block).
**PRD link:** §9 endpoint list, §11 Phase 7 scope, §6 NFR "Data export".
**Plan link:** `docs/IMPLEMENTATION_PLAN.md` EPIC 10, Feature 10.3.

---

## Goal

Give every authenticated user a single-click way to download their own
data — characters, ships, game sessions, and the children those tables
own — as a versioned JSON file. Satisfies PRD §6 ("Data export") and
GDPR portability without taking on any re-import surface.

## Scope (PRD-literal)

In the bundle:

- **Characters** the user owns, with their nested `items`, `statusFlags`,
  `talents`.
- **Ships** the user owns, with their nested `modules` and `crew`.
- **Game sessions** the user is GM of, with their nested `npcs` (and
  each NPC's `weapons` / `armor`), `encounters`, and each encounter's
  `combatants`.

Explicitly **out** of v1 scope (deferred follow-ups, not no-forever):

- Rolls log, push-mechanic records, share-link tokens, user settings
  (HC theme, locale persistence).
- Re-import (`POST /me/import`) — not in PRD.
- `GET /characters/:id/export` (single-character dump — PRD §9 lists it
  but not blocking 10.3). File as a follow-up after this lands.
- Mobile (Flutter) export button — separate task.
- Streamed delivery (revisit only if real-user bundles exceed ~1 MB).
- Compression (`.zip` / `gzip`).

## Bundle envelope

Versioned wrapper. `$schemaVersion` is a string `const: "1"` so a
future re-import path can branch deterministically without reading the
shape.

```jsonc
{
  "$schemaVersion": "1",
  "exportedAt": "2026-05-11T13:42:00Z",
  "user": {
    "id": "ckv9q…",
    "displayName": "Kirill",
    "locale": "ru",
    // email intentionally omitted — see "Open decisions resolved"
  },
  "characters": [
    /* Character + items + statusFlags + talents */
  ],
  "ships": [
    /* Ship + modules + crew */
  ],
  "gameSessions": [
    /* GameSession + npcs[(weapons,armor)] + encounters[combatants] */
  ],
}
```

Nested children are inlined under their parent (no top-level
`items: []` etc.) because the model is owned-by-cascade and a flat
shape would force the consumer to re-join. Top-level arrays match
Prisma `findMany({ include: { … } })` output one-to-one.

## OpenAPI surface

`packages/specs/openapi/openapi.yaml`:

- **Path:** `GET /me/export`
- **Auth:** existing bearer security scheme.
- **Responses:**
  - `200` — `application/json` returning `#/components/schemas/MeExportBundle`.
  - `401` — standard problem+json (existing shared response).
- **No request body, no query params.**

New schemas in `components.schemas`:

- `MeExportBundle` —
  - `$schemaVersion`: `string`, `const: "1"`.
  - `exportedAt`: `string`, `format: date-time`.
  - `user`: `$ref: MeExportUser`.
  - `characters`: `array` of existing `Character` schema (with its
    nested `items` etc. already in the schema).
  - `ships`: `array` of existing `Ship` schema (with nested
    `modules` + `crew`).
  - `gameSessions`: `array` of existing `GameSession` schema (with
    nested `npcs` + `encounters` + `combatants`).
- `MeExportUser` — `{ id, displayName, locale }`. Deliberately **does
  not** include email or any auth-side fields. The file is downloaded
  by the user, but written to disk and potentially shared — keeping
  email out of the dump avoids accidental leakage.

After editing the spec:

```sh
pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen
```

Codegen artefacts land in their own commit per the standing rule.
`express-openapi-validator` enforces the response shape at runtime.

## Backend (`apps/backend`)

Module layout:

```
apps/backend/src/modules/me-export/
  me-export.module.ts
  me-export.controller.ts
  application/
    queries/
      export-me.query.ts
      export-me.handler.ts
  __tests__/
    export-me.handler.spec.ts
    me-export.e2e-spec.ts
```

Wiring:

- `MeExportModule` registers `MeExportController` + `ExportMeHandler`,
  imports the existing CQRS module + `PrismaModule`.
- Mounted from `AppModule` next to `UsersModule`.

`ExportMeHandler`:

- Injects `PrismaService`. Receives `ExportMeQuery({ userId })`.
- Three sequential reads (sequence chosen so the handler reads
  parent-first; not parallelised because the v1 bundle is small and
  serial reads keep the SQL connection pool sane):
  1. `prisma.character.findMany({ where: { userId }, include: { items: true, statusFlags: true, talents: true } })`
  2. `prisma.ship.findMany({ where: { ownerId: userId }, include: { modules: true, crew: true } })`
  3. `prisma.gameSession.findMany({ where: { ownerId: userId }, include: { npcs: { include: { weapons: true, armor: true } }, encounters: { include: { combatants: true } } } })`

  Verified against `apps/backend/prisma/schema.prisma`: `Character`,
  `Ship`, and `GameSession` all use `ownerId` as the user foreign
  key. No renaming needed at the plan stage.

- Also reads `prisma.user.findUniqueOrThrow({ where: { id }, select: { id: true, displayName: true, locale: true } })` for the `user` block.
- Returns the assembled `MeExportBundle` POJO.

`MeExportController`:

- `@Get('/me/export')`, `@UseGuards(JwtAuthGuard)`.
- Pulls `userId` from the request principal (existing pattern — same
  decorator the `UsersModule` uses).
- Dispatches `ExportMeQuery` via `QueryBus`.
- Sets `Content-Disposition: attachment; filename="coriolis-export-<userId>-<YYYY-MM-DD>.json"`
  on the response.
- Returns the bundle; Nest serialises it.

Rate limit: existing global `@nestjs/throttler` defaults already cover
this — export is a rare action. No per-route override for v1.

No Prisma migration. No new tables.

## Web (`apps/web`)

Settings route already exists (`apps/web/app/pages/app/settings.vue` —
landed in T-2026-05-10-018). Add a new "Data" section **between
Appearance and Account** (between viewer-friendly sections and the
danger zone):

- `AppCard` with eyebrow label `t('sectionData')`.
- Inside the card: short help text `t('exportDescription')` ("Download
  a copy of your data — every character, ship, and game session you
  own, as a single JSON file. Keep it somewhere safe.") + an
  `AppButton variant="primary"` labelled `t('exportButton')`
  ("Download a copy of my data"). The button takes a `:loading="exportInProgress"`
  prop following the existing dialog-button pattern in
  `confirmDeleteAccount`.
- State machine matching the existing per-section pattern:
  ```ts
  type ExportState = 'idle' | 'pending' | 'error';
  const exportState = ref<ExportState>('idle');
  const exportError = ref('');
  ```
  No toast helper — the project uses inline `<p role="alert">` for
  errors (see `__theme-error`, `__save-error`). New `&__export-error`
  follows the same SCSS pattern.
- Click handler:
  1. Sets `exportState = 'pending'`.
  2. Calls the new method on the existing `useMeApi()` composable
     (extended to expose `exportMe()` — returns a `Blob` because the
     generated client tag is the same `me`). The composable handles
     `responseType: 'blob'` on the axios call.
  3. Parses the `Content-Disposition` filename via a small helper
     (regex `filename="([^"]+)"`); falls back to `coriolis-export.json`
     if absent.
  4. Creates an object URL, triggers an anchor-tag download, revokes
     the URL.
  5. Resets to `'idle'`. On thrown error, sets `'error'` + populates
     `exportError` from the `Problem` shape.

i18n keys live in the page-local `<i18n lang="json">` block (same
pattern as the existing sections). The project keeps **4-way locale
parity**: `en`, `ru`, `uk`, `el` — `uk` / `el` use the existing
`[uk-todo]` / `[el-todo]` placeholder convention for greenfield copy.
New keys:

- `sectionData`
- `exportDescription`
- `exportButton`
- `exportInProgress` (button loading label)
- `exportError` (default error message)

No new `@app/ui` primitives. No design-token additions. No SCSS
beyond `&__export` + `&__export-help` + `&__export-error` mirroring
the existing `&__theme` cluster.

## Testing

- **Backend unit** — `export-me.handler.spec.ts`:
  - Returns a bundle with the right shape for a seeded user.
  - Strict user isolation: another user's characters / ships /
    sessions don't appear.
  - Empty-account case returns `characters: []`, `ships: []`,
    `gameSessions: []` (not undefined / not 404).
- **Backend e2e** — `me-export.e2e-spec.ts`:
  - `GET /me/export` returns 401 without bearer.
  - With a bearer token: 200, response body validates against
    `MeExportBundle` (via the runtime validator), `Content-Disposition`
    header present and well-formed, `$schemaVersion === "1"`.
- **Web component spec** — settings export-button spec:
  - Renders title + description + button.
  - Click → mocked client called → object-URL created + revoked →
    anchor click invoked with the parsed filename.
  - Error path surfaces the toast.
- **Playwright smoke** — extend the existing role-picker harness with
  one new test:
  - Login → navigate to Settings → click "Download a copy of my data"
    → assert the network response is `200 application/json` with the
    expected `Content-Disposition` header.
  - Do NOT assert the file landed on disk (CI doesn't need a
    filesystem assertion; the network assertion is sufficient).

## Quality gates (per PR)

- `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen` (drift-free).
- `pnpm --filter @app/backend test` (unit + e2e green).
- `pnpm --filter @app/web test` (component spec green).
- `pnpm --filter @app/web playwright:test` (smoke green).
- `pnpm check:i18n` (4-way locale parity: en, ru, uk-todo, el-todo).
- `pnpm design:audit` (no new components, but run anyway).
- Stylelint, ESLint, Prettier clean.

## Risks & open notes

- **Bundle size at scale.** v1 assumption: a normal user's dump is
  under 1 MB. Streaming is deferred. If beta users report large
  characters / many sessions and the buffered response causes
  pressure, the follow-up work is a streamed variant (open question:
  do we keep the same path or version it `v2`?).
- **PII / accidental sharing.** Email is omitted from `MeExportUser`
  for this reason. If the file _is_ shared, it still contains the
  user's display name and character / NPC content, but no
  authentication-side identifier beyond an opaque `id`. Worth a line
  in the settings-page copy ("Keep it somewhere safe") — already
  captured above.
- **Prisma FK names.** The handler section calls out `userId` /
  `ownerId` / `gmId` as placeholder field names. The plan step must
  verify these against `prisma/schema.prisma` before any code lands.

## Open decisions — resolved

| Question                | Resolution                                                                        |
| ----------------------- | --------------------------------------------------------------------------------- |
| Bundle scope            | PRD-literal: characters + ships + game sessions (with cascade children).          |
| Delivery                | Buffered JSON in a single response. Streaming deferred.                           |
| Envelope shape          | Versioned wrapper with `$schemaVersion: "1"`.                                     |
| Mobile parity           | Web-only for this task; mobile follow-up filed separately if needed.              |
| Email in `MeExportUser` | **Omitted.** File is portable + potentially shareable; keep auth identifiers out. |
| Settings copy tone      | Warmer — "Download a copy of your data" rather than the terse "Export my data".   |

## Out of scope — explicit list

- `GET /characters/:id/export`.
- Mobile Flutter export UI.
- Re-import / `POST /me/import`.
- Streamed bundle.
- Compressed bundle.
- Rolls log, push records, share tokens, user settings in the bundle.

## Definition of Done

- OpenAPI spec updated, codegen drift-free.
- Backend module shipped with unit + e2e tests green.
- Web settings page has the working export flow with en + ru copy.
- Playwright smoke green on `main`.
- `specs/tasks/done.md` entry written with PR link.
- No code in `packages/api-client-*/generated/` edited by hand.
