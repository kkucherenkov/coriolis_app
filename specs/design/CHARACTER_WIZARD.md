# CHARACTER_WIZARD — canonical step inventory

Single source of truth for the Coriolis character-creation flow across web
(`apps/web/app/components/wizard/Step{1..N}*.vue`) and mobile
(`apps/mobile/lib/features/characters/presentation/pages/character_create_page.dart`).
Resolves the three-way conflict logged in
[`docs/audits/design-2026-05-14.md` §4 follow-up 9](../../docs/audits/design-2026-05-14.md)
between the handoff (8 steps), the web build (7), and the mobile build (6).

The handoff is **not** the canonical source for step taxonomy. The canonical
source is **Coriolis ST3001 Глава 2 «Персонажи игроков»** — the Russian
rulebook listed in
[`MEMORY → coriolis-rulebook-ru`](../../memory/coriolis-rulebook-ru.md).
Where handoff and rulebook disagree, this doc follows the rulebook and
documents the divergence in [§5](#5-divergences-from-the-handoff).

---

## 1. Rulebook reference

ST3001 ГЛАВА 2 lists the personal-character creation order in
**«ПОРЯДОК СОЗДАНИЯ ПЕРСОНАЖА ИГРОКА»**, items 6–19. Verbatim (RU):

| #   | Rulebook step                                                  |
| --- | -------------------------------------------------------------- |
| 6   | Выбери биографию (Origin + Upbringing)                         |
| 7   | Выбери амплуа (Concept; role is selected within the archetype) |
| 8   | Определи показатель репутации                                  |
| 9   | Определись с именем                                            |
| 10  | Определись с внешним видом                                     |
| 11  | Распредели пункты характеристик (Attributes)                   |
| 12  | Вычисли показатели здоровья и рассудка (HP / MP — derived)     |
| 13  | Распредели пункты навыков (Skills)                             |
| 14  | Выбери достоинство (Talent)                                    |
| 15  | Случайным образом определи Лика-покровителя (Icon — d66 roll)  |
| 16  | Выбери личную проблему                                         |
| 17  | Определись со взаимоотношениями                                |
| 18  | Выбери снаряжение (Gear — pick from per-amplua tables)         |
| 19  | Распределите корабельные должности (team / off-flow)           |

«АМПЛУА КОМАНДЫ» (Crew Concept / Group) is a **team-level decision made
before any personal character creation** — ST3001 ГЛАВА 2 lines 24–29
(«СОЗДАНИЕ КОМАНДЫ»). It is **not** a personal-character step.

«Роль» is **not** a separate step in the rulebook — it is a refinement
within the chosen amplua (each archetype lists 3 roles in its description
table).

«Снаряжение» (Gear) **is** an explicit step in the rulebook (#18). The
player picks one item per row from per-amplua tables; it is not
auto-derived.

---

## 2. Canonical wizard for the Coriolis Companion App (v1)

The Companion App is single-character-first; the rulebook's team phase
(Crew Concept + Ship roles) is stitched into the personal flow as a
pragmatic compromise (one player per character, no GM table needed for
character creation). Wizards omit rulebook items that are pure flavour
fields with no mechanical effect (Name and Appearance are surfaced
inline outside the wizard).

The canonical inventory is **8 steps**, in this order:

| #   | Step           | Rulebook map | Backend field(s)                                   | Status                              |
| --- | -------------- | ------------ | -------------------------------------------------- | ----------------------------------- |
| 1   | **Biography**  | item 6       | `upbringing`, `origin`, `crewConcept`, age         | live (web Step2)                    |
| 2   | **Concept**    | item 7       | `concept`                                          | live (web Step1)                    |
| 3   | **Role**       | within #7    | `role` (string, validated against `concept`)       | live (web Step5)                    |
| 4   | **Attributes** | item 11      | `attributes`                                       | live (web Step4)                    |
| 5   | **Skills**     | item 13      | `skills`                                           | live (web Step6)                    |
| 6   | **Talents**    | item 14      | personal + crew + (mutant lineage) talent IDs      | live (web Step7)                    |
| 7   | **Icon**       | item 15      | `iconId` — random d66 default, manual override     | live (web Step3)                    |
| 8   | **Gear**       | item 18      | none yet — see [§4](#4-gap-against-current-builds) | **deferred — needs backend wallet** |

Notes on canonical decisions:

- **Role is a discrete UI step** (not folded into Concept) because the
  amplua → role drill-down is non-trivial UX (5 key skills + reputation
  modifier change with the role; see `Step1Concept.vue:40` and
  `roleCatalogue.ts`). Logically it remains "part of Concept selection"
  per the rulebook — the spec calls them out as adjacent, paired steps.
- **Crew Concept is folded into Biography** instead of being a discrete
  team step. The rulebook treats it as team-level and pre-character; the
  app accepts it on the personal sheet so a single player can complete
  character creation without a GM lobby. When multi-player team setup
  ships (post-v1), Crew Concept moves to a team-creation flow and is
  removed from Biography.
- **Icon comes after Talents**, not before Attributes. The rulebook
  places Icon at item 15 (after Talents at 14). The current web order
  has Icon at Step3 — see [§4](#4-gap-against-current-builds).
- **Gear is canonical** (rulebook item 18) but **deferred** until the
  backend supports a wallet (`birr` balance) and starting-kit derivation
  per amplua table. See [§7](#7-follow-up-tickets).

---

## 3. Step contracts

### 3.1 Biography (#1)

- **Inputs:** `upbringing` (required, enum
  `plebeian | stationary | aristocrat`), `origin` (optional free text
  ≤200 chars, no mechanical effect), `crewConcept` (optional, enum
  `free-trader | mercenary | explorer | agents | pilgrim`), `age`
  (optional positive integer).
- **Side effects (server):** `upbringing` drives starting attribute,
  skill, reputation, and birr budgets — single source of truth in
  `apps/backend/src/modules/characters/commands/create-character.command.ts:73`
  and the `RulesEngine` per ST3001 ch.2 table 2.2.
- **Surface:** single screen, three field groups stacked
  (`Origin · Upbringing · Crew · Age`).

### 3.2 Concept (#2)

- **Inputs:** `concept` (required, enum of 11 amplua —
  `Step1Concept.vue:8`).
- **Surface:** 3×4 grid of medallion cards. Selecting a concept reveals
  the key attribute + 5 key skills + reputation modifier inline.

### 3.3 Role (#3)

- **Inputs:** `role` (required, string; validated against `concept` by
  the server — `update-character.command.ts` + handler).
- **Surface:** card grid filtered by the chosen amplua via
  `rolesForConcept` (`apps/web/app/utils/roleCatalogue.ts`).
- **Empty state:** if no concept is picked yet, render a placeholder
  `step.role.placeholderNoConcept` and disable Continue.

### 3.4 Attributes (#4)

- **Inputs:** `strength`, `agility`, `wits`, `empathy` (all 1–5; primary
  capped at 5, others at 4 per ST3001 ch.2 attribute table).
- **Budget:** total = `upbringing.attributes` (13 / 14 / 15 — see
  `Step2Background.vue:34`).

### 3.5 Skills (#5)

- **Inputs:** 16 skills, each 0–5; key skills cap at 3, non-key at 1
  per ST3001 ch.2 «Навыки». Budget = `upbringing.skills` (8 / 10 / 12).
- **Constraint:** key skills are **role-scoped**, not concept-scoped —
  see `Step6Skills.vue` and the migration in commit `80bf2d8`.

### 3.6 Talents (#6)

- **Inputs:** one personal talent + one crew talent + (if mutant) one
  mutant lineage talent + (optionally) one stigma. Personal pool is
  filtered by amplua per the catalogue contract in `@app/specs`.
- **Surface:** stacked card lists with one-tap select; "locked" talents
  granted by Concept / Crew / Icon are visible but non-interactive.

### 3.7 Icon (#7)

- **Inputs:** `iconId` (enum of nine Icons — `Step3Icon.vue` /
  `create-character.command.ts:61`).
- **Surface:** 3×3 medallion grid with aura-pulse on hover (suppressed
  under `prefers-reduced-motion` per
  [`PATTERNS.md` § 10 «Drift»](./PATTERNS.md)).
- **Default:** the rulebook prescribes a d66 random roll. The wizard
  defaults to **manual selection** (player agency over numerology) but
  exposes a "Roll for me" affordance that maps d66 → IconId via the
  rulebook's table.

### 3.8 Gear (#8) — deferred

- **Status:** not implemented in the wizard surface. Tracked as
  [§7 follow-up T-WIZARD-GEAR](#7-follow-up-tickets).
- **Wallet contract** _(spec landed in `packages/specs/openapi/openapi.yaml`,
  block 4 — backend impl still pending under `T-WIZARD-GEAR-BACKEND-IMPL`)_:
  - `Character.startingWealth` — _read-only_ historical record (birrs the
    character was created with). Derived from `upbringing` (plebeian=500,
    stationary=1000, aristocrat=5000); immutable once written.
  - `Character.birr` — current spendable balance. Optional in the spec
    until the backend Prisma column ships; once it does, becomes
    required and the field promotes to `required:` in OpenAPI.
  - **Lifecycle:** seeded as `birr = startingWealth` on the wizard's
    `status: draft → active` (forge) transition. While `status: draft`,
    explicit PATCHes to `birr` are rejected (`BIRR_DRAFT_IMMUTABLE`) —
    the upbringing field is still mutable, so any draft-time wallet
    write would be stranded. After activation, `birr` is the canonical
    debit/credit field for Bazaar purchases (items API) and
    session payouts (`PATCH /characters/{id}` with `{ birr }`).
- **Starting-kit derivation:** still TODO — per ST3001 amplua tables
  the player picks one item per row from per-role tables. To be
  designed under `T-WIZARD-GEAR-BACKEND-DERIVE` (separate sub-block);
  options are (a) backend computes a starter pack on activation, or
  (b) client renders the per-amplua picker reading a static catalogue.

---

## 4. Gap against current builds

### Web (`apps/web/app/pages/app/characters/new.vue:25-32`, `TOTAL_STEPS = 7`)

| Canonical # | Canonical name | Current web step     | Action                       |
| ----------- | -------------- | -------------------- | ---------------------------- |
| 1           | Biography      | Step**2** Background | **Reorder → Step 1**         |
| 2           | Concept        | Step**1** Concept    | **Reorder → Step 2**         |
| 3           | Role           | Step**5** Role       | **Reorder → Step 3**         |
| 4           | Attributes     | Step**4** Attributes | **Reorder → Step 4** (no-op) |
| 5           | Skills         | Step**6** Skills     | **Reorder → Step 5**         |
| 6           | Talents        | Step**7** Talents    | **Reorder → Step 6**         |
| 7           | Icon           | Step**3** Icon       | **Reorder → Step 7**         |
| 8           | Gear           | —                    | **Add — deferred**           |

Renumber + reorder to be done in T-WIZARD-WEB-REORDER (see §7). The
existing `Step{N}Foo.vue` filenames are renamed in lockstep.

### Mobile (`apps/mobile/lib/features/characters/presentation/pages/character_create_page.dart:116-123`, 6 steps)

| Canonical # | Canonical name | Current mobile step  | Action                                                 |
| ----------- | -------------- | -------------------- | ------------------------------------------------------ |
| 1           | Biography      | Step**2** Background | **Reorder + add CrewConcept field** (currently absent) |
| 2           | Concept        | Step**1** Concept    | **Reorder → Step 2**                                   |
| 3           | Role           | —                    | **Add new step**                                       |
| 4           | Attributes     | Step**4** Attributes | **No-op**                                              |
| 5           | Skills         | Step**5** Skills     | **No-op**                                              |
| 6           | Talents        | Step**6** Talents    | **No-op**                                              |
| 7           | Icon           | Step**3** Icon       | **Reorder → Step 7**                                   |
| 8           | Gear           | —                    | **Add — deferred**                                     |

Mobile is missing Role entirely; backend already accepts `role` so the
mobile cubit must accept and round-trip the field.

---

## 5. Divergences from the handoff

The handoff (`/tmp/coriolis-handoff/coriolis-app/project/specs/design/SURFACES.md:95-157`)
proposed **8 steps** with this order:

> Origin · Concept · Group · Attributes · Icon · Skills · Talents · Gear

Documented divergences (canonical wins):

1. **"Origin" → "Biography".** The handoff's Origin step described
   Stationary / Zenithian / Firstcome / Nomad — these are not the
   ST3001 categories. The rulebook calls this stage Биография and
   uses Plebeian / Stationary / Aristocrat as upbringing categories
   (table 2.2). The Companion App follows the rulebook.
2. **"Group" merged into Biography.** Crew Concept is a team-level
   choice in the rulebook, not a personal step. Folded into Biography
   for the v1 single-character flow; lifts out into a separate
   team-creation flow when multi-player team setup ships.
3. **Role added.** Handoff has no Role step; rulebook treats role as a
   refinement within Concept. The web build promotes role to a discrete
   UI step because the role-scoped key-skill caps demand the
   indirection (commit `80bf2d8` introduced role-scoped key skills on
   the backend; `a9ca8e5` enforced them on the wizard).
4. **Icon position.** Handoff places Icon at #5; rulebook places it at
   #15 (after Talents). Canonical follows the rulebook.

---

## 6. i18n

Step labels live in the wizard component `<i18n>` blocks today:

- web: `apps/web/app/components/wizard/Step*.vue` (`step.N.title`) and
  the orchestrator `apps/web/app/pages/app/characters/new.vue:374-487`
  (`step.N.title` per locale).
- mobile: `apps/mobile/lib/i18n/characters_<locale>.i18n.json`
  (`wizardStepNLabel` / `wizardStepNTitle`).

When the reorder lands, all locale catalogues must be updated together
to avoid stale `step.N` keys pointing at the wrong screen. Per
[`I18N.md`](./I18N.md), key naming follows `domain.subject.detail` —
wizard keys live under `wizard.step.<canonical-name>.<field>` after the
reorder (e.g. `wizard.step.biography.title`), with the legacy numeric
`step.1..7` keys deleted in the same PR.

---

## 7. Follow-up tickets

Open items, to be tracked under
[`specs/tasks/active.md` T-2026-05-14-005](../tasks/active.md):

- **T-WIZARD-WEB-REORDER** — rename `StepN*.vue`, update
  `TOTAL_STEPS = 8`, reshuffle imports in `new.vue`, swap `step.N.*`
  i18n keys to `wizard.step.<name>.*`, update Vitest page spec.
- **T-WIZARD-MOBILE-PARITY** — add Role step, add CrewConcept field to
  Biography, reorder steps to canonical 8, port the i18n key rename.
- **T-WIZARD-GEAR-BACKEND** — design the wallet/starting-kit contract
  on `Character` (backend): add `birr: Int` balance, derive starting
  birr from `upbringing.wealth`, add starting-kit derivation per
  (amplua, role) per ST3001 amplua tables. Spec in
  `packages/specs/openapi/openapi.yaml` first.
- **T-WIZARD-GEAR-UI** — once the backend ships, add Step 8 Gear on
  web + mobile (per-amplua picker + Bazaar shop).
- **T-WIZARD-ICON-ROLL** — add the optional "Roll d66 for me" CTA on
  the Icon step using the rulebook table.

---

## 8. Cross-references

- [`PATTERNS.md` §7](./PATTERNS.md) — wizard footer button pairing
  (`Back` ghost + `Continue` primary).
- [`PATTERNS.md` §5](./PATTERNS.md) — modal contract (wizard close
  behaviour: drafts are session-scoped until the final commit).
- [`A11Y.md`](./A11Y.md) — focus order, landmark map, keyboard map.
- [`I18N.md`](./I18N.md) — `domain.subject.detail` key naming and
  plural design.
- [`CONTENT.md`](./CONTENT.md) — voice ("steward, not a host") and
  in-product taxonomy used in step copy.
- [`HANDOFF_NAME_MAP.md`](./HANDOFF_NAME_MAP.md) — handoff term ⇄
  project name mapping (will gain a "Wizard step" row when the reorder
  lands).
