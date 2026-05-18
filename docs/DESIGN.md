# Coriolis Companion App — Design Description

**Version:** 2.0 (adapted to the `claude-driven-nest-nuxt-flutter-monorepo` boilerplate)
**Status:** Ready for visual design execution
**Companion to:** PRD.md

---

## 1. Design Philosophy

The Coriolis universe is built on a deliberate paradox: deep-space science fiction wrapped in pre-modern, sacred, ornate visual language. Starships have arabesques etched into their hulls. Pilots whisper prayers to the Icons before pushing dice. The visual identity of the companion app must honour that paradox — feel like a _digital relic_ rather than a generic SaaS dashboard.

**Three non-negotiables:**

1. **Ornament with purpose.** Decoration is welcome where it reinforces meaning (Icon affinities, prayer states, the mystical), restrained where it competes with information density (combat tracker, inventory rows).
2. **Brass on indigo.** The palette is the brand. Avoid any drift toward neutral greys or generic dark-mode blacks.
3. **Information first when it matters.** A character sheet is read at speed during play. Ornament must not push numeric stats below the fold or reduce contrast on critical values.

Reference moods: the ornate astrolabe more than the Star Trek LCARS panel; illuminated manuscripts more than holographic UIs; the Coriolis core book itself more than any other RPG digital tool.

This document expresses those decisions inside the monorepo's design pipeline: every value below ends up in `specs/design/tokens/*.json`, gets emitted to `tokens.generated.css` (web), `design-tokens.generated.ts` (web TS), and `tokens.g.dart` (Flutter) by `pnpm design:build`. **Stylelint blocks hex literals in components** — every color shown here is a token name, and the hex value lives only in the JSON.

---

## 2. Tokens

The boilerplate uses W3C Design Tokens. JSON groups in `specs/design/tokens/` map to CSS custom properties as `--<group>-<name>`. The cascade is layered: `:root, [data-theme='light']` for light, `[data-theme='dark']` for dark. Coriolis is **dark-first** — light mode is reserved for the share-link viewer and the high-contrast accessibility variant.

### 2.1 Color tokens

All values verified for WCAG AA contrast in their documented usage. Token names are the only allowed reference inside `apps/web` and `packages/ui` SCSS.

#### Surfaces (background hierarchy)

| Token                 | Hex (dark) | Usage                                                             |
| --------------------- | ---------- | ----------------------------------------------------------------- |
| `--surface-void`      | `#0B0E2C`  | Primary background, deep space.                                   |
| `--surface-night`     | `#15193F`  | Elevated surfaces (cards, panels).                                |
| `--surface-dawn`      | `#252B5C`  | Hover states, secondary surfaces.                                 |
| `--surface-parchment` | `#F2E8D0`  | Light-mode background; share-link viewer; banner surface on dark. |

#### Brand (brass)

| Token                  | Hex       | Usage                                        |
| ---------------------- | --------- | -------------------------------------------- |
| `--brand-brass-light`  | `#F4E4B8` | Headlines on dark surfaces.                  |
| `--brand-brass`        | `#D4A95C` | Standard brass, primary accent.              |
| `--brand-brass-deep`   | `#A67C28` | Borders and dividers.                        |
| `--brand-brass-shadow` | `#6B4E1A` | Inset details, beveled "brass plate" effect. |

#### Text

| Token              | Hex (dark) | Usage                                                      |
| ------------------ | ---------- | ---------------------------------------------------------- |
| `--text-primary`   | `#F2E8D0`  | Body text on dark.                                         |
| `--text-secondary` | `#D9CDB0`  | Secondary text on dark.                                    |
| `--text-ink`       | `#1A1810`  | Body text on light surfaces, share-link viewer.            |
| `--text-on-brass`  | `#0B0E2C`  | Text rendered on a brass-filled element (primary buttons). |

#### Semantic

| Token                    | Hex       | Usage                                       |
| ------------------------ | --------- | ------------------------------------------- |
| `--state-crimson`        | `#A8324A` | HP loss, critical injuries, danger actions. |
| `--state-crimson-bright` | `#E54E6B` | Critical injury icon, "wound" state.        |
| `--state-mystic-teal`    | `#2BA3A0` | Mystic powers, MP, prayer-eligible state.   |
| `--state-success`        | `#5A8A3A` | Successes (rolled 6s), positive feedback.   |
| `--state-darkness`       | `#5B2A78` | Darkness Points, GM-only UI.                |

