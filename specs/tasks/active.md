## T-2026-05-10-007 — Phase 6 backend: NPC + Encounter + Combatant + initiative + combat realtime

- Created: 2026-05-10
- Owner: claude
- Spec: T-2026-05-10-006 locked the wire contract
  (`packages/specs/openapi/openapi.yaml` v0.16.0 +
  `packages/specs/asyncapi/centrifugo.yaml` v0.9.0). This task
  delivers the matching backend modules.
- Goal: NestJS implementation behind every Phase 6 path so the
  generated TS + Dart clients become live. Standard CQRS layout
  per existing modules (`apps/backend/src/modules/ships`,
  `.../game-sessions`): `domain` ports + errors, `infra` Prisma
  repo, `commands` + `queries` handlers, controller(s),
  `module.ts`. Centrifugo `combat.updated` publish from the same
  unit that mutates encounter / combatant state — atomic with
  the DB transaction (publish _after_ commit, before HTTP 200,
  see `dp.publisher.ts` precedent).
- Acceptance:
  - All NPC paths green: list / create / get / patch / delete /
    duplicate. Cursor pagination matches Ships module.
  - All Encounter paths green with state-machine guards (422
    `ENCOUNTER_INVALID_TRANSITION`, `ENCOUNTER_NO_COMBATANTS`).
    GM-owner-only on writes, session members can read (mirror
    GameSession membership rules).
  - Combatant sub-resource: add / patch / delete / list with
    snapshot semantics on PC adds (read Character once at
    add-time, copy `attributes`, `skills`, `hpMax` into a
    `pcSnapshot` JSON column; do NOT join Character rows at
    read-time). NPC adds use NPC stats verbatim (also snapshot).
  - Initiative ops: `rollInitiative` uses `crypto.randomInt(1,11)`
    per combatant, sorts desc with `agility` tie-break, sets
    `turnOrder` indices, atomically transitions `setup → active`.
    `reorderInitiative` overwrites `turnOrder` without touching
    `activeCombatantId`. `advanceTurn` rotates and increments
    `round` on wrap. All three publish a `combat.updated` snapshot.
  - Centrifugo: every successful encounter / combatant mutation
    publishes a `combat.updated` envelope on the encounter's
    parent `session.{id}` channel — payload is the full
    Encounter snapshot exactly as `getEncounter` would return.
  - `express-openapi-validator` rejects no Phase 6 path (zero
    contract drift).
  - Test count climbs by ≥80 (rough budget — Ships module added
    ~80 spec cases; this is a similar surface).
- Spec diff: none (spec already shipped in T-006).
- Codegen impact: none.
- Design impact: none.
- Tests: vitest specs per command + query handler; controller
  smoke tests via Supertest with a real Postgres test container
  (mirrors Ships module pattern). Centrifugo publish covered by
  a `MockCombatPublisher` injected via DI in unit tests; one
  e2e test exercises the real publisher against the docker
  centrifugo via the existing `@CombatPublisher` symbol.
- Sub-blocks (one feat-backend commit per block + one
  active.md follow-up commit, per `feedback_block_workflow.md`):
  - [x] Block 1 — Prisma migration + NPC module. New tables
        `Npc` (owner-scoped), no foreign-key relationships
        beyond owner. CRUD + duplicate handlers + controller.
        Cursor pagination identical to ShipsRepo.list.
        Module wired into AppModule. Vitest specs for every
        handler.
        Result: commit 34a1fca. Files:
        `apps/backend/src/modules/npcs/` (domain, infra,
        commands ×4, queries ×2, controller, module),
        `apps/backend/prisma/migrations/20260510000003_npcs/`.
        Test delta: +50 (511 → 561 total).
  - [x] Block 2 — Encounter module. Tables `Encounter`
        (FK to `GameSession`), state-machine guards in
        domain layer (`encounter.state-machine.ts`),
        repo + handlers + nested + flat controllers
        (`/api/v1/game-sessions/{id}/encounters` + `/api/v1/encounters/{id}`).
        Membership + ownership checks lifted from `game-sessions`
        module. No combatants yet — `setup → active` blocked
        with `ENCOUNTER_NO_COMBATANTS` until Block 3 lands.
        Result: commit 87688a3. Files:
        `apps/backend/src/modules/encounters/` (domain, infra,
        commands ×3, queries ×2, controllers ×2, module),
        `apps/backend/prisma/migrations/20260510000004_encounters/`.
        Design call: IGameSessionAccess injected as a DI port
        (GAME_SESSION_ACCESS token) with a Prisma adapter in infra/
        (renamed .adapter.ts to avoid \*.service.ts lint rule that bans
        direct PrismaService injection). All endpoints GM-owner-only
        per spec (spec overrides task desc on member reads).
        Test delta: +53 (561 → 614 total).
  - [x] Block 3 — Combatant sub-resource. Table `Combatant`
        with discriminator + snapshot JSON columns
        (`pcSnapshot` / `npcSnapshot`). Read-once-at-add
        copy semantics implemented in
        `commands/add-combatant.handler.ts`. List / patch /
        delete handlers. Encounter `setup → active` becomes
        legal once ≥1 row.
        Result: commit TBD. Files:
        `apps/backend/src/modules/combatants/` (domain, infra,
        commands ×3 + specs ×3, queries ×1 + spec ×1,
        controllers ×2, module),
        `apps/backend/prisma/migrations/20260510000005_combatants/`.
        Test delta: +35 (632 → 667 total).
        Design calls: (1) `hasCombatants` flows through
        `ICombatantCount` port — `CombatantRepo` implements both
        `ICombatantRepo` and `ICombatantCount`, exported under
        separate tokens, imported into `EncountersModule` via
        `forwardRef(() => CombatantsModule)` to break the circular
        dep. (2) Deleting the active combatant is allowed in `setup`
        status only (spec); the `onDelete:SetNull` on
        `Encounter.activeCombatant` relation cascades the FK to null
        automatically in the same Prisma call. (3) Spec overrides
        prose: `hpCurrent` has no upper cap — CT3001 allows going
        below 0 and the spec says "May go below 0"; task prose
        mentions `COMBATANT_HP_OVER_MAX` but that code does not
        appear anywhere in the spec, so it was not implemented.
  - [ ] Block 4 — Initiative + turn ops. `rollInitiative`
        as a single transactional handler (d10 per row,
        agility tie-break, `turnOrder` index assignment,
        encounter status transition, `round = 1`,
        `activeCombatantId = turnOrder:0`).
        `reorderInitiative` validates the request array
        permutes the existing combatant set 1:1 (422
        `ENCOUNTER_REORDER_MISMATCH` otherwise) then
        rewrites `turnOrder`. `advanceTurn` rotates,
        increments `round` on wrap, returns
        `{ activeCombatantId, round, isNewRound }`.
        Defensive 422 `ENCOUNTER_INITIATIVE_NOT_ROLLED`
        if `advanceTurn` is called from `setup` (currently
        unreachable but documented in the spec).
  - [ ] Block 5 — Centrifugo `combat.updated` publisher.
        New `CombatPublisher` interface in
        `apps/backend/src/modules/encounters/infra/combat.publisher.ts` + `CentrifugoCombatPublisher` impl mirroring
        `dp.publisher.ts`. Hooked into every mutation
        handler (encounter create / patch / delete,
        combatant add / patch / delete, initiative
        roll / reorder / advance) — published _after_
        commit, before HTTP 200, with the full
        Encounter snapshot. e2e test against the real
        docker centrifugo (skip if not running, log
        warn) verifies the channel + payload.
