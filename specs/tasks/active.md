## T-2026-05-09-005 — character creation rules alignment with ST3001

- Created: 2026-05-09
- Owner: claude
- Spec: Coriolis ST3001 — `ГЛАВА 2 Персонажи игроков` + `ГЛАВА 4 Достоинства`
  (Russian rulebook, canonical per `.claude/projects/.../memory/coriolis-rulebook-ru.md`).
  PRD §5.2 is silent / partially wrong on these mechanics.
- Goal: make web character creation enforce the rulebook's budget,
  caps, and talent model. User-reported gaps: skill points + attribute
  budget should depend on origin (really: **upbringing**); origin
  should drive a hint panel; talent catalog is incomplete; Icon gift
  - Crew talent are missing entirely.
- Acceptance:
  - **Upbringing field** (Plebeian/Stationary/Aristocrat) drives the
    attribute budget (15/14/13), skill budget (8/10/12), reputation
    (2/4/6), and starting wealth (500/1000/5000 birrs). Origin is
    narrative-only (free text, optional).
  - **Concept (Amplua)** is a structured enum (11 amplua per ch.2)
    with key attribute (cap 5, others cap 4) and key skills (cap 3
    at creation, others cap 1).
  - **Talents at creation = 3** (4 if mutant): one personal (from
    amplua list), one crew (from crew amplua list), one icon gift
    (auto-derived from chosen icon). Stigma if mutant.
  - **Talent catalog** populated from ch.4: 5 crew amplua × 3
    talents = 15; 9 icon gifts; ~30 personal talents.
  - Backend rejects budget violations with structured 400 + i18n.
  - Web wizard surfaces budgets/caps as hints on each step.
  - Mobile is OUT OF SCOPE — only spec/backend/web.
- Spec diff: `packages/specs/openapi/openapi.yaml` minor → 0.9.0.
  Adds Upbringing, Concept enums; Talent.kind discriminator (personal
  | crew | iconGift | stigma); CrewConcept enum; talent catalog
  reference under `components.examples` for client display.
- Codegen impact: yes (TS + Dart clients).
- Design impact: Step1/Step2/Step6 wizard pages need redesigned hint
  panels and structured pickers; stays inside existing tokens.