### 2.2 High-contrast accessibility variant

Activated by user preference and persisted in `AppConfig` on the backend (so mobile + web stay in sync). Implemented as a third theme attribute, `[data-theme='high-contrast']`, that overrides the dark theme:

- `--surface-void` → `#000018`
- `--brand-brass` → `#FFD773` (boosted to 7:1 contrast on void)
- `--text-primary` → `#FFFFFF`

### 2.3 Spacing, radius, motion, z-index

Tokens, never literals. All `px`, `ms`, and `z-index` values inside `apps/web` and `packages/ui` SCSS reference these — Stylelint flags raw numbers in the relevant properties.

- `--space-1` … `--space-12` — 4px base unit, 4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 / 48 / 56 / 64 / 80.
- `--radius-sm` 2px, `--radius-md` 4px (default for cards and buttons), `--radius-lg` 8px (modals), `--radius-pill` 9999px (reserved — see §6.1).
- `--motion-duration-fast` 100ms, `--motion-duration` 200ms, `--motion-duration-slow` 400ms, `--motion-duration-ceremony` 600ms.
- `--motion-ease-standard` `cubic-bezier(0.2, 0.0, 0.2, 1)`, `--motion-ease-emphasis` `cubic-bezier(0.3, 0.0, 0.0, 1)`.
- `--z-base` 0, `--z-sticky` 10, `--z-overlay` 50, `--z-modal` 100, `--z-toast` 200.

### 2.4 Token authoring rules (from the design-system handbook)

- Edit `specs/design/tokens/*.json`, run `pnpm design:build` — never edit the generated files (`tokens.generated.css`, `design-tokens.generated.ts`, `tokens.g.dart`).
- Renaming or removing a token requires an ADR (architectural decision record) — it is a breaking change for every consumer.
- `pnpm design:audit` cross-checks `specs/design/README.md` inventory against the actual component folders. Untracked tokens or undocumented components fail CI.

---

## 3. Typography

v1 ships two locales: **English and Russian (en / ru)**. Every typeface below carries **Latin + Cyrillic** glyphs. Forum (the display face) doesn't cover Greek or CJK — if a future locale demands one of those scripts the display face will need a re-pick (see §3.1).

| Role                   | Family             | Weights            | Scripts                                             | Notes                                                                                                                                                                       |
| ---------------------- | ------------------ | ------------------ | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Display / Headings** | **Forum**          | 400                | Latin + Latin Ext + Cyrillic + Cyrillic Ext         | Roman-inscriptional, Trajan-inspired, by Denis Masharov. Replaces our original Cinzel choice (Latin-only). Used for character names, section headers, and the app wordmark. |
| **Body**               | **Inter**          | 400, 500, 600, 700 | Latin + Latin Ext + Cyrillic + Cyrillic Ext + Greek | Highly legible at small sizes. Used for sheet labels, descriptions, all UI copy.                                                                                            |
| **Numeric / Stats**    | **JetBrains Mono** | 500, 700           | Latin + Cyrillic + Greek                            | Tabular figures, designed for technical UIs. Used for HP / MP / dice values and anything that benefits from columnar alignment.                                             |

All three are Google Fonts, free, served self-hosted via the boilerplate's font pipeline (no third-party CDN). Per-locale subset bundles keep the network cost down: a Russian-only user never downloads the Latin-Extended table.

### 3.1 The Forum trade-off

Forum carries the same ceremonial Roman-capital authority Cinzel did, with the same brass-plate-inscription feel, and adds Cyrillic — but it ships in **a single weight (Regular 400) on Google Fonts**. To compensate, weight emphasis comes from **size and tracking**, not boldness:

- Larger sizes (36px+) read with natural authority.
- Tracking (`letter-spacing`) of `0.04em–0.10em` thickens presence without bolding.
- For cases where typographic emphasis is essential alongside Forum (e.g., a UI heading with a descriptor), pair Forum (display) with Inter Semibold (descriptor) rather than reaching for a non-existent Forum Bold.

If a future locale demands a script Forum doesn't carry, we re-evaluate the display face wholesale — partial fallback (Forum for `en`/`ru`, something else for the other locale) is brittle. Forum doesn't subset Greek; if Greek is ever added, expect to swap to Cormorant Garamond or EB Garamond, both of which cover Latin + Cyrillic + Greek across multiple weights. Ukrainian is fine — Forum's Cyrillic subset includes the Ukrainian-specific letters (ї, є, ґ, і).

