# Content & voice

How the app talks. This file is for copywriters and designers — engineering
doesn't need it day-to-day, but every reviewer should know it exists. The
canonical Russian rulebook glossary that backs ru-locale copy lives in
[`.claude/docs/i18n.md` § Glossary](../../.claude/docs/i18n.md#glossary--non-negotiable-canon-translations);
this doc is the voice layer, not the lexicon.

---

## 1. Voice in two sentences

We are a **steward, not a host.** The app is the brass instrument on the
navigator's table — it never narrates the adventure, never improvises lore,
never pretends to be a co-author. The GM and players do that. We just hold
their numbers, route their words, and try to sound like we belong in their
setting.

When we _do_ speak — empty states, system messages, error pages — we sound
like the ship's announcer at the end of a long shift. Quiet. Aware. Slightly
formal. Never cheery, never sarcastic, never glib.

---

## 2. Concrete rules

### Do

- **"The Third Horizon waits."** — short sentences with deliberate weight.
- **"Push if you must."** — gentle imperatives, mechanical-sounding.
- **"The dice listen. The Icons whisper."** — paired clauses, almost
  prayer-like.
- **"Connection lost. Messages will send when we reconnect."** — factual
  recovery copy that owns the failure without panicking.

### Don't

- ❌ "Whoops! Something went wrong!" — too friendly, breaks immersion.
- ❌ "🎲 You rolled..." — no emoji in chrome copy.
- ❌ "Let's get you set up!" — onboarding-coach voice; we are not that app.
- ❌ "Welcome aboard, space cowboy!" — pastiche, not setting.
- ❌ "Pro tip:" / "Did you know?" — never. We do not volunteer trivia.

### Edge cases

- **Confirmations.** State the consequence, not the action.
  Not "Are you sure you want to revoke?" → "Revoking invalidates the old
  link immediately."
- **Empty states.** A one-line elegy + a path forward. Not a friendly nudge.
  - "No messages yet. Say hello in {sessionName}."
  - "You haven't joined any sessions yet. Ask your GM for an invite link."
- **Errors.** Explain what failed in player terms, not HTTP terms. "This
  invite is no longer valid" is exposed; the RFC 9457 `title` / `detail`
  sits below as a monospaced subtitle for the technically inclined.

---

## 3. Sentence shapes

We favour:

- **Short declarative** — "The link rotated."
- **Paired clauses** — "The dice listen. The Icons whisper."
- **Imperatives that warn, not command** — "Push if you must."

We avoid:

- Run-on explanations.
- Bracketed asides.
- Lists in body copy (use a real list instead).
- Exclamation marks of any kind.

---

## 4. The lore tier

A small set of evocative aphorisms appear in low-frequency, low-stakes
places:

| Surface              | Aphorism                                                                                      |
| -------------------- | --------------------------------------------------------------------------------------------- |
| Bridge footer        | "The dice listen. The Icons whisper. Push if you must."                                       |
| Token reference foot | "Stylelint forbids hex literals in `apps/web` and `packages/ui`. Renaming a token is an ADR." |
| Wizard step 1 blurb  | "Where in the Horizon do you come from?"                                                      |
| Wizard step 5 blurb  | "The Icons watch from beyond the dark water."                                                 |
| Invite reveal warn   | "This is the only time we'll show this link."                                                 |

These are not decorative — they're the system's small contribution to the
table's atmosphere. Don't add new ones casually; new aphorisms require a
design review on the same footing as a new token.

---

## 5. Naming the things

### In-product (user-visible)

- **Bridge** — the dashboard.
- **Library** — character & ship lists (production; nav-label only — never
  inside chat or descriptive copy).
- **Settings** — account settings.
- **Session** — a live game in progress.
- **Encounter** — a combat / scene within a session.
- **Push** — re-roll for a Darkness Point. Russian canon: **«вознесение
  молитв»** — see [`.claude/docs/i18n.md`](../../.claude/docs/i18n.md#glossary--non-negotiable-canon-translations).
- **Icon** (capitalized) — one of the Nine. Never lowercase. Russian: **Лик**.
- **Mystic** — adjective. Never "magic". Russian: **мистический**.

### In code

- `apps/web/app/components/sheet/*.vue` — character & ship sheet surfaces.
- `apps/web/app/components/CombatTracker.vue` — initiative tool.
- `apps/web/app/components/sheet/SheetDiceRoller.vue` — the dice.
- `apps/web/app/components/EncounterPanel.vue` — encounter list / picker.
- `apps/mobile/lib/features/<area>/` — feature-first Flutter layering.
- `@app/ui` component names get the **`App` prefix** (Vue) and **`Cor`
  prefix** (Flutter, in the rare bridged atoms). The Storybook story uses
  the bare base name.

---

## 6. Truncation & ellipsis

- Use the Unicode ellipsis **`…`** (U+2026), never three dots.
- Truncate display names: 220 px in chat tabs, 240 px in member lists,
  320 px in session cards.
- Truncate session names **never** — they are hero text, accept the wrap.
- Truncate item names with a `title` tooltip (web) / `Tooltip` widget
  (mobile) so the full string remains discoverable.

---

## 7. Number formatting (display)

Mono font (`--type-mono-stat-*`) for every number; tabular numerals so
columns align without effort. Slash and successes-star are Unicode literals,
not glyph-only fonts — they must render in plain Inter as a fallback.

| Thing           | Format                                                 | Example         |
| --------------- | ------------------------------------------------------ | --------------- |
| HP / MP         | `<current> / <max>` with **`/`** U+002F slash          | `11 / 12`       |
| Init order      | bare integer                                           | `12`            |
| Skill rank      | bare integer + `AppDots`                               | `5 ● ● ● ● ●`   |
| Encumbrance     | one decimal                                            | `2.0 / 8.0`     |
| Birr (currency) | integer + `b` suffix (no space-before? — _space_)      | `600 b`         |
| Dice count      | integer + space + plural noun                          | `8 dice`        |
| Successes       | `<n> ✶ successes` with **`✶`** U+2736 six-pointed star | `2 ✶ successes` |

Russian:

- Successes still use `✶` U+2736; word is `успех / успеха / успехов` via
  CLDR `one/few/many`.
- Birr renders as `600 b` regardless of locale — the letter is the currency
  symbol, not an abbreviation.

---

## 8. Time

- Timestamps inside chat: `HH:mm` 24-hour. Never AM/PM, never localized
  12-hour.
- Session "last activity": relative format ("2h ago", "yesterday") via
  `Intl.RelativeTimeFormat`.
- Long-form dates only in invite-management metadata, e.g. "Active since
  2 days ago".
- **Never** "Just now" — it lies the moment the user looks away. Use the
  absolute or relative timestamp.

---

## 9. Dice flavour copy

When a `roll_pushed` system message renders in chat, the wording follows the
template:

```
{author} pushed {label} and gained {n} {success_word} (+{dp} DP)
```

Where `success_word` resolves through the locale's plural rules (English
`success / successes`; Russian `успех / успеха / успехов`). If a push
**fails** — no new successes — the system message reads:

```
{author} pushed {label} — no new successes. The Icons did not listen.
```

The "did not listen" closing is the only place we let the app voice register
emotion. It works because it is rare. Audit-flag any expansion of this
pattern beyond the two canonical templates above.

---

## 10. Where copy is reviewed

User-visible strings live in three places. The reviewer's job is to keep
all three honest to the rules above:

| Platform | Location                                                                  | Mechanism                                     |
| -------- | ------------------------------------------------------------------------- | --------------------------------------------- |
| Web      | Colocated SFC `<i18n lang="json">` block, plus the `@nuxtjs/i18n` runtime | `useI18n({ useScope: 'local' })` → `t('key')` |
| Mobile   | `apps/mobile/lib/i18n/<namespace>_<locale>.i18n.json` (slang)             | `context.t.<namespace>.<key>`                 |
| Backend  | `apps/backend/src/i18n/<locale>/<namespace>.json` (nestjs-i18n)           | `this.i18n.t('<ns>.<key>', { lang })`         |

Rules:

- `@app/ui` components **never** call `useI18n()` — translated strings come
  in via props. The component library is locale-agnostic.
- `en` is the default. Every `en` key must exist in `ru` (and `uk` / `el`
  where added). Missing translation is a bug, not a fallback.
- RFC 9457 error bodies stay English-canonical in `title` and `detail`;
  `nestjs-i18n` is for strings the client passes through verbatim.

---

## See also

- [`PATTERNS.md`](./PATTERNS.md) — interaction grammar (empty states,
  banners, modals, view-only triad) that this voice fills.
- [`.claude/docs/i18n.md`](../../.claude/docs/i18n.md) — canonical Russian
  glossary and platform i18n contracts.
- [`HANDOFF_NAME_MAP.md`](./HANDOFF_NAME_MAP.md) — handoff-term ⇄
  project-name rationale.

> **Forthcoming as part of T-2026-05-14-006.** `FOUNDATIONS.md`, `A11Y.md`,
> design-layer `I18N.md` ship in subsequent blocks.
