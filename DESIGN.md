---
name: Coriolis Companion App
description: A digital relic for the Third Horizon. Brass on indigo, ceremony over chrome.
colors:
  surface-void: "#0B0E2C"
  surface-night: "#15193F"
  surface-dawn: "#252B5C"
  surface-parchment: "#F2E8D0"
  brass-light: "#F4E4B8"
  brass: "#D4A95C"
  brass-deep: "#A67C28"
  brass-shadow: "#6B4E1A"
  text-primary: "#F2E8D0"
  text-secondary: "#D9CDB0"
  text-ink: "#1A1810"
  text-on-brass: "#0B0E2C"
  crimson: "#A8324A"
  crimson-bright: "#E54E6B"
  mystic-teal: "#2BA3A0"
  success: "#5A8A3A"
  darkness: "#5B2A78"
typography:
  display-xl:
    fontFamily: "Forum, Cormorant Garamond, serif"
    fontSize: "48px"
    lineHeight: "56px"
    fontWeight: 400
    letterSpacing: "0.06em"
  display-lg:
    fontFamily: "Forum, Cormorant Garamond, serif"
    fontSize: "36px"
    lineHeight: "44px"
    fontWeight: 400
    letterSpacing: "0.04em"
  display-md:
    fontFamily: "Forum, Cormorant Garamond, serif"
    fontSize: "28px"
    lineHeight: "36px"
    fontWeight: 400
    letterSpacing: "0.04em"
  display-sm:
    fontFamily: "Forum, Cormorant Garamond, serif"
    fontSize: "20px"
    lineHeight: "28px"
    fontWeight: 400
    letterSpacing: "0.08em"
  body-lg:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: "18px"
    lineHeight: "28px"
    fontWeight: 400
  body-md:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: "16px"
    lineHeight: "24px"
    fontWeight: 400
  body-sm:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: "14px"
    lineHeight: "20px"
    fontWeight: 500
  label-sm:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: "12px"
    lineHeight: "1.4"
    fontWeight: 500
    letterSpacing: "0.06em"
  mono-stat-xl:
    fontFamily: "JetBrains Mono, ui-monospace, monospace"
    fontSize: "32px"
    lineHeight: "32px"
    fontWeight: 700
  mono-stat-md:
    fontFamily: "JetBrains Mono, ui-monospace, monospace"
    fontSize: "20px"
    lineHeight: "24px"
    fontWeight: 500
rounded:
  sm: "2px"
  md: "4px"
  lg: "8px"
  pill: "9999px"
spacing:
  "1": "4px"
  "2": "8px"
  "3": "12px"
  "4": "16px"
  "5": "20px"
  "6": "24px"
  "7": "32px"
  "8": "40px"
  "9": "48px"
  "10": "56px"
  "11": "64px"
  "12": "80px"
components:
  button-primary:
    backgroundColor: "{colors.brass}"
    textColor: "{colors.text-on-brass}"
    typography: "{typography.body-md}"
    rounded: "{rounded.md}"
    padding: "8px 16px"
  button-primary-hover:
    backgroundColor: "{colors.brass-light}"
    textColor: "{colors.text-on-brass}"
  button-primary-active:
    backgroundColor: "{colors.brass-deep}"
    textColor: "{colors.text-on-brass}"
  button-mystic:
    backgroundColor: "{colors.mystic-teal}"
    textColor: "{colors.text-on-brass}"
    rounded: "{rounded.md}"
    padding: "8px 16px"
  button-secondary:
    backgroundColor: "transparent"
    textColor: "{colors.brass}"
    rounded: "{rounded.md}"
    padding: "8px 16px"
  button-danger:
    backgroundColor: "{colors.crimson}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.md}"
    padding: "8px 16px"
  input:
    backgroundColor: "{colors.surface-night}"
    textColor: "{colors.brass-light}"
    rounded: "{rounded.md}"
    padding: "8px 16px"
  chip:
    backgroundColor: "transparent"
    textColor: "{colors.brass-light}"
    rounded: "{rounded.pill}"
    padding: "3px 12px"
  card:
    backgroundColor: "{colors.surface-night}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.md}"
    padding: "24px"
---

# Design System: Coriolis Companion App

## 1. Overview

**Creative North Star: "The Brass Astrolabe"**

The Coriolis universe is deep-space science fiction wrapped in pre-modern, sacred, ornate language. Starships wear arabesques on their hulls; pilots whisper to the Icons before they push dice. The companion app is a ceremonial instrument, brass etched on the indigo void, closer to an astrolabe than to a SaaS console. Every surface should read as a digital relic that earns its ornament, not a dashboard that decorates for the sake of it.