- Status: ready
- Blockers: —

---

## T-2026-05-10-008 — Phase 6 web: NPC library + GM combat tracker

- Created: 2026-05-10
- Owner: claude
- Spec: T-006 locked the wire contract; T-007 lands the backend
  implementation. This task wires the web SPA against both.
- Goal: GM-facing combat tracker UX — NPC library page,
  inline encounter creation on the session view, combatant
  picker (PC + NPC), initiative roll/reorder/advance, live
  combat re-render via the existing centrifuge subscription
  on `session.{id}` (DP composable already subscribes; reuse
  the channel, branch on payload type).
- Depends on: T-2026-05-10-007 (Phase 6 backend).
- Acceptance:
  - `/app/npcs` index — list + filter + inline create form +
    per-card Open / Duplicate / Delete + empty state, mirrors
    `/app/ships` index pattern.
  - `/app/npcs/[id]` sheet — full editable stat block with
    `useAutoSave` debounce on blur, header with rename +
    duplicate + delete + AppSavePulse.
  - On the session view (`/app/sessions/[id]`): an
    `EncounterPanel` that lists encounters for the session,
    inline create (name + notes), per-card open which expands
    a `CombatTracker` widget.
  - `CombatTracker` widget — combatant list ordered by
    `turnOrder`, active row highlighted, GM-only Roll
    Initiative / Advance Turn / Reorder (drag-and-drop)
    buttons. Add Combatant flyout with two tabs (PC picker
    pulling characters from the session, NPC picker pulling
    from `/api/v1/npcs`). Status flag chips
    (`broken | exposed | covered | prone`) editable inline.
  - Realtime: subscribe to `session.{id}` (already done for
    DP) — branch on `payload.type` to update DP counter or
    re-render the combat tracker from the lazy snapshot. No
    diff computation in the client — replace local state
    wholesale.
  - i18n: every user-visible string keyed; ru + en strings
    in the existing `apps/web/i18n/locales/{ru,en}.json`.
  - Storybook: `CombatTracker` and `EncounterPanel` get
    stories (states: empty / setup / active / ended).
  - Vitest count climbs by ≥40.
- Spec diff: none.
- Codegen impact: none — generated TS client already exposes
  the Phase 6 ops from T-006.
- Design impact: combat tracker is a new pattern — capture
  tokens / spacing in the Storybook stories, no new design
  tokens needed (reuse existing role / size scales).
- Tests: vitest @testing-library/vue specs per page +
  composable; Storybook visual stories; one Playwright
  smoke flow (create encounter → add 2 combatants → roll
  initiative → advance turn → realtime update arrives).
- Sub-blocks (one feat-web commit per block + one
  active.md follow-up commit, per `feedback_block_workflow.md`):
  - [ ] Block 1 — `useNpcsApi` composable + `/app/npcs`
        index page (list, inline create, per-card actions,
        empty state, error retry). Nav link from characters
        AppBar.
  - [ ] Block 2 — `/app/npcs/[id]` sheet with auto-save
        on blur, header actions, problems card.
  - [ ] Block 3 — `useEncountersApi` composable +
        `EncounterPanel` on the session view. Inline create,
        list, open / delete. State-machine UI hints
        (e.g. "Add ≥1 combatant before rolling initiative").
  - [ ] Block 4 — `useCombatantsApi` + `CombatTracker`
        widget. PC + NPC picker, status chips, drag reorder.
        No initiative actions yet — picker + list only.
  - [ ] Block 5 — Initiative ops + realtime wire-up.
        Roll / Advance Turn buttons, drag reorder dispatch
        to backend, branch the existing `session.{id}`
        subscription on payload type to update tracker
        from `combat.updated` snapshots. Storybook
        stories landed.
- Status: queued (blocked on T-007 backend)
- Blockers: T-2026-05-10-007
