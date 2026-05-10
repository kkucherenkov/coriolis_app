# Phase 5 — Ships

**Phase:** 5
**Tag:** `phase-5-complete`
**PRD section:** §11 (roadmap)
**Date:** 2026-05-10

## What shipped

A player can now build a ship from any of the twenty ST3001 hulls,
fit modules with discriminator-aware data (weapon ranges, torpedo
counts, hold tonnage, sensor bonus), assign their characters across
the six standard crew positions, and duplicate the whole assembly
into a fresh "(copy)" without disturbing the original. Phase 4 left
the dice loop and the GM-side game session container running on
top of the character sheet; Phase 5 wires the missing fleet half —
backend ShipsModule (Prisma migration, CRUD, modules sub-resource,
crew assignment, duplicate) and the web ship list + sheet + module
editor + crew widget that consume it. Roughly twenty commits across
backend, web, and bookkeeping. No spec changes — the OpenAPI ship
surface had been carrying the contract since the Phase-1 sweep.

A player can:

- Create a ship via `POST /api/v1/ships` — server seeds hull /
  energy / armor / maneuverability / signature / speed / cargo
  from `BASE_STATS_BY_CLASS` keyed off the chosen `ship_class`,
  auto-creates the three mandatory modules (BRIDGE, REACTOR,
  DRIVE), and inserts six vacant `crew_slot` rows.
- List their ships at `GET /api/v1/ships` (cursor pagination,
  default limit 20) and edit any owned ship via `PATCH
  /api/v1/ships/{id}` — name, registry, model, the full stat
  block, problems array, history, notes.
- Add or remove modules via `POST /api/v1/ships/{id}/modules` /
  `PATCH /api/v1/ship-modules/{id}` / `DELETE /api/v1/ship-modules/
  {id}` — with discriminator-aware validation per slot and a 422
  `SHIP_MODULE_MANDATORY` guard against deleting BRIDGE / REACTOR
  / DRIVE.
- Assign a character to one of six positions via `POST /api/v1/
  ships/{id}/crew` (captain, pilot, sensorOp, gunner, engineer,
  serviceCrew) and unassign via `DELETE …/crew/{characterId}`.
  Re-assigning a character already serving on the same ship moves
  them between positions; only `CREW_POSITION_TAKEN` (400) fires
  when the destination is held by someone else.
- Duplicate a ship via `POST /api/v1/ships/{id}/duplicate` — deep
  copy of ship + modules in one Prisma transaction with `(copy)`
  / `(copy 2)` / `(copy 3)` name escalation via
  `listNamesByPrefix`; crew roster resets to vacant.

On the web client a player can:

- Open `/app/ships` to see their fleet as a card grid (hull /
  energy stats, module + crew badges, per-card Open / Duplicate /
  Delete with `AppModal` confirm), reach an inline create form
  with the full twenty-class picker, and land an empty-state
  "Build your fleet" prompt when the list is empty.
- Open `/app/ships/[id]` to edit the sheet — header (name h1 +
  class chip + Duplicate + Delete + Export + `AppSavePulse`),
  identity card with 600 ms `useAutoSave` debounce, full stat
  block with hull/energy steppers, modules grouped by mandatory
  vs optional, the editable crew widget, plus collapsible notes
  / history / problems cards.
- Open the discriminator-aware `ShipModuleEditor` modal in create
  / edit / confirm-delete modes — slot picker with the three
  mandatory slots filtered out in create mode, slot frozen in
  edit, branch-specific fields per discriminator (WEAPON: bonus /
  range / damage / crit; TORPEDO: torpedo + mine counts; HOLD:
  cargoTons + concealed switch; SENSOR: detectionBonus; base-only
  for the rest).
- Assign / move / unassign crew via the inline `<select>` widget
  with two `<optgroup>`s splitting "Available" from "Already on
  this ship (will move)" so the move semantics is visible before
  commit.
- Click Export — currently a thin `target="_blank"` link to the
  501 stub with an `(experimental)` chip — and click Duplicate to
  get a `?duplicatedFrom=<name>` query-param toast on the next
  index render that clears via `router.replace` so a refresh
  doesn't re-fire it.