The system is dark-first. Light (parchment) is reserved for the share-link viewer and the high-contrast accessibility variant; it is the exception that proves the void. Ornament is welcome where it carries meaning (Icon affinity, prayer state, the mystical) and goes silent where information density rules (combat tracker, inventory rows). A character sheet is read at speed during play: numbers stay legible and high-contrast, decoration never pushes a stat below the fold.

This system explicitly rejects the generic dark-mode tool, the Notion-grey minimalism, the virtual-tabletop density of Foundry and Roll20, and Western-fantasy parchment-and-dragons. The indigo is Coriolis-blue, never zinc or slate. The metal is brass, never gold-rush bling.

**Key Characteristics:**
- Brass (`#D4A95C`) on indigo void (`#0B0E2C`) is the entire brand; greys are forbidden.
- Ceremonial, restrained motion. The app asks you to pray to dice, so reveals are weighty, not bouncy.
- Display type (Forum) names things; it never labels them.
- Flat on dark. Depth comes from brass borders and inset bevels, not drop shadows.
- Color is never the sole signal; meaning is doubled with icon, prefix, or aria state.

## 2. Colors

A two-anchor palette: brass warmth struck against indigo depth, with a tight semantic set for play states.

### Primary
- **Brass** (`#D4A95C`): the brand. Primary fills, key borders, focus rings, active accents.
- **Brass Light** (`#F4E4B8`): headings on dark, hover-lift on primary fills, focused brass.
- **Brass Deep** (`#A67C28`): aged brass for hairline rules and secondary borders; primary-button active state.
- **Brass Shadow** (`#6B4E1A`): inset shadows, deep dividers, input resting borders.

### Secondary
- **Mystic Teal** (`#2BA3A0`): the only non-brass accent allowed to carry weight. Mystic powers, MP, the Push / prayer relationship, chosen-Icon glow. When teal appears, something ritual is happening.

### Tertiary
Semantic-only, never decorative.
- **Crimson** (`#A8324A`) / **Crimson Bright** (`#E54E6B`): HP loss, critical injury, destructive actions, validation errors.
- **Success** (`#5A8A3A`): rolled successes (6s), positive completion.
- **Darkness** (`#5B2A78`): Darkness Points, GM-only corruption UI.

### Neutral
- **Surface Void** (`#0B0E2C`): the deepest indigo. App background, the dice canvas, the void of space.
- **Surface Night** (`#15193F`): card and panel background.
- **Surface Dawn** (`#252B5C`): elevated surfaces, modals, hovered cards.
- **Surface Parchment** (`#F2E8D0`): warm light surface for the share-link viewer and printed-feeling overlays.
- **Text Primary** (`#F2E8D0`) / **Text Secondary** (`#D9CDB0`): body and helper copy on dark.
- **Text Ink** (`#1A1810`): body text on parchment.
- **Text On Brass** (`#0B0E2C`): indigo text on a brass fill (primary buttons).

### Named Rules
**The Brass-on-Indigo Rule.** The palette is the brand. There is no drift toward neutral grey, zinc, slate, or generic dark-mode black. If a surface looks grey, it is wrong; tint it back toward indigo.

**The One Teal Voice Rule.** Mystic teal is the single accent permitted to break the brass monopoly, and only to signal the mystical or the Push. Used anywhere else it dilutes the one moment it is meant to mark.

**The Ornament-with-Purpose Rule.** Decoration appears where it reinforces meaning (Icon cards, prayer states, sheet headers) and is forbidden where it competes with information density (combat rows, inventory tables).

## 3. Typography

**Display Font:** Forum (with Cormorant Garamond, serif fallback)
**Body Font:** Inter (with system-ui, sans-serif fallback)
**Numeric / Mono Font:** JetBrains Mono (with ui-monospace, monospace fallback)

**Character:** Forum is Roman-inscriptional, Trajan-inspired, the authority of a brass plate engraved into a ship's hull. Inter carries the legible UI workload underneath it. JetBrains Mono gives every number a player scans under pressure a tabular, columnar home. All three ship Latin and Cyrillic; the app renders en and ru with no conditional font loading.

