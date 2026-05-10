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
  - [x] Block A — **Initiative die + tie-break.** Hard
        violations H1, H2. **Done in d0e553b (spec) +
        bf41a9a (backend).**
        Spec change: `Combatant.initiative.maximum` 10 → 6 in
        OpenAPI and AsyncAPI; descriptions cite ГЛАВА 5
        «Бросьте по кубику…»; `rollInitiative` and
        `InitiativeRollResult` rewritten to describe a bounded
        d6 reroll loop (≤3 passes) and drop the agility
        tie-break narrative; example values repointed into
        the 1..6 range.
        Backend: `roll-initiative.handler.ts` switched to
        `randomInt(1, 7)`; new pure `rerollTies(items, rollD6)`
        in `domain/initiative.ts`; `sortInitiative` simplified
        to initiative-desc + createdAt-asc; `getAgility`
        deleted. Tests added: 7 `rerollTies` cases
        (no-tie short-circuit, first-pass resolve, multi-pass
        resolve, give-up after MAX_REROLL_PASSES, partial tie
        among three, single combatant, no-mutation invariant)
        plus a reroll-tiebreak handler test and a d6-range
        guard. Backend vitest count grew by +5 (tied to
        Block A).
        Round-wrap canon citation already in
        `advance-turn.handler.ts:14-15` (landed with
        T-007 Block 5).
        Baseline collateral fix shipped on the way:
        a7367f4 imports `RealtimeModule` into
        `EncountersModule` (the T-007 Block 5 publisher
        couldn't resolve `CENTRIFUGO_CLIENT` because the
        module was never `@Global()`); 7a09ee5 exempts
        `specs/tasks/{active,done}.md` from prettier so
        the next `pnpm format` doesn't collapse the nested
        list outline.
  - [x] Block B — **Combatant statusFlags taxonomy.** Hard
        violation H3. **Done in c0fcba9 (spec) +
        9e3d0dd (backend fixtures).**
        Decision: kept `statusFlags: string[]` free-form (no enum
        lock) per the librarian audit's greenfield recommendation —
        GMs need scene-specific tags and a hard schema would force
        migrations every time a campaign needs a new condition.
        Description rewritten on `Combatant`, `CombatantUpdate`,
        and the AsyncAPI combatant snapshot to cite ГЛАВА 5
        «Раунды, ходы и инициатива» and name the canonical tags
        (`incapacitated`, `prone`, `covered`) without constraining
        the field. Removed the fabricated «`broken` halves all
        attributes per ST3001 p.77» one-liner — no such rule exists
        in the rulebook.
        Wire examples scrubbed of the dropped taxonomy:
        `Combatant.statusFlags` example `[broken, exposed]` →
        `[incapacitated]`; `CombatantUpdate` example `[broken]` →
        `[incapacitated]`; the GET-encounter NPC combatant fixture
        moved from `[exposed]` (also non-canonical) to `[covered]`;
        the PATCH-combatant `applyDamage` example summary,
        request, and response payload all switched to
        `incapacitated`.
        No Prisma migration: schema shape is unchanged
        (`String[]` Postgres array, same as before). Backend code
        is untouched — there was never an enum guard. Test
        fixtures in
        `combatants/commands/update-combatant.handler.spec.ts` and
        `combatants/queries/list-combatants.handler.spec.ts`
        rewritten to use `['incapacitated']` so they stop
        perpetuating the dropped taxonomy. 172 combatants +
        encounters specs pass inside the dev container.
        TS + Dart codegen: doc-comment-only diff (no schema break);
        consumers compile clean. T-008 design follow-up
        (combat-tracker status chips redrawn against canonical
        tags) is already noted in that task's «Design impact».
  - [x] Block C — **Dice pool min/max.** Hard violations
        H4, H5. **Done in 8a27aef (spec) + 8d8c30a (codegen)
        + 457fe42 (backend).**
        Spec: `Roll.pool.minimum` and `RollCreate.pool.minimum`
        lowered 1 → 0; `.maximum` widened 10 → 20 with a
        PRD-override note explaining 20 is a payload cap (no
        canonical upper bound exists in ST3001, realistic stacks
        max out around 12–14). The «Ноль кубиков» rule
        (ГЛАВА 3 line 161) is now documented on `RollCreate`
        and `Roll.dice` flags that the array still has 2
        elements when `pool === 0`.
        Backend: `rollPool(0)` rolls 2d6; `countHits` gained a
        `pool` parameter and only counts a success when every
        die is a 6 in the zero-dice case (returns 0 or 1, never
        the raw count). `CreateRollDto` now `@Min(0) @Max(20)`;
        `RollPoolOutOfRangeError` detail updated to "0–20"; the
        belt-and-suspenders check in `CreateRollHandler` mirrors
        the DTO. `PushRollHandler` passes `roll.pool` so a
        pushed zero-pool roll keeps the double-six rule.
        Tests added: 10 new `roll-engine.spec.ts` cases (no
        existing engine spec — file created), 5 new
        `create-roll.handler.spec.ts` cases (pool=0 stores 2
        dice, double-six invariant across 50 trials, pool=20
        accepted, pool=21 + pool=-1 rejected), 1 new
        `push-roll.handler.spec.ts` case (pushed zero-pool
        preserves the leading 6 and reports hits=1 only when
        the rerolled die also lands on 6). Backend vitest count
        739 → 749 (+10).
  - [x] Block D — **Attribute min + advanced skill cap.**
        Hard violations H6, H7. **Done in 345e0e4 (spec) +
        381ddef (codegen) + 05b6a2c (backend) + aac0dca
        (NPC fixture cleanup).**
        H6 applied: `Attributes.{strength,agility,wits,empathy}`
        `minimum` lifted 1 → 2 in OpenAPI. Schema description
        rewritten to cite ГЛАВА 2 «ХАРАКТЕРИСТИКИ» / §РАЗВИТИЕ
        ПЕРСОНАЖА — the rulebook scale is 1..5 in the abstract,
        but the active-PC invariant is 2..5 (creation distributes
        2..4, key-attr exception lifts to 5; no in-game mechanic
        lowers an attribute below 2). The 5-cap stays as the
        canonical lifetime maximum.
        H7 **rejected** as non-canonical. The audit asked for
        `AdvancedSkill 0..3`, but ГЛАВА 3 «Перечень навыков»
        («значения характеристик могут варьироваться от 1 до 5,
        а навыков — от 0 до 5») and ГЛАВА 2 §РАЗВИТИЕ ПЕРСОНАЖА
        («максимально возможное значение навыка равно 5»)
        explicitly cap every skill at 5 with no general/advanced
        distinction. The audit conflated the **creation-time**
        cap (key skills up to 3, others up to 1, ГЛАВА 2
        «НАВЫКИ») — already enforced by `validateSkillsAtCreation`
        — with a lifetime cap. The `Skills` schema description
        was rewritten to call this out and to document the actual
        general/advanced distinction (the value-≥-1 gate to roll
        an advanced skill, ГЛАВА 3 §«Специальные навыки», lives
        in the dice engine, not the schema). No range change on
        any skill.
        Backend: `validateAttributes` (update path) and
        `validateAttributesAtCreation` (create path) floors lifted
        1 → 2; `AttributeOutOfRangeError.detail` now reads
        "(2–5)". `validateSkills` untouched. NPC fixture
        `add-combatant.handler.spec.ts:109` `empathy: 1 → 2`
        (incidental fixture, not exercising the floor). Tests
        added: 4 new boundary cases on update (1/2/5/6) + 1 new
        boundary case on create + 1 reframed creation-range case
        showing the absolute-floor guard wins precedence over the
        creation-range guard. Backend vitest count 748 → 754
        (+6).
        Codegen: TS + Dart `Attributes` models pick up the new
        floor in their generated docs; no breaking change to the
        wire shape (the bound only tightens). The TS/Dart
        generators don't carry numeric `minimum` constraints in
        the type system — runtime enforcement remains the
        express-openapi-validator; that is a known soft mismatch
        documented in the schema description.
        OpenAPI `info.version` not bumped this block — the
        major bump is deferred to the closing block of T-010
        per the plan; if Block D lands on `main` standalone for
        any reason, the next block must include a major bump
        (the floor tightening from 1 to 2 is a breaking change
        for any caller who was sending `1`).
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
