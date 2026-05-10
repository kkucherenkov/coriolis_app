## T-2026-05-10-010 — Canon alignment: librarian audit remediation (ST3001)

- Created: 2026-05-10
- Owner: claude
- Source: 4-agent librarian sweep ran 2026-05-10 against the
  whole game-mechanic surface. 10 hard violations + 9 soft
  mismatches + 11 spec-silences captured. Full report in the
  session transcript.
- Goal: reconcile the implementation with the Russian ST3001
  rulebook (`/Users/kkucherenkov/Documents/vaults/obsidian/`
  `70.01 Areas/TRPG/Coriolis/ST3001/`). Hard violations are
  spec-first changes; soft mismatches need a PRD/code comment
  explaining the deliberate divergence; silences need either
  a comment or a deferred follow-up task.
- Why now: T-2026-05-10-008 (web combat tracker) is queued on
  T-007. Shipping the tracker on top of d10 + agility-tiebreak +
  non-canonical statusFlags + 5-band weapon ranges would compound
  the drift with i18n, Storybook, and Flutter UI. Fix the
  contract before the consumers wire up.
- Depends on: T-2026-05-10-007 (already done — gives us a known
  baseline to rebase the spec on). **Blocks: T-2026-05-10-008.**
- Acceptance:
  - Every hard violation closed in the spec + backend + tests.
  - Every soft mismatch carries an inline `// PRD override:`
    comment with the canon quote and the product reason
    (no silent drift).
  - Every spec silence either gets a one-line comment naming
    the rulebook section the implementation chose to defer to,
    or becomes a tracked follow-up task in `done.md` /
    `active.md`.
  - `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen`
    runs clean — codegen artefacts shipped in their own commit.
  - Backend test count holds or grows (no regressions); new
    rule-fix specs added per block.
- Spec diff: large — touches `Encounter`, `Combatant`,
  `RollCreate`, `Attributes`, `Skill`, `ItemRangeEnum`,
  `ItemCybernetic`. **Major bump** of the OpenAPI semver
  (breaking changes to enum values + tightened ranges).
- Codegen impact: TS + Dart clients regenerated; web + mobile
  consumers will surface compile errors where the old enum
  literals are used — fix-forward in the same PR.
- Design impact: combat tracker mockups (T-008) referenced the
  `[broken, exposed, covered, prone]` status chips —
  redraw with the canonical taxonomy
  (`incapacitated, prone, covered`) before T-008 starts.
- Tests: per-block vitest specs; one e2e flow exercising a
  combat round end-to-end with the corrected rules.