### Hierarchy
- **Display XL** (Forum 400, 48px/56px, tracking 0.06em): landing headline only.
- **Display LG** (Forum 400, 36px/44px, tracking 0.04em): character name on the sheet header.
- **Display MD** (Forum 400, 28px/36px, tracking 0.04em): section headers (Skills, Inventory).
- **Display SM** (Forum 400, 20px/28px, tracking 0.08em, uppercase): stat-block labels.
- **Body LG / MD / SM** (Inter, 18px / 16px / 14px): primary body, default UI copy, and labels-captions. Cap reading measures at 65 to 75ch.
- **Label SM** (Inter 500, 12px, tracking 0.06em, uppercase): menu eyebrows, dense chrome.
- **Mono Stat XL** (JetBrains Mono 700, 32px): HP and MP big counters.
- **Mono Stat MD** (JetBrains Mono 500, 20px): skill ranks, item weights, dice values.

### Named Rules
**The Reserved Display Rule.** Forum names things; it never labels them. It is forbidden on buttons, tooltips, and table cells. Use it for a character's name, a section title, the wordmark, never for a control.

**The Single Weight Rule.** Forum ships one weight (Regular 400). Emphasis comes from size and tracking (0.04em to 0.10em), never from a non-existent bold. When a heading needs a bold descriptor beside it, pair Forum with Inter Semibold rather than faking weight.

## 4. Elevation

The system is flat on dark. Drop shadows on an indigo surface read as smudge, so depth is built from brass: a 1px border at rest, a beveled inset for emphasis, a teal halo for the mystical. Light overlays (modals, the parchment share viewer) are the only place a soft indigo lift appears.

### Shadow Vocabulary
- **Brass Bevel** (`inset 0 1px 0 rgba(244,228,184,0.4), inset 0 -1px 0 rgba(107,78,26,0.6)`): the pressed brass-plate effect on primary buttons and medallions. The default "raised metal" treatment.
- **Card Featured** (`inset 0 0 0 1px #6B4E1A`): inset brass edge on a selected or active card (session, chosen Icon).
- **Panel Rise** (`0 8px 24px rgba(11,14,44,0.6)`): subtle indigo lift, reserved for elevated panels and modals on light or dawn surfaces.
- **Icon Glow** (`0 0 24px rgba(43,163,160,0.35)`): mystic teal halo for chosen Icons and active mystic elements. Meaning, not decoration.
- **Danger Pulse** (`0 0 16px rgba(229,78,107,0.45)`): crimson glow for crit-fail and destructive confirmation states.

### Named Rules
**The Flat-on-Dark Rule.** No drop shadows on dark surfaces. Convey depth with a brass border plus an inset highlight. An inline `box-shadow` with a literal value is a Stylelint failure.

**The Glow-as-Meaning Rule.** A glow is never ambient polish. Teal glow means mystic, crimson glow means danger. If a glow does not encode state, delete it.

## 5. Components

Foundation primitives are native Vue SFCs with scoped SCSS on tokens (BEM, max 3-level nesting, no Tailwind utilities in the rendered DOM, no `!important`, no inline literal styles). Nuxt UI is wrapped only for behavior-heavy primitives (modal, slideover, dropdown).

### Buttons (`AppButton`)
- **Shape:** square-cornered, never pill (`--radius-md`, 4px). Pills feel modern-SaaS and fight the aesthetic; the pill radius is reserved for status chips only.
- **Primary:** brass fill (`#D4A95C`), indigo text (`#0B0E2C`), brass-bevel inset. Used for Save, Create Character.
- **Mystic:** teal fill (`#2BA3A0`), indigo text. The ritual CTA: Push the Roll, prayer-eligible confirms.
- **Secondary:** transparent fill, 1px brass border, brass text. Cancel, Skip, Reroll.
- **Ghost:** transparent fill, 1px brass-deep border, brass-light text.
- **Danger:** crimson fill (`#A8324A`), light text. Destructive irrevocable actions only (delete character, revoke share).
- **Hover / Focus:** primary lifts to brass-light; outlined variants tint their fill via `color-mix`. Focus is a 2px brass outline at 2px offset, no soft ring.

### Chips (`AppChip`)
- **Shape:** pill (`--radius-pill`). The one place pills are allowed.
- **Variants:** brass / mystic / crimson / success / darkness, each as outline at rest, solid fill when active (`aria-pressed`). Selected state inverts to filled accent with contrasting text.
- **Use:** filter and toggle affordances (dice pool shortcuts, condition pills).

### Cards / Containers (`AppCard`)
- **Corner Style:** 4px (`--radius-md`).
- **Background:** surface-night (`#15193F`).
- **Border:** 1px brass-shadow (`#6B4E1A`) at rest.
- **Featured:** brass-deep border plus brass-bevel inset, with a second inset brass edge on hover. The beveled brass plate, reserved for active session and selected Icon.
- **Internal Padding:** `--space-6` (24px) body, `--space-4 --space-6` header and footer.