## What landed (by feature group)

### Phase 5 backend — ShipsModule (T-2026-05-10-004)

The five-block backend pass: storage, core CRUD, the module
sub-resource on its own controller, crew assignment with move
semantics, and the duplicate handler. The OpenAPI ship surface
predated the work; no spec edits and no codegen pass needed.

- `f0b8a7f` — feat(backend): Block 1 — Prisma migration for Ships
- `9d71a3d` — chore(tasks): Block 1 done — start Block 2
- `400b186` — feat(backend): Block 2 — ShipsModule core CRUD
- `2f2f7fb` — chore(tasks): Block 2 done — start Block 3
- `1d06bcc` — feat(backend): Block 3 — ship module sub-resource
- `0e4a01c` — feat(backend): Block 4 — crew assignment endpoints
- `0197d12` — chore(tasks): Block 4 done — start Block 5
- `1ba07ee` — feat(backend): Block 5 — duplicate ship + export stub
- `159eb13` — chore(tasks): Block 5 done — task ready to archive
- `500830f` — chore(tasks): archive T-004; push T-005 (Phase 5 web)

Test count climbed 434 → 511 (+77 specs across the five blocks).
Lint clean at every block boundary.

### Phase 5 web — ship list + sheet + module editor + crew (T-2026-05-10-005)

The five-block web pass: composables + index page; sheet with
auto-save and full stat block; discriminator-aware module editor;
editable crew card; polish (delete confirm, duplicate toast,
export affordance, empty-state copy).

- `40483a0` — feat(web): Block 1 — useShipsApi + /app/ships index page
- `3c484fa` — chore(tasks): Block 1 done — start Block 2
- `dbf0351` — feat(web): Block 2 — ship sheet with scalar PATCH editing
- `471ea9a` — chore(tasks): Block 2 done — start Block 3
- `3472047` — feat(web): Block 3 — discriminator-aware module editor
- `22fb590` — chore(tasks): Block 3 done — start Block 4
- `e065118` — feat(web): Block 4 — crew assignment widget on the ship sheet
- `9adf1a8` — chore(tasks): Block 4 done — start Block 5
- `c8f6d11` — feat(web): Block 5 — polish (delete confirm, duplicate toast, export, empty state)
- `e616a05` — chore(tasks): Block 5 done — task ready to archive
- `39595f8` — chore(tasks): archive T-005; push T-006 (Phase 6 spec)

Web test count climbed 53 → 143 (+90 vitest cases). typecheck and
lint clean at every block boundary.

## Notable decisions

