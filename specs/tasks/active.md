## T-2026-05-10-004 — Phase 5 backend: Ships module (CRUD + modules + crew)

- Created: 2026-05-10
- Owner: claude
- Spec: PRD §11 Phase 5 + the OpenAPI 3.1 surface already shipped at
  `packages/specs/openapi/openapi.yaml` (paths `/api/v1/ships*`,
  schemas `Ship`, `ShipCreate`, `ShipUpdate`, `ShipModule`,
  `ShipModuleCreate`, `ShipModuleUpdate`, `CrewSlot`,
  `AssignCrewRequest`, etc). The HTTP surface exists and the dart +
  ts clients are generated; there is **no** backend implementation
  yet (`apps/backend/src/modules/ships` does not exist, no Prisma
  Ship model, no migrations). `express-openapi-validator` rejects
  any caller that hits these paths with a 404.
- Goal: Stand up the backend Ships module so the web (Phase 5
  frontend, separate task) and mobile clients can persist + edit
  fleets. ST3001 ГЛАВА 7 base stats are populated from a class
  table on create; mandatory modules (BRIDGE, REACTOR, DRIVE) are
  auto-created. Owner ACL on every endpoint — no public read
  surface, share-link parity comes later.
- Acceptance:
  - `POST /api/v1/ships` returns 201 with a freshly-minted Ship
    carrying base stats from the class table and the three
    mandatory modules, plus the empty crew roster (six positions).
  - `GET /api/v1/ships` returns the authenticated user's ships
    paginated (cursor + limit, default 20).
  - `GET /api/v1/ships/{id}` / `PATCH /api/v1/ships/{id}` /
    `DELETE /api/v1/ships/{id}` work; non-owner gets 403 / 404.
  - Module sub-resource: `POST /modules`, `PATCH /modules/{id}`,
    `DELETE /modules/{id}` work. Mandatory modules
    (BRIDGE/REACTOR/DRIVE) cannot be deleted — server returns 422
    `SHIP_MODULE_MANDATORY` per the spec.
  - Crew assignment: `POST /crew` assigns a character to a
    position; only the ship owner may assign and the character
    must be owned by the same user. `DELETE /crew/{characterId}`
    unassigns. Returns the updated Ship.
  - `POST /api/v1/ships/{id}/duplicate` returns a fresh Ship with
    "(copy)" appended to the name and identical modules + stats
    (crew roster reset to empty).
  - `GET /api/v1/ships/{id}/export` returns 501 stub (full export
    is its own task — keeps the surface complete so frontends can
    render the affordance behind a feature flag).
- Spec diff: none expected — the OpenAPI surface is already at
  v0.12.0 and stable. Any wire-shape gap surfaced during wiring
  gets a spec-first fix in its own commit.
- Codegen impact: none expected.
- Design impact: none (backend only).
- Tests: per-block unit specs covering each command/query handler
  (RFC 9457 errors, ACL, mandatory-module guard). Each block adds
  enough specs to keep the new module's coverage ≥ 80% (consistent
  with the rest of the backend).
- Sub-blocks (one commit + push + active.md follow-up per block):
  - [x] Block 1 — Prisma migration `20260510000002_ships`. Three
        tables (ship / ship_module / crew_slot), three enums
        (ship_class / ship_module_slot / crew_position).
        ShipModule subtype payload lives in `data: Json` mirroring
        the Item table. Schema applied via `db push` (the project
        doesn't use `_prisma_migrations` yet); migration SQL
        committed as the canonical artefact. 434/434 backend tests
        pass.
  - [x] Block 2 — `ShipsModule` core CRUD: list / get / create /
        update / delete commands and queries, controller mounting
        `/api/v1/ships*`. Class-table seed for ST3001 base stats
        (lives in `rules-engine` so the data is reusable from the
        web class picker later). Cursor pagination on list.
        Commit `400b186`. All five CRUD commands + two 501 stubs
        (duplicate, export), SessionGuard-protected controller,
        ShipRepo using single `include: { modules, crew }` query,
        ship-class-table with all 20 classes. Ran `prisma generate`
        to pick up Block 1 schema. 463/463 tests pass (+29 new
        specs); lint clean. Next: Block 3 — module sub-resource.
  - [x] Block 3 — Module sub-resource: `addModule`, `updateModule`,
        `deleteModule` commands. Discriminator-aware request body
        validation (HOLD vs WEAPON vs TORPEDO vs SENSOR vs OTHER —
        the spec uses oneOf). Mandatory-module guard
        (`SHIP_MODULE_MANDATORY` 422).
        Three new domain errors (`ShipModuleNotFoundError`,
        `ShipModuleMandatoryError`, `ShipModuleSlotInvalidError`,
        `ShipModuleTypeMismatchError`, `ShipModuleNotOwnedError`).
        Pure validation helper `ship-module-validation.ts` with full
        discriminator-aware logic; a second controller
        `ShipModulesController` at `/api/v1/ship-modules/{id}` for
        the PATCH+DELETE surface (matching the spec's separate path).
        IShipRepo extended with `findModuleById`, `addModule`,
        `updateModule`, `deleteModule`. 490/490 tests pass (+27 new
        specs across 4 files); lint clean. Next: Block 4 — crew
        assignment.
  - [x] Block 4 — Crew assignment: `assignCrew` / `unassignCrew`
        commands. Ship + character ownership guards. Move semantics:
        if the character is already on the ship at a different
        position the old slot is cleared before the new one is
        filled (only if the target is vacant; otherwise
        CREW_POSITION_TAKEN). Same-position re-assign is a no-op
        returning the existing slot. DELETE is idempotent.
        Three new domain errors (CrewPositionTakenError 400,
        CharacterNotFoundError 400, CharacterNotOwnedError 403).
        IShipRepo extended with four crew methods; ShipsModule
        imports CharactersModule for CHARACTER_REPO.
        Spec note: active.md mentioned CREW_ALREADY_ASSIGNED 422
        for same-character-two-positions; the OpenAPI spec has no
        such code. Resolved by move semantics — no 422 surface.
        Commit `0e4a01c`. 490 → 503 tests (+13 specs, 2 files);
        lint clean. Next: Block 5 — duplicateShip + getShipExport
        stub.
  - [ ] Block 5 — `duplicateShip` command (deep copy with name
        suffix), stub `getShipExport` returning 501. Closes the
        Ship API surface so the Phase 5 frontend tasks can wire
        against a complete contract.
- Status: in-progress
- Blockers: —
