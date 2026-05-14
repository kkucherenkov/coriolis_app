# Foundations

The atomic layer of the Coriolis Companion design system — visual DNA, motif
doctrine, hard rules, and the semantic intent behind every token. The token
**pipeline**, the high-contrast theme, the reduced-motion guarantee, and the
full token tables live in the technical companion
[`README.md`](./README.md); this file is the design layer that explains
_why_ each token exists and _where_ it may appear.

**Source of truth**: `specs/design/tokens/*.json` (W3C DTCG format). The
generated artefacts under `apps/web/app/assets/css/tokens.generated.css`,
`packages/ui/src/tokens.generated.css`, and
`packages/ui_flutter/lib/src/theme/tokens.g.dart` are runtime mirrors — if
they ever drift, the JSON wins. See
[`README.md` § Token pipeline](./README.md#token-pipeline).

---

## 1. Visual DNA

**Brass on indigo.** Period. We do not have a neutral grey scale and we do
not introduce one. The entire UI is warm brass on cold indigo, with state
colours as sparing accents.

This is a deliberate echo of the Coriolis RPG's source artwork:
Arabic-revival architectural ornament, brass instrumentation, deep
blue-violet space. The system is dark-first. The single light surface —
`--surface-parchment` — is reserved for ceremonial overlays (the
share-viewer banner) and printed-feel panels.

---

## 2. Motifs and density

Four decorative primitives, each with a specific job. The component column
points at the `@app/ui` atom that owns the motif:

| Motif              | Component                              | When to use                                                               |
| ------------------ | -------------------------------------- | ------------------------------------------------------------------------- |
| Eight-pointed star | `<AppStarOrnament>`                    | Section markers, watermarks, hero ornament, empty-state ceremonies.       |
| Arabesque corner   | `<AppArabesqueCorner>`                 | Major panels and modals. **Never on dense surfaces.**                     |
| Calligraphic swash | `<AppSwash>`                           | Replaces section divider beneath titles (auto-paired by `AppPanelTitle`). |
| Astrolabe ring     | inline in `<AppDie>` / `<AppPortrait>` | Dice faces, portrait medallions, attribute circles.                       |

### Motif density

Ornament concentrates at heroes and headers. Combat tracker rows, skill
lists, and the encounter sidebar are deliberately quiet — no corners, no
stars, just type and dots. The contract is a three-stop scale, surfaced via
the Tweaks panel and (in production) `Me.preferences.motifDensity`:

| Token value  | Surface budget                                                                                |
| ------------ | --------------------------------------------------------------------------------------------- |
| `restrained` | Heroes only — landing hero, sheet hero, share viewer header. Everything else strips ornament. |
| `balanced`   | **Default.** Heroes + section headers + empty states.                                         |
| `maximum`    | Heroes + section headers + empty states + card-level arabesque corners on featured cards.     |

Hard floor: at `restrained`, swashes beneath `AppPanelTitle` still render —
the swash is part of the type system, not the ornament budget.

---

## 3. Colour — semantic intent

Full token tables live in
[`README.md` § Token inventory](./README.md#token-inventory-design-2). This
section explains _which token to reach for_, not what each one resolves to.

### Surfaces

- `--surface-void` — the app shell background. The "voids of space" — never
  used to fill cards.
- `--surface-night` — every card body and panel background.
- `--surface-dawn` — elevated surfaces: modals, hovered cards, popover bodies.
- `--surface-parchment` — the single light surface; ceremonial only.

### Brand brass

A four-stop scale, **not** a continuum. Pick by role:

- `--brand-brass-light` — typographic highlight, focused brass, headings on
  brass-tinted surfaces.
- `--brand-brass` — primary brass: button fills, key borders, medallions.
- `--brand-brass-deep` — aged brass: hairline rules, secondary borders,
  star-ornament fill in empty states.
- `--brand-brass-shadow` — inset shadows, deep dividers, input borders.

### Text

- `--text-primary` — body text on dark surfaces.
- `--text-secondary` — captions, helper copy, view-only suffix.
- `--text-ink` — black-equivalent for parchment surfaces only.
- `--text-on-brass` — for text rendered on brass fills (button labels).

### Semantic state

- `--state-crimson` / `--state-crimson-bright` — danger fill / danger
  emphasis. Reserved for failure, destructive, crit text.
- `--state-mystic-teal` — Icon-related accent. The 6s glow on dice. Never a
  decorative teal.
- `--state-success` — success / completion. Never a celebration colour.
- `--state-darkness` — The Darkness — corruption, DP counter background.

### Hex literal — the hard rule

**No raw hex literal** in any file under `apps/web/app/**`, `packages/ui/**`,
or `packages/ui_flutter/**`. Stylelint enforces this in CI. Hex belongs in
`tokens/color.json`; consumers reference `var(--token)` (web) or the
generated Dart symbol (mobile). The one exception, documented in
[ADR-0004](../../docs/adr/0004-typography-token-schema.md), is that any
**new** brand colour must be promoted to a token in a dedicated ADR — never
introduced as a one-off literal.

---

## 4. Typography — composite tokens

Project-canonical role names (`display-xl` / `display-lg` / `display-md` /
`display-sm`, `body-{lg,md,sm,xs}`, `label-sm`, `mono-stat-{xl,md}`) are
documented with their CSS custom-property emission in
[`README.md` § Typography](./README.md#typography-typographyjson). This
section governs **when** to use each role and the hard rules around the
display family.

### Composite token contract

Each role emits five decomposed CSS custom properties
(`--type-<role>-font-family`, `-font-size`, `-line-height`, `-font-weight`,
`-letter-spacing`), plus `--type-<role>-text-transform` when set. Consumers
**must** read all five via the composite shorthand or the role's class
helper; never cherry-pick `font-size` from a composite without the matching
line height. Composite roles compose from the **atom layer** under
`font.{size,line-height,tracking}` — adding a new role is a token edit, not
a hand-copied literal.

### Where each role belongs

| Role           | Surface examples                                                       |
| -------------- | ---------------------------------------------------------------------- |
| `display-xl`   | Landing wordmark; sheet hero name on desktop; Bridge cycle-stat.       |
| `display-lg`   | Sheet hero name on tablet; modal titles for destructive confirmations. |
| `display-md`   | Section headers inside cards; encounter-card titles.                   |
| `display-sm`   | Subhead uppercase markers (`STRENGTH`, `HULL`); empty-state titles.    |
| `body-lg`      | First-paragraph body inside hero cards.                                |
| `body-md`      | Default body copy.                                                     |
| `body-sm`      | Helper text, secondary descriptions.                                   |
| `body-xs`      | Dense metadata, chat-system messages.                                  |
| `label-sm`     | All form labels (uppercase Inter, 0.06 em tracking).                   |
| `mono-stat-xl` | Primary numerics: HP / MP, Hull / Energy, successes.                   |
| `mono-stat-md` | Inline numerics: init order, encumbrance, dice count.                  |

### Handoff vocabulary gap

The handoff bundle uses `display-{hero,title,section}` /
`body-{default,small}` / `eyebrow` / `label` / `numeric-stat`. We kept
project-canonical role names to avoid a 50-file rename + visible visual diff
alongside a schema change. Map and rationale in
[`README.md` § Handoff vocabulary (deferred)](./README.md#handoff-vocabulary-deferred)
and [ADR-0004 § Alternatives considered](../../docs/adr/0004-typography-token-schema.md).
The handoff `display-hero` (64 px) is the one role with no current project
peer — the landing wordmark uses `display-xl` plus a one-off `font.size.64`
atom on the glyph itself.

### Tracking scale

Forum gets aggressive tracking — that's its weight system. The scale runs
from `0.04 em` for small display titles up to `0.30 em` for hero eyebrows.
Inter uppercase eyebrows default to `0.16 em`; mono **never** gets tracking.
Atoms exposed under `font.tracking.{04,06,08,10,12,14,16,18,20,30}`.

---

## 5. Hard typography rules

These four are zero-tolerance — Stylelint or design audit fails CI on any
violation:

1. **Forum never appears inside chat.** It's a display face; in dense
   reading contexts it slows the eye. Chat is Inter (`body-md` / `body-sm`)
   plus JetBrains Mono (`mono-stat-md`) for inline dice / roll cards only.
2. **Minimum font size at 1920 × 1080 is 24 px** for primary reading copy.
   This is a property of the display canvas (large monitors are the most
   common Bridge setting), not the responsive breakpoint. Mobile minimum:
   **9 px** for tab-bar labels under hit-target ≥ 44 pt icons; **11 px**
   for any reading copy.
3. **No `<small>`.** Use `--type-body-xs` or `--type-label-sm`.
4. **No raw hex** in any screen file — see §3 above.

---

## 6. Spacing — 4 px base

The numeric table lives in
[`README.md` § Spacing](./README.md#spacing-spacingjson). The doctrine: use
the scale, _always_. Custom one-off values (`padding: 13px`) are direct
evidence of either a new pattern that needs a token, or a wrong layout.
Audit-flag any.

The three canonical page padding-x values
(`--space-10` / `--space-8` / `--space-4`) are codified in
[`PATTERNS.md` § Layout](./PATTERNS.md#1-layout); use them rather than
re-deriving from spacing intuition.

---

## 7. Radius — semantic intent

Numbers live in
[`README.md` § Radius](./README.md#radius-radiusjson). Intent:

- `--radius-sm` (2 px) — inputs, dots, hairline corners.
- `--radius-md` (4 px) — the system default: cards, buttons, most inputs.
- `--radius-lg` (8 px) — modals, elevated panels, chat bubbles.
- `--radius-pill` (9999 px) — **chips only**. Never on buttons.

---

## 8. Shadows — semantic, never decorative

Source: `tokens/shadow.json`. We do not have generic drop shadows. Each
shadow is a named token and carries a meaning:

| Token                    | Effect                                                      | Reach for when…                                                    |
| ------------------------ | ----------------------------------------------------------- | ------------------------------------------------------------------ |
| `--shadow-card-featured` | Inset brass shadow on selected / featured cards             | A card is the focus of the surface (`AppCard variant="featured"`). |
| `--shadow-panel-rise`    | Subtle indigo lift                                          | Modal panel base, popover body.                                    |
| `--shadow-icon-glow`     | Mystic teal halo                                            | Chosen Icon medallion, active mystic-state element.                |
| `--shadow-brass-bevel`   | Two-stop inset (highlight / shadow) — a pressed brass bevel | Brass buttons, medallions, dice faces.                             |
| `--shadow-danger-pulse`  | Crimson glow                                                | Crit-fail dice, destructive confirmation state.                    |

Audit rule: any `box-shadow` literal in a `.vue` / `.scss` file is a CI
failure — register a new shadow token or compose from the existing ones.

---

## 9. Motion — duration & easing

Token table lives in
[`README.md` § Motion](./README.md#motion-motionjson). Per-pattern
applications live in [`PATTERNS.md` § 10](./PATTERNS.md#10-motion-patterns).
The doctrine:

- **No interaction animation > 200 ms.** Layout shifts cap at 250 ms.
- **Reduced motion is a first-class state.** Every animated surface ships
  an inert variant — see
  [`README.md` § Reduced-motion guarantee](./README.md#reduced-motion-guarantee).
- **No spring physics in chrome.** The dice settle is the one exception —
  it earns it by being a focal ritual.
- The `--motion-duration-ceremony` (600 ms) token is reserved for
  ceremonial moments: dice settle, Push glow, Icon halo. Audit-flag use
  outside those three.

---

## 10. Opacity — semantic stops

Source: `tokens/opacity.json`. **Use the semantic stop, not a raw decimal.**
The five stops carry meaning; raw decimals lose it.

| Token                 | Value | Meaning                                                           |
| --------------------- | ----- | ----------------------------------------------------------------- |
| `--opacity-disabled`  | 0.4   | Disabled controls. The user can see them; they cannot act.        |
| `--opacity-muted`     | 0.5   | Inactive step labels, future-state hints.                         |
| `--opacity-subtle`    | 0.6   | Hairline rules, soft dividers.                                    |
| `--opacity-secondary` | 0.7   | Secondary chrome, helper hints, ornament at `restrained` density. |
| `--opacity-elevated`  | 0.85  | Backdrop scrims for modals.                                       |

Plus the trivial endpoints — `--opacity-0` and `--opacity-100` — for
animation keyframes only. Audit-flag any `opacity: 0.42` literal.

---

## 11. Z-index — fixed stack

Source: `tokens/z-index.json`. Stops are spaced so new layers slot in
without renumbering. Numbers in
[`README.md` § Z-index](./README.md#z-index-z-indexjson). Doctrine:

- Never use raw `z-index` literals. Stylelint flags any in
  `apps/web/app/**` and `packages/ui/**`.
- `--z-max` (999) is reserved for emergencies (debug overlays); regular
  code paths must not reach it.

---

## See also

- [`README.md`](./README.md) — token pipeline, inventory tables, theme
  overrides, motion guarantee, component inventory.
- [`PATTERNS.md`](./PATTERNS.md) — interaction grammar that composes from
  these atoms.
- [`CONTENT.md`](./CONTENT.md) — voice, number formatting (the typographic
  application).
- [`HANDOFF_NAME_MAP.md`](./HANDOFF_NAME_MAP.md) — every handoff term ⇄
  project name, with rationale.

> **Forthcoming as part of T-2026-05-14-006.** `A11Y.md` and design-layer
> `I18N.md` ship in subsequent blocks.