- **Three storage tables, not one.** `ship` carries the flat stat
  columns and the owner-cascade FK; `ship_module` is a one-to-many
  with the discriminated subtype payload going into a `data: Json`
  column (mirroring the `Item` table's pattern from earlier phases)
  and the common fields (slot, name, energyUse) promoted to columns
  so list / filter queries don't have to crack JSON; `crew_slot`
  has a composite primary key on `(shipId, position)` with `ON
  DELETE SET NULL` on the character FK, so a deleted PC vacates
  the position rather than dropping the slot row. Six rows per
  ship, the slot enum is the source of truth on which positions
  exist. (`f0b8a7f`.)
- **Module sub-resource on its own controller, not nested.** The
  OpenAPI spec splits `addShipModule` (`POST /ships/{id}/modules`)
  from `updateShipModule` / `deleteShipModule` (`PATCH` / `DELETE
  /ship-modules/{id}`). Block 3 followed that split — the create
  endpoint sits on `ShipsController`, the edit and delete endpoints
  on a second `ShipModulesController`. Same NestJS module, same
  CQRS handlers, two surfaces. Side effect: the read path doesn't
  need a `shipId` lookup for module updates because the module's
  primary key is sufficient. (`1d06bcc`.)
- **Crew assignment uses move semantics, not 422 conflict.** The
  task entry originally floated `CREW_ALREADY_ASSIGNED` 422 when a
  character was already serving elsewhere on the same ship; the
  shipped behaviour instead **moves** them between positions
  (idempotent, single Prisma `update`). The only error is
  `CREW_POSITION_TAKEN` (400) — and only when the **destination**
  slot is held by a **different** character. Same-position
  re-assign is a no-op. The web `<optgroup>` picker surfaces the
  move semantics before commit so the player sees what the
  backend will do. (`0e4a01c`, `e065118`.)
- **Duplicate is a deep copy in one transaction; export is a 501
  stub.** `DuplicateShipHandler` resolves the next `(copy N)`
  suffix via `listNamesByPrefix` (no race-window guard — last
  writer wins on the suffix counter, acceptable for a personal
  fleet), then deep-copies ship + modules inside a single
  `prisma.$transaction`. Crew roster comes back vacant by design
  — duplicating a ship with its current crew assigned across two
  hulls would violate the position uniqueness invariant. Export
  (`getShipExport`) is left as a 501 stub matching the spec — the
  format itself isn't fully nailed down and the web client links
  to it with an `(experimental)` chip rather than gating the
  affordance. (`1ba07ee`, `c8f6d11`.)
- **Base stats from a class table, not the OpenAPI default
  values.** `BASE_STATS_BY_CLASS` lives in
  `apps/backend/src/rules-engine/ship-class-table.ts` keyed off
  the twenty `ship_class` enum values. Server-side seeding on
  create means the client never has to know hull-by-class — it
  just picks the class. The numbers are pulled from ST3001 ГЛАВА
  7 Table 7.5 with a follow-up TODO to verify exact values
  against the rulebook in a dedicated rules-pass. (`400b186`.)
- **No spec changes; no codegen pass.** The OpenAPI surface for
  Ships had been shipped since `75a6ee8` in Phase 1 — the
  Phase-5 work was purely the missing backend and web
  implementation behind a contract that already existed. Every
  ship-related path before Phase 5 was 404'ing at the
  `express-openapi-validator` layer; the Phase-5 backend is what
  flipped them on.
- **Schema applied via `prisma db push`, migration SQL committed
  for posterity.** The repo doesn't yet baseline
  `_prisma_migrations` — `migrate dev` fails on the
  `20260508000001_character_status` migration's shadow-DB step,
  so the dev DB is reconciled with `db push` and the generated
  migration SQL (`20260510000002_ships/migration.sql`) is
  committed as canonical for future deploy targets. Tracked as a
  Phase-7 hardening item, not a Phase-5 blocker. (`f0b8a7f`.)
- **Auto-save on the sheet uses the same `useAutoSave`
  composable as the character sheet.** 600 ms debounce on blur
  for scalar PATCH (name, registry, hull current, energy current,
  armor, etc); the `AppSavePulse` chip in the header shows
  pending / saving / saved / error states. The crew and module
  editors don't go through auto-save — those are explicit
  commits because they have multi-field forms with discriminator
  branches and their own modal lifecycle. (`dbf0351`.)
- **Discriminator switch in the module editor mirrors the
  Prisma JSON column.** The same five branches that get
  serialised into `ship_module.data` (WEAPON / TORPEDO / HOLD /
  SENSOR / OTHER) are the five branches the editor renders.
  Mandatory-slot Delete is hidden in edit mode for BRIDGE /
  REACTOR / DRIVE; the slot picker in create mode filters them
  out. Same truth table on both sides — the 422
  `SHIP_MODULE_MANDATORY` is defense-in-depth, not the primary
  gate. (`3472047`.)

## Follow-ups

- **Phase 5 mobile (Flutter) parity.** The mobile client got no
  Ships work in this phase — neither a list nor a read-only
  sheet. Deferred to a later phase (read-only sheet at minimum is
  the natural next step once the Phase-6 GM tools settle). The
  generated Dart SDK already carries the typed Ship shapes from
  Phase 1.
- **Ship sharing — share-link surface.** PRD §11 Phase 5 reads
  "Ship sheets, crew assignment, ship **sharing**". The first
  two shipped; share-link parity with characters (the `share-
  link-design` ADR) did not. The contract pieces exist generally
  for `Character` but no `ship.share-link` route exists yet on
  spec, backend, or web. Carried into a follow-on task.
- **`getShipExport` real implementation.** Currently 501.
  Format is sketched in the spec but not nailed down — likely
  JSON for v1 with a PDF / printable second pass. Web links to
  the stub with an `(experimental)` chip so the affordance is
  visible.
- **`cargoCapacity` recalculation when HOLD modules are
  added / removed.** The OpenAPI says "Total cargo capacity in
  tonnes across all hold modules" but Block 2 leaves it
  client-driven — the server stores the explicit value seeded
  from the class table. A `cargoCapacity` derived-stat
  recompute on every `addShipModule` / `updateShipModule` /
  `deleteShipModule` is the correct shape but it's coupled to
  whatever the rules-engine ends up doing with HOLD module
  totals.
- **`_prisma_migrations` baselining.** Same Phase-7 hardening
  item as the rest of the migrations — until the
  `character_status` migration's shadow-DB step is fixed,
  `migrate deploy` isn't the canonical apply path.
- **Pre-existing px-dimension stylelint violations in
  Blocks 1–4.** Carried as a separate cleanup task — the
  existing CSS uses `max-width: 960px` / `min-width: 480px` /
  similar literal pixels that violate the design-token rule.
  Not a Phase-5 regression; the violations were inherited from
  earlier phases.
- **ST3001 ГЛАВА 7 base-stat verification.** The
  `BASE_STATS_BY_CLASS` table needs a rules-pass against the
  rulebook (Table 7.5) to confirm the exact hull / energy /
  armor / maneuverability / signature / speed / cargo numbers
  per hull class. The shape is right; the constants are pending
  proof.
- **uk + el ship translations.** Block 4 added en + ru for the
  crew widget and shipped uk / el placeholders. Same status as
  the rest of the wizard — carried.
- **Storybook visual regression.** Still TODO; carried since
  Phase 1.
- **8 Flutter primitives.** Still pending the per-widget
  Material/Cupertino evaluation pass; carried since Phase 1.
- **Web `pnpm typecheck` local breakage.** macOS `oxc-parser`
  binding bug; CI under Linux remains the source of truth.
  Carried.
- **Phase 6 entry point.** GM Tools — combat tracker (desktop-
  shaped; mobile read-along card), NPC library, GM session
  view, realtime combatant updates. Per PRD §11 Phase 6.
  Greenfield: neither the OpenAPI nor AsyncAPI carries any
  encounter / combatant / NPC shape today (the AsyncAPI even
  has a "stubbed — they land in Epic 9" comment on the session
  channel). T-006 in `active.md` opens the Phase-6 spec pass
  with five sub-blocks (NPC resource, Encounter resource,
  Combatant sub-resource, initiative + turn-order ops,
  AsyncAPI `combat.updated` extension), each ending with a
  codegen pass.

## Local merge ledger

Roughly twenty commits across the `dbc22c9..39595f8` range,
landed under the same push-per-block cadence (see
`feedback_block_workflow.md` in auto-memory). Most recent first;
the per-feature task entries with judgement-call notes live in
`specs/tasks/done.md`.

- `39595f8` — archive T-005; push T-006 (Phase 6 spec)
- `e616a05` + `c8f6d11` + `9adf1a8` + `e065118` + `22fb590`
  + `3472047` + `471ea9a` + `dbf0351` + `3c484fa` + `40483a0` —
  T-005 web ship list + sheet + module editor + crew + polish
- `500830f` — archive T-004; push T-005 (Phase 5 web)
- `159eb13` + `1ba07ee` + `0197d12` + `0e4a01c` + `1d06bcc`
  + `2f2f7fb` + `400b186` + `9d71a3d` + `f0b8a7f` —
  T-004 backend Prisma migration + ShipsModule CRUD + modules
  sub-resource + crew assignment + duplicate + export stub
