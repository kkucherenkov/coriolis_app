# Design System — Tokens & Component Inventory

The Coriolis Companion App design language is documented in
[`docs/DESIGN.md`](../../docs/DESIGN.md). This README is the technical
companion: token paths, the build pipeline, and the component inventory
used by `pnpm design:audit`. The design-doctrine layer (visual DNA, motif
density, voice, patterns, a11y, i18n) lives in the sibling docs below.

## Reading order

If you are doing a design audit or onboarding, read in this order:

1. [`FOUNDATIONS.md`](./FOUNDATIONS.md) — visual DNA, motif density
   (`restrained | balanced | maximum`), semantic intent of every
   colour / shadow / opacity token, composite typography contract,
   four hard rules (Forum-not-in-chat · 24 px min @ 1920 × 1080 ·
   no `<small>` · no raw hex).
2. [`PATTERNS.md`](./PATTERNS.md) — cross-cutting interaction grammar:
   page padding scale, card composition order, hero grid, empty-state
   cadence, banner recipes, modal contract (backdrop click is **not** a
   close trigger), button taxonomy, view-only triad, realtime signals.
3. [`A11Y.md`](./A11Y.md) — canonical accessibility contract: focus-ring
   token, keyboard map (roving for tablist / listbox / radio), landmark
   map, ARIA per component, colour-is-not-the-only-signal matrix,
   reduced-motion catalogue, RTL readiness, PR-gate checklist. Point-in-time
   audit findings live separately in
   [`docs/A11Y_AUDIT.md`](../../docs/A11Y_AUDIT.md).
4. [`CONTENT.md`](./CONTENT.md) — voice doctrine, in-product taxonomy
   (Bridge · Library · Push · Icon · Mystic), number formatting
   (`/` HP separator, ✶ U+2736 successes, `b` birr), time format, dice
   flavour template, copy do/don't list.
5. [`I18N.md`](./I18N.md) — design-layer i18n: Cyrillic stress test,
   plural design (CLDR `one`/`few`/`many`/`other`),
   `domain.subject.detail` key naming, `Intl.RelativeTimeFormat`, locale
   × Forum matrix (Forum **carries Cyrillic** — resolved 2026-05-14),
   untranslated-nouns list.
6. [`HANDOFF_NAME_MAP.md`](./HANDOFF_NAME_MAP.md) — handoff term ⇄
   project name (`AppFoo` ⇄ `Foo`), rationale for every documented drift.
7. The token JSON itself — `tokens/*.json` and the typography schema in
   [`packages/design-tokens/src/types.ts`](../../packages/design-tokens/src/types.ts).
8. The remainder of this file — token pipeline, theme overrides, motion
   guarantee, component inventory.

## Token pipeline

Source of truth: `specs/design/tokens/*.json` (W3C DTCG format, with the
Coriolis schema documented in
[`packages/design-tokens/src/types.ts`](../../packages/design-tokens/src/types.ts)).

```
specs/design/tokens/*.json
        │
        ▼  pnpm design:build  (@app/design-tokens)
        ├── apps/web/app/assets/css/tokens.generated.css   (gitignored)
        ├── packages/ui/src/tokens.generated.css           (gitignored)
        ├── apps/web/app/design-tokens.generated.ts        (gitignored)
        ├── packages/ui/src/design-tokens.generated.ts     (gitignored)
        └── packages/ui_flutter/lib/src/theme/tokens.g.dart  (committed)
```

The Flutter artefact is committed for review and CI determinism. The web /
ui CSS+TS mirrors are regenerated on every install (`postinstall` hook on
`@app/specs` triggers `pnpm spec:codegen`; `pnpm design:build` is run
manually after editing tokens). They stay gitignored — see `.gitignore`.

**Rules:**

- Never edit the generated files. Edit JSON, run `pnpm design:build`.
- Renaming or removing a token requires an ADR in `docs/adr/` (per DESIGN
  §2.4). Adding a token does not.
- `pnpm design:audit` cross-checks the component inventory below against
  the actual `packages/ui/src/components/` and `packages/ui_flutter/lib/src/`
  folders.

## Token inventory (DESIGN §2)

