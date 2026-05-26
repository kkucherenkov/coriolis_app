---
target: character sheet (apps/web/app/pages/app/characters/[id].vue)
total_score: 29
p0_count: 1
p1_count: 2
timestamp: 2026-05-25T15-10-18Z
slug: apps-web-app-pages-app-characters-id-vue
---

## Design Health Score

| #         | Heuristic                       | Score     | Key Issue                                                                                                                                                            |
| --------- | ------------------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1         | Visibility of System Status     | 3         | `AppSavePulse` covers only the _name_ save; attribute/skill/HP/MP/condition mutations save and roll back silently.                                                   |
| 2         | Match System / Real World       | 4         | Coriolis vocabulary is fluent: Push, hits, mystic powers, governing-attribute badges, prayer-flavored outcome lines.                                                 |
| 3         | User Control and Freedom        | 3         | Character/talent deletes are guarded, but no undo for an HP drop and the injury `×` (1242) removes with no confirm.                                                  |
| 4         | Consistency and Standards       | 2         | Three different −/+ stepper implementations; "Talents" is both a panel and a dead tab; "Saved" used as a button label; raw `<dialog>` vs `AppModal` everywhere else. |
| 5         | Error Prevention                | 3         | Optimistic rollback + talent validation solid; injury removal unguarded; HP/MP decrement to 0 with no boundary check.                                                |
| 6         | Recognition Rather Than Recall  | 3         | Governing-attr badges + general/advanced legend are strong; skill numeric value is hidden behind the popover (dots-only in the row).                                 |
| 7         | Flexibility and Efficiency      | 2         | No keyboard shortcuts for roll / push / HP±; every edit is a 4-step popover dance; no type-a-number, no bulk actions.                                                |
| 8         | Aesthetic and Minimalist Design | 4         | Clean three-column hierarchy, restrained ornament, managed density, tasteful advanced-skill accent rail.                                                             |
| 9         | Error Recovery                  | 2         | Attribute/skill/HP failures snap back silently with no message; conditions/injuries DO surface a banner — inconsistent and a dead end on the silent paths.           |
| 10        | Help and Documentation          | 3         | In-context teaching ("requires training", ENC −1-die banner) but no first-run guidance, thin empty states, no HP/MP/ENC explanation.                                 |
| **Total** |                                 | **29/40** | **Good (lower-middle of band)**                                                                                                                                      |

## Anti-Patterns Verdict

**Does this look AI-generated? No.** This is design-system-disciplined work that a fluent user would trust, with three or four specific places that would make them pause.

**LLM assessment.** Token discipline is real: every color is a CSS var, fonts correctly assigned (Forum for titles + name, mono for stats, Inter for actionable text), brass-on-indigo holds, mystic teal reserved for mystic/Push, crimson for injury/encumbrance/delete. Optimistic-update-with-rollback on every mutation; skeleton loaders not spinners; `prefers-reduced-motion` honored. The slop-adjacent moments: (a) the "Save" stepper button labeled with the status string `t('statusSaved')` ("Saved"); (b) a popover+stepper mode to edit a 0–5 value the dots already render; (c) three "Coming in a future update" tabs, one of which (Talents) duplicates a live panel; (d) three visually-distinct −/+ steppers for the same "nudge a number" job.

**Deterministic scan.** Bundled detector unavailable in this skill install (`detect.mjs` ran a real attempt, exited 1: `detector/detect-antipatterns.mjs` module missing). Browser automation unavailable in session → no visual overlay. Manual ban-pattern grep run as substitute: **0 real ban violations**. Two false positives — `border-left/right: none` (2589-2590, a `<button>` reset, not a side-stripe) and a token-based `linear-gradient(surface-night → surface-void)` on the hero (1977, a background gradient, outside the gradient-_text_ ban). One corroboration: raw `<dialog :open>` at 1739, confirming the accessibility finding below.

**Visual overlays.** None available (no browser automation in session).

## Overall Impression