### 3.2 Type scale (token names)

Tokens authored in `specs/design/tokens/typography.json`, consumed via SCSS mixins (`@include type-display-md`) in `packages/ui` components.

- `--type-display-xl` — 48 / 56, Forum 400, tracking 0.06em. Landing headline only.
- `--type-display-lg` — 36 / 44, Forum 400, tracking 0.04em. Character name on sheet header.
- `--type-display-md` — 28 / 36, Forum 400, tracking 0.04em. Section headers (Skills, Inventory).
- `--type-display-sm` — 20 / 28, Forum 400, tracking 0.08em uppercase. Stat-block labels.
- `--type-body-lg` — 18 / 28, Inter 400. Primary body.
- `--type-body-md` — 16 / 24, Inter 400. Default body.
- `--type-body-sm` — 14 / 20, Inter 500. Labels, captions.
- `--type-mono-stat-xl` — 32 / 32, JetBrains Mono 700. HP and MP big counters.
- `--type-mono-stat-md` — 20 / 24, JetBrains Mono 500. Skill ranks, item weights.

### 3.3 Usage rules

- Forum is reserved. Never use it for buttons, tooltips, or table cells. It is for _naming_ things, not _labeling_ them.
- Inter handles 90% of UI surface.
- JetBrains Mono is for any number a player will scan for, glance at, or update under pressure.
- The same three families render across en and ru — no conditional font loading by locale.

---

## 4. Iconography & Motifs

### 4.1 Decorative motifs

- **Eight-pointed star (rub el hizb):** repeating border element, share-link banner, loading states.
- **Arabesque corner ornaments:** the four corners of major panels (sheet header, encounter modal). Stroke only, never filled.
- **Astrolabe rings:** circular UI elements (dice roller, attribute circles) framed with concentric thin brass strokes evoking astronomical instruments.
- **Calligraphic underline:** a hand-drawn brass swash beneath section titles, replacing a flat divider line.

### 4.2 The Nine Icons

Each Icon (The Lady of Tears, The Traveler, The Messenger, The Merchant, The Dancer, The Gambler, The Judge, The Faceless One, The Deckhand) gets a dedicated SVG glyph in brass, designed in a single illustration pass for stylistic coherence. Used in:

- The character creation wizard: large, on selection cards.
- The sheet header: small, beside the Icon name.
- The prayer / push button: animated to glow when prayer is invoked.

Glyphs ship in `packages/ui/src/assets/icons/` and are imported through an `AppIconCoriolis` component (so usage is centralized and auditable).

### 4.3 Functional iconography

Use **Lucide** as the base set, restyled with `stroke-width: 1.5` and `currentColor` set to `var(--brand-brass)` in dark mode. Avoid filled icons except where weight is needed (active tab indicators, equipped-gear marker). Lucide is wrapped by an `AppIcon` component in `@app/ui` so we can swap providers later without touching consumers.

---

## 5. Layout & Grid

### 5.1 Breakpoints (token names)

Authored in `specs/design/tokens/layout.json`:

- `--breakpoint-sm` 640px — single column, everything stacks. Phone in portrait.
- `--breakpoint-md` 768px — sheet shows two columns, combat tracker is usable.
- `--breakpoint-lg` 1024px — sheet shows three columns, GM tools fully expand.
- `--breakpoint-xl` 1280px — max content width caps at 1200px; further width adds breathing room only.

### 5.2 Sheet layout

**Mobile (web `sm` breakpoint and Flutter):** vertical stack with sticky header showing name, HP, MP, conditions. Tab bar at bottom: Stats | Gear | Talents | Notes.

**Desktop:** three-column layout.

- **Left column (28%):** identity (portrait, name, concept, group, Icon), conditions, push status.
- **Center column (44%):** attributes and skills, large and central — the most-touched area.
- **Right column (28%):** quick inventory (equipped only), talents, recent rolls.

Tabs at the top of the page give access to full Inventory, full Talents list, Notes, and Share management.

### 5.3 Spacing

Always tokens. Component padding uses `--space-3` / `--space-4` / `--space-6` / `--space-8`. Section gaps use `--space-8` / `--space-12`. The hero sheet header gets `--space-16` top padding to let Forum breathe.