Coriolis is dark-first. The base values below define the default theme
emitted under `:root`; `[data-theme='high-contrast']` overrides only the
deltas listed in `color.json` `theme.high-contrast`.

### Color (`color.json`)

| Group     | Tokens                                                            |
| --------- | ----------------------------------------------------------------- |
| `surface` | `void`, `night`, `dawn`, `parchment`                              |
| `brand`   | `brass-light`, `brass`, `brass-deep`, `brass-shadow`              |
| `text`    | `primary`, `secondary`, `ink`, `on-brass`                         |
| `state`   | `crimson`, `crimson-bright`, `mystic-teal`, `success`, `darkness` |

CSS custom properties: `--<group>-<name>` (e.g. `--surface-void`,
`--brand-brass`).

### Typography (`typography.json`)

Three families: **Forum** (display), **Inter** (body), **JetBrains Mono**
(numeric). See DESIGN §3. Schema rationale:
[`docs/adr/0004-typography-token-schema.md`](../../docs/adr/0004-typography-token-schema.md).

Composite roles reference an **atom layer** under `font.{size,line-height,tracking}`
via DTCG `{font.size.16}` syntax — adding a new role no longer requires
hand-copying literals. Atoms:

- `font.size.{9,10,11,12,13,14,15,16,18,20,24,28,32,36,40,44,48,56,64}` — px scale
- `font.line-height.{tight,snug,normal,relaxed,loose}` — ratios 1.1 / 1.25 / 1.4 / 1.5 / 1.6
- `font.tracking.{tight,normal,04,06,08,10,12,14,16,18,20,30}` — em scale

Composite type roles emit decomposed CSS custom properties under
`--type-<role>-{font-family,font-size,line-height,font-weight,letter-spacing}`
(plus `--type-<role>-text-transform` when set):

| Role           | Family         | Size / Line | Weight | Tracking         |
| -------------- | -------------- | ----------- | ------ | ---------------- |
| `display-xl`   | Forum          | 48 / 56     | 400    | 0.06em           |
| `display-lg`   | Forum          | 36 / 44     | 400    | 0.04em           |
| `display-md`   | Forum          | 28 / 36     | 400    | 0.04em           |
| `display-sm`   | Forum          | 20 / 28     | 400    | 0.08em uppercase |
| `body-lg`      | Inter          | 18 / 28     | 400    | normal           |
| `body-md`      | Inter          | 16 / 24     | 400    | normal           |
| `body-sm`      | Inter          | 14 / 20     | 500    | normal           |
| `body-xs`      | Inter          | 12 / 1.4    | 400    | normal           |
| `label-sm`     | Inter          | 12 / 1.4    | 500    | 0.06em uppercase |
| `mono-stat-xl` | JetBrains Mono | 32 / 32     | 700    | normal           |
| `mono-stat-md` | JetBrains Mono | 20 / 24     | 500    | normal           |

#### Handoff vocabulary (deferred)

The handoff bundle uses `display-{hero,title,section}` / `body-{default,small}` /
`eyebrow` / `label` / `numeric-stat`. We kept project-canonical role names to
avoid a 50-file rename + visible visual diff alongside a schema change. See
ADR-0004 §_Alternatives considered_ for the rationale and gap log.

### Spacing (`spacing.json`)

`--space-1` … `--space-12` on a 4 px base: 4 / 8 / 12 / 16 / 20 / 24 / 32 /
40 / 48 / 56 / 64 / 80.

### Radius (`radius.json`)

`--radius-sm` 2px · `--radius-md` 4px · `--radius-lg` 8px · `--radius-pill`
9999px (chips only).

### Motion (`motion.json`)

- Durations: `--motion-duration-fast` 100ms · `--motion-duration` 200ms ·
  `--motion-duration-slow` 400ms · `--motion-duration-ceremony` 600ms.
- Easings: `--motion-ease-standard` (default), `--motion-ease-emphasis`,
  `--motion-ease-linear`.

### Z-index (`z-index.json`)

`--z-base` 0 · `--z-raised` 1 · `--z-sticky` 10 · `--z-dropdown` 20 ·
`--z-overlay` 50 · `--z-modal` 100 · `--z-toast` 200 · `--z-tooltip` 300 ·
`--z-max` 999 (reserved).