The bones are good and the dice surface is genuinely lovable. The score (29) is dragged down by three concentrated, fixable gaps: inconsistency (#4), edit-efficiency (#7), and silent error recovery (#9). The single biggest opportunity: surface save failures. Right now an attribute that fails to save snaps back under the player's eyes with zero explanation, which at a live table is indistinguishable from a bug.

## What's Working

1. **Domain-true dice surface (`SheetDiceRoller`).** Mirrors server-side `RulesEngine.canPush` client-side so the disabled state appears without a round-trip (67-73); the exhausted-blocks-push rule is _shown_ not just enforced (303-305); the outcome copy is flavored to the setting's mysticism (italic brass-shadow fail line vs mystic-teal success, 277-291). Color is never the sole signal. This is the product working _for_ the task at its highest-stakes moment.
2. **Rigorous optimistic-update-with-rollback across every mutation.** `commitAttr`, `commitSkill`, `adjustHp/Mp`, `toggleCondition`, `confirmAddInjury`, `removeInjury` all snapshot, apply optimistically, revert on failure. The sheet feels instant during play. (The gap is _surfacing_ failure, not the mechanism.)
3. **Disciplined, accessible component foundation.** `AppDots` uses `role="meter"` with `aria-valuenow/min/max`; `AppConditionPill` doubles meaning with icon + `aria-pressed`; `AppButton` exposes `aria-busy`/reduced-motion spinner fallback; `AppPopover`/`AppModal` implement focus trap + return-focus + Escape. Every interactive atom has the full state set.

## Priority Issues

### [P0] Silent save failure on attributes / skills / HP / MP

`commitAttr` (424-426), `commitSkill` (455-457), `adjustHp` (475-477), `adjustMp` (493-495) all `catch {}` and silently revert with no user-visible signal.

- **Why it matters:** at a live table the player's input vanishes with no explanation; indistinguishable from a bug; breaks trust at the moment the tool is relied on.
- **Fix:** reuse the error-banner pattern already present for conditions/injuries — surface a transient toast/banner ("Couldn't save Strength — reverted") on every rollback path, and/or feed these mutations through `useAutoSave` so the hero `AppSavePulse` reflects them. Infrastructure already exists; it's just not wired to these four paths.
- **Suggested command:** `/impeccable harden`

### [P1] Three dead tabs, one duplicating a live feature

Tab bar (1163-1184) shows Stats/Gear/Talents/Notes/Share; Talents/Notes/Share render "Coming in a future update" (1714-1728). Talents is _also_ a working panel inside Stats.

- **Why it matters:** 60% of primary navigation is a trap; the duplicate "Talents" label actively misleads.
- **Fix:** remove the three placeholders until they ship (Stats + Gear only), or render them disabled (`AppTab` supports `:disabled` + `tabindex="-1"` + `aria-disabled`) with a "soon" affordance. Do not keep a Talents tab competing with the Talents panel.
- **Suggested command:** `/impeccable distill`

### [P1] "Saved" used as the commit-button label in steppers

Lines 1359-1361, 1457-1463, 1554-1559: `<AppButton @click="commitAttr(...)">{{ t('statusSaved') }}</AppButton>` renders "Saved" on the button that _performs_ the save.

- **Why it matters:** a status word on an action control reads as "already done," causing hesitation on the most-repeated edit on the sheet.
- **Fix:** add a dedicated `t('apply')` / `t('done')` key ("Apply" / "Применить") and use it; never reuse a status string as an imperative label.
- **Suggested command:** `/impeccable clarify`

### [P2] Tab bar is `role="tablist"` but not a real tab widget

Container has `role="tablist"` (1163) and `AppTab` emits `role="tab"`/`aria-selected`/roving tabindex, but panels are plain `<div v-show>` with no `role="tabpanel"`, no `aria-labelledby`/`id`/`aria-controls`, and no arrow-key navigation between tabs.

- **Why it matters:** a screen-reader user hears "tab, selected" then lands in unlabeled content with no programmatic relationship; keyboard users can't arrow between tabs as the ARIA pattern promises.
- **Fix:** add `id` + `aria-controls` on tabs, `role="tabpanel"` + `aria-labelledby` + `tabindex="0"` on panels, and arrow-key handling — or drop `role="tablist"` and present an honest button group.
- **Suggested command:** `/impeccable harden`

### [P2] Destructive actions: raw `<dialog>` delete + unguarded injury remove

The delete confirm is a raw `<dialog :open="deleteDialogOpen">` (1739), not `showModal()` and not `AppModal` — so focus is NOT trapped, the page behind is not inert, and Escape is not handled, for the single most destructive action on the screen. Separately, the critical-injury `×` (1242-1248) calls `removeInjury` immediately with no confirm.

- **Why it matters:** the riskiest action has the weakest overlay and is inconsistent with the focus-trapping `AppModal` used everywhere else; accidental injury loss has no undo.
- **Fix:** route delete through `AppModal` (or `dialog.showModal()`); convert injury removal to a confirm or an undoable toast ("Injury removed — Undo").
- **Suggested command:** `/impeccable harden`

## Cognitive Load

8-item checklist: **1 failure → low load overall.** The one failure is **minimal choices ≤4**: the 5-tab bar exceeds 4 _and_ 3 of 5 options are non-functional traps. Density is otherwise managed well by the three-column split and the general/advanced legend. Decision point >4 options: the tab bar (5, with 60% dead).

## Emotional Journey

- **Peak:** the dice roll + Push outcome line — flavored, visible, color-doubled. The surface players will love.
- **Valley:** silent rollback (`commitAttr` catch, 424-426) — at a live table this reads as "the app is broken."
- **High-stakes reassurance is uneven:** character delete well-guarded, talent delete doubly-guarded, but HP→0 ("Broken" in Coriolis) has no acknowledgment and injury removal has no confirm.
- **Warmest guidance:** the Gear empty state ("Add your first item to get started").

## Persona Red Flags

**Alex (power user):** no keyboard shortcut to roll/push/adjust HP; every attribute/skill edit is a 4-step popover dance with no type-a-number; HP ±1 per click (4 damage = 4 clicks); no bulk equip/unequip.

**Sam (screen reader / keyboard-only):** raw `<dialog :open>` delete (1739) isn't modal — no focus trap, no inert background, no Escape; tab panels lack `role="tabpanel"`/`aria-labelledby`; save status sr-only text narrates _only_ name saves, so attribute/skill/HP edits produce no live-region announcement; skill value is dots-only with no numeral for low-vision sighted users.

**Riley (stress tester):** long names handled (ellipsis everywhere — good); empty states all present (good); but the live roller `__result-label` (375) has no overflow guard for an 80-char label in the narrow right column; rapid "Save" on injuries could spawn multiple optimistic temp entries before the first response lands; ENC is display-only with no weight breakdown.

## Minor Observations

- `useAutoSave` `onBeforeUnmount` calls `cancel()` (382), which _discards_ a pending name edit — rename-then-navigate-away loses the rename. Consider `flush()`.
- Hero uses a token-based `linear-gradient(surface-night → surface-void)` (1977); doctrine is flat-on-dark, but this is a restrained, token-only depth cue (not a banned text gradient). Defensible; worth a conscious decision.
- "Recent Rolls" panel nests a second "History" `<h4>` — slightly redundant labeling.
- The advanced-skills "requires training" note (1477-1479) is rendered at `9px` / 0.7 opacity — borderline legible for an important rule.
- Roll history caps at 50 with no "load more"; a heavy session loses older rolls silently.
- Verify the nested 2-col skills grid doesn't get cramped at ~768-1024px when the center column already narrows.

## Questions to Consider

1. Why a popover-with-stepper to edit a 0–5 value at all? The dots are already rendered — what if clicking the 3rd dot _sets_ the value to 3 directly, collapsing the slowest, most-repeated interaction into one click and killing the "Saved"-as-label problem outright?
2. At a live table, is silent optimistic save the right default, or is the real need a single persistent, glanceable "All changes saved · 2s ago" anchor with a clear error state?
3. Should the dramatic transitions (HP→0 "Broken", gaining a critical injury) get the same ceremony the dice Push got? The Push line is the peak precisely because it's flavored and visible; going Broken is a bigger moment with none.
4. Do the three "coming soon" tabs earn a place in primary nav, or is a roadmap leaking into the UI?