### Inputs / Fields (`AppInput`)
- **Style:** surface-night fill, 1px brass-shadow border, brass-light text, 4px radius.
- **Hover:** border shifts to brass-deep.
- **Focus:** 2px brass outline at 2px offset plus a brass border. No default web ring.
- **Error:** crimson border and outline; validation message sits below in crimson-bright, surfaced from the API's RFC 9457 `problem+json` detail via a localized key.

### Component contract & prop conventions

**Validation states.** The `invalid` prop (crimson border + `aria-invalid`) lives on the **form-input controls**: `AppInput`, `AppSelect`, `AppTextarea`, `AppSwitch`, `AppSegControl` — and is wired automatically when they sit inside an `AppField` with an `error`. **Filter / display components are validation-exempt** and intentionally have no `invalid` prop: `AppChip` (filter/toggle affordance), `AppConditionPill`, `AppBadge`, `AppStatBlock`, `AppDots` (read-only display). A control that takes user input carries every interactive state; a control that only filters or displays does not.

**Focus ring.** Every focusable control shows the same ring: `outline: 2px solid var(--brand-brass); outline-offset: 2px`. Compound controls (e.g. `AppChatComposer`) put the ring on the container via `:focus-within` rather than the inner element. There is no second focus idiom.

**`tone` vs `variant`.** `variant` names a **semantic palette** choice on a multi-colour control (`AppChip`, `AppBadge`: brass / mystic / crimson / success / darkness). `tone` names a **two-value brass↔mystic axis** on otherwise monochrome controls (`AppTab`, `AppSkillRow`, `AppStatBlock`, `AppDiePool`). They are distinct concepts, not synonyms; a physical rename is out of scope (breaking change), so the split is documented rather than collapsed.

**Size matrix.** `sm | md | lg` on layout-bearing controls (`AppButton`, `AppInput`, `AppSelect`, `AppTextarea`, `AppSegControl`); `sm | md` only on compact controls (`AppField`, `AppSwitch`, `AppChip`, `AppBadge`, `AppConditionPill`, `AppTab`). `md` is always the default.

### Navigation
- Desktop: top tabs in Inter, brass-light active, brass-deep idle. Mobile: bottom bar with iconography (thumb reach beats label clarity at the table).

### Signature: Dice Roller (`AppDiceRoller`)
Floating panel anchored bottom-right on desktop, full-width bottom sheet on mobile. Pool selector, a full-width roll button, then each die rendered as a 48px brass d6 face. A rolled 6 settles with a ceremonial teal glow. The Push button appears only when a push is legal and uses the mystic-teal fill to signal the prayer-and-cost relationship; pushed rerolls slide in to the right of the originals so the player sees what changed.

## 6. Do's and Don'ts

### Do:
- **Do** keep brass on indigo as the entire brand voice. Tint every neutral toward Coriolis-blue.
- **Do** reserve mystic teal for the mystical and the Push, and crimson for HP loss and destruction.
- **Do** convey depth with brass borders and inset bevels; keep dark surfaces flat.
- **Do** double every color signal. The active combat turn carries a brass left treatment plus a "▶" prefix and `aria-current`, not color alone.
- **Do** round buttons to 4px and keep them square-shouldered.
- **Do** use Forum to name things (character names, section titles, the wordmark) and Inter to label them.
- **Do** let motion stay restrained and ceremonial, easing out, respecting `prefers-reduced-motion`.

### Don't:
- **Don't** build a generic dark mode. The indigo is Coriolis-blue, not zinc, slate, or neutral grey.
- **Don't** make it a Notion clone: no floating menus, no slash commands, no minimal-grey aesthetic.
- **Don't** make it a Foundry / Roll20 GM screen: this is a digital character sheet that happens to have a combat tracker, not a virtual tabletop.
- **Don't** go skeuomorphic. The aesthetic is digital made ceremonial, not digital faking paper or leather.
- **Don't** use Western-fantasy iconography: no parchment-with-blood-spatter, no dragons, no medieval longswords. The look is Arabian sci-fi.
- **Don't** ship pill-shaped buttons; pills read as modern-SaaS and are reserved for status chips.
- **Don't** put a drop shadow on a dark surface, or any `box-shadow` outside the defined tokens. Inline `box-shadow` literals fail Stylelint.
- **Don't** use Forum for buttons, tooltips, or table cells.
- **Don't** write a private brand hex (like `#D4A95C`) into a `.vue` or `.scss` file; reference the token. `color-no-hex` enforces it.
- **Don't** use a gradient on text, a side-stripe colored border, or decorative glassmorphism.