### Shadow (`shadow.json`)

`--shadow-card-featured` (inset brass) · `--shadow-panel-rise` (indigo
lift) · `--shadow-icon-glow` (mystic teal halo) · `--shadow-brass-bevel`
(inset two-stop highlight/shadow) · `--shadow-danger-pulse` (crimson glow).

### Opacity (`opacity.json`)

`--opacity-disabled` 0.4 · `--opacity-muted` 0.5 · `--opacity-subtle` 0.6 ·
`--opacity-secondary` 0.7 · `--opacity-elevated` 0.85 · plus `0` and
`100`.

## High-contrast theme

`[data-theme='high-contrast']` overrides three tokens for accessibility:

| Token            | Default   | High-contrast |
| ---------------- | --------- | ------------- |
| `--surface-void` | `#0B0E2C` | `#000018`     |
| `--brand-brass`  | `#D4A95C` | `#FFD773`     |
| `--text-primary` | `#F2E8D0` | `#FFFFFF`     |

**Persistence guarantee (v0.7.1):** User preference is stored server-side as
`Me.theme` (enum: `dark` | `high-contrast`, default `dark`). The web app
reads the server value on load and applies it to `document.documentElement`
via `data-theme="high-contrast"`. A localStorage hint (`coriolis.theme`) is
applied immediately on page load to avoid a flash of the default theme before
the `/me` response arrives; the server value reconciles the hint after load.
Web + mobile stay in sync because both read from the same `PATCH /api/v1/me`
endpoint.

## Reduced-motion guarantee

Every motion-bearing component in `@app/ui` and in `apps/web` must declare a
`@media (prefers-reduced-motion: reduce)` override that eliminates all
continuous or triggered animations. The allowed fallbacks are:

- **Fade-only:** opacity transition/animation without scale or translate.
- **Static state:** `animation: none` with a visible static visual equivalent.

**Verified components (T-6.5.1.e — 2026-05-09):**

| Component            | Motion type                   | Reduce fallback                      |
| -------------------- | ----------------------------- | ------------------------------------ |
| `AppSavePulse`       | scale + opacity pulse         | fade-only keyframe                   |
| `AppPopover`         | scale + fade entrance         | `animation: none`                    |
| `AppModal`           | scale + fade (Vue Transition) | opacity-only transition              |
| `Step3Icon` (wizard) | aura box-shadow pulse         | static box-shadow, `animation: none` |
| `AppButton` spinner  | continuous rotation           | opacity pulse, no rotation           |
| skeleton animations  | shimmer / opacity pulse       | `animation: none`                    |

Any new motion introduced in `@app/ui` or `apps/web` must include a
`prefers-reduced-motion: reduce` fallback before the PR is merged.

## Component inventory

Populated as components ship. `pnpm design:audit` compares the rows below
against the actual folders under `packages/ui/src/components/` (Vue) and
`packages/ui_flutter/lib/src/` (Flutter), and fails CI on drift.

For the **handoff ⇄ project name map** (which `AppFoo` corresponds to
which handoff `Foo`, plus the rationale for every documented drift) see
[`HANDOFF_NAME_MAP.md`](HANDOFF_NAME_MAP.md). The map is the canonical
reference for review questions like "why is `cor-chip--cond` shipped as
its own `AppConditionPill` atom instead of an `AppChip` variant?".