- Sub-steps:
  - [x] Push task to active.md
  - [x] Read ST3001 ch.2 (upbringing 15/8 — 14/10 — 13/12) and ch.4
        (5 crew × 3 + 9 icons + ~30 personal talents)
  - [x] **Block 1 — Upbringing + budgets** (committed 2026-05-09)
    - [x] openapi 0.8.1 → 0.9.0: Upbringing enum,
          CharacterCreate.upbringing required, Character.upbringing /
          origin / reputation / startingWealth, CharacterUpdate.upbringing
          (draft-only) + reputation/origin
    - [x] codegen
    - [x] Prisma migration `20260509000005_upbringing_fields`
    - [x] RulesEngine: UPBRINGING_BUDGETS, sumAttributes, sumSkills
    - [x] CreateCharacterHandler: 2..4 per-attr cap + sum ≤ budget +
          derives reputation/startingWealth
    - [x] UpdateCharacterHandler: upbringing mutable while draft, frozen
          once active (UpbringingImmutableError)
    - [x] Step2Background: 3-option SegControl + budget hint panel
    - [x] Step4Attributes / Step5Skills: derive pool from upbringing prop
    - [x] new.vue wizard parent wires upbringing through; default
          'stationary' for fresh drafts
    - [x] i18n: en + ru complete, [uk-todo]/[el-todo] placeholders
    - [x] Tests: rules-engine (+5) and CreateCharacterHandler (+8)
  - [x] **Block 2 — Concept (amplua) enum** (committed 2026-05-09)
    - [x] openapi 0.9.0 → 0.10.0: Concept enum (11 amplua); Character.concept
          and CharacterCreate/Update.concept replace free-text string with
          `Concept | null`; CharacterUpdate.concept draft-only (immutable
          once active); spec table documents key-attr / rep-modifier per amplua
    - [x] codegen
    - [x] Prisma migration `20260509000006_concept_enum` — drops the old
          `concept TEXT?` column, adds `concept Concept?` enum
    - [x] RulesEngine: CONCEPT_KEYS table (keyAttribute, keySkills,
          reputationModifier per concept), AttributeKey / SkillKey types
    - [x] CreateCharacterHandler: per-attribute cap = 5 if key (else 4),
          per-skill cap = 3 if key (else 1); reputation =
          upbringing.reputation + concept.reputationModifier (clamped ≥ 0)
    - [x] UpdateCharacterHandler: concept mutable while draft, frozen on
          active (ConceptImmutableError); recomputes derived reputation when
          either upbringing or concept changes during draft
    - [x] Step1Concept: replaced free-text concept input with an 11-chip
          structured picker + hint panel showing key attribute, key skills,
          and reputation modifier
    - [x] Step4Attributes: key-attribute cap 5 on the concept's
          keyAttribute, 4 elsewhere; AppDots :max bound to maxFor(key)
    - [x] Step5Skills: key-skill cap 3, non-key cap 1, looked up per row
          from the concept's keySkills set
    - [x] Character sheet ([id].vue): concept rendered as a localized
          readonly badge (was a free-text input that could no longer round-trip)
    - [x] i18n: en + ru concept labels in Step1Concept and the sheet,
          [uk-todo]/[el-todo] placeholders elsewhere
    - [x] Tests: rules-engine CONCEPT_KEYS specs (+15) and
          CreateCharacterHandler concept-aware specs (+6) — 384/384 backend
          and 53/53 web tests green
  - [x] **Block 3 — Talent kind discriminator** (committed 2026-05-09)
    - [x] openapi 0.10.0 → 0.11.0: `Talent.kind` enum (personal | crew
          | iconGift | stigma); new `CrewConcept` enum (free-trader /
          mercenary / explorer / agents / pilgrim — ST3001 ch.2
          §АМПЛУА КОМАНДЫ); `Character.crewConcept` field;
          `TalentCreate.kind` (defaults to personal); 400
          `TALENT_KIND_DUPLICATE` documented
    - [x] codegen
    - [x] Prisma migration
          `20260509000007_talent_kind_and_crew_concept` — adds CrewConcept
          and TalentKind enums, `character.crewConcept` column, `talent.kind`
          column (default `personal`)
    - [x] RulesEngine: `CrewConcept` / `TalentKind` types,
          `ICON_GIFT_TALENT_IDS` mapping (icon → gift-talent ID)
    - [x] CreateCharacterHandler accepts `crewConcept` and auto-seeds
          an `iconGift` talent from the chosen icon (placeholder name/desc
          until Block 4 catalog ships); duplicate non-personal kind rejected
          via `TalentKindDuplicateError`
    - [x] UpdateCharacterHandler: `crewConcept` mutable while draft,
          frozen on active (`CrewConceptImmutableError`)
    - [x] AddTalentHandler: persists `kind` (defaults to personal),
          enforces "≤1 of each non-personal kind" via
          `TalentRepo.listByCharacterId`
    - [x] CharacterRepo + ShareLinkRepo: extended SELECT, mappers, and
          kebab→snake mapping for the Prisma `CrewConcept` enum identifier;
          `talents.create` nested write seeds iconGift on create
    - [x] Web Step2Background: chip-style CrewConcept picker (5 amplua)
          with EN/RU labels and per-amplua descriptions
    - [x] Web Step6Talents: 3-section split (personal pool / crew slot
          derived from selected CrewConcept / icon-gift slot derived from
          chosen icon); empty placeholders prompt the player back to
          Step 2/3
    - [x] new.vue wires `draftCrewConcept` through autosave + forge
          payload; hydrates from existing draft on resume
    - [x] Tests: AddTalentHandler (+5), CreateCharacterHandler (+5),
          UpdateCharacterHandler (+3) — 397/397 backend, 53/53 web green
  - [x] **Block 4 — Talent catalog data** (committed 2026-05-09)
    - [x] New `packages/specs/src/talents.ts` ships the canonical
          ST3001 ch.4 catalog: 9 icon gifts (one per icon, kebab IDs match
          the existing `gift-{iconId}` convention), 15 crew talents
          (5 amplua × 3), 26 personal talents, 3 pasynok stigmas. Each
          entry carries stable `id`, `kind`, `name`/`description` in
          en+ru with `[uk-todo]/[el-todo]` placeholders, and `rankCap`
          1..3.
    - [x] Helpers: `getIconGiftByIconId`, `getCrewTalentsByConcept`,
          `findCatalogTalentById`. `@app/specs` package gained `main` +
          `types` so backend's classic `moduleResolution: Node` resolves
          the workspace barrel cleanly.
    - [x] Backend `CreateCharacterHandler` now hydrates the iconGift
          seed via `getIconGiftByIconId(iconId)` — talent record stores
          catalog ID in `name` and the canonical EN description as
          readable fallback for non-catalog consumers. Old
          `ICON_GIFT_TALENT_IDS` constant removed from rules-engine
          (catalog is the single source of truth).
    - [x] Web `Step6Talents.vue` rewritten on top of the catalog:
          personal pool renders all 26 entries with rule text; crew
          section renders 3 cards from the chosen amplua; iconGift slot
          shows localized name + full rule text. New emits
          `update:personalTalentId` / `update:crewTalentId` (single-pick).
    - [x] `apps/web/app/pages/app/characters/new.vue`: tracks
          `draftPersonalTalentId` + `draftCrewTalentId`, posts each pick
          via `addCharacterTalent` after `forge()` succeeds (iconGift
          stays auto-seeded server-side). `useCharactersApi` gained
          `addTalent`.
    - [x] Tests: new `talents-catalog.spec.ts` (15 specs covering
          catalog shape — 9 icons covered, 5 amplua × 3 crew, ≥26
          personal, 3 stigmas, unique IDs, en+ru non-empty,
          uk/el placeholders, rankCap range, helpers); updated
          `create-character.handler.spec.ts` so the iconGift assertion
          checks catalog-hydrated description (regression guard against
          reverting to empty placeholder). 412/412 backend, 53/53 web.
  - [ ] **Block 5 — Mutant flag + stigma (defer if scope blows up)**
    - openapi: Character.mutant, mutant lineage enum (zirba | shingura
      | nerida) → 1 of 3 stigma talents
  - [ ] tests: backend rules-engine specs (≥15), web wizard specs
  - [ ] lint + typecheck + format
  - [ ] PR with all blocks (per user's "single big PR" preference)
- Status: in-progress (block 5 next — mutant flag + stigma)
- Block 5 follow-up (start in fresh session):
  - openapi 0.11.0 → 0.12.0: `Character.mutant: boolean` (default
    false), new `MutantLineage` enum (`zirba | shingura | nerida`,
    nullable), and a `CharacterCreate.mutant` field. Codegen.
  - Prisma migration adding `mutant Boolean @default(false)` and
    `mutantLineage MutantLineage?` to Character. Match
    kebab/snake-case mapping pattern already used by CrewConcept
    (Block 3) if any enum identifier needs translation.
  - `CreateCharacterHandler`: when `mutant=true`, auto-seed one
    stigma talent (the player picks the stigma — UI selection from
    the 3 catalog entries). Validate that non-mutants cannot carry
    a `kind: stigma` talent (`AddTalentHandler` already enforces
    "≤1 of each non-personal kind", extend with a mutant-required
    check).
  - Web wizard: add a Mutant toggle on Step1 (or a new mini-step
    after Step3) that, when on, swaps Step6 crew section with a
    stigma-picker section showing the 3 stigma talents from the
    catalog. iconGift stays the same. Personal pool stays the same.
  - i18n: 3 stigma names already in catalog en+ru; Step1 mutant
    toggle copy en+ru with [uk-todo]/[el-todo].
  - Tests: ≥6 unit specs covering mutant flag persistence, stigma
    auto-pick, non-mutant rejection of stigma talents.
- Blockers: —
- Estimate: 22–34 hours total. Will commit per block to keep diff
  reviewable; merge as one PR.

## T-2026-05-09-004 — web: signup page + auth layout fixes

- Created: 2026-05-09
- Owner: claude
- Spec: bug-fix on existing auth UI (no PRD/epic)
- Goal: Add missing /signup page, fix landing CTA wiring, improve auth-page layout proportions.
- Acceptance:
  - `/signup` route exists and renders email + password + confirm form
  - Successful submit calls `auth.signUp.email` and redirects to `/`
  - Landing "Create account" button navigates to `/signup`
  - Login (and signup) page no longer feels narrow/tall: wider card, no 100dvh stretching, wordmark above card
- Spec diff: none (no wire change)
- Codegen impact: none
- Design impact: web-only — page-scoped CSS, design-token aligned
- Sub-steps:
  - [x] Push task to active.md
  - [ ] Fix index.vue onCreateAccount → /signup
  - [ ] Extend AuthClientLike (useAuth.ts) with signUp.email
  - [ ] Create apps/web/app/pages/signup.vue (mirror login.vue, add confirm-password)
  - [ ] Update login.vue layout (max-width 480px, drop 100dvh, wordmark above card)
  - [ ] lint --fix + stylelint:fix + format + typecheck
- Status: in-progress
- Blockers: —

## T-2026-05-09-003 — Epic 7 Feature 7.3: Darkness Points + push wiring (T-7.3.1.a, .b, .c)

- Created: 2026-05-09
- Owner: claude
- Spec: Epic 7, Feature 7.3, tasks T-7.3.1.a, T-7.3.1.b, T-7.3.1.c
- Goal: DP adjustment endpoint, DpEvent audit log, RollPushedEvent → +1 DP wiring.
- Acceptance:
  - `POST /api/v1/game-sessions/{id}/dp` adjusts Darkness Points atomically
  - `GET /api/v1/game-sessions/{id}/dp/events` returns paginated DpEvent audit log
  - DpEvent persisted per adjustment (source: GM_MANUAL | ROLL_PUSH | SYSTEM)
  - Only GM owner may apply negative deltas; +1 from roll push bypasses ACL via internal flag
  - RollPushedHandler emits UpdateDpCommand when gameSessionId != null
  - ≥12 new unit specs
- Spec diff: openapi.yaml 0.8.0 → 0.8.1 (additive)
- Codegen impact: yes
- Design impact: none (backend only)
- Sub-steps:
  - [x] Push task to active.md
  - [ ] openapi.yaml bump + DP paths/schemas
  - [ ] pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen
  - [ ] Prisma DpEvent model + DpSource enum + migration dp-events
  - [ ] dp/ subdirectory under game-sessions — domain, commands, queries, events, infra
  - [ ] UpdateDpCommand handler + DpRepo
  - [ ] ListDpEventsQuery handler
  - [ ] Wire RollPushedEvent → UpdateDpCommand (drop TODO(epic-7-3-dp))
  - [ ] Controller endpoint POST dp + GET dp/events
  - [ ] lint + typecheck + test
- Status: in-progress
- Blockers: —

## T-2026-05-09-002 — Epic 7 Feature 7.1 backend: DiceModule (T-7.1.1.a, .b, .e)

- Created: 2026-05-09
- Owner: claude
- Spec: Epic 7, Feature 7.1, tasks T-7.1.1.a, T-7.1.1.b, T-7.1.1.e
- Goal: Server-side Coriolis dice roller with push mechanic. Create roll, list history, push reroll.
- Acceptance:
  - `POST /api/v1/characters/{id}/rolls` → 201 Roll (server rolls pool d6 with crypto.randomInt)
  - `GET /api/v1/characters/{id}/rolls?limit=50` → 200 RollList (last 50, ordered desc)
  - `PATCH /api/v1/rolls/{id}/push` → 200 Roll (pushed dice, pushed=true) | 422 ROLL_NOT_PUSHABLE
  - RulesEngine `canPush()` returns `{ ok, reason? }`, gated on exhausted + already-pushed
  - `RollPushedEvent` emitted on event bus with `{ rollId, characterId, gameSessionId, hits }`
  - ≥18 new unit specs
- Spec diff: openapi.yaml 0.7.1 → 0.8.0; new Roll, RollCreate, RollList schemas + 3 paths
- Codegen impact: yes
- Design impact: none (backend only)
- Tests: ≥18 new specs
- Sub-steps:
  - [x] Push task to active.md
  - [ ] openapi.yaml bump + Roll paths/schemas
  - [ ] pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen
  - [ ] RulesEngine canPush update (new signature)
  - [ ] Prisma Roll model + migration rolls
  - [ ] DiceModule — domain, commands, queries, events, infra, controller
  - [ ] lint + typecheck + test
- Status: in-progress
- Blockers: —

## T-2026-05-09-001 — implement share-link backend (Epic 6 Feature 6.1)

- Created: 2026-05-09
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md §5.4, Plan §6.1
- Goal: Enable public read-only sharing of characters via unguessable slug URLs with owner controls (create, list, revoke) and lazy view tracking.
- Acceptance:
  - `POST /api/v1/characters/{id}/share` returns 201 with a `ShareLink` containing a 24-char nanoid slug.
  - `GET /api/v1/characters/{id}/shares` returns active links for the character.
  - `DELETE /api/v1/share-links/{id}` soft-revokes a link (sets `revokedAt`); subsequent `GET /api/v1/public/character/{slug}` returns 410.
  - `GET /api/v1/public/character/{slug}` returns the character without auth; filters `notes` when `includeGmNotes=false`.
  - `GET /api/v1/public/og/character/{slug}.png` returns 501.
  - View counts are batched in memory and flushed every minute.
- Spec diff: packages/specs/openapi/openapi.yaml — version 0.6.0 → 0.7.0; new paths + schemas for ShareLink.
- Codegen impact: yes — regenerate api-client-{ts,dart}
- Design impact: none (backend only)
- Tests: ≥15 unit specs covering all handlers + ViewTracker
- Sub-steps:
  - [x] Push task to active.md
  - [x] docs/adr/0003-share-link-design.md
  - [x] openapi.yaml bump + new paths/schemas
  - [x] pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen
  - [x] Prisma ShareLink model + migration share-links
  - [x] SharingModule — domain, commands, queries, infra, controller
  - [x] ViewTracker + FlushViewTrackerJob
  - [x] Stub OG image controller
  - [x] lint + typecheck + test
- Status: in-progress
- Blockers: —