### 5.4 Border treatment

- Standard cards: 1px `var(--brand-brass-deep)` border, `var(--radius-md)` corner radius.
- Featured cards (active session, selected Icon): 1px `var(--brand-brass)` with 1px inset `var(--brand-brass-shadow)`, giving a beveled brass plate effect. Reserved for emphasis.
- No drop shadows on dark surfaces (they read as smudge). Use border + subtle inset highlight instead.
- No `box-shadow` outside what tokens define. Inline `style="box-shadow: …"` is a Stylelint failure.

---

## 6. Component Patterns

All foundation primitives below are **native Vue SFCs** in `packages/ui/src/components/<Name>/`, with scoped SCSS, BEM naming (`.app-<name>`, `.app-<name>__el`, `.app-<name>--mod`), max 3-level nesting, no Tailwind utility classes in the rendered DOM, no `!important`, no inline `style=""` with literal values. Each ships with `<Name>.vue + <Name>.stories.ts + <Name>.spec.ts + index.ts`. Flutter equivalents live in `packages/ui_flutter/lib/src/widgets/`, themed off `tokens.g.dart`.

### 6.1 Buttons (`AppButton`)

- **Primary:** `var(--brand-brass)` background, `var(--text-on-brass)` text, 1px `var(--brand-brass-deep)` border. Hover lifts to `var(--brand-brass-light)`. Used for "Save," "Push the Roll," "Create Character."
- **Secondary:** transparent background, `var(--brand-brass)` text and 1px border. Hover fills with `var(--surface-dawn)`.
- **Tertiary / Link:** `var(--brand-brass)` text only, underline on hover.
- **Danger:** `var(--state-crimson)` background, `var(--text-primary)` text. Reserved for destructive irrevocable actions (delete character, revoke share).

All `AppButton`s round to `var(--radius-md)`. **Never pill-shaped** — pills feel modern-SaaS, which fights the aesthetic. The `--radius-pill` token exists but is reserved for status chips only.

### 6.2 Forms (`AppInput`, `AppLabel`, `AppFieldError`)

- Labels in `--type-body-sm`, `var(--brand-brass)`, above the input.
- Inputs: `var(--surface-night)` background, 1px `var(--brand-brass-shadow)` border, `var(--brand-brass)` text. Focus state: 2px `var(--brand-brass)` border with no ring (rings feel too web-default), but a `:focus-visible` outline so keyboard users get a clear focus indicator.
- Validation errors below the input in `var(--state-crimson-bright)`, `--type-body-sm`, surfaced from the API's RFC 9457 `application/problem+json` `detail` field via the localized error key.

### 6.3 Sheet stat blocks (`AppStatBlock`)

A repeating component used for attributes and skills. Renders as:

- Label in Forum, uppercase (`text-transform: uppercase`), `--type-body-sm` with `letter-spacing: 0.08em`, `var(--brand-brass-light)`.
- Value in JetBrains Mono `--type-mono-stat-md`, `var(--text-primary)`.
- Optional rank dots — filled `var(--brand-brass)` circles in a row of 5, with text equivalents in `aria-valuenow` / `aria-valuemax`.

Tappable on mobile, click-to-edit-inline on desktop. No modal for editing a single stat; that interrupts flow. The component never imports `useI18n()` itself — translated strings (label, accessible name) come in as props.

### 6.4 Dice roller panel (`AppDiceRoller`)

Floating panel anchored bottom-right on desktop, full-width sheet bottom on mobile. When invoked:

1. Pool size selector (numeric input + skill / attribute shortcut chips).
2. Roll button (primary, full-width).
3. On result: each die rendered as a 48px brass d6 face, 6s glowing teal.
4. Push button only appears if push is legal. Push button uses `var(--state-mystic-teal)` background to signal the prayer / cost relationship.

The pushed reroll dice appear _to the right_ of originals, slightly translated, so the player sees "what changed." Rolled and pushed events broadcast over the session's Centrifugo channel — the GM screen's DP counter updates without polling.

### 6.5 Combat tracker row (`AppCombatRow`)

Horizontal strip per combatant, height 64px:

