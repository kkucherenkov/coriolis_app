## T-2026-05-10-006 — Phase 6 spec: Encounters + Combatants + NPCs + combat realtime

- Created: 2026-05-10
- Owner: claude
- Spec: PRD §11 Phase 6 (GM Tools). Phase 6 is greenfield — neither
  `packages/specs/openapi/openapi.yaml` nor
  `packages/specs/asyncapi/centrifugo.yaml` carries any Phase 6
  shape today. The asyncapi already namespaces a `session.{id}`
  channel and notes "Encounter and combatant payloads are stubbed —
  they land in Epic 9" (`packages/specs/asyncapi/centrifugo.yaml:50`)
  — this task delivers those.
- Goal: Lock the Phase 6 wire contract so the downstream backend +
  web + mobile tasks can run in parallel without re-spec churn. No
  implementation in this task — spec edits + codegen + a green
  `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen` run
  per block. Generated client diffs land in their own
  `chore(codegen)` commits inside each block (`apps/api-client-ts`
  + `apps/api-client-dart`).
- Acceptance:
  - `Npc` resource: full CRUD at `/api/v1/npcs` and
    `/api/v1/npcs/{id}` with create / list / get / patch / delete,
    plus a `duplicate` action mirroring the Ships pattern.
  - `Encounter` resource: `/api/v1/game-sessions/{sessionId}/encounters`
    list + create; `/api/v1/encounters/{id}` get / patch (rename,
    state transitions: `setup → active → ended`) / delete.
  - `Combatant` sub-resource on Encounter: add (POST
    `/api/v1/encounters/{id}/combatants`), patch (PATCH
    `/api/v1/combatants/{id}`), delete. Combatants are either a
    `pc` reference (existing Character id) or an `npc` reference
    (NPC id) — discriminated by `combatantType: 'pc' | 'npc'`.
    Each carries the rolled `initiative` (1..10 per ST3001), a
    `hpCurrent` snapshot, and a turn-order index.
  - Initiative: `POST /api/v1/encounters/{id}/initiative/roll`
    rolls d10 per combatant and sorts them. `PATCH
    /api/v1/encounters/{id}/initiative` lets the GM manually
    re-order. `POST /api/v1/encounters/{id}/turn/advance` rotates
    the active turn forward (wraps to next round).
  - AsyncAPI extension: a `combat.updated` message on the existing
    `session.{id}` channel carrying the full updated Encounter
    snapshot (lazy approach — clients re-render from the snapshot
    rather than computing diffs). Versioning: bump the AsyncAPI
    info.version to a new minor.
  - OpenAPI bumps to a new minor (`0.12.0 → 0.13.0` —
    additive-only, no breaking changes).
- Spec diff: substantial. New schemas: `Npc`, `NpcCreate`,
  `NpcUpdate`, `NpcList`, `Encounter`, `EncounterCreate`,
  `EncounterUpdate`, `EncounterList`, `EncounterStatus`
  (`setup | active | ended`), `Combatant`, `CombatantCreate`,
  `CombatantUpdate`, `CombatantList`, `CombatantType` (`pc | npc`),
  `InitiativeRollResult`, `InitiativeReorderRequest`,
  `TurnAdvanceResult`. Plus `combat.updated` on the AsyncAPI side.
- Codegen impact: yes — every block ends with a regenerated
  `packages/api-client-{ts,dart}` landing as its own
  `chore(codegen)` commit.
- Design impact: none yet — UX work lands in the downstream tasks.
- Tests: spec-only. Each block runs `pnpm spec:validate &&
  pnpm spec:bundle && pnpm spec:codegen` to keep the contract
  green; each block also verifies the codegen diff is sensible
  (no spurious noise in the generated clients).
