# Phase 2 — Character Sheet

**Phase:** 2
**Tag:** `phase-2-complete`
**PRD section:** §11 (roadmap)
**Date:** 2026-05-09

## What shipped

A logged-in user can now play a character end-to-end. Phase 1 left a
sheet skeleton with name + concept inline-edit; Phase 2 fills in the
body — attributes, skills, talents, conditions, gear with derived
stats, and a six-step character creation wizard with full Cyrillic
copy. Auto-save threading is unified across every edit surface (the
new `useAutoSave` composable on web, `AppSavePulse` indicator
everywhere) and the same surfaces ship on Flutter at parity. Fifty
commits across web, mobile, backend, specs, `@app/ui`, codegen,
i18n, ADR, and task bookkeeping.

A logged-in user can:

- Open `/app/characters/[id]`, see the three-column sheet (hero
  counters, attributes + skills panels, derived stats column).
- Inline-edit attribute and skill dice values via the `AppPopover`
  popover, watch hp.max / mp.max / encumbrance.max recompute through
  the rules engine.
- Toggle conditions on the pill panel; each active condition shaves
  −1 die off the next push (rules-engine `applyConditions`).
- Manage talents and gear (six item types — WEAPON / ARMOR / GEAR /
  CYBERNETIC / SHIP_MODULE / OTHER) through the modal-based item
  editor; equipped view + encumbrance warning surface alongside.
- Watch every save go through the four-state `AppSavePulse` dot
  (idle / saving / saved / error) — the pattern reused on every
  edit field.
- Run the six-step character-creation wizard (Concept → People &
  Background → Nine Icons → Attributes pool → Skills pool → Talents
  → Forge), with the draft persisted server-side via
  `Character.status='draft'` and promoted to `active` on Forge.
- Read every wizard string in en or ru (uk + el seeded as
  placeholders); the Cyrillic Q/A pass per PRD §11 is done.

The Flutter app does the same on mobile — full sheet edit surfaces
plus the wizard, BLoC-driven, with the Dart `AppSavePulse` widget
mirroring the web indicator.

## What landed (by feature group)

### Storybook a11y CI (Epic 2 tail, carried from Phase 1 follow-up)

Storybook a11y panel surfaced 61 axe violations across 8 primitive
stories; this group brought the count to zero before the sheet work
started, so every new wizard / sheet panel built on `@app/ui`
inherited a clean baseline.

- `ec99ba3` — fix(ui): a11y violations in 8 component stories (61 → 0)
- `acfc53d` — docs(tasks): bookkeep Storybook a11y CI + web typecheck fix

### `@app/ui` primitives needed for Phase 2

Two new web primitives (`AppStatBlock`, `AppPopover`) and one
cross-platform indicator (`AppSavePulse`) plus the modal primitive
deferred from Phase 1. `AppBanner` got a follow-up after the a11y
refactor changed its root element.

- `a646cf5` — feat(ui): AppStatBlock — attribute/derived-stat block primitive
- `082ebc5` — feat(ui): AppPopover — tokens-styled inline-edit popover
- `b508bac` — chore(ui): export AppStatBlock + AppPopover from `@app/ui` barrel
- `43d2e87` — fix(ui): align AppBanner spec with `<div>` root after a11y refactor
- `c320a61` — feat(ui): add AppSavePulse primitive
- `39bc84f` — fix(ui): drop redundant story-local a11y override on AppSavePulse
- `14cdcf6` — feat(ui): AppModal primitive
- `8c8efcd` — feat(ui-flutter): AppSavePulse widget — 4-state animated dot for auto-save

### Auto-save composable extraction

Phase 1's sheet skeleton inlined the debounced-save loop in the
header. Phase 2 extracted it into a reusable composable before
adding more edit surfaces — so the new attribute, skill, condition,
talent, and gear panels all share one save state machine.

- `63882b2` — feat(web): extract useAutoSave composable from sheet skeleton

### Character sheet body — web (Epic 5 Feature 5.1 + 5.2 + 5.3 + 5.5)

The three-column layout, attribute + skill panels with inline-edit
popovers, conditions panel with optimistic toggle + rollback,
talents composable, and the rules-engine condition penalty wiring.

- `ba6b7ee` — feat(web): character sheet — three-column layout, hero counters, attributes + skills panels
- `cb58fcf` — docs(tasks): bookkeep Epic 5 Feature 5.1 (Attributes & skills section)
- `55f17f7` — feat(backend): rules-engine.applyConditions — −1 die per active condition
- `09bb4a1` — feat(web): conditions panel — pills with optimistic toggle + rollback
- `62d2426` — feat(web): add useTalentsApi composable
- `9e023fa` — test(web): condition / talent / save-pulse orchestration specs
- `e489a2f` — docs(tasks): bookkeep Epic 5 Features 5.2 + 5.3 + 5.5

### Inventory & gear (Epic 5 Feature 5.4)

