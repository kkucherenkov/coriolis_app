---
target: character sheet (apps/web/app/pages/app/characters/[id].vue)
total_score: 34
p0_count: 0
p1_count: 2
timestamp: 2026-05-26T09-01-10Z
slug: apps-web-app-pages-app-characters-id-vue
---
## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 4 | Identity has `AppSavePulse`+`aria-live`; optimistic everywhere. But stat/skill/HP/MP edits have no per-control in-flight indicator (silent unless they fail). |
| 2 | Match System / Real World | 4 | Coriolis vocabulary exact; governing-attr badges match the rulebook; prayer-flavored Push outcome. |
| 3 | User Control and Freedom | 3 | Destructive ops gated by AppConfirm, but stat edits have no undo and the only mouse down-path (click top dot) is undiscoverable. |
| 4 | Consistency and Standards | 3 | Three stepper idioms coexist: HP/MP ± buttons, dice pool ± buttons, attributes/skills click-dots. Same action, three controls. |
| 5 | Error Prevention | 3 | Confirms on delete, double-submit guard on add-injury, client-mirrors server canPush. But click-top-dot-to-decrement is an error-prone gesture (one stray click silently drops a stat). |
| 6 | Recognition Rather Than Recall | 3 | Legend + governing-attr aid recognition, but the dot control relies on recalling that dots are clickable and that clicking the active dot decrements. |
| 7 | Flexibility and Efficiency | 4 | Slider Arrow/Home/End, arrow-key tab nav, Enter/Esc in dialogs. Power users well served once they know the controls exist. |
| 8 | Aesthetic and Minimalist Design | 4 | Beautiful, restrained, on-brand; flat-on-dark; three-column hierarchy reads at a glance. |
| 9 | Error Recovery | 4 | `statError` banner with reverted-value copy + per-section banners + Problem.detail. Standout. |
| 10 | Help and Documentation | 2 | No hint dots are editable, no tooltip on the down-step gesture, no first-run teaching of the edit model. |
| **Total** | | **34/40** | **Good (upper band)** |

## Anti-Patterns Verdict

**Does this look AI-generated? No.** Craftsman's surface — real ARIA tabs, focus-trapping confirms, optimistic-with-rollback, skeleton loading, defensive `minmax(0,…)` grids, reduced-motion honored. The one thing that makes a fluent user pause: the editable attribute/skill dots look identical to the read-only `AppDots` meter and give no affordance that they're interactive.

