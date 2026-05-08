# Active tasks

## T-2026-05-08-013 — Implement AppChip Coriolis primitive

- Created: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md §Epic 2.1.c
- Goal: Ship the interactive toggleable chip primitive for Coriolis condition tracking and ship-status pills.
- Acceptance:
  - AppChip renders as `<button type="button">` with `aria-pressed` reflecting modelValue
  - Clicking toggles and emits `update:modelValue` with the negated value
  - Removable variant renders a trailing × button; clicking it emits `remove` without toggling
  - Disabled chip neither toggles nor fires events
  - All five Coriolis variants (brass/mystic/crimson/success/darkness) have correct inactive (outline) and active (filled) visual states using design tokens only
  - Typecheck, unit tests (28), and Stylelint all pass
- Sub-steps:
  - [x] Push task entry
  - [x] Write AppChip.vue
  - [x] Write AppChip.stories.ts
  - [x] Write AppChip.spec.ts
  - [x] Write index.ts barrel
  - [x] Update specs/design/README.md inventory
  - [x] typecheck + test + stylelint green
  - [x] commit (3 commits)
- Status: in-progress
- Blockers: —

## T-2026-05-08-014 — Build AppProgress Coriolis primitive

- Created: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.f; docs/DESIGN.md §6.8, §10, §11.1
- Goal: Ship a fully-tokenised, accessible progress bar primitive for HP/MP visualisation and wizard step progress.
- Sub-steps: complete (linear variant only; circular deferred — see notes)
- Status: in-progress
- Blockers: —
- Notes: Circular variant deferred to v2; wizard-icon.jsx and sheet-desktop.jsx only need the linear bar.

## T-2026-05-08-012 — AppSwitch Coriolis primitive

- Created: 2026-05-08
- Owner: claude
- Epic: 2.1.e
- Goal: Rebuild AppSwitch to the Coriolis brass-on-night design with `<button role="switch">` root, `aria-checked`, sm/md sizes, slot+label fallback.
- Sub-steps: complete
- Status: in-progress
- Blockers: —