The Gear tab with the six-variant `ItemEditor` modal, equipped view,
and the encumbrance-over-max warning. Hits the same auto-save loop
as every other surface.

- `0d4d15d` — feat(web): useItemsApi composable
- `3ceecc1` — feat(web): Gear tab, ItemEditor (6 types), equipped view, encumbrance warning
- `2fa8ada` — test(web): inventory orchestration specs + typecheck fix in test union type
- `84fc9fd` — docs(tasks): bookkeep Epic 5 Feature 5.4 (Inventory & gear)

### Character draft state — spec + backend + ADR-0002

The wizard needs a half-built character to persist between steps.
ADR-0002 picks option B: a `status` column (`draft | active`) on the
existing Character table, with a status-transition guard
(draft → active only via the wizard's Forge step) and an
`includeDrafts` query param on the listing endpoint.

- `5d1af2e` — docs(adr): 0002 — character draft state via status flag
- `3a7a1c0` — feat(specs): add Character.status (draft|active) + includeDrafts query param
- `a3ad6aa` — chore(codegen): regenerate clients after Character.status
- `4e2eb90` — feat(backend): Prisma Character.status migration
- `459d453` — feat(backend): wizard support — draft status + status-transition guard + listings
- `45bfa43` — fix(backend): align legacy list-characters specs with includeDrafts param

### Character creation wizard — web (Epic 5 Feature 5.6)

Six-step wizard (Concept → People & Background → Nine Icons grid
with teal aura pulse → Attributes point pool → Skills point pool →
Talents → Forge transition). en + ru full, uk + el seeded as
placeholders; orchestration specs cover the step transitions and
the Forge promotion.

- `be06e2a` — feat(web): wizard shell — progress, header, footer, navigation
- `88c9eba` — feat(web): wizard step 1+2 — concept + people/background
- `4307e65` — feat(web): wizard step 3 — Nine Icons grid + teal aura pulse
- `6c949f2` — feat(web): wizard step 4+5 — attributes + skills point pools
- `19a9820` — feat(web): wizard step 6 — talents + Forge transition
- `e2b1eec` — i18n(web): wizard en + ru full, uk + el placeholders
- `2f440ab` — test(web): wizard orchestration specs
- `692f821` — docs(tasks): bookkeep Epic 5 Feature 5.6 (character creation wizard)

### Mobile — full sheet + wizard parity

The Flutter app catches up to web in one batch: the full sheet edit
surfaces, then the wizard. Same six steps, same draft → active
Forge transition, BLoC-driven with `CharacterSheetCubit` extended
and a new `CharacterWizardCubit` state machine.

- `e92e6fa` — feat(mobile): extend CharacterSheetCubit + domain for full edit surfaces
- `cfe6ae0` — feat(mobile): full character sheet page — header, tabs, all edit surfaces
- `fecf343` — test(mobile): BLoC + widget tests for character sheet edit surfaces
- `bf4b4e7` — feat(mobile): CharacterWizardCubit + state machine + draft persistence
- `f99f7b8` — feat(mobile): wizard shell page — progress, navigation, save-and-exit
- `4070c17` — feat(mobile): wizard step 1+2 — concept + people/background
- `98857a7` — feat(mobile): wizard step 3 — Nine Icons grid + teal aura pulse
- `6fd5713` — feat(mobile): wizard step 4+5 — attributes + skills point pools
- `7a6c164` — feat(mobile): wizard step 6 — talents + Forge transition
- `1c21436` — i18n(mobile): wizard en + ru full, uk + el placeholders
- `08f2507` — test(mobile): wizard cubit + widget specs
- `fea59d6` — chore(codegen): regenerate dart client + bundled types after spec v0.6.0
- `1934a57` — fix(mobile): wire CharacterStatus through repo + wizard forge
- `a47e535` — docs(tasks): bookkeep Flutter tail — mobile sheet + wizard

## Notable decisions

- **ADR-0002 — `Character.status` flag, not a separate Draft
  resource.** Considered (a) a separate `/api/v1/character-drafts`
  resource and (b) localStorage-only. Picked option (c) — a
  `status: draft|active` column on the existing Character row, with
  a server-side status-transition guard. Drafts use the same auth /
  ownership guards / item + talent sub-resources as active
  characters, no schema duplication, and the wizard can resume
  cross-device. Trade-off: list endpoints had to learn an
  `includeDrafts` query param so the existing characters list
  doesn't surface half-built rows. (See `5d1af2e` and the listing
  follow-up `45bfa43`.)
- **Forge as the single status-transition gate.** `draft → active`
  only happens at the wizard's final step. The backend rejects
  arbitrary PATCHes to `status` — same pattern as the Phase 1
  `ReadOnlyFieldError` defends derived fields.