**LLM assessment.** The hardening pass (PR #64) and the click-the-dot model (PR #65) both landed cleanly on the engineering side. The new `AppDotInput` is the *correct* a11y pattern (composite `role="slider"`, inner dots `aria-hidden`). But removing the popover removed the discoverability the popover provided, and the decrement gesture is hidden + a silent footgun — the exact "click-idiom feel / discoverability" risk flagged in the shape brief landed as a real gap.

**Deterministic scan.** Bundled detector unavailable in this skill install (`detect.mjs` ran, exited 1 — module missing). Browser automation unavailable → no overlay. Manual ban-pattern grep on `[id].vue` + `AppDotInput.vue`: **0 real ban violations.** Only match is the token-based hero `linear-gradient(surface-night → surface-void)` (1904) — a background gradient, outside the gradient-*text* ban; carried over, unchanged.

**Visual overlays.** None (no browser automation in session).

## Overall Impression
34/40, up from 29. The hardening earned heuristics 1 and 9 their high marks; the new dot model is what holds 3, 5, 6, and 10 down. Biggest opportunity: make the dots *advertise* they're editable and give the decrement an explicit affordance. Fix discoverability + unify the stepper vocabulary and this reaches the Excellent band.

## What's Working
1. **Error-recovery is best-in-class for the register.** Every mutation (attrs/skills/HP/MP/conditions/injuries/talents) does optimistic update → rollback-to-server-truth → scoped `role="alert"` banner with reverted-value copy (`[id].vue:461-467, 490-494`).
2. **The ARIA tabs widget is textbook.** Roving tabindex (`AppTab.vue:51`), `role="tablist"`/`tabpanel`/`aria-controls`/`aria-labelledby`, arrow-key nav skipping disabled tabs (`[id].vue:196`), visible "soon" on roadmap tabs.
3. **Defensive layout under stress.** `minmax(0,1fr)` everywhere, ellipsis on every overflow-prone cell, documented `fr` grid. Long names + narrow viewports handled before they happen.

## Priority Issues

### [P1] Editable dots have no affordance — the signature task is undiscoverable
`AppDotInput` dots render visually identical to the read-only `AppDots` meter (same diameters/tones/fill); the skill rows lost their `<button>` wrapper so even the old row-hover cue is gone. Cursor is `pointer` but invisible at rest.
- **Why it matters:** editing a stat is the signature task of a character sheet; the control hides its own interactivity (heuristic 6; "tool disappears into the task" taken too far).
- **Fix:** give `AppDotInput` a rest-state interactive affordance distinct from `AppDots` — empty-dot ring outlines, a whole-control hover lift, and a one-time inline hint near the Attributes header ("Tap dots to set").
- **Cite:** `AppDotInput.vue:117-132`, `[id].vue:1458-1466`.
- **Suggested command:** `/impeccable bolder` or `/impeccable affordance via polish`

### [P1] "Click the top dot to decrement" is undiscoverable AND a silent footgun
The only mouse down-path is clicking the highest filled dot (`AppDotInput.vue:58-61`): invisible knowledge, and a stray click on that dot silently drops the value by one with no confirmation, distinct feedback, or undo.
- **Why it matters:** silent, unrecoverable mutation of persistent game state during live play (heuristics 3 and 5). Star-rating idiom borrowed into a higher-stakes context.
- **Fix:** add an explicit decrement affordance on hover/focus (a small `−` mirroring the HP stepper the user already knows), or telegraph the gesture with a tooltip on the top filled dot. Most consistent: give the dot control an optional ± pair (also resolves the idiom split below).
- **Cite:** `AppDotInput.vue:55-61`.
- **Suggested command:** `/impeccable harden`

### [P2] Three inconsistent stepper idioms for the same action
Incrementing a bounded number happens three ways: HP/MP ± buttons (`[id].vue:1169-1212`), dice pool ± buttons (`SheetDiceRoller.vue:221-243`), attributes/skills click-dots. One mental model, three controls.
- **Why it matters:** heuristic 4; inconsistent component vocabulary is an explicit product-register failure; motor habits break across panels of the same screen.
- **Fix:** pick one. Either give the dot control a ± pair and use it for HP/MP too, or standardize on ± and keep dots display-only. Don't ship both idioms side by side on the signature screen.
- **Cite:** `[id].vue:1169-1212`, `SheetDiceRoller.vue:221-243`.
- **Suggested command:** `/impeccable distill`

### [P2] No per-control save feedback on stat/skill edits
Identity (name) gets `AppSavePulse`+`aria-live`; the more frequent attribute/skill/HP/MP edits have no in-flight indicator. The 350ms debounce + round-trip is silent unless it fails. Dot edits bypass `useAutoSave` with a bare `useDebounceFn` (`[id].vue:446-448, 477-479`).
- **Why it matters:** heuristic 1; a player sets a stat, sees nothing confirm it persisted (the dot already filled optimistically).
- **Fix:** surface a subtle brass save pulse near the Attributes/Skills panel headers, or route stat edits through the existing `useAutoSave` save-state.
- **Cite:** `[id].vue:446-500`.
- **Suggested command:** `/impeccable harden`

### [P3] Identity concept rendered two different ways (likely a real bug)
Hero label runs `conceptValue` through `t(\`concept.${conceptValue}\`)` (`[id].vue:1135`) — expecting an enum key. The Identity card renders raw `character.concept || '—'` (`[id].vue:1305`) — unlocalized. One of these is wrong: if concept is an enum, the card shows the raw key; if free text, the hero `t()` returns a missing-key string (violates the t() mandate). Pre-existing; predates this work.
- **Fix:** resolve concept once into a localized computed and use it in both places.
- **Suggested command:** `/impeccable clarify`

## Cognitive Load
8-item checklist: **3 soft flags.** (1) Stats tab is multi-panel, not single-focus (defensible for a reference sheet). (2) Skills card exposes **16 editable sliders at once** — the densest interaction zone, with no progressive disclosure. (3) Working memory: the decrement gesture must be remembered, nothing on-screen reminds. Decision point >4: the 16-slider skills card and the 5-tab bar (3 disabled → 2 live).

## Emotional Journey
- **Peak:** the dice roller + prayer-flavored Push outcome (`SheetDiceRoller.vue:165`).
- **Reassurance:** excellent — delete + injury removal via focus-trapping AppConfirm with named consequences; `statError` means a failed save never silently lies.
- **Valley 1:** first stat edit — a new user can't tell how to change a number; dots look decorative.
- **Valley 2:** accidental decrement — clicking the top dot silently subtracts one mid-session with no undo.

## Persona Red Flags
- **Alex (power/keyboard):** slider Arrow/Home/End works, but 4 attribute + 16 skill sliders = 20 sequential tab stops in the Stats panel with no way to jump between panels (arrows move within a slider). Mouse vs keyboard learn different down-step mental models.
- **Sam (SR/keyboard/contrast):** the `role="slider"` + aria-hidden dots pattern is correct and sound. Gaps: `aria-valuetext` is "Force: 3" without the "of 5" ceiling that `AppStatBlock`/`AppDots` announce; no `aria-roledescription`/`aria-describedby` to teach the control exists/operates; unfilled dots are transparent with a `--brand-brass-shadow` 1px border on indigo — check WCAG 1.4.11 non-text contrast (3:1).
- **Riley (stress):** ellipsis defenses hold; teaching empty states present. The whole-array PATCH for list mutations (injuries) is fragile under rapid cross-open races. On touch (coarse pointer, good 32px targets) Riley can only intuitively *increase* a stat — lowering requires the hidden gesture.

## Minor Observations
- `onTabKeydown` `End` case has a redundant nested block + stray `// No default` comment (`[id].vue:213-219`) — eslint-autofix artifact, harmless.
- `AppStatBlock` editable passes `:label="ariaLabel ?? label"` to the slider, losing the "of 5" SR context that read-only mode has.
- `statError` is one shared ref across attrs/skills/HP/MP; two near-simultaneous failures overwrite each other.
- Encumbrance surfaces in three places at once (hero crimson counter + full banner + Gear badge) — possibly over-shouting a non-error state.
- Hover preview is fine-pointer only and is the *only* discoverability cue — which doesn't exist on touch.

## Questions to Consider
1. If HP/MP/pool all use ± steppers, what did removing the popover stepper actually buy, given it cost discoverability and added a third idiom on the same screen?
2. Will "click the topmost filled dot to decrement" ever be discovered by a user who didn't read a changelog? If not, the mouse down-path is effectively missing.
3. Should a sheet read 95% / edited 5% show all 16 skills always-live-editable, or default to view-mode with an explicit edit affordance?