- Left: drag handle, initiative number in `--type-mono-stat-md`.
- Center: portrait / initial circle, name in Forum `--type-display-md`, condition pills.
- Right: HP / MP counters with +/- buttons, quick action menu (apply damage, heal, condition).
- Active turn: row gets `var(--brand-brass)` left border 4px, an "▶" prefix in screen-reader-visible text, and a faint inner glow. **Color is never the sole signal** — the prefix and aria-current attribute carry the meaning equally.

### 6.6 Share-link viewer (`AppShareViewer`)

Public read-only sheets get a different chrome to make their nature obvious:

- Top banner in `var(--surface-parchment)` background, `var(--text-ink)` text: _"Shared by [name] — last updated [time]. Read-only view."_
- Watermark of the eight-pointed star at 5% opacity in the page background.
- No edit affordances rendered at all (not disabled — absent).

The route is `/shared/character/:slug` and is client-rendered (`ssr: false`); the Open Graph preview image is served by the API at `/api/v1/public/og/character/:slug.png` so social/Discord previews still work.

### 6.7 What goes in `@app/ui` vs. what stays in pages

The handbook is strict here: **all stateless UI lives in `@app/ui`**. Pages in `apps/web/app/pages/` are thin orchestrators — fetch data, pass props, handle routing, no ad-hoc markup past one `<section>` wrapping `@app/ui` compositions. Storybook-first is blocking — no `apps/web` PR may introduce a new visual element not already in `@app/ui` with a story + spec.

### 6.8 Foundation primitives are native — Nuxt UI is for behavior only

Per the boilerplate's design-system handbook:

- `AppButton`, `AppBadge`, `AppChip`, `AppInput`, `AppSwitch`, `AppProgress`, `AppCard`, `AppStatBlock`, `AppCombatRow`, `AppDiceRoller`, `AppShareViewer` are **native Vue SFCs** with scoped SCSS on tokens. They do not wrap `UButton` / `UBadge` / `UInput` / etc.
- Nuxt UI is allowed only for **behavior-heavy** primitives: `UModal`, `USlideover`, `UDropdownMenu`, `UPopover`, `UTooltip`, `UCommandPalette`, `UTable`, `UCalendar`. Each is wrapped by an `AppXxx` component (`AppModal`, `AppDropdown`, …) — that wrapper is the only place the Nuxt UI symbol may be imported.
- Zero direct Nuxt UI imports in `apps/web` — `import { UButton } from '#components'` is a review blocker.

---

## 7. Key Screens (briefs)

### 7.1 Landing page (public, client-rendered)

Single hero with the app wordmark in Forum, a tagline ("Your character sheet for the Third Horizon"), and two buttons: "Sign in" / "Create account." Background: `var(--surface-void)` with subtle star-field SVG and a brass arabesque border. Below the fold: three feature blocks (Sheet, Share, Run). Footer with the fan-project disclaimer.

### 7.2 Dashboard (auth)

Personal "bridge" view. Cards for Characters, Ships, Sessions (GM only). Each card lists 0–3 most-recent items with quick-open. Empty states use brass line-art ("No characters yet — chart a course"). Top-right: avatar menu.

### 7.3 Character creation wizard

Six steps, progress bar in `var(--brand-brass)`. Each step is a single decision focused on a single question. The Icon step is the most ornamental: a 3×3 grid of Icon cards, each with the glyph, name, and a one-line domain ("The Traveler — patron of explorers and pilots"). Selecting an Icon pulses its card with a teal aura.

### 7.4 Character sheet

The product's centerpiece. Already detailed in §5.2 above. The sheet header carries the brass plate treatment: portrait left, name and concept centered in Forum, HP/MP counters right with +/- controls. Tabs below (Stats | Gear | Talents | Notes | Share).

### 7.5 Combat tracker

Desktop-shaped, even on tablet. Header shows session name, round counter, Darkness Points (in `var(--state-darkness)` with a dedicated pulsing dot when DP changes via Centrifugo). Below: vertically stacked combatant rows (§6.5). Bottom toolbar: "Next turn," "End round," "End encounter."

### 7.6 GM session view

A session has three tabs: Overview (notes, DP log), Encounters (list, plus active combat tracker), Crew (linked PC sheets in read-only). Player sheets open in a modal slide-in (`AppSlideover`, wrapping `USlideover`), not a navigation transition, so the GM never loses session context.

---

## 8. Mobile Considerations

The Flutter app (`apps/mobile`) is a first-class client, not a "future" target — it consumes the same generated `app_api_client` (Dart) and the same `tokens.g.dart` design system as the web app's CSS variables.