| Category    | Component            | Vue (`@app/ui`) | Flutter (`app_ui`) |
| ----------- | -------------------- | --------------- | ------------------ |
| Coriolis    | `AppArabesqueCorner` | ✓               | —                  |
| Primitive   | `AppAvatar`          | ✓               | —                  |
| Primitive   | `AppBadge`           | ✓               | —                  |
| Primitive   | `AppBanner`          | ✓               | —                  |
| Primitive   | `AppButton`          | ✓               | —                  |
| Primitive   | `AppCard`            | ✓               | —                  |
| Primitive   | `AppChip`            | ✓               | —                  |
| Coriolis    | `AppConditionPill`   | ✓               | —                  |
| Coriolis    | `AppDie`             | ✓               | —                  |
| Coriolis    | `AppDiePool`         | ✓               | —                  |
| Primitive   | `AppDivider`         | ✓               | —                  |
| Primitive   | `AppDots`            | ✓               | —                  |
| Primitive   | `AppField`           | ✓               | —                  |
| Composition | `AppHeader`          | ✓               | —                  |
| Coriolis    | `AppIconCoriolis`    | ✓               | —                  |
| Coriolis    | `AppIconMedallion`   | ✓               | ✓                  |
| Primitive   | `AppIcon`            | ✓               | —                  |
| Primitive   | `AppInput`           | ✓               | —                  |
| Primitive   | `AppKbd`             | ✓               | —                  |
| Primitive   | `AppLabel`           | ✓               | —                  |
| Composition | `AppMobileDrawer`    | ✓               | —                  |
| Coriolis    | `AppPanelTitle`      | ✓               | ✓                  |
| Primitive   | `AppProgress`        | ✓               | —                  |
| Coriolis    | `AppSavePulse`       | ✓               | ✓                  |
| Primitive   | `AppSegControl`      | ✓               | —                  |
| Primitive   | `AppSelect`          | ✓               | —                  |
| Coriolis    | `AppSkillRow`        | ✓               | ✓                  |
| Coriolis    | `AppStarOrnament`    | ✓               | —                  |
| Coriolis    | `AppSwash`           | ✓               | ✓                  |
| Primitive   | `AppSwitch`          | ✓               | —                  |
| Primitive   | `AppTab`             | ✓               | —                  |
| Primitive   | `AppTextarea`        | ✓               | —                  |
| Primitive   | `AppTooltip`         | ✓               | —                  |
| Coriolis    | `AppWordmark`        | ✓               | ✓                  |
| Coriolis    | `AppStatBlock`       | ✓               | —                  |
| Primitive   | `AppModal`           | ✓               | —                  |
| Primitive   | `AppPopover`         | ✓               | —                  |
| Coriolis    | `AppPortrait`        | ✓               | ✓                  |
| Composition | `UserMenu`           | ✓               | —                  |

## Gap log

Known gaps the design audit (`docs/audits/design-2026-05-14.md`) should
treat as in-flight, not as drift:

- **`SURFACES.md`** — per-screen design briefs (intent, layout, states,
  edge cases). Not authored yet; will land if the next audit raises
  surface-level gaps that this README's component inventory does not
  already cover. Until then, surface intent lives inline in
  [`docs/DESIGN.md`](../../docs/DESIGN.md).
- **`COMPONENTS.md`** — per-component contracts beyond the inventory
  table above. Not authored yet; component-level rules currently live in
  each component's colocated Storybook story + spec.
- **Bridge dashboard** — handoff-canonical "three-card cycle / sync /
  aphorism" surface. Implementation tracked in
  **T-2026-05-14-004** (specs/tasks/active.md). PATTERNS.md and
  CONTENT.md assume the Bridge naming throughout.
- **Wizard step inventory** — handoff (8) vs. web (7) vs. mobile (6).
  Reconciliation tracked in **T-2026-05-14-005** sub-step
  `T-WIZARD-STEP-COUNT`.
- **`AppModal.closeOnBackdrop` default** — currently `true`
  (`packages/ui/src/components/AppModal/AppModal.vue:25`); the
  documented contract in
  [`PATTERNS.md` § 5](./PATTERNS.md#5-modals--dialogs) is "**not** a
  close trigger by default." Flip + audit call sites is a follow-up.
- **Forum × Greek** — Forum does not subset Greek; when `el` is ever
  populated we swap the display face wholesale (see
  [`I18N.md` § 6](./I18N.md#6-cyrillic-glyph-coverage--forum-decision)
  and [`docs/DESIGN.md` § 3.1](../../docs/DESIGN.md#31-the-forum-trade-off)).
- **`display-hero` typography role (64 px)** — handoff vocabulary; the
  project's largest composite is `display-xl` (48 px). Landing wordmark
  uses `display-xl` + the `font.size.64` atom on the glyph only. Tracked
  in [ADR-0004](../../docs/adr/0004-typography-token-schema.md) and
  [`FOUNDATIONS.md` § 4](./FOUNDATIONS.md#4-typography--composite-tokens).