- **`useAutoSave` extracted before Phase 2 panels were written.** The
  four edit surfaces added in Phase 2 (attributes, skills,
  conditions, talents/gear) plus the wizard would all have grown
  their own debounce + state machine if the composable hadn't been
  factored out first. `63882b2` lands one commit before
  `ba6b7ee` deliberately.
- **Optimistic toggle with rollback for conditions.** Conditions
  flip is a one-bit edit per pill — the pill goes "active" the
  moment the user clicks, the request fires in the background, and
  on error the state rolls back. Different from the auto-save
  debounce-then-replay pattern used everywhere else.
- **Storybook a11y panel as a hard quality gate before sheet work.**
  61 → 0 axe violations across 8 stories before the sheet body
  landed. Color-contrast and nested-interactive disabled globally
  with documented WHY; everything else is fixed at the story level.
- **Derived stats pinned to the rules engine.** `applyConditions`
  joined the Phase 1 `computeHpMax / computeMpMax /
  computeEncumbranceMax` family — pure functions, no DB read in the
  rules layer, exercised both in backend tests and in the read
  mapper.
- **i18n strategy for the wizard.** en + ru fully translated; uk +
  el seeded with placeholders and surface in the parity check
  intentionally (the Cyrillic Q/A pass was scoped to ru only per
  PRD §11). uk + el real translations are explicitly Phase 3+ work.
- **Codegen artefacts in their own commits.** `fea59d6`,
  `a3ad6aa` follow the spec-first loop literally — spec edit,
  validate, bundle, codegen, separate commit. Same convention as
  Phase 1.

## Follow-ups

- **uk + el wizard translations.** Both web (`e2b1eec`) and mobile
  (`1c21436`) ship en + ru full and uk + el as placeholders. Real
  copy is Phase 3+ work and gets a Cyrillic-style Q/A pass of its
  own for uk.
- **`AppTextarea` autosize.** Still only accepts the BEM modifier;
  content-grow is unimplemented. Carried from Phase 1 follow-ups —
  no Phase 2 surface needed it.
- **`AppProgress` circular variant.** The wizard step indicator uses
  the linear variant; circular is still deferred.
- **Web `pnpm typecheck` local breakage.** The macOS `oxc-parser`
  binding bug from Phase 1 is still in `docs/troubleshooting.md`. CI
  under Linux remains the source of truth.
- **Theme persistence sync.** `Me.themePreference` server column not
  yet added — the high-contrast toggle is still localStorage-only.
- **Storybook visual regression.** a11y panel is wired; visual
  diffing is still TODO.
- **8 Flutter primitives from Phase 1.** `AppIcon`, `AppTab`,
  `AppBanner`, `AppTooltip`, `AppKbd`, `AppSegControl`, `AppSelect`,
  `AppTextarea` still pending the per-widget Material/Cupertino
  evaluation pass. Phase 2 mobile sheet + wizard rendered fine
  without them.
- **Phase 3 entry point.** Sharing & polish — share links, public
  read-only views, mobile pass, accessibility audit. Per PRD §11
  Phase 3.

## Local merge ledger

Fifty commits across the phase-1-complete..phase-2-complete range,
landed in a single push-per-block cadence (the user adopted the
"commit + push + new session per block" rule mid-phase — see the
auto-memory note at `feedback_block_workflow.md`). Most recent
first; the per-feature task entries with judgement-call notes live
in `specs/tasks/done.md`.

- `a47e535` — Flutter mobile sheet + wizard bookkeeping
- `1934a57` — CharacterStatus through mobile repo + Forge
- `08f2507` + `fea59d6` — wizard cubit specs + dart codegen catch-up
- `bf4b4e7` … `7a6c164` — mobile wizard cubit + 6 step pages
- `e92e6fa` + `cfe6ae0` + `fecf343` — mobile full sheet edit surfaces + tests
- `8c8efcd` — Flutter `AppSavePulse`
- `692f821` — Epic 5 Feature 5.6 bookkeeping (web wizard)
- `2f440ab` + `e2b1eec` — wizard orchestration specs + i18n
- `be06e2a` … `19a9820` — web wizard shell + 6 step pages
- `45bfa43` + `459d453` + `4e2eb90` + `a3ad6aa` + `3a7a1c0` + `5d1af2e` — draft-status spec → migration → backend → ADR
- `84fc9fd` + `2fa8ada` + `3ceecc1` + `0d4d15d` + `14cdcf6` — inventory + AppModal
- `e489a2f` + `9e023fa` + `09bb4a1` + `62d2426` + `c320a61` + `39bc84f` — conditions + talents + AppSavePulse
- `55f17f7` — rules-engine `applyConditions`
- `cb58fcf` + `ba6b7ee` + `63882b2` — sheet three-column layout + `useAutoSave`
- `b508bac` + `082ebc5` + `a646cf5` + `43d2e87` — `AppPopover` + `AppStatBlock` + `AppBanner` fix
- `acfc53d` + `ec99ba3` — Storybook a11y panel green
