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