- Sheet header is sticky and condensed: name, HP, MP, conditions only. The portrait collapses to a 32px circle.
- Tabs become a bottom bar with iconography (because thumb reach on a phone at the table matters more than label clarity).
- Dice roller is a full-width sheet that slides up from the bottom, dismissable by swipe-down.
- Forms use platform-native input types so phone keyboards switch correctly (`keyboardType: TextInputType.number` for stats).
- Tap targets minimum 44×44px (enforced by `app_ui` tokens).
- The combat tracker on mobile drops to a simplified one-combatant-at-a-time card with prev / next swipe — usable but not the recommended GM device. Sources of state: Centrifugo subscriptions on `session.<gameSessionId>` keep the displayed combatant in sync with whatever the GM is editing.

---

## 9. Motion & Micro-interactions

Motion is restrained and ceremonial — befitting an app that asks you to pray to dice. Every duration and easing is a token; no raw `200ms` literals in component code.

- **Page transitions:** `var(--motion-duration)` cross-fade. No slide-from-right router animations.
- **Roll resolution:** dice "settle" with a `var(--motion-duration-slow)` staggered scale-in. Successes (6s) get a `var(--motion-duration-ceremony)` teal glow pulse.
- **Push:** a half-second brass-particle effect emanating from the prayer button as DP increments visibly on the GM's session counter (over Centrifugo).
- **Save state:** auto-save indicator is a single brass dot that pulses once on save. No "Saving…" toasts.
- **Damage applied:** the affected combatant's row briefly flashes `var(--state-crimson)` at 30% opacity for 250ms.

All motion respects `prefers-reduced-motion: reduce`. Reduced-motion variant: state changes are instantaneous, glows replaced with static color shifts. `AppCombatRow` and `AppDiceRoller` specs include a reduced-motion test case.

---

## 10. Accessibility

Beyond the WCAG AA baseline in the PRD:

- All Icon glyphs have `aria-label` with the Icon's full name (localized).
- Stat-block dot indicators include text equivalents (`aria-valuenow`, `aria-valuemax`).
- Color is never the sole signal — the active turn in combat uses a left border _and_ a "▶" prefix, not just the brass border alone.
- Screen-reader-only headings structure the sheet for navigation: H1 character name, H2 per major section, H3 per subsection.
- The floating dice roller is a `role="dialog"` with proper focus trap when open. Wrapped with `AppModal` (built on `UModal`).
- Keyboard shortcuts (combat: `n` next turn, `r` end round, `d` apply damage to focused combatant) are documented in a `?` overlay.
- Storybook's `addon-a11y` panel must be **clean** for every component — non-negotiable for merge. CI runs the audit.

---

## 11. Component Inventory

This list maps to `specs/design/README.md` and is the source of truth for what `pnpm design:audit` checks. Every entry is a folder under `packages/ui/src/components/<Name>/`, plus the matching Flutter widget under `packages/ui_flutter/lib/src/widgets/`.

### 11.1 Foundation primitives (native SCSS)

`AppButton`, `AppBadge`, `AppChip`, `AppInput`, `AppSwitch`, `AppProgress`, `AppIcon`, `AppCard`, `AppAvatar`, `AppBanner`, `AppTab`, `AppTooltip`, `AppKbd`, `AppDots` (rank dots), `AppDivider`, `AppSegControl`.

### 11.2 Coriolis-specific primitives

`AppIconCoriolis` (one of the Nine), `AppDie` (single d6 face), `AppDiePool` (collection of dice with success counting), `AppConditionPill` (Exhausted / Sleepless / Thirsty / Hungry), `AppStarOrnament` (eight-pointed star, sizes sm / md / lg), `AppArabesqueCorner` (four orientations).

### 11.3 Compositions

`AppPageHero`, `AppEmptyState`, `AppSkeleton`, `AppStatBlock`, `AppSheetHeader`, `AppCombatRow`, `AppDiceRoller`, `AppShareViewer`, `AppDpCounter`, `AppShipStatBlock`, `AppCrewRow`, `AppNpcCard`, `AppRollHistoryItem`.

### 11.4 Behavior-wrapping (Nuxt UI inside, AppXxx outside)

