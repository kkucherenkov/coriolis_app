# Patterns

Cross-cutting interaction and composition rules. Not components — the _grammar_
by which components combine. Token names below come from
[`tokens/`](./tokens/); component names from
[`README.md` — Component inventory](./README.md#component-inventory). For each
handoff term that differs from the project-canonical name, see
[`HANDOFF_NAME_MAP.md`](./HANDOFF_NAME_MAP.md).

---

## 1. Layout

### Page padding-x

Three canonical values:

- `--space-10` (56 px) — hero pages: Landing, Bridge dashboard, the wizard,
  Character Sheet desktop, Ship Sheet desktop.
- `--space-8` (40 px) — content pages: combat tracker, GM session, share
  viewer, library.
- `--space-4` (16 px) — mobile (all surfaces).

Never mix horizontal paddings within a single column. If a sub-section needs
more breathing room, wrap it in a card with its own internal padding instead.

### Grid gaps

| Use                                 | Token                       |
| ----------------------------------- | --------------------------- |
| Major card columns                  | `--space-6` (24 px)         |
| Dense card content                  | `--space-4` (16 px)         |
| Chip rows, dot rows                 | `--space-2` (8 px)          |
| Inline icon + text                  | `--space-3` (12 px)         |
| Wizard step content → footer offset | `--space-8` (40 px) min-top |

### Card composition order

A card is an `<AppCard>` instance (variant `default` or `featured`). The
contents follow a fixed order — composition is the grammar; freeform stacking
is forbidden:

1. **Optional eyebrow** — `--type-label-sm` (uppercase Inter, brass-deep).
2. **`AppPanelTitle`** — auto-pairs with `AppSwash` directly beneath.
3. **Body content** — single-column flex/grid; do not interleave eyebrows.
4. **Optional footer row** — buttons (trailing primary) or meta chips.

Don't nest cards more than one level deep. Don't put a card inside a chip. If
a card needs a sub-section, separate it with `<AppDivider />` rather than an
inner card. Never apply a custom `box-shadow` to `AppCard` — use
`variant="featured"` if you need elevation.

---

## 2. Hero composition

The standardized hero shape used on Character Sheet, Ship Sheet, Share Viewer,
and Session Join:

```
+-----------------------------------------+
| ↖ AppArabesqueCorner   AppArabesque… ↗ |
|                                         |
|  [AppPortrait]  EYEBROW                 |
|                 Forum display name      |
|                 ‿‿‿‿‿‿‿  (AppSwash)      |
|                 [AppIconMedallion] · descriptor
+-----------------------------------------+
```

- Grid: `gridTemplateColumns: 'auto 1fr auto'`. Portrait and the optional
  right-side stat block hug their content; name + swash flex in the middle
  column.
- Optional stat block (HP/MP on character; Hull/Energy on ship) sits flush
  with the **bottom** of the name + swash row, not the top.
- Hero font roles (project-canonical, see
  [`README.md` typography table](./README.md#typography-typographyjson)):
  - Landing wordmark / cycle stat — `display-xl` (48 / 56), one composite.
  - Sheet name — `display-lg` (36 / 44).
  - Sub-headers — `display-md` (28 / 36) or `display-sm` (20 / 28 uppercase).

> **Gap.** The handoff uses a `display-hero` (64 px) role for Landing; the
> project's largest composite is `display-xl` (48 px). Tracked in the
> [Handoff name map](./HANDOFF_NAME_MAP.md). Until that role is added, the
> landing wordmark uses `display-xl` plus the `font.size.64` atom on the
> wordmark glyph only.

---

## 3. Empty states

A standardized empty card uses the same five-row cadence everywhere — the
ceremony, not the absence, is the message:

1. `AppStarOrnament` at 48–56 px, fill `--brand-brass-deep`,
   opacity 0.5–0.7.
2. Forum mini-title (`--type-display-sm`) in `--brand-brass-light` — one
   short sentence, declarative.
3. Inter body explanation (`--type-body-sm`) in `--text-secondary`, max-width
   ~320–380 px.
4. Optional secondary `AppButton variant="ghost"` link to the next action.
5. Vertical rhythm: row gap `--space-3` (12 px).

| Surface                  | Title                 | Body                                                    | CTA                     |
| ------------------------ | --------------------- | ------------------------------------------------------- | ----------------------- |
| Bridge — no characters   | "No characters yet"   | "Begin a new dossier."                                  | "Create one →"          |
| Chat panel — first visit | "No messages yet"     | "Say hello in {session}."                               | —                       |
| Crew tab — no players    | "Crew not yet aboard" | "Share your invite link to bring players to the table." | "Open invite manager →" |
| Player sessions list     | "No sessions yet"     | "Ask your GM for an invite link."                       | —                       |

Never replace the star with a generic SVG icon; the ornament is the signature.

---

## 4. Stateful banners

Three banner heights, three semantics. Use `<AppBanner>` for every variant —
do not hand-roll banner markup.

| Banner       | Background                                                                 | Tone prop | Role            | When                              |
| ------------ | -------------------------------------------------------------------------- | --------- | --------------- | --------------------------------- |
| Reconnecting | `color-mix(in oklab, var(--brand-brass) 14%, var(--surface-night))`        | `info`    | `role="status"` | Centrifugo reconnect in flight    |
| Disconnected | `color-mix(in oklab, var(--state-crimson) 18%, var(--surface-night))`      | `danger`  | `role="alert"`  | Connection lost                   |
| View-only    | `color-mix(in oklab, var(--brand-brass) 10%, transparent)` + dashed border | `view`    | `role="note"`   | Read-only echo of a writable card |

Banner contracts:

- **One banner per surface**, top of the relevant column.
- Reconnecting and disconnected mirror the `ConnectionPip` colour — never
  render them with conflicting state (see §13).
- View-only banners always sit **inside** the host card, not above it.

---

## 5. Modals & dialogs

The modal contract — every `<AppModal>` (or any future modal-like
component):

- **Wrapper.** `position: fixed; inset: 0` with scrim opacity
  `--opacity-elevated` (0.85). Scrim never fades content beneath without
  also blocking pointer events.
- **Dialog card.** `--radius-lg`, `AppArabesqueCorner` on the top edge,
  `AppSwash` beneath the title.
- **Labelling.** `aria-labelledby` points at the heading id. `aria-label` is
  the fallback only when the modal has no visible heading.
- **Close affordances.** `Esc` always closes. Explicit `Close` button always
  closes. Backdrop click is **not** a close trigger by default — too easy to
  mis-click and lose state. Override per-instance only when the modal carries
  no risk (e.g. the whisper-target picker).

### Dialog vs. alertdialog

- `role="dialog"` — informational, dismissable, no consequence.
- `role="alertdialog"` — requires explicit acknowledgement. Used for invite
  reveals, destructive confirmations (Revoke, Delete, Leave session).

### Drift note (2026-05-14)

`packages/ui/src/components/AppModal/AppModal.vue:25` currently defaults
`closeOnBackdrop: true`. This contradicts the contract above and is the
single point of drift between this document and shipped code. Tracked as a
follow-up — flip the default to `false` and audit every call site before the
modal contract is fully enforced. Until then, every consumer **must** pass
`:close-on-backdrop="false"` explicitly unless the surface is in the safe
override list (whisper-target picker only).

---

## 6. Forms

Inputs are dark on dark: `<AppInput>` uses `--surface-night` fill with
`--brand-brass-shadow` borders. Labels are uppercase Inter at
`--type-label-sm` (0.06 em tracking).

### Form group

```
LABEL UPPERCASE
[ input field                          ]
helper text in --text-secondary
```

Vertical stack only. **No** inline labels (label-on-left) — Cyrillic label
lengths blow up label-on-left alignment, and the resulting rag undermines
the brass-on-night silhouette. Compose every form row through
`<AppField>` so label + input + helper + error share one rhythm.

### Validation

Errors render **below** the input, in `--state-crimson-bright`, 12 px Inter,
prefixed with a small crimson dot. The input border shifts to
`--state-crimson` on error; the helper text is replaced (not appended) by the
error.

### Disabled

`opacity: var(--opacity-disabled)` (0.4). Background unchanged.
`cursor: not-allowed`. Disabled inputs remain in the tab order only when they
carry a tooltip explaining why.

---

## 7. Buttons

Pick the variant by _action consequence_, not visual weight. The variant set
is fixed and lives on `<AppButton :variant>`:

| Variant     | Consequence                                                                 |
| ----------- | --------------------------------------------------------------------------- |
| `primary`   | Primary intent of the screen. **One per surface.**                          |
| `secondary` | Reverse / alternative path.                                                 |
| `ghost`     | Tertiary — Close, Back, See all.                                            |
| `danger`    | Destructive — Revoke, Delete, Leave session.                                |
| `mystic`    | Ritual moments — Push the Roll, ritual blessings, Chosen-Icon affirmations. |

Hit target ≥ 44 × 44 logical px. On dense surfaces (Combat Tracker inline
actions) use the dense action style: brass-deep border + transparent fill +
11 px label + 4 × 10 px padding — implemented today as
`<AppButton variant="ghost" size="sm">` with the surface-local
`combat-tracker__action` modifier. Promote to a `dense` size on `AppButton`
when a second surface demands the same recipe.

### Pairing

Standard pairs (leading → trailing):

- **Wizard footer** — `Back` (ghost) + `Continue` (primary).
- **Invite — active** — `Revoke` (danger) + `Rotate` (secondary) + `Copy`
  (primary).
- **Dice roller** — `Close` (ghost) + `Reroll` (secondary) + `Push` (mystic).
- **Destructive confirmation** — `Cancel` (ghost) + `Delete` (danger).

Cancel-style ghosts always sit at the **leading** edge; primary action at
the trailing edge. Never reverse — muscle memory matters.

---

## 8. Chips & badges

Chips communicate _kind_; badges communicate _count_. The two never appear
side-by-side on the same row.

| Type           | When                                                                | Component                 |
| -------------- | ------------------------------------------------------------------- | ------------------------- |
| Default chip   | Metadata (Session 12, locked, +N more).                             | `<AppChip>`               |
| Condition pill | Bad condition or critical injury.                                   | `<AppConditionPill>`      |
| Mystic chip    | Ritual / blessing — Chosen, Online (in chat picker), Push-eligible. | `<AppChip tone="mystic">` |
| Count badge    | Numeric only — unread chat count, tab unread, dot-with-number.      | `<AppBadge>`              |

Badge rules:

- Always sit on the **trailing** edge of the host element.
- Minimum width 18 px; render `9+` past 9 in production (mockups may show raw
  values).
- Unread count badges use brass fill + mono number
  (`--type-mono-stat-md`, weight 500).

---

## 9. Iconography vs. medallions vs. portraits

The system avoids generic sprite icons. Three families, in order of
preference:

- **Medallions** (`<AppIconMedallion>`) — Forum monogram glyphs in a brass
  disc. Used for The Nine Icons, archetype concepts, group concepts, Bridge
  card titles.
- **Portraits** (`<AppPortrait>`) — Initials in a brass medallion. Used for
  characters, NPCs, member avatars in the crew rail.
- **Functional glyphs** (`<AppIcon>` inline SVG) — only where there is no
  good ornamental alternative: send arrow, X close, magnifier, dropdown
  caret, plus/minus, kebab/menu.

When in doubt, prefer a medallion. Audit-flag any sprite icon-font usage
during PR review — there should be none.

---

## 10. Motion patterns

All durations and easings come from `motion.json`. Every animated component
must declare a `@media (prefers-reduced-motion: reduce)` fallback per
[`README.md` — Reduced-motion guarantee](./README.md#reduced-motion-guarantee).

### Bubble in / out

New chat messages: 200 ms fade-in + 4 px upward translate. Reduced motion:
appear instantly.

### Tab change

Active `<AppTab>` swap: 200 ms cross-fade of the underline + 100 ms colour
shift of the label. Reduced motion: instant.

### Dice settle

After roll: 600 ms `--motion-ease-emphasis` end-easing on each
`<AppDie>`. 6s gain their teal glow at the **end** of the curve, not at the
start — the glow is the reveal. Reduced motion: all dice appear in their
final state, no glow animation.

### Push ritual

The `<AppButton variant="mystic">` glows for 600 ms before triggering the
reroll. Conveys "the gods are listening." Reduced motion: no glow; the
button shifts colour instantly.

### Modal enter

Backdrop fades in 100 ms. Dialog scales from 0.96 → 1.0 in 200 ms with
`--motion-ease-emphasis`. Reduced motion: backdrop appears instantly;
dialog at final scale.

### Save pulse

`<AppSavePulse>` shows a 600 ms brass halo on autosave success. Reduced
motion: replaces the halo with a fade-only opacity tick.

---

## 11. Cross-surface persistence

Things that **do** survive a page refresh:

- **Theme** — `Me.theme` enum (`dark` | `high-contrast`) on the server, with
  a `coriolis.theme` localStorage hint to avoid the default-theme flash. See
  [`README.md` — High-contrast theme](./README.md#high-contrast-theme).
- **Locale** — `Accept-Language` + the user setting on `Me`.
- **Tweaks panel state** (ornament density, debug overlays) — localStorage,
  scoped per device.

Things that **do not** persist:

- **Chat scroll position** — reset on tab swap is intentional; players want
  "new since I was last here" behaviour, modelled via a server-side
  `lastSeenAt` cursor.
- **Active wizard step** — closing the wizard discards progress until the
  final step commits. Drafts are session-scoped only.
- **Dice roller history filter** — resets on close.

---

## 12. Permissions & view-only patterns

Two distinct view-only modes. Pick by scope, not by author convenience.

### 12a. Partial view-only — the triad

When a writable surface contains a **subset** of read-only data (the canonical
case: a player viewing a session where DP, encounter cards, and roster live
on a GM-writable surface), the read-only zones render with the **view-only
triad** — all three signals together, never one alone:

1. **Affordance suppression.** Buttons that mutate are absent or replaced
   with a static label.
2. **Banner.** The host card adds the `view-only` banner (dashed
   `--brand-brass-deep` border, low-opacity brass fill, italic note in
   `--brand-brass-light`).
3. **Header suffix.** The header may add `(view only)` next to the value in
   `--text-secondary`, 11 px.

Surfaces that exercise the triad today:

- Player session header DP counter — number + ` view only` suffix.
- Player session encounter card — dashed-border note inside the card.

Never partial within the triad — never show "looks editable" controls that
quietly no-op. The banner alone (without affordance suppression) is also
forbidden.

### 12b. Fully read-only — chrome differentiation

When the **entire surface** is read-only (the share viewer at
`/shared/character/{slug}`, future archived-snapshot surfaces), the triad is
overkill — every card would carry a redundant dashed-border note. Signal 2

- signal 3 are scoped out; signal 1 (affordance suppression) is mandatory
  and the **chrome itself** carries the read-only message:

* A non-default surface palette — share viewer uses
  `--surface-parchment` instead of `--surface-night`.
* A top-of-page parchment banner with context metadata (GM display name,
  last-updated, public URL eyebrow) — see `SURFACES.md §10`.
* A faint `StarOrnament` watermark at low opacity.
* Footer CTA inviting the viewer to author their own sheet
  ("Sign in to create your own").

Surfaces that exercise chrome differentiation today:

- Share viewer (character) — `pages/shared/character/[slug].vue` +
  `AppShareViewer.vue`.
- Share viewer (ship) — `pages/shared/ship/[slug].vue`.

Audit checklist: a fully read-only surface that loses its chrome
differentiation (e.g. reverts to `--surface-night`) must adopt the §12a
triad instead. There is no middle ground.

---

## 13. Realtime / Centrifugo signals

Three places where realtime status surfaces. They are mirrors of each other,
never independent truths:

1. **Session header pip** (`ConnectionPip`) — green / amber-pulse / red.
   Lives in GM session, player session, and chat panel.
2. **Last-sync hint** — `Updated via Centrifugo · 2 s ago` on the GM DP card.
3. **Reconnecting banner** in the chat panel — amber bar (§4).

Rules:

- Never display contradictory signals (green pip + reconnecting banner is a
  bug; raise an issue).
- The realtime token endpoint is `POST /api/v1/realtime/token` (TTL ≤ 5 min);
  components never read Centrifugo state directly — they consume the channel
  client.
- Reduced motion: amber pulse on the pip falls back to a static amber dot
  with a tooltip "Reconnecting".

---

## See also

- [`README.md`](./README.md) — token pipeline, component inventory, theme/motion
  guarantees.
- [`HANDOFF_NAME_MAP.md`](./HANDOFF_NAME_MAP.md) — handoff term ⇄ project name
  map (rationale for every documented drift).
- [`../../docs/DESIGN.md`](../../docs/DESIGN.md) — top-level design system
  doctrine (the tone source for these patterns).

> **Forthcoming as part of T-2026-05-14-006.** `FOUNDATIONS.md` (motif density,
> hard rules), `CONTENT.md` (voice, taxonomy, number formatting), `A11Y.md`
> (keyboard map, focus-ring contract), and a design-layer `I18N.md` ship in
> subsequent blocks of the same backfill task. `SURFACES.md` and
> `COMPONENTS.md` will follow if the audit raises new gaps after that batch.