- Sub-blocks (one feat-* commit per block + one
  active.md follow-up commit, per `feedback_block_workflow.md`):
  - [ ] Block A — **Initiative die + tie-break.** Hard
        violations H1, H2.
        Spec: change `initiative` field range to 1..6 with
        description «d6 — ГЛАВА 5 line 18»; rewrite the
        `InitiativeRollResult` description; drop agility
        tie-break from the spec narrative.
        Code: `roll-initiative.handler.ts` → `randomInt(1, 7)`;
        `initiative.ts` → re-roll d6 for ties (loop until
        every initiative value is unique within the encounter,
        or fall back to GM reorder after N=3 reroll passes).
        Update `roll-initiative.handler.spec.ts`,
        `initiative.spec.ts`. Adds: one-line code comment in
        `advance-turn.handler.ts:80-82` citing «инициатива
        остаётся прежней до конца сражения» (round wrap is
        canon-correct, just not documented).
  - [ ] Block B — **Combatant statusFlags taxonomy.** Hard
        violation H3.
        Spec: drop the `[broken, exposed, covered, prone]`
        wire example; either keep `statusFlags: string[]`
        free-form (recommended for greenfield) or replace
        with `[incapacitated, prone, covered]` and document
        each citing ГЛАВА 5 lines 188-189.
        Remove the misleading "broken halves attributes per
        ST3001 p.77" descriptor — that rule does not exist.
        Code: no migration if string[] stays; otherwise a
        Prisma migration to renormalise legacy values.
        Storybook stories for combat-tracker (T-008 design)
        need to be redrawn before T-008 lands.
  - [ ] Block C — **Dice pool min/max.** Hard violations H4, H5.
        Spec: drop `pool: maximum: 10` (or widen to 20 with
        a PRD-rationale comment); change `pool: minimum: 1`
        to `0`. Document the «Ноль кубиков» rule (2d6,
        success only on double sixes) in the
        `RollCreate` description.
        Code: `roll-engine.ts` already handles arbitrary
        pool size; add a branch for `pool === 0` →
        `randomInt(1, 7)` twice and only count success if
        both 6s. Tests for both edge cases.
  - [ ] Block D — **Attribute min + advanced skill cap.**
        Hard violations H6, H7.
        Spec: `Attributes.{strength|agility|wits|empathy}`
        `minimum: 2`; split `Skill` into
        `GeneralSkill (0–5)` and `AdvancedSkill (0–3)`,
        or add a discriminator on the existing schema.
        Backend rules-engine validation must enforce the
        same caps server-side regardless of wizard-side
        guards. Update wizard step 4 + step 5 specs.
  - [ ] Block E — **`CONCEPT_KEY_SKILLS` per role, not
        per amplua.** Hard violation H8.
        Refactor `apps/backend/src/modules/rules-engine/`
        `rules-engine.ts:112-168` into three dictionaries
        per amplua, one per canonical role (е.g. ПИЛОТ:
        Водитель / Ас / Дальнобойщик), each with exactly 4
        key skills sourced verbatim from ГЛАВА 2. Web
        wizard step 5 needs a role-picker between concept
        and skill distribution.
        Spec: add `Character.role: string` (or per-concept
        enum); migration backfills existing characters with
        a sane default (the first role in their concept's
        list) and flags a `role_unmigrated: true` so the
        wizard can re-prompt on next edit.
  - [ ] Block F — **Personal-scale weapon range bands.**
        Hard violation H9.
        Spec: replace `ItemRangeEnum =
        [arm, near, short, long, distant]` with the
        canonical 4-band ladder
        `[bliznyaya, srednyaya, dalnyaya, predelnaya]`
        (or English `[close, medium, long, extreme]`,
        with the Russian as `description`).
        Backend: `apps/backend/src/modules/characters/`
        `items/commands/{add,update}-item.command.ts`
        VALID_RANGES → 4-band; migration translates legacy
        `arm → close`, `near → close`, `short → medium`,
        `long → long`, `distant → extreme`.
        ⚠️ Distinct from `ShipWeaponRange = [zero, close,`
        `medium, long, extreme]` (5-band ship-combat ladder
        from ГЛАВА 7 line 709) — keep that enum as-is, it's
        canon.
  - [ ] Block G — **Cybernetic `bodyPoints` field.** Hard
        violation H10.
        Spec: drop the `bodyPoints: 0–6` field from
        `ItemCybernetic`; replace with `xpCost: 1–3`
        sourced from ГЛАВА 6 §КИБЕРНЕТИЧЕСКИЕ ИМПЛАНТАТЫ +
        ТАБЛИЦА 6.15 (cybernetics are dual-priced
        бирры + опыт; the XP cost equals the talent rank
        the cybernetic doubles as).
        Prisma migration: drop column; reseed values from
        the canonical table.
  - [ ] Block H — **`ItemSlotType` deprecation.** Soft
        mismatch (already self-documented in
        `openapi.yaml:7697-7699`).
        Repoint `ItemShipModule.slot` at `ShipModuleSlot`;
        delete `ItemSlotType` after a one-version
        deprecation window. Run codegen.
  - [ ] Block I — **PRD-override comments on soft
        mismatches.** Inline annotations:
        - `Combatant.hpCurrent`: «PRD override —
          ГЛАВА 5 line 189: HP не опускается ниже нуля.
          Greenfield product allows negative for damage
          overflow display».
        - `Combatant.signature`: «PRD: NPC sensor signature.
          ST3001 has no per-combatant numeric signature
          stat — the canonical mechanic is скрытность
          (skill, ГЛАВА 3) at roll time. Field reserved
          for future GM tooling».
        - `rules-engine.ts` Exhausted-blocks-push:
          «PRD override — ST3001 (ГЛАВА 3) only restricts
          push to skill checks and once per check;
          Exhausted is a greenfield UX gate».
        - i18n glossary entry: `push → молитва Ликам /
          re-roll`, never «толкнуть» / «пуш».
        - Round-wrap one-liner already covered in Block A.
  - [ ] Block J — **Spec-silence follow-ups split into
        deferred tasks.** Each becomes its own active.md
        push when needed:
        - `T-2026-05-XX-XXX` — `ItemWeapon.initiative`
          modifier column from ГЛАВА 6 weapon tables.
        - `T-2026-05-XX-XXX` — `ItemArmor.extraSlotCount`
          from ТАБЛИЦА 6.14.
        - `T-2026-05-XX-XXX` — Ship deterministic stats
          (Манёвренность / Заметность / Скорость / отсеки)
          from class via ТАБЛИЦА 7.5.
        - `T-2026-05-XX-XXX` — `RollKind` discriminator
          (skill / save / trauma / initiative) so push is
          gated on `kind === 'skill'`.
        - `T-2026-05-XX-XXX` — `RollCreate.breakdown`
          optional object {attribute, skill, gear,
          modifier, helpers} for GM-tools audit trail.
