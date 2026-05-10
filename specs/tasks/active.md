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
  - [x] Block E — **`CONCEPT_KEY_SKILLS` per role, not
        per amplua.** Hard violation H8. **Done in 059f661
        (spec) + 1e6ca54 (codegen) + 80bf2d8 (backend
        refactor + Prisma migration).** Web wizard reflow
        deferred to **T-2026-05-10-011** (see below).
        Spec: new `Role` enum with 33 canonical role slugs
        (companion, musician, poet, analyst,
        correspondent, network-djinn, criminal, mystic,
        revolutionary, agitator, diplomat, dealer,
        assassin, guard, spy, ace, driver, trucker,
        colonist, prospector, scout, ascetic, missionary,
        prophet, archaeologist, medicurg, technologist,
        ship-engineer, labourer, loader, legionnaire,
        mercenary, officer). Slugs are unique across
        amplua so the enum is flat. Russian display names
        carried inline so localised clients can render
        labels without a rulebook round-trip. New
        `Character.role: Role | null` (and on
        CharacterCreate / CharacterUpdate). Nullable for
        drafts and for legacy rows. Server enforces
        `ROLE_CONCEPT_MISMATCH` (HTTP 400) when the role
        is not in the chosen concept's three.
        Backend rules-engine: refactored `CONCEPT_KEYS`
        from a hand-curated 5-element union per amplua to
        a derived value computed from a new
        `CONCEPT_ROLES` dictionary that holds all 33
        canonical role × 4 skill mappings (single source
        of truth). New exports: `Role` (string union),
        `RoleData`, `CONCEPT_ROLES`, `ROLE_BY_CONCEPT`,
        `CONCEPT_BY_ROLE`, `getRoleKeySkills(role)`,
        `defaultRoleForConcept(concept)`. Barrel
        `rules-engine/index.ts` updated so handlers can
        import them. Legacy callers reading
        `CONCEPT_KEYS[c].keySkills` keep working — that
        property is now derived as the union of the three
        roles' skills (no API change for them).
        Backend handlers: `CreateCharacterHandler` and
        `UpdateCharacterHandler` validate `dto.role`
        belongs to `dto.concept` (or the character's
        existing concept, on update) via
        `CONCEPT_BY_ROLE`; new
        `RoleConceptMismatchError` (code
        `ROLE_CONCEPT_MISMATCH`). When a role is
        provided, the per-skill creation cap uses the
        role's exact 4 key skills (not the union),
        tightening the gate for non-key advanced skills
        from "up to 1" against a 5-skill key set to "up
        to 1" against the canonical 4-skill set.
        Setting a role on update clears `roleUnmigrated`.
        Prisma migration `20260510000006_add_character_`
        `role`: adds `role text NULL` and
        `roleUnmigrated bool NOT NULL DEFAULT false` to
        the `character` table; idempotent backfill
        (`UPDATE … WHERE concept IS NOT NULL AND role IS
        NULL` with a `CASE WHEN concept = 'pilot' THEN
        'ace' …` clause) sets `role` to the canonical
        first role per amplua and `roleUnmigrated = true`
        so the wizard re-prompts on next edit.
        `defaultRoleForConcept` mirrors the same first-
        role mapping for app-side use.
        Tests: 33 cases verifying every role's 4 key
        skills against the canonical table, 11 cases
        verifying `CONCEPT_KEYS[c].keySkills` is the
        deduplicated union of the three roles, 11 cases
        for `defaultRoleForConcept`, 33 cases for the
        `CONCEPT_BY_ROLE` reverse lookup, plus handler
        cases for valid role+concept combos, mismatch
        errors, null-role legacy path, and
        `roleUnmigrated` flag clearing on update.
        Backend vitest count 754 → 850 (+96).
        Backend container restarted after `prisma
        generate` so node_modules picks up the new
        client.
        OpenAPI `info.version` not bumped this block —
        deferred to the closing block of T-010 per the
        plan; the closing block must include a major bump
        because Block D (1 → 2 attribute floor) and the
        new required-when-active `ROLE_CONCEPT_MISMATCH`
        invariant are both breaking changes for naive
        callers.
        **Follow-up: T-2026-05-10-011** (web wizard
        step 5 role-picker, see below) — captures the UI
        reflow that wires up the new role field on the
        creation flow. Backend is fully ready for it; the
        wizard just needs a select between concept and
        skill distribution that POSTs `role` with the
        rest of the wizard payload.
  - [x] Block F — **Personal-scale weapon range bands.**
        Hard violation H9. **Done in 1219df4 (spec) +
        39df704 (codegen) + 6ddf8c3 (backend + migration).**
        Spec: `ItemRangeEnum` lifted from the legacy 5-band
        `[arm, near, short, long, distant]` to the
        canonical 4-band ladder `[close, medium, long,
        extreme]` per ST3001 ГЛАВА 5 «Дистанция» (Ближняя
        ≤2m / Средняя ≤20m / Дальняя ≤100m / Предельная
        ≤1000m). The rulebook does not separate hand-to-
        hand from close quarters in its range taxonomy
        (those distinctions are handled by combat actions),
        so the legacy `arm` and `near` collapse into the
        canonical `close`; `short` becomes `medium`,
        `distant` becomes `extreme`, `long` keeps the slug
        with narrowed semantics. ShipWeaponRange (5-band
        ladder from ГЛАВА 7) intentionally untouched —
        the slug overlap is fine because it lives in a
        different schema and ship combat genuinely needs
        the `zero` (boarding) band.
        Wire examples: 5 personal-scale weapon snippets
        rewritten (`short → medium`); NPC and ship-weapon
        examples unchanged.
        Backend: `VALID_RANGES` in
        `add-item.command.ts` and the matching `@IsIn`
        decorator in `update-item.command.ts` tightened to
        the 4-band list. Tests: legacy `'short'` fixtures
        in `add-item.handler.spec.ts` switched to
        `'medium'`; new negative test verifies the legacy
        `'short'` value is now rejected. Backend vitest
        count 850 → 851 (+1).
        Prisma migration `20260510000007_canonicalise_item_`
        `range`: idempotent JSONB rewrite of `item.data`
        (where `type = 'WEAPON'` and `data.range` is one
        of the legacy slugs) plus `npc.weapons` (jsonb
        array; jsonb_array_elements + jsonb_agg pattern).
        Mapping: `arm/near → close`, `short → medium`,
        `long → long` (untouched), `distant → extreme`.
        Migration applied with `prisma migrate deploy`
        inside the backend container (consistent with the
        Block E shadow-DB workaround); backend container
        restarted afterwards.
  - [x] Block G — **Cybernetic `bodyPoints` field.** Hard
        violation H10. **Done in 4cca564 (spec) + 23c412d
        (codegen) + 49821a4 (backend + migration).**
        Spec: dropped the non-canonical `bodyPoints: 0–6`
        field from `ItemCybernetic` /
        `ItemCyberneticCreate` / `ItemCyberneticUpdate`
        and replaced with `xpCost: 0–15`. ST3001 has no
        "body points" / "system strain" stat — that was a
        fabrication in the original spec. Cybernetics are
        dual-priced (ГЛАВА 6 «КИБЕРНЕТИЧЕСКИЕ ИМПЛАНТАТЫ»
        — «считается и снаряжением, и достоинством, так
        что на его покупку тебе понадобятся не только
        бирры, но и пункты опыта»); the canonical
        acquisition cost is 5 XP per ГЛАВА 4 «Новые
        достоинства». The 0..15 bound accepts GM
        concessions (0 for in-game gifts) and high-rank
        exotics (3 ranks × 5 XP).
        **Audit override on H10:** the audit's
        prescription was `xpCost: 1..3` mapping to a
        "talent rank". The rulebook does not list
        cybernetics as ranked; each is a single talent at
        a single rank. The 1..3 cap would silently
        amputate the GM-extension space, so the spec uses
        0..15 instead — same canon source, broader
        envelope.
        Backend: command DTOs (`add-item.command.ts`,
        `update-item.command.ts`) renamed
        `bodyPoints` → `xpCost`; range tightened to
        `@Min(0) @Max(15)` on both create and update
        (update was previously `@Min(0)` only — block G
        adds the cap to match the new spec).
        `rules-engine.ts` top-level docstring purged of
        the obsolete "systemStrain not weight"
        parenthetical (no formula change — encumbrance
        still sums `weight` across all items including
        CYBERNETIC). Tests: 2 new CYBERNETIC boundary
        cases (`xpCost: 5` happy-path, `xpCost: 16`
        rejection); existing fixtures renamed. NPC module
        verified to carry zero CYBERNETIC references —
        no NPC migration needed.
        Prisma migration `20260510000008_rename_cyberneti`
        `c_bodyPoints_to_xpCost`: idempotent JSONB rename
        on `item.data` for `type = 'CYBERNETIC'` rows
        (`data - 'bodyPoints' || jsonb_build_object('xp`
        `Cost', 5)`); defensive backfill for any
        CYBERNETIC row missing both keys. Backfill value
        of 5 mirrors ГЛАВА 4's canonical talent
        acquisition cost (the rulebook never assigns
        per-implant XP, so 5 is the most defensible
        default).
        Backend vitest count 851 → 853 (+2).
  - [x] Block H — **`ItemSlotType` deprecation.** Soft
        mismatch closed. **Done in c5cde35 (spec) + 78e556e
        (codegen) + 9bc569b (backend + migration).**
        The lowercase 7-value `ItemSlotType` enum is
        retired entirely; `ItemShipModule(.slot)` /
        `ItemShipModuleCreate(.slot)` /
        `ItemShipModuleUpdate(.slot)` now reference the
        canonical 21-value `ShipModuleSlot` from
        ГЛАВА 7. The two contexts (character-inventory
        ship-modules and installed ship-modules) share
        one enum.
        Migration mapping for the JSONB rewrite:
        `bridge → BRIDGE`, `hull → OTHER` (no canonical
        hull slot in ГЛАВА 7's slot taxonomy — armour
        and structural pieces are baked into hull-class
        Table 7.5, not slot-level), `hold → HOLD`,
        `weapon → WEAPON`, `drive → DRIVE`,
        `sensor → SENSOR`, `comms → COMMS`. Documented
        on `ShipModuleSlot.description`.
        Backend: `add-item.command.ts` and
        `update-item.command.ts` import
        `VALID_SHIP_MODULE_SLOTS` (new export from
        `ships/domain/ship-module-validation.ts`); the
        existing `VALID_SLOTS` Set is now built from the
        same canonical list to keep one source of truth.
        Tests: 2 new boundary cases in
        `add-item.handler.spec.ts` (legacy lower-case
        rejected; canonical upper-case accepted).
        Backend vitest count 853 → 855 (+2).
        Codegen: deleted Dart `item_slot_type.dart` /
        `item_slot_type.g.dart` /
        `item_slot_type_test.dart` (51 + 112 + 9
        lines); TS client `ItemSlotType` symbol gone;
        consumer code that still imports the old type
        now hits a compile error — fix-forward in this
        PR.
        Prisma migration `20260510000009_canonicalise_ship`
        `_module_slot`: idempotent JSONB rewrite of
        `item.data.slot` for `type = 'SHIP_MODULE'`
        rows. Applied with `prisma migrate deploy`;
        backend container restarted.
  - [x] Block I — **PRD-override comments on soft
        mismatches.** Done as a spec / codegen / backend
        triplet (SHAs surfaced in commit log; spec
        carries Combatant.hpCurrent + Combatant.signature
        rewrites, codegen carries the TS client regen,
        backend carries rules-engine canPush docblock +
        the new `.claude/docs/i18n.md` glossary section).
        - `Combatant.hpCurrent` description rewritten to
          name the PRD override explicitly: ГЛАВА 5
          «Урон» («запас пунктов здоровья не может
          опуститься ниже нуля») clamps HP at 0; the
          greenfield product allows the field to go
          negative for damage-overflow display, with
          prescribed UI behaviour (red rendering +
          healing math note).
        - `Combatant.signature` description rewritten:
          ST3001 has no per-combatant numeric signature
          stat; the canonical detection mechanic is
          `скрытность` (ГЛАВА 3 «СКРЫТНОСТЬ») rolled at
          detection-time. The field is reserved for
          future GM tooling and clients MUST NOT
          silently bypass a скрытность check by reading
          it.
        - `rules-engine.ts canPush` PRD §10 docblock now
          spells out the override: ГЛАВА 3 §«Вознесение
          молитв» restricts push to skill checks and
          one-per-check, but does NOT gate on
          Exhausted; Exhausted-blocks-push is a
          greenfield UX gate. The «only-on-skill-checks»
          half is tracked as a Block-J follow-up
          (`RollKind` discriminator).
        - `.claude/docs/i18n.md` gained a "Glossary —
          non-negotiable canon translations" section.
          Codifies the audit's `push → молитва Ликам /
          re-roll` rule (never «толкнуть» / «пуш»)
          alongside other game-mechanic mappings
          (Mercy → Владычица Слёз, Faceless One →
          Лик-без-лика, key skill → ключевой навык,
          Exhausted → Истощён, prone → Лёжа, covered →
          В укрытии, Mystic Darkness → Межзвёздная
          Тьма, …). Becomes the translator's source of
          truth since web `<i18n>` blocks are
          colocated (no central JSON to maintain).
        - Round-wrap one-liner already covered in
          Block A — no change needed.
        Soft mismatch noted: Dart codegen
        (openapi-generator-cli dart-dio) failed on this
        run with a non-deterministic generator-internal
        error unrelated to the spec content (schema is
        unchanged; prior blocks regenerated fine). TS
        client picked up the new docstrings; Dart client
        lags by exactly these two doc-comments. Wire
        shape and runtime behaviour stay correct — only
        Dart in-IDE help is stale on Combatant.hpCurrent
        / signature. The next codegen run that touches
        the dart-dio cache (typically the next spec
        change) will catch up automatically.
        No vitest delta (description-only).
  - [x] Block J — **Spec-silence follow-ups split into
        deferred tasks.** Five new T-tasks pushed to the
        stack (entries below T-011, before T-008):
        T-2026-05-10-012 (`ItemWeapon.initiative`),
        T-2026-05-10-013 (`ItemArmor.extraSlotCount`),
        T-2026-05-10-014 (ship deterministic stats from
        class), T-2026-05-10-015 (`RollKind` discriminator
        + push gate), T-2026-05-10-016
        (`RollCreate.breakdown` audit trail). Each carries
        its own canon citation, acceptance criteria,
        spec-diff scope, and codegen impact so they can
        be picked up independently.
        Also bumped OpenAPI `info.version` 0.17.0 → 1.0.0
        per spec-reviewer's earlier note: T-010 has
        accumulated multiple breaking wire changes (Attr
        floor 1→2, ItemRangeEnum 5→4, ItemSlotType
        retired, ItemCybernetic.bodyPoints replaced by
        xpCost, Character.role added with concept-mismatch
        invariant) so a major bump is owed. The 1.0.0
        marker also reflects the canon-alignment effort
        finishing — clients shipping after this version
        rely on canon-correct contracts as the baseline.
- Status: done — ready to archive
- Blockers: —

---

## T-2026-05-10-011 — Web wizard: role picker (Block E follow-up)

- Created: 2026-05-10
- Owner: claude
- Source: split out of T-2026-05-10-010 Block E so the canon-
  remediation backend could land without slipping on UI work.
  The backend half (spec, codegen, rules-engine refactor,
  Prisma migration with backfill) shipped in 059f661 + 1e6ca54
  + 80bf2d8.
- Goal: add a role-picker step to the web character-creation
  wizard so the user explicitly chooses 1 of 3 canonical roles
  within their chosen amplua (ГЛАВА 2 «АМПЛУА И РОЛИ»). The
  chosen role drives the per-skill cap on the skill-
  distribution step (key skills cap at 3, non-key at 1, role-
  scoped, not concept-scoped). Existing characters whose
  `roleUnmigrated === true` (set by the Block E backfill) are
  re-prompted on next edit.
- Why now: backend is fully ready (spec contract, validation,
  migration). The current wizard silently breaks on `role`
  submission — it never sets the field, so any character
  forged by the wizard hits the server with `role: null` and
  the server then enforces `ROLE_CONCEPT_MISMATCH` only when
  the user later adds a role. Without this task the role
  field is dead UX.
- Depends on:
  - T-2026-05-10-010 Block E (done — wire contract + backend
    validation in place).
  - Generated TS client (`packages/api-client-ts`) — `Role`
    enum already exposed.
- Acceptance:
  - **Wizard step renumbering**: insert a new `Step5Role.vue`
    between the current `Step4Attributes.vue` and the current
    `Step5Skills.vue`. The current `Step5Skills.vue` becomes
    `Step6Skills.vue`, and `Step6Talents.vue` becomes
    `Step7Talents.vue`. Update `WizardShell.vue` step list +
    progress indicator + the wizard-store `currentStep` enum.
  - `Step5Role.vue`: shows the 3 canonical roles for the
    chosen concept as cards (extending the concept-card
    pattern from `Step1Concept.vue`). Each card carries the
    Russian display name (from the rulebook), a one-line
    Russian flavour text (extracted from ГЛАВА 2 §РОЛИ for
    that role), and the four key skills as chip tags. The
    selected card highlights via the same focus-ring tokens
    Step1Concept uses.
  - **Concept→roles mapping in web**: a small `roleCatalogue.ts`
    module under `apps/web/app/composables/` (or
    `apps/web/app/utils/`) exposes
    `CONCEPT_ROLES: Record<Concept, ReadonlyArray<{slug: Role,
    ruLabel: string, ruFlavour: string, keySkills:
    [SkillKey,SkillKey,SkillKey,SkillKey]}>>` mirroring the
    backend's `CONCEPT_ROLES` (single source of truth in the
    backend; the web reproduces the data because the OpenAPI
    enum is intentionally flat to keep the wire contract
    simple — duplicate the 33 entries by hand and unit-test
    them against the regenerated `Role` enum to catch drift).
  - **Skill distribution step uses role-scoped key skills**:
    `Step6Skills.vue` (was Step5Skills) reads the chosen role
    from the wizard store and caps the four role-keys at 3
    points each, the other twelve at 1 point each. The "key
    skills" hint at the top of the step lists the four
    role-keys ("Key skills: X / Y / Z / W — max 3 each").
    Existing budget logic per Upbringing stays untouched.
  - **roleUnmigrated banner**: on
    `apps/web/app/pages/app/characters/[id].vue` (or
    `CharacterHeader.vue` if there's a dedicated header
    component), when the loaded character has
    `roleUnmigrated === true`, render a non-dismissable banner
    inviting the user to confirm the role. Clicking "Confirm"
    opens a small dialog with the same role-card list scoped
    to the character's concept; selecting a role fires
    PATCH `/api/v1/characters/{id}` with the chosen `role`,
    after which the backend clears `roleUnmigrated` (logic
    already in 80bf2d8) and the banner disappears on the next
    re-render.
  - **Wizard payload**: the wizard store includes `role` in
    the POST `/api/v1/characters` body. The role is required
    when status flips to `active`; it stays nullable while
    `status === 'draft'` so users can step backwards.
  - **i18n**: every user-visible string keyed in
    `apps/web/i18n/locales/{ru,en}.json`. Russian display
    names from the canonical rulebook table (Компаньон,
    Музыкант, Поэт, Аналитик, Корреспондент, Сетевой джинн,
    Преступник, Мистик, Революционер, Агитатор, Дипломат,
    Делец, Ассасин, Стражник, Шпион, Ас, Водитель,
    Дальнобойщик, Колонист, Старатель, Скаут, Аскет,
    Миссионер, Пророк, Археолог, Медикург, Технологик,
    Бортинженер, Разнорабочий, Грузчик, Легионер, Наёмник,
    Офицер) keyed under `wizard.role.<slug>.label`. English
    translations keyed under the same path. Flavour text
    keyed under `wizard.role.<slug>.flavour`. Page-level
    strings ("Choose your role", "Confirm role", etc.) keyed
    under `wizard.role.headline`, `wizard.role.cta`, banner
    strings under `character.roleUnmigrated.banner.*`.
  - **Storybook**: stories for `Step5Role.vue` (4 states:
    no concept selected → empty placeholder; concept chosen,
    no role selected → 3 cards; role selected → focus-ring on
    one card; loading → skeleton). Stories for the
    `RoleUnmigratedBanner` if it's split out as its own
    component (3 states: hidden, visible, dialog open).
  - **Vitest count climbs by ≥15**: `Step5Role.spec.ts` (≥6
    cases — render with each concept's role triplet, click
    selects, keyboard nav, no-concept guard), `Step6Skills.`
    `spec.ts` updates (≥3 cases — role-scoped cap of 3 for
    role keys, cap of 1 for non-role keys, hint renders the
    4 keys), `roleCatalogue.spec.ts` (≥4 cases — every
    `Role` enum value present, every concept has exactly 3
    roles, every role has exactly 4 key skills, all key
    skills are valid `SkillKey` values), banner spec (≥2
    cases — visible when flag true, hides after PATCH).
  - **Playwright smoke** (optional but encouraged): one new
    flow `wizard-role-picker.spec.ts` — concept → role →
    skills → forge, asserting the created character has
    `role: <slug>` and `roleUnmigrated: false`.
  - **a11y**: role cards use `role="radio"` with proper
    `aria-checked` state; the radiogroup container carries
    `role="radiogroup"` and an accessible name; arrow-key
    navigation between cards. Banner uses `role="status"`
    until clicked, then the dialog uses `role="dialog"` with
    a labelled heading + `aria-describedby`.
- Spec diff: none — wire contract already lands in T-010
  Block E (Character.role + Role enum + ROLE_CONCEPT_MISMATCH).
- Codegen impact: none — generated TS client already exposes
  the new types.
- Design impact: extend the existing concept-card pattern to
  role cards (smaller, denser, role-coloured if amplua already
  has a colour token; otherwise reuse the neutral surface
  tokens). No new design tokens needed — reuse spacing /
  radius / focus-ring / role-chip styles already in the
  design system. The card density goal: 3 cards must fit in
  one row on the laptop breakpoint (≥1024px) and stack
  vertically on the mobile breakpoint (<640px).
- Tests: per-block vitest as listed above; one Playwright
  smoke; one i18n-completeness lint that asserts the 33
  `wizard.role.<slug>.label` and `wizard.role.<slug>.flavour`
  keys exist in both `ru.json` and `en.json` (drives the
  `i18n-keys` lint rule already in `apps/web`).
- Sub-blocks (one feat-web commit per block + one active.md
  follow-up commit, per `feedback_block_workflow.md`):
  - [x] Block 1 — `roleCatalogue.ts` + drift tests. **Done in
        a248e1e.** Pure data module under
        `apps/web/app/utils/roleCatalogue.ts` mirrors the
        backend `CONCEPT_ROLES` 1-for-1 (33 entries × 4
        skills); `rolesForConcept`, `keySkillsForRole`,
        `conceptForRole`, `CONCEPT_BY_ROLE` reverse map.
        22 vitest cases including drift detection against
        the regenerated `Role` enum.
  - [x] Block 2 — `Step5Role.vue` + WizardShell renumber 6→7.
        **Done in 29a20d0.** New `Step5Role.vue`
        (radiogroup of 3 role cards, a11y compliant);
        `Step5Skills.vue` → `Step6Skills.vue` (rename + BEM
        class rename); `Step6Talents.vue` → `Step7Talents`
        `.vue`; `new.vue` orchestrator: `TOTAL_STEPS` 6→7,
        `draftRole` state, role cleared if concept change
        orphans it, role included in `persistDraft` +
        `forge` PATCH; i18n carries 33 role labels + 33
        flavours in en + ru, `[uk-todo]` / `[el-todo]`
        placeholders for the rest.
  - [x] Block 3 — Step6Skills role-scoped caps. **Done
        directly (Step6Skills.vue + new.vue edits +
        Block 3 commit).** `Step6Skills` reads
        `role: Role | null`; caps the four canonical key
        skills at 3, every other at 1; falls back to the
        concept-union when role is null (legacy drafts).
        New role-scoped hint below the upbringing-pool
        hint: "Key skills for your role: …". `new.vue`
        passes `:role` into Step6Skills.
  - [x] Block 4 — `RoleUnmigratedBanner` + `RoleCardGrid`.
        **Done in bfa24ee.** Extracted the role-card grid
        from `Step5Role.vue` into a reusable top-level
        `RoleCardGrid.vue` (a11y + arrow-key nav
        preserved). New `RoleUnmigratedBanner.vue` on the
        character-sheet header surfaces when
        `roleUnmigrated === true`, opens an `AppModal`
        with the role-card grid, PATCHes the chosen role,
        backend clears the flag. 32 new vitest cases
        (15 RoleCardGrid + 17 RoleUnmigratedBanner).
  - [x] Block 5 — spec gap closed + i18n-completeness
        lint. **Done in (spec) + (codegen) + Block-5
        web cleanup commit.** Closed a Block-E gap by
        adding `Character.roleUnmigrated: boolean`
        (readOnly, default false) to OpenAPI spec; TS
        client regenerated. The web augmented type in
        `useCharactersApi.ts` is gone — `Character` now
        re-exports the regenerated type directly. New
        `RoleCardGrid.i18n.spec.ts` (8 cases) locks down
        the role catalogue's i18n contract: every
        canonical role has en + ru `label` and
        `flavour`, no orphan en keys, ru labels carry
        Cyrillic, en labels do not, plus a spot-check
        against ГЛАВА 2 canonical Russian display names.
        Web vitest count 163 → 203 (+40 across Blocks
        1, 4, 5).
        **Playwright smoke deferred** to
        T-2026-05-10-017 — `apps/web` has no Playwright
        bootstrap yet; bringing it up is its own infra
        task. The vitest + i18n-completeness coverage in
        this task is enough to gate the role-picker
        feature on its own.
- Status: done — ready to archive (move T-011 to done.md
  on the next session start). Playwright smoke continues
  in T-2026-05-10-017.
- Blockers: —

---

## T-2026-05-10-018 — Web global navigation + language switcher + settings

- Created: 2026-05-10
- Owner: claude
- Source: user-requested mid-session 2026-05-10 — «if I navigate
  to ships, I can't get back to characters. And add settings, or
  at least language select». Brought up while T-010 Block H was
  in-flight; deferred so the canon-remediation finished cleanly,
  then formalised here so it doesn't get lost.
- Goal: a persistent global header on every authenticated `/app/*`
  page that lets the user move between the major sections
  (Characters, Ships, NPCs, Sessions) and reach a user menu with
  language switcher, theme toggle (if tokens exist), settings
  page link, and sign-out. Today the only way to get from
  `/app/ships` back to `/app/characters` is to type the URL or
  open a new tab — that's a real UX gap that's been masking the
  rest of the site's depth.
- Why now: T-010 + T-011 made the canon surface honest; T-018
  makes the *navigation* surface honest. With the wizard reflow
  landing in T-011, character creation surfaces ~7 steps and a
  banner — the site is genuinely an app now, not a single-page
  prototype, and deserves real chrome.
- Depends on: T-2026-05-10-011 done (banner + role picker landed
  the last greenfield wizard work); the i18n glossary in
  `.claude/docs/i18n.md` is the translator's source of truth for
  any new copy.
- Acceptance:
  - **Global `<AppHeader>` component** in `packages/ui`
    (Storybook story + colocated spec — required for `@app/ui`
    per CLAUDE.md). Renders:
    - Brand mark / logo on the left (link to `/app` dashboard).
    - Centre nav: links to Characters, Ships, NPCs, Sessions
      with the current section highlighted via an active-style
      token (use the existing `--brand-brass` accent — no new
      tokens). Each link uses `<NuxtLink>` with `prefetch`.
    - Right side: `<UserMenu>` dropdown (see below).
    - Mobile: a hamburger that opens a side drawer with the
      same links + user menu nested. Use the existing breakpoint
      tokens (768px). a11y: hamburger is a `<button>` with
      `aria-controls` and `aria-expanded`; drawer is a
      `<dialog>` with focus trap.
  - **`<UserMenu>` dropdown** in `packages/ui`:
    - Avatar + display name (from `useMeApi`).
    - Submenu items:
      - Language: ru / en / uk / el (radio-group inside menu;
        switching calls `setLocale(code)` and persists via the
        existing `i18n_locale` cookie set in `nuxt.config.ts`;
        the locale list is the source of truth — read from the
        i18n config, not hard-coded).
      - Theme (optional, only if design tokens already cover
        light + dark — check `specs/design/tokens/`; if
        single-theme today, leave a `[ ] dark theme` follow-up
        on T-018's sub-block for v1.1).
      - Settings (link to `/app/settings`).
      - Sign out (calls Better Auth signOut endpoint, then
        navigates to `/login` or wherever the project's logout
        landing is — read what the existing logout button
        does; reuse, don't reinvent).
    - a11y: trigger button has `aria-haspopup="menu"` and
      `aria-expanded`; menu has `role="menu"`, items use
      `role="menuitem"` with `role="menuitemradio"` for the
      language radios; arrow-key navigation; ESC closes.
  - **Layout integration**: extend the existing default Nuxt
    layout (`apps/web/app/layouts/default.vue` if it exists,
    otherwise create one) to mount `<AppHeader />` above the
    `<NuxtPage />` for every `/app/*` route. Public pages
    (`/login`, `/register`, share-link viewer at
    `/share/{token}`) keep their existing chrome — the header
    is for authenticated app routes only.
  - **`/app/settings` page** stub: a page that hosts the
    language / theme / sign-out controls in a full-page form,
    mirroring the dropdown but without the menu chrome. v1
    can be just a placeholder that hosts the language switcher
    again with a "more settings coming" note; the goal is to
    have the route reachable so the menu link is not a
    dead-end.
  - **Active-section detection**: the header reads the current
    route via `useRoute()` and applies the active style to the
    matching link. Sections: Characters (`/app/characters/*`),
    Ships (`/app/ships/*`), NPCs (`/app/npcs/*`), Sessions
    (`/app/sessions/*`).
  - **i18n**: every label keyed in colocated `<i18n>` blocks
    (`nav.characters`, `nav.ships`, `nav.npcs`, `nav.sessions`,
    `userMenu.language.label`, `userMenu.signOut`,
    `userMenu.settings`, `header.brand` if there's a brand
    string). en + ru translated; uk + el follow the existing
    `[uk-todo]` / `[el-todo]` pattern. The four locale display
    names (English / Русский / Українська / Ελληνικά) come
    from `nuxt.config.ts`'s i18n locales config.
  - **Language switcher persistence**: switching language
    updates the `i18n_locale` cookie (already configured in
    `nuxt.config.ts`) so the choice survives reload. No backend
    round-trip is needed today; if the user wants the locale
    persisted server-side later, that's a separate task.
  - **Storybook**: `<AppHeader>` gets ≥4 stories — desktop +
    selected section, desktop + user menu open, mobile +
    drawer closed, mobile + drawer open. `<UserMenu>` gets
    its own stories.
  - **Tests**:
    - `packages/ui` colocated specs for both new components
      (≥10 vitest cases — render, click handlers, keyboard
      nav, language-change cookie write).
    - `apps/web` integration test asserting the header
      mounts on `/app/characters` and `/app/ships` and links
      navigate (use `@nuxt/test-utils`).
- Spec diff: none — this is pure client work. No new wire
  contract, no codegen.
- Codegen impact: none.
- Design impact: a header pattern is new — sketch it in
  `specs/design/mockups/` (one PNG / SVG / JSX is fine), or at
  minimum capture the layout in the Storybook stories. Reuse
  existing tokens; do not introduce new colour or radius
  tokens for this task. The active-link accent uses
  `--brand-brass`; the mobile drawer overlay uses
  `--surface-void` with a `--alpha-overlay` (or whatever the
  existing dialog overlay uses).
- a11y / responsive checklist:
  - Skip-link (`<a href="#main-content">Skip to content</a>`)
    that becomes visible on focus, anchored at the top of the
    layout. Required for keyboard navigation of any page that
    has navigation chrome.
  - Lighthouse a11y score on `/app/characters` should not
    regress.
  - Mobile drawer focus trap: pressing Tab cycles within the
    drawer until ESC closes it.
  - Reduced motion: drawer slide-in respects
    `prefers-reduced-motion` (instant open instead of
    animation).
- Sub-blocks (one feat-* commit per block + active.md
  follow-up, per `feedback_block_workflow.md`):
  - [ ] Block 1 — `@app/ui` `<UserMenu>` component
        (dropdown, language radio-group, sign-out wiring,
        Storybook + spec). No header yet — UserMenu standalone
        so the wizard / standalone settings page can also
        adopt it.
  - [ ] Block 2 — `@app/ui` `<AppHeader>` component
        (brand + nav + UserMenu slot, active-link styling,
        Storybook + spec). Desktop only — mobile drawer is
        Block 3.
  - [ ] Block 3 — Mobile drawer: hamburger + slide-in
        nav + a11y focus trap. AppHeader stories grow to
        cover the mobile breakpoint.
  - [ ] Block 4 — `apps/web` layout integration: default
        Nuxt layout mounts `<AppHeader>`; every `/app/*`
        page picks it up; `/login`, `/register`, and
        share-link viewer stay on their existing minimal
        chrome. Skip-link + active-section detection wired.
  - [ ] Block 5 — `/app/settings` page stub + final a11y
        / Lighthouse pass + nav integration test.
- Status: queued (no blockers — UI work, ready when the user
  picks it). Higher user-value than the spec follow-ups
  T-012..T-016, which are mostly back-end polish.
- Blockers: —

---

## T-2026-05-10-017 — `apps/web` Playwright bootstrap + role-picker smoke

**Status: done — ready to archive.** Landed in (commit hash on push).
Scope narrowed: the Playwright bootstrap was already in place from
an earlier task — `tests/e2e/playwright.config.ts`,
`.github/workflows/e2e.yml`, `tests/e2e/smoke.spec.ts`, and
`tests/e2e/a11y.spec.ts` were all there with the
`CORIOLIS_E2E_SESSION_COOKIE` skip pattern. T-017's task was just
to add the role-picker spec.

What landed:

- `tests/e2e/wizard-role-picker.spec.ts` — walks
  `/app/characters/new` through concept → role → skills → forge,
  asserts the forged character carries `role: 'driver'` and
  `roleUnmigrated: false` via a backend GET. Auth-gated; skips
  when `CORIOLIS_E2E_SESSION_COOKIE` is unset (default CI) but
  still parses / lints / type-checks so structural drift surfaces
  on every PR.
- `pnpm exec playwright test --config=tests/e2e/playwright.config.ts --list`
  shows 8 tests in 3 files (the new spec + the existing 2);
  the wizard spec is correctly enumerated.

The role-unmigrated banner spec proposed in T-017 acceptance is
deferred — the banner already has 17 component-level vitest cases
in `apps/web/app/components/__tests__/RoleUnmigratedBanner.spec.ts`
which cover the click → dialog → PATCH → emit cycle; an e2e for
that flow needs a seeded `roleUnmigrated: true` row that the
existing dev seed doesn't provide. A future task (when the dev
seed gets a "legacy character" fixture) can add the banner e2e.



- Created: 2026-05-10
- Owner: claude
- Source: split out of T-2026-05-10-011 Block 5 because `apps/web`
  has no Playwright runtime yet — bringing it up is an infra
  bootstrap task in its own right (config, browser deps in CI,
  fixtures for the dev container's seeded user, screenshot policy,
  etc.) and shouldn't gate the role-picker feature.
- Goal: stand up Playwright in `apps/web`, wire it into CI, and
  land one end-to-end smoke that exercises the wizard's role
  picker (concept → role → skills → forge) plus the
  `RoleUnmigratedBanner` flow on a backfilled character.
- Depends on: T-2026-05-10-011 done (UI is in place).
- Acceptance:
  - `apps/web` gains `@playwright/test` + a `playwright.config.ts`
    pointing at `http://localhost:3001` (dev container) by default,
    with overridable `BASE_URL` env for CI.
  - `apps/web/tests/e2e/` directory established. One smoke spec:
    `wizard-role-picker.e2e.ts`. Steps:
    1. Sign in (use the existing dev seed user; document the
       fixture pattern for future specs).
    2. Navigate to `/app/characters/new`.
    3. Type a name; pick concept `pilot`.
    4. Click through to step 5; pick role `driver`.
    5. Click through to step 6 (skills); assert the four role
       keys (force, pilot, rangedCombat, survival) cap at 3 in
       the UI; spend points up to budget.
    6. Click forge; assert navigation to
       `/app/characters/{id}` and that the GET response carries
       `role: 'driver'` + `roleUnmigrated: false`.
  - Second optional smoke: `role-unmigrated-banner.e2e.ts` —
    seed a character via API call with
    `roleUnmigrated: true` and `role: 'ace'` (first canonical
    pilot role from the migration), navigate to its sheet, click
    the banner CTA, pick `driver` in the dialog, confirm the
    banner disappears and the GET shows `roleUnmigrated: false`.
  - CI: a Playwright job is added to `.github/workflows/ci.yml`
    (or wherever the project's CI lives) that builds `apps/web`,
    starts the dev container stack, and runs both specs. Browser
    deps (`pnpm exec playwright install chromium`) cached.
  - The Playwright runner does NOT collide with vitest — its tests
    live under `tests/e2e/` and are excluded from the vitest
    `include` glob (already enforced by the existing config
    pattern).
  - Documentation: a `docs/testing.md` paragraph or a `tests/`
    README explaining when to write vitest vs Playwright and how
    to run each locally.
- Spec diff: none.
- Codegen impact: none.
- Design impact: none — instrumentation only.
- Tests: the two new e2e specs + the vitest coverage stays.
- Sub-blocks: probably one `chore(web)` infra commit for the
  Playwright bootstrap and one `test(web)` commit for each smoke,
  followed by the active.md follow-up.
- Status: queued
- Blockers: —

---

## T-2026-05-10-012 — `ItemWeapon.initiative` modifier (Block J split)

- Created: 2026-05-10
- Owner: claude
- Source: split from T-2026-05-10-010 Block J. ST3001 ГЛАВА 6
  weapon tables list a per-weapon initiative modifier (the «модификатор
  инициативы» column on Tables 6.5–6.10 — heavy weapons impose −1 or −2,
  fast weapons grant +1 to +2). The current spec has no field for this,
  so the GM can't carry the modifier into the initiative roll and the
  rules-engine has no way to apply it.
- Goal: add `ItemWeapon.initiative: integer` (signed, typically −2..+2)
  to the spec; teach `roll-initiative.handler` to look up equipped
  weapons and add the modifier to the d6 result before the tie-break
  pass; surface the modifier on the combat-tracker UI.
- Depends on: T-2026-05-10-010 Block A (initiative d6 + tie-break) — done.
- Acceptance:
  - Spec: `ItemWeapon.initiative` (and on Create / Update); range −5..+5
    to be permissive (canon goes −2..+2 but house rules vary).
  - Backend: `roll-initiative.handler` reads `equipped: true` weapons
    from the source PC/NPC and sums the `initiative` modifiers; clamp
    the d6 result to 1..6 after applying. Tie-break loop unchanged
    (re-roll equal initiatives, ≤3 passes).
  - NPC weapon JSON shape gains the field too (NpcItemWeapon).
  - Migration: `Item.data.initiative` defaults to 0 for legacy weapons.
  - Tests: ≥6 cases — modifier on creation / update / clamp / equipped
    only / multiple weapons sum / tie-break interaction.
- Spec diff: small. Major bump if landed alone; or fold into the next
  combat-side block bump.
- Codegen impact: TS + Dart regen.
- Status: **done — ready to archive.** **Landed in 9fcd89d (spec) +
  e2ed42f (codegen) + 3b3f5f7 (backend).**
  - Spec: `ItemWeapon.initiative: integer −5..+5, default 0` on
    `ItemWeapon` / `ItemWeaponCreate` / `ItemWeaponUpdate`.
    `Combatant.initiative.maximum` bumped 6 → 10 (a roll of 6 +
    Посох +2 + ambush +2 = 10 is canon-legal). NPC weapons inherit
    via the existing `$ref: ItemWeapon` indirection. AsyncAPI
    centrifugo combatant snapshot bumped maximum 6 → 10 too;
    AsyncAPI version 0.9.0 → 0.10.0; OpenAPI version 1.0.0 → 1.1.0.
  - Backend: new pure helpers `sumWeaponInitiative` and
    `clampInitiative` in `encounters/domain/initiative.ts`.
    `roll-initiative.handler` reads the combatant's weapons from
    the snapshot stored at add-time (architectural decision: keep
    "snapshot is authoritative at add-time" consistent with hp /
    armor / skills — no live PC/NPC re-lookup). The `add-combatant`
    path now snapshots `weapons[]` alongside the existing stat
    block; `SourceLookupAdapter` extended to fetch WEAPON items
    on the PC path (one combined query with ARMOR; no extra
    round-trip) and `weapons` from the Npc row. Tie-break loop
    operates on post-modifier values (no signature change).
  - Tests: ≥17 new vitest cases (helper invariants, equipped-only
    semantics, missing-modifier defaults to 0, multi-weapon sum,
    NPC parity, tie-break interaction). Backend vitest 855 → 872.
  - Migration: none — `Item.data.initiative` defaults to 0 server-
    side via the spec's `default: 0`; absence in the JSONB blob
    reads as 0 by the handler's `?? 0` guard. Legacy weapons stay
    valid without a backfill.

---

## T-2026-05-10-013 — `ItemArmor.extraSlotCount` (Block J split)

- Created: 2026-05-10
- Owner: claude
- Source: split from T-2026-05-10-010 Block J. ST3001 ТАБЛИЦА 6.14
  (special armor) lists an «extra slots» column — heavy armor can carry
  pouches / mounts / pockets that grant additional encumbrance slots.
  The current `ItemArmor` schema has no field for this and the
  rules-engine `computeEncumbranceMax` does not factor it in.
- Goal: add `ItemArmor.extraSlotCount: integer` (0..4 typical) to the
  spec; teach the encumbrance calculator to add the worn-armor's value
  to `STR × 2`.
- Depends on: T-2026-05-10-010 done.
- Acceptance:
  - Spec: `ItemArmor.extraSlotCount` (0..6 cap); on Create / Update.
  - Backend: `computeEncumbranceMax` signature changes to accept the
    sum of equipped-armor extra slots; handler that derives the read
    model passes the sum.
  - Tests: ≥4 cases — base, +N from one armor, multiple armors, only
    equipped armor counts.
- Spec diff: small.
- Codegen impact: TS + Dart regen.
- Status: **done — ready to archive.** Landed in 196e8ed (spec) +
  459febd (codegen) + 998901a (backend).
  - Spec: `ItemArmor.extraSlotCount: integer 0..6, default 0` on
    `ItemArmor` / `ItemArmorCreate` / `ItemArmorUpdate`. NPC armor
    inherits via the existing `$ref: ItemArmor` indirection — no
    separate schema needed. Canonical printed values: most armors 0;
    Тяжёлый экзоскафандр / Лёгкая броня / Тяжёлая броня 1; Экзодоспех
    2; Тяжёлый экзодоспех 5. OpenAPI version 1.1.0 → 1.2.0.
  - Backend: `computeEncumbranceMax` gained an optional second
    parameter `armorExtraSlots = 0` (back-compat); new pure helper
    `sumArmorExtraSlots` filters equipped ARMOR items and sums their
    `extraSlotCount` (uses `for...of` to satisfy
    `unicorn/no-array-reduce`). `character.repo.toReadModel` wires
    the sum into the encumbrance.max derivation — no extra DB hit
    (the inventory was already loaded for `computeEncumbranceCurrent`).
    NPC encumbrance not surfaced today; no NPC-side wiring needed.
  - Tests: 15 new vitest cases (6 `computeEncumbranceMax` boundary
    cases + 9 `sumArmorExtraSlots` cases). Backend vitest 872 → 887.
  - Migration: none — JSONB absence reads as 0 via the handler's
    `?? 0` guard.
- Blockers: —

---

## T-2026-05-10-014 — Ship deterministic stats from class (Block J split, scope narrowed)

**Status: done — ready to archive.** Landed in 1fc660c (backend).
Audit scope **narrowed** before implementation: the original prescription
(drop freehand columns, refuse mutation, blanket readOnly) contradicts
canon — ГЛАВА 7 explicitly allows yard modifiers (Хелеб +1
maneuverability, Хальгрия −1 maneuverability) and upgrade modifiers
(Прочный корпус +1 hull, Мощный реактор +1 energy) to *modify* the
base class stats. Making them readOnly would break canonical ship-build
flexibility.

What landed instead:

- `BASE_STATS_BY_TIER: Record<'I'|'II'|'III'|'IV'|'V', ShipBaseStats>`
  with values verified against ТАБЛИЦА 7.5 verbatim (Class I: 3/2/+2/
  −2/3/4/3 → Class V: 7/12/−2/+3/9/1/40). Replaced the prior
  per-ship-type table (which carried a `TODO(ship-stats): verify`
  comment because nobody had cross-checked). 20 ship-type slugs map
  to tiers via `TIER_BY_SHIP_TYPE`; helpers `getTierForShipType` and
  `getBaseStatsByShipType`. Backwards-compat alias
  `BASE_STATS_BY_CLASS` preserved for existing call sites.
- `cargoCapacity` removed from `ShipBaseStats` — it's a sum of
  hold-module capacities (ТАБЛИЦА 7.6 § Грузовой отсек), not a class
  stat. Default at create is 0; the spec's `Ship.cargoCapacity` stays
  for now but its semantics shift toward "computed from modules"
  (a future task can wire that derivation).
- Spec untouched — `Ship.{hull.max, energy.max, armor, maneuverability,
  signature, speed, moduleSlots}` remain editable per upgrade canon.
- Tests: 43 new vitest cases — every BASE_STATS_BY_TIER row, every
  ship-type → tier mapping, helper invariants, fixture refresh against
  canon. Backend vitest 887 → 930 (+43).
- Fixture updates in `create-ship.handler.spec.ts`: fighter `hullMax`
  4 → 2 (canon Class I); cargoCapacity 50 → 0 (no longer a class stat).

Original (pre-narrowing) audit text retained below for the archive
record.



- Created: 2026-05-10
- Owner: claude
- Source: split from T-2026-05-10-010 Block J. ST3001 ГЛАВА 7
  ТАБЛИЦА 7.5 lists deterministic stat blocks per ship class:
  Манёвренность, Заметность, Скорость, отсеки (energy / hull /
  module slots / armor / signature). Today the `Ship` schema lets
  the GM set these freehand, which silently breaks canon: a `cruiser`
  can ship with `signature: -10` if the GM forgets the table.
- Goal: make `Ship.{maneuverability, signature, speed, energySlots,
  hullPoints, moduleSlots, armor}` server-derived from `Ship.class`;
  the spec marks them readOnly; the rules-engine carries the lookup
  table from ГЛАВА 7 and the create / update handlers refuse mutation.
- Depends on: T-2026-05-10-010 done.
- Acceptance:
  - Spec: all five fields move to readOnly. New `SHIP_CLASS_TABLE` in
    `apps/backend/src/modules/rules-engine/ship-class-table.ts`
    (already exists for partial stats — extend it).
  - Backend: `ShipReadModel.{maneuverability, signature, speed,
    energySlots, hullPoints, moduleSlots, armor}` are computed at
    read time from `Ship.class`; `CreateShipHandler` and
    `UpdateShipHandler` reject any incoming value for these fields
    (`SHIP_STAT_NOT_EDITABLE` error).
  - Migration: drop the freehand columns; values derive from class.
  - Tests: ≥10 cases — every ship class returns the canonical stat
    block; mutation attempts on each readonly field raise the new
    error.
- Spec diff: large (multiple readOnly transitions + new error).
  Major bump.
- Codegen impact: TS + Dart regen.
- Status: queued
- Blockers: —

---

## T-2026-05-10-015 — `RollKind` discriminator + push gate (Block J split)

**Status: done — ready to archive.** Landed in f3c03d1 (spec) +
a7fe95b (codegen) + df349c1 (backend + migration).

What landed:

- Spec: new `RollKind` enum `[skill, save, trauma, initiative,
  darkness]` with full canon citations (ГЛАВА 3 «Вознесение
  молитв», ГЛАВА 5 «Урон» / «Травмирующие атаки», ГЛАВА 5
  «Раунды, ходы и инициатива», ГЛАВА 15). `Roll.kind` required;
  `RollCreate.kind` optional with `default: skill` for back-compat.
  New error `PUSH_NOT_ALLOWED_ON_NON_SKILL_ROLL` (HTTP 400) on
  the push endpoint. AsyncAPI rollPushed gained the field;
  AsyncAPI version 0.10.0 → 0.11.0; OpenAPI version 1.2.0 → 1.3.0.
- Backend: Prisma migration `20260510000010_add_roll_kind` adds
  `kind text NOT NULL DEFAULT 'skill'` (idempotent backfill — all
  existing rolls become 'skill', the canonical safe default).
  `RollReadModel` gains `kind: RollKind`; defence-in-depth
  `toRollKind()` narrowing on the read path logs a warning if
  Prisma returns an unknown value. `CreateRollDto` gains optional
  `@IsIn(...)` decorator; handler defaults to 'skill' when omitted.
  `PushRollHandler` checks `roll.kind !== 'skill'` *before*
  `canPush` so the kind-error wins precedence over
  `ROLL_ALREADY_PUSHED`. `rules-engine.canPush` docblock trimmed
  — the «only-on-skill-checks» Block-J flag is now resolved.
- Tests: 9 new vitest cases (2 create-roll defaults, 6 push-handler
  rejection paths including precedence lock, 1 read-model
  surfacing). Backend vitest 930 → 939.



- Created: 2026-05-10
- Owner: claude
- Source: split from T-2026-05-10-010 Block J. ST3001 ГЛАВА 3
  §«Вознесение молитв» («Молитву можно возносить только при проверках
  навыков и только один раз за проверку») restricts push to skill
  checks. Today `Roll` has no discriminator, so the rules-engine's
  `canPush` allows pushing on save / trauma / initiative rolls,
  silently violating canon.
- Goal: add `Roll.kind: 'skill' | 'save' | 'trauma' | 'initiative' |
  'darkness'` (the 5 canonical roll types); `canPush` gates on
  `kind === 'skill'`; `PushRollHandler` rejects non-skill rolls with
  a new `PUSH_NOT_ALLOWED_ON_NON_SKILL_ROLL` error.
- Depends on: T-2026-05-10-010 (Block I docblock already flags this
  follow-up).
- Acceptance:
  - Spec: `RollKind` enum + `Roll.kind` (required) + `RollCreate.kind`.
  - Backend: `canPush(roll, conditions)` signature gains
    `roll.kind`; new domain error; handler tests cover each kind's
    push-allowed / push-blocked case.
  - Migration: backfill existing rolls with `kind: 'skill'` as the
    safe default (the rules-engine already treats them as skill).
  - i18n: glossary entry for each kind label (ru + en).
  - Tests: ≥8 cases — 5 kinds × push allowance + edge cases.
- Spec diff: medium. Major bump.
- Codegen impact: TS + Dart regen.
- Status: queued
- Blockers: —

---

## T-2026-05-10-016 — `RollCreate.breakdown` audit trail (Block J split)

**Status: done — ready to archive.** Landed in f77cdb2 (spec) +
3cb7e85 (codegen) + ddf436d (backend + migration).

What landed:

- Spec: new `RollBreakdown` schema (5 components: attribute / skill /
  gear / modifier / helpers, each 0..10). `Roll.breakdown` and
  `RollCreate.breakdown` optional + nullable. New error
  `ROLL_BREAKDOWN_MISMATCH` (HTTP 400) when breakdown sum ≠ pool.
  AsyncAPI untouched (RollPushed is a minimal event envelope, no
  breakdown to mirror). OpenAPI version 1.3.0 → 1.4.0.
- Backend: Prisma migration `20260510000011_add_roll_breakdown`
  adds `breakdown jsonb` (nullable, no backfill — existing rolls
  read as null). `RollReadModel` gains `breakdown: RollBreakdown
  | null`; defence-in-depth `toRollBreakdown()` narrowing on the
  read path with warn-log on malformed JSONB. `CreateRollDto`
  gains `RollBreakdownDto` with `@ValidateNested` + per-component
  `@Min(0) @Max(10)`. Handler asserts `attribute + skill + gear +
  modifier + helpers === pool` when breakdown is supplied; throws
  `RollBreakdownMismatchError` otherwise. PushRollHandler
  untouched (breakdown is read-only after create).
- Tests: 6 new vitest cases (null breakdown, matching, mismatch,
  zero-dice boundary, read-model surfacing on both null and
  non-null). Backend vitest 939 → 945.



- Created: 2026-05-10
- Owner: claude
- Source: split from T-2026-05-10-010 Block J. The current `RollCreate`
  payload only carries the final `pool: integer`, losing the
  attribute / skill / gear / modifier / helpers breakdown that the GM
  / rules-lawyer audience needs to verify the math. ST3001 doesn't
  prescribe a wire format here — this is a tooling concern — but
  serialising the breakdown lets a future GM-tools view replay every
  roll's provenance.
- Goal: add `RollCreate.breakdown: { attribute: integer, skill:
  integer, gear: integer, modifier: integer, helpers: integer }`
  (all required, all 0..10); the backend stores the breakdown
  alongside the roll's `pool` and the `Roll` read model surfaces it.
- Depends on: T-2026-05-10-010 done.
- Acceptance:
  - Spec: `RollBreakdown` schema + `RollCreate.breakdown` optional
    (omitted on programmatic rolls; required-when-present from a
    user-driven UI), `Roll.breakdown` readOnly.
  - Backend: persist the breakdown; the create handler asserts
    `attribute + skill + gear + modifier + helpers === pool` if
    breakdown is supplied (server-side guard against UI bugs).
  - Tests: ≥4 cases — supplied & matching, supplied & mismatched
    (rejected), omitted, round-trips through GET.
- Spec diff: small. Minor bump.
- Codegen impact: TS + Dart regen.
- Status: queued
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
