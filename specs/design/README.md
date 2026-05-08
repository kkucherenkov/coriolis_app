# Design System — Tokens & Component Inventory

The Coriolis Companion App design language is documented in
[`docs/DESIGN.md`](../../docs/DESIGN.md). This README is the technical
companion: token paths, the build pipeline, and the component inventory
used by `pnpm design:audit`.

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

| Group | Tokens |
|---|---|
| `surface` | `void`, `night`, `dawn`, `parchment` |
| `brand` | `brass-light`, `brass`, `brass-deep`, `brass-shadow` |
| `text` | `primary`, `secondary`, `ink`, `on-brass` |
| `state` | `crimson`, `crimson-bright`, `mystic-teal`, `success`, `darkness` |

CSS custom properties: `--<group>-<name>` (e.g. `--surface-void`,
`--brand-brass`).

### Typography (`typography.json`)

Three families: **Forum** (display), **Inter** (body), **JetBrains Mono**
(numeric). See DESIGN §3.

Composite type roles emit decomposed CSS custom properties under
`--type-<role>-{font-family,font-size,line-height,font-weight,letter-spacing}`
(plus `--type-<role>-text-transform` when set):

| Role | Family | Size / Line | Weight | Tracking |
|---|---|---|---|---|
| `display-xl` | Forum | 48 / 56 | 400 | 0.06em |
| `display-lg` | Forum | 36 / 44 | 400 | 0.04em |
| `display-md` | Forum | 28 / 36 | 400 | 0.04em |
| `display-sm` | Forum | 20 / 28 | 400 | 0.08em uppercase |
| `body-lg` | Inter | 18 / 28 | 400 | normal |
| `body-md` | Inter | 16 / 24 | 400 | normal |
| `body-sm` | Inter | 14 / 20 | 500 | normal |
| `mono-stat-xl` | JetBrains Mono | 32 / 32 | 700 | normal |
| `mono-stat-md` | JetBrains Mono | 20 / 24 | 500 | normal |

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

| Token | Default | High-contrast |
|---|---|---|
| `--surface-void` | `#0B0E2C` | `#000018` |
| `--brand-brass` | `#D4A95C` | `#FFD773` |
| `--text-primary` | `#F2E8D0` | `#FFFFFF` |

User preference is persisted in `AppConfig` on the backend so web + mobile
stay in sync (DESIGN §2.2).

## Component inventory

Populated as components ship. `pnpm design:audit` compares the rows below
against the actual folders under `packages/ui/src/components/` (Vue) and
`packages/ui_flutter/lib/src/` (Flutter), and fails CI on drift.

| Category | Component | Vue (`@app/ui`) | Flutter (`app_ui`) |
| -------- | --------- | --------------- | ------------------ |
| Primitive | `AppButton` | ✓ | — |
| Primitive | `AppCard` | ✓ | — |
| Primitive | `AppInput` | ✓ | — |
| Primitive | `AppBadge` | ✓ | — |
| Primitive | `AppDivider` | ✓ | — |
| Primitive | `AppDots` | ✓ | — |
| Primitive | `AppIcon` | ✓ | — |