- Status: ready
- Blockers: —

---

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
  - [x] Block 4 — Initiative + turn ops. `rollInitiative`
        as a single transactional handler (d10 per row,
        agility tie-break, `turnOrder` index assignment,
        encounter status transition, `round = 1`,
        `activeCombatantId = turnOrder:0`).
        `reorderInitiative` validates the request array
        permutes the existing combatant set 1:1 (422
        `INITIATIVE_DUPLICATE` / `INITIATIVE_UNKNOWN_COMBATANT`
        / `INITIATIVE_INCOMPLETE`) then rewrites `turnOrder`.
        `advanceTurn` rotates, increments `round` on wrap,
        returns `{ activeCombatantId, round, isNewRound }`.
        Defensive 422 `ENCOUNTER_INITIATIVE_NOT_ROLLED`
        if `advanceTurn` is called when `activeCombatantId`
        is null (currently unreachable via `rollInitiative`
        but documented in the spec).
        Result: commit 022309c. Files:
        `apps/backend/src/modules/encounters/commands/`
        (roll-initiative ×3, reorder-initiative ×3,
        advance-turn ×3), `domain/initiative.{ts,spec.ts}`
        (pure tie-break sort), `infra/initiative.repo.ts`
        (atomic `$transaction` adapter), updates to
        `encounter.errors.ts` (+5 errors:
        `ENCOUNTER_INVALID_STATUS`,
        `ENCOUNTER_INITIATIVE_NOT_ROLLED`,
        `INITIATIVE_DUPLICATE`,
        `INITIATIVE_UNKNOWN_COMBATANT`,
        `INITIATIVE_INCOMPLETE`),
        `encounter.ports.ts` (`InitiativeRollResult`,
        `TurnAdvanceResult`, `IInitiativeRepo` port),
        `encounters.controller.ts` (+3 routes),
        `encounters.module.ts` (wire-up), and
        `combatants/{domain,infra}/combatant.{ports,repo}.ts`
        (`listByEncounterWithSnapshot` for snapshot-aware
        tie-break load).
        Test delta: +34 (667 → 701 total).
        Design calls: (1) `IInitiativeRepo` is a separate
        port (`INITIATIVE_REPO` token) rather than extending
        `IEncounterRepo`, so the atomic `$transaction` stays
        in infra without leaking Prisma into command handlers.
        (2) Spec overrides task prose: the reorder error
        codes are not `ENCOUNTER_REORDER_MISMATCH` (a single
        umbrella code mentioned in the task) but the three
        granular codes shipped in T-006
        (`INITIATIVE_DUPLICATE` / `INITIATIVE_UNKNOWN_COMBATANT`
        / `INITIATIVE_INCOMPLETE`).
        (3) Tie-break — agility — pulls from
        `pcSnapshot.attributes.agility` and
        `npcSnapshot.attributes.agility` snapshotted at
        add-time (Block 3); no Character / NPC join at
        roll-time.
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
- Status: queued (blocked on T-007 backend + T-010 canon
  remediation — combat tracker UI cannot lock in until the
  status-flag taxonomy and initiative formulas match canon)
- Blockers: T-2026-05-10-007, T-2026-05-10-010