`AppModal` (over `UModal`), `AppSlideover` (over `USlideover`), `AppDropdown` (over `UDropdownMenu`), `AppPopover` (over `UPopover`), `AppCommandPalette` (over `UCommandPalette`), `AppTable` (over `UTable`), `AppCalendar` (over `UCalendar`).

Every component in §11.1–§11.4 must have a story covering every variant in light / dark, plus a `*.spec.ts` that hits rendering, a11y smoke, variant tests, and (where relevant) reduced-motion behavior.

---

## 12. Source-Bundle Mockups

The boilerplate's design hierarchy is **JSX mockups > screen `.md` specs > implementation**. Pixel-precise reference mockups go in `specs/design/mockups/*.jsx`. For Coriolis v1, the bundle ships:

- `LandingPage.jsx`
- `Dashboard.jsx`
- `CharacterCreationWizard_StepIcon.jsx` (most ornate step)
- `CharacterSheet_Desktop.jsx`
- `CharacterSheet_Mobile.jsx`
- `ShipSheet.jsx`
- `CombatTracker.jsx`
- `DiceRoller_Open.jsx`
- `DiceRoller_Pushed.jsx`
- `ShareViewer.jsx`
- `GmSession_Overview.jsx`

Each mockup uses the same CSS variable names emitted by `pnpm design:build`, so a JSX mockup is a faithful preview of how the real component will look once the `@app/ui` build is wired up. **If a `.md` spec contradicts the JSX, the JSX wins.**

---

## 13. Asset List

For the design execution phase, the following assets must be commissioned or created:

1. **App wordmark** — Forum-based, hand-tuned, with optional brass arabesque flourish. Render with Latin and Cyrillic variants for marketing assets.
2. **Nine Icon glyphs** — single illustrator pass, SVG, brass on transparent.
3. **Eight-pointed star ornament set** — corner, divider, watermark variants.
4. **Arabesque corner pieces** — four orientations.
5. **Empty-state line art** — 4 illustrations: no characters, no ships, no sessions, no shared links.
6. **Dice face SVGs** — 1–6, with hit (6) variant in teal glow.
7. **Loading state** — spinning astrolabe SVG, 1.2s rotation (token: `--motion-duration-ceremony × 2`).
8. **Open Graph image template** — 1200×630, rendered server-side at `/api/v1/public/og/character/:slug.png` with character name and Icon glyph.

Illustration brief: line weight 1.5pt at 24px reference size, no gradients, single-color brass on transparent, no Western-fantasy iconography (no swords-and-sorcery flourishes — keep it Coriolis-specific). All assets must be re-renderable from the brand pipeline so a token edit cascades cleanly.

---

## 14. What This Design Is Not

To keep the team aligned, what we are explicitly _not_ building visually:

- Not a Notion clone — no floating menus, no slash commands, no minimal-grey aesthetic.
- Not a Foundry / Roll20 GM screen — those are dense, technical, function-over-form. This app is _a digital character sheet that happens to have a combat tracker_, not a virtual tabletop.
- Not a generic dark mode — the indigo is specifically Coriolis-blue, not zinc / slate / neutral.
- Not skeuomorphic — we are not faking paper or leather. The aesthetic is _digital made ceremonial_, not _digital pretending to be physical_.
- Not Western fantasy — no parchment-with-blood-spatter, no dragon iconography, no medieval longswords. The look is Arabian-sci-fi, not D&D.
- Not Tailwind-utility-driven — utility classes are forbidden in `@app/ui` foundation primitives' rendered DOM. Tokens-via-SCSS is the path.

---

## 15. Hard bans (design)

Mirroring the boilerplate's `design-system.md`:

- Private brand hex like `#F26A1F` in a `.vue` or `.scss` file — reference `var(--brand-brass)` (or the appropriate token) instead. Stylelint's `color-no-hex` enforces this.
- An `@app/ui` component without a Storybook story + colocated `*.spec.ts`.
- Wrapping a Nuxt UI foundation primitive (`UButton`, `UInput`) as `@app/ui` — those must be native SCSS.
- Tailwind utility classes (`bg-primary`, `hover:*`) in the rendered DOM of an `@app/ui` foundation primitive.
- Ad-hoc markup in `apps/web/app/pages/` instead of extending `@app/ui`.
- A user-visible string without `t()` (web) or `context.t.*` (mobile) — every label, ARIA value, and toast text is keyed.
- Renaming or deleting a token without an ADR.
