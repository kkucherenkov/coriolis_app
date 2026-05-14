# Handoff → Project Component Name Map

Reference table that pairs every component in the Coriolis handoff bundle
(`/tmp/coriolis-handoff/coriolis-app/project/specs/design/COMPONENTS.md`

- `/tmp/coriolis-handoff/coriolis-app/project/screens/primitives.jsx`)
  with its `@app/ui` and `app_ui` (Flutter) implementations.

Companion document to the inventory table in
[`specs/design/README.md`](README.md) and the
[design audit](../../docs/audits/design-2026-05-14.md) §3 ("Components").

**Last revised:** 2026-05-14 — T-2026-05-14-003 block 7 (closes audit §3.3
"publish a handoff→project name map" action item).

## How to read this

- **Handoff name** — what the handoff calls the primitive (React JSX
  component name or `cor-*` CSS class).
- **Project name** — Vue `@app/ui` component + Flutter mirror under
  `packages/ui_flutter/lib/src/widgets/`.
- **Status** — `aligned` (visual + API parity), `aligned-rename`
  (vocabulary differs but behaviour matches), `drift-documented`
  (visual or API delta the team has decided to keep — see "Notes"),
  `project-only` (we ship this; the handoff doesn't), `handoff-only`
  (the handoff specifies it; we haven't shipped it yet).
- **Notes** — the why-it-differs sentence, plus the source-of-truth
  citation (handoff path:line, project file:line, or audit §).

## Atom layer (handoff primitives)

| Handoff name      | Project name (`@app/ui`)   | Flutter mirror     | Status           | Notes                                                                                                                                                                                                                                                                        |
| ----------------- | -------------------------- | ------------------ | ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `StarOrnament`    | `AppStarOrnament`          | —                  | drift-documented | Project renders a filled 16-point polygon; handoff is a stroke-only overlap of two squares + centre dot. Audit §3.2 marks `variant: 'outlined' \| 'filled'` as the follow-up. `AppStarOrnament.vue:22`, handoff `primitives.jsx:L24-L52`.                                    |
| `StarFilled`      | `AppStarOrnament` (filled) | —                  | aligned-rename   | Handoff exports `StarFilled` as a sibling; project unifies via the (future) variant prop above.                                                                                                                                                                              |
| `ArabesqueCorner` | `AppArabesqueCorner`       | —                  | drift-documented | Default colour differs — project `brass`, handoff `brand-brass-deep`. Trivial; tracked in audit §3.2. `AppArabesqueCorner.vue:8-11`.                                                                                                                                         |
| `Swash`           | `AppSwash`                 | `AppSwash`         | aligned          | Paired with every `PanelTitle` + the wordmark. `COMPONENTS.md:L82-L89` ↔ `packages/ui/src/components/AppSwash/`.                                                                                                                                                             |
| `PanelTitle`      | `AppPanelTitle`            | `AppPanelTitle`    | aligned          | Forum heading + paired swash; sm / md / lg sizes. `COMPONENTS.md:L36-L46`.                                                                                                                                                                                                   |
| `Wordmark`        | `AppWordmark`              | `AppWordmark`      | aligned          | Forum brand + brass swash + Inter eyebrow. Auto-scales eyebrow + swash from `size`. `COMPONENTS.md:L76-L81`.                                                                                                                                                                 |
| `IconMedallion`   | `AppIconMedallion`         | `AppIconMedallion` | aligned          | Brass disc + 16 astrolabe ticks + Forum monogram + optional mystic-teal halo on `glow`. **Distinct from** `AppIconCoriolis` (sprite-based glyph). Audit §3.1 row: "add as new atom; do not refactor `AppIconCoriolis`". `COMPONENTS.md:L45-L55`.                             |
| `Die`             | `AppDie`                   | —                  | drift-documented | Handoff: `{ value, size, hit, pushed }` (two booleans). Project: `{ value, size, state: 'normal'\|'hit'\|'pushed'\|'failed' }` — collapses the booleans + adds `failed`. Visual: project face is night-blue + brass stroke, handoff is brass-bevel gradient. Audit §3.2.     |
| `StatBlock`       | `AppStatBlock`             | —                  | aligned          | Uppercase eyebrow + mono value + dot row. `COMPONENTS.md:L86-L95`.                                                                                                                                                                                                           |
| `SkillRow`        | `AppSkillRow`              | `AppSkillRow`      | aligned          | Dense skill row used in sheet + wizard step 6. `name` slot (`nameBuilder` in Flutter) covers the handoff's "name may be a React node" case for the key-skill chip. `COMPONENTS.md:L96-L103`.                                                                                 |
| `Portrait`        | `AppPortrait`              | `AppPortrait`      | aligned          | Forum initials inside brass-rimmed indigo disc + 24 astrolabe ticks. **Distinct from** `AppAvatar` (generic initials/image avatar for account chrome). T-2026-05-14-003 block 6 records the rationale for shipping it as a standalone atom rather than wrapping `AppAvatar`. |

## CSS-class primitive layer (`.cor-*`)

Handoff defines a CSS-class layer (`coriolis.html` `<style>`). The project
materialises each as a Vue component with token-driven styling instead of
relying on a global stylesheet.

| Handoff class                | Project name                               | Notes                                                                                                                                                      |
| ---------------------------- | ------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `.cor-card`                  | `AppCard`                                  | Base card surface.                                                                                                                                         |
| `.cor-card--featured`        | `AppCard` (`featured` variant)             | Inset brass bevel + brass border highlight.                                                                                                                |
| `.cor-btn` (default)         | `AppButton` `variant="primary"`            | Brass-fill hero CTA.                                                                                                                                       |
| `.cor-btn--secondary`        | `AppButton` `variant="secondary"`          | Transparent fill + brass border. Cancel / Skip / Reroll. Landed 2026-05-14 (T-2026-05-14-003 block 4).                                                     |
| `.cor-btn--ghost`            | `AppButton` `variant="ghost"`              | Project ghost is `brass-deep` bordered; handoff ghost is borderless. Documented divergence — project ghost sits between handoff secondary + handoff ghost. |
| `.cor-btn--danger`           | `AppButton` `variant="danger"`             | Crimson fill.                                                                                                                                              |
| `.cor-btn--mystic`           | `AppButton` `variant="mystic"`             | Mystic-teal fill — "Push the Roll" CTA + ritual confirms. Landed 2026-05-14 (T-2026-05-14-003 block 4).                                                    |
| `.cor-chip` (default)        | `AppChip`                                  | Neutral pill-shaped tag.                                                                                                                                   |
| `.cor-chip--cond`            | `AppConditionPill`                         | Condition / status-injury chip is a dedicated atom in the project — clearer ownership for condition rules in the sheet. Documented split per audit §3.2.   |
| `.cor-chip--mystic`          | `AppChip` `variant="mystic"`               | Mystic / chosen state.                                                                                                                                     |
| `.cor-dot` / `.cor-dots`     | `AppDots`                                  | Rank meter (`role="meter"`, `aria-valuenow`).                                                                                                              |
| `.cor-display` / `.cor-body` | n/a (typography tokens)                    | Handoff utility classes; project applies the equivalent via `--type-*` tokens directly in component styles.                                                |
| `.cor-uppercase`             | n/a (typography tokens)                    | Same — applied per-component via `text-transform: uppercase`.                                                                                              |
| `.cor-focus`                 | `:focus-visible` on every interactive atom | Project applies the focus ring per atom (`outline: 2px solid var(--brand-brass)`) rather than via a utility class.                                         |

## Composition layer (handoff compound specs)

| Handoff name       | Project name                                                            | Notes                                                                                          |
| ------------------ | ----------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `SheetDesktop`     | `apps/web/app/pages/app/characters/[id].vue`                            | Surface composition; not an `@app/ui` atom.                                                    |
| `SheetMobile`      | `apps/mobile/lib/features/characters/.../character_sheet_page.dart`     | Surface composition (Flutter).                                                                 |
| `ShipSheet`        | `apps/web/app/pages/app/ships/[id].vue`                                 | Mobile equivalent is still missing — tracked under T-2026-05-14-005 (mobile ship sheet).       |
| `CombatTracker`    | `apps/web/app/components/CombatTracker.vue`                             | Mobile equivalent is card-only today; T-2026-05-14-005 expands to the full initiative tracker. |
| `DiceRollerOpen`   | `apps/web/app/components/sheet/SheetDiceRoller.vue`                     | Web ships; mobile uses `widgets/dice_bottom_sheet.dart`.                                       |
| `DiceRollerPushed` | Pushed-state branch of the same component                               | Visual aftermath grid not deep-verified yet (audit §4).                                        |
| `ShareViewer`      | `apps/web/app/pages/shared/character/[slug].vue` + `AppShareViewer.vue` | Parchment surface; revoked / 404 states present.                                               |
| `ChatAvatar`       | not yet shipped — wraps `AppPortrait` + presence pip                    | Handoff-only at the time of writing. Spec: `COMPONENTS.md:L345`.                               |

## Project-only extras (no handoff equivalent)

These atoms ship in `@app/ui` but are not part of the handoff catalog —
they exist to cover surfaces the handoff does not yet specify (auth flows,
account chrome, mobile patterns, observability chrome).

| Project name      | Why it exists                                                       | Surfaces                                   |
| ----------------- | ------------------------------------------------------------------- | ------------------------------------------ |
| `AppHeader`       | Account-chrome top nav with brand lockup + locale toggle + UserMenu | Every authed page                          |
| `AppMobileDrawer` | Mobile slide-in nav drawer for sub-1024px viewports                 | `pages/app/*`                              |
| `UserMenu`        | Account dropdown (theme toggle, locale, logout)                     | `AppHeader`                                |
| `AppBadge`        | Generic counter / status badge                                      | Header notifications, session-status chips |
| `AppBanner`       | Page-level banner (warning / info / success)                        | `RoleUnmigratedBanner`, settings warnings  |
| `AppField`        | Form field wrapper (label + control + hint + error)                 | Every form                                 |
| `AppInput`        | Text input primitive                                                | Every form                                 |
| `AppTextarea`     | Multi-line text input                                               | Sheet biography, GM notes                  |
| `AppSelect`       | Native select wrapper with project-tone chrome                      | Filters, locale switch                     |
| `AppSwitch`       | Toggle switch                                                       | Settings, accessibility prefs              |
| `AppSegControl`   | Segmented control                                                   | Sheet tab strips, GM session tab strip     |
| `AppTab`          | Standalone tab affordance                                           | Sheet, GM session                          |
| `AppLabel`        | Form label primitive                                                | `AppField`                                 |
| `AppKbd`          | Keyboard-key visual marker                                          | Tooltips, help text                        |
| `AppIcon`         | Generic icon wrapper (size + colour + decorative)                   | Inline iconography                         |
| `AppModal`        | Modal dialog with focus trap + backdrop                             | Confirm, picker, share-link reveal         |
| `AppPopover`      | Anchored popover with positioning + focus management                | Tooltips, GM context menus                 |
| `AppTooltip`      | Hover / focus tooltip                                               | Iconography, dense controls                |
| `AppProgress`     | Determinate progress bar                                            | Wizard step indicator, save state          |
| `AppSavePulse`    | Brief save-confirmation pulse animation                             | Sheet save, GM DP adjust                   |
| `AppDiePool`      | Multi-die layout helper for the dice roller                         | Dice roller, pushed-state grid             |

## Updating this file

Add an entry whenever:

- a new handoff primitive ships as `@app/ui` (status `aligned` or
  `aligned-rename` with the rationale),
- a project component diverges visually or in API from its handoff
  counterpart (status `drift-documented` with a one-line "why"),
- a new project-only atom lands (add to the Extras table).

CI does not currently enforce this map — `pnpm design:audit` only checks
folder ↔ inventory parity. Treat the map as the canonical reference for
"why does the project call it `AppFoo` when the handoff calls it `Foo`"
questions during reviews.