- Sub-blocks (one feat-spec commit + one codegen commit + one
  active.md follow-up commit per block, per
  `feedback_block_workflow.md`):
  - [x] Block 1 — `Npc` resource. Schemas (`Npc`, `NpcCreate`,
        `NpcUpdate`, `NpcList`, `NpcId` parameter) + paths
        (`/api/v1/npcs`, `/api/v1/npcs/{id}`,
        `/api/v1/npcs/{id}/duplicate`). Cursor-paginated list.
        NPC carries enough stats to drive a combat tracker:
        attributes (str/agi/wits/emp), key skills, weapons
        (reuses `ItemWeapon` shape), armor, hp, mp, signature,
        plus a free-form `description` and `tags` (string array).
        Landed in 1dca68b (spec) + 738e2bc (codegen). `pnpm
        spec:validate && pnpm spec:bundle && pnpm spec:codegen`
        green. TS exports: `Npc`, `NpcCreate`, `NpcUpdate`,
        `NpcList`, `listNpcs`, `createNpc`, `getNpc`, `updateNpc`,
        `deleteNpc`, `duplicateNpc`. Dart: `npcs_api.dart` +
        model files. Design call: `keySkillModifier` and `hp`/`mp`
        are plain integer / inline-object fields with no Character
        precedent — appropriate since NPC hp/mp are fully
        GM-editable (not server-derived formulas). The
        `NpcCreate.attributes` and `NpcCreate.skills` fields
        reference the shared `Attributes` / `Skills` schemas with
        server-side defaults documented in the description.
  - [x] Block 2 — `Encounter` resource. Schemas (`Encounter`,
        `EncounterCreate`, `EncounterUpdate`, `EncounterList`,
        `EncounterStatus`, `EncounterId` parameter) + paths
        (`GET/POST /api/v1/game-sessions/{sessionId}/encounters`,
        `GET/PATCH/DELETE /api/v1/encounters/{id}`). Tag `encounters`
        added. State machine fully documented in `EncounterStatus`
        and `updateEncounter` descriptions: `setup → active` requires
        ≥1 combatant (422 `ENCOUNTER_NO_COMBATANTS` if zero; forward-
        compatible with Block 3 combatant surface); `active → ended`
        resets `activeCombatantId` to null; all reverse and skip
        transitions return 422 `ENCOUNTER_INVALID_TRANSITION`; rename
        and notes editing are permitted at any status. Landed in
        db0186c (spec v0.14.0) + a1e9658 (codegen). `pnpm spec:validate
        && pnpm spec:bundle && pnpm spec:codegen` green. TS exports:
        `Encounter`, `EncounterCreate`, `EncounterUpdate`,
        `EncounterList`, `EncounterStatus`, `listEncounters`,
        `createEncounter`, `getEncounter`, `updateEncounter`,
        `deleteEncounter`. Dart: `encounters_api.dart` + model files
        + `.g.dart` serializers via build_runner.
  - [x] Block 3 — `Combatant` sub-resource. Schemas + paths.
        `combatantType` discriminator. Combatants store the
        snapshot of stats at the moment of add (not a live ref)
        — protects against PC mid-fight edits scrambling the
        tracker. Documented in the schema description.
        Landed in 55d792e (spec v0.15.0) + codegen commit.
        `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen`
        green. New schemas: `CombatantType`, `Combatant`,
        `CombatantCreate`, `CombatantUpdate`, `CombatantList`,
        `CombatantId` parameter. New operationIds:
        `listCombatants`, `addCombatant`, `updateCombatant`,
        `deleteCombatant`. Design call: `statusFlags` is a
        free-form `string[]` with four well-known values documented
        in the schema description (`broken`, `exposed`, `covered`,
        `prone`) — no inline enum so GMs can add custom tags in v1
        without a spec bump. `initiative` and `turnOrder` are
        `readOnly: true` on `CombatantUpdate` so generators emit
        them as read-only; Block 4 sets them via dedicated ops.
        Dart `.g.dart` files generated for `combatant_list`,
        `combatant_type`, `combatant_update`; `combatant.dart`
        and `combatant_create.dart` did not get `.g.dart` files
        (pre-existing build_runner limitation with complex types —
        same pattern as Blocks 1+2).
  - [ ] Block 4 — Initiative + turn order ops. Three new path
        actions on the encounter resource (roll, reorder,
        advance). `InitiativeRollResult` returns the sorted
        combatants array with `turnOrder` indices populated.
        `TurnAdvanceResult` returns `{ activeCombatantId,
        round, isNewRound }`.
  - [ ] Block 5 — AsyncAPI `combat.updated` message on the
        existing `session.{id}` channel. Payload is the full
        Encounter snapshot; clients diff against the previous
        render. Bump the asyncapi info.version. Drop the
        "stubbed" note from the channel description. Confirm
        the dart + ts clients pick up the new message type.
- Status: in-progress
- Blockers: —
