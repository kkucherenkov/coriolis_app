# Active tasks

## T-2026-05-08-010 — Add AppDivider primitive to @app/ui

- Created: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.o
- Goal: Ship a semantic separator primitive (horizontal + vertical) with brass tone variants so sheet panels and card sections can be divided without custom markup.
- Acceptance:
  - `AppDivider` renders `<hr>` for horizontal and `<div role="separator" aria-orientation="vertical">` for vertical
  - All three tone + three weight + inset combos apply the correct BEM class
  - Storybook shows all stories without errors
  - Vitest suite passes
  - Stylelint passes; no hex literals in SCSS
- Sub-steps:
  - [x] Push task entry
  - [x] Create AppDivider.vue
  - [x] Create AppDivider.stories.ts
  - [x] Create AppDivider.spec.ts
  - [x] Create index.ts barrel
  - [x] Export from packages/ui/src/index.ts
  - [x] Add row to specs/design/README.md
  - [x] Verify typecheck + test + stylelint pass
- Status: in-progress
- Blockers: —

## T-2026-05-08-009 — Add AppDots primitive to @app/ui

- Created: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md § T-2.1.1.n
- Goal: Ship a reusable rank-dots row component (0..N filled dots) used across character sheets, ship sheets, and stat blocks.
- Acceptance:
  - `<AppDots :value="3" :max="5" />` renders 5 dots, first 3 filled
  - `value > max` is clamped silently, no throw
  - Root element has `role="meter"` with correct `aria-value*` attrs
  - `label` prop sets `aria-label` on the meter
  - `size` prop (sm/md/lg) changes dot diameter via SCSS variables
  - `tone` prop (brass/mystic/crimson/darkness) changes filled-dot color via token
  - Storybook stories cover all tones, sizes, edge cases, and WallOfStats layout
  - Vitest spec covers all above acceptance criteria
- Sub-steps:
  - [x] Push task to active.md
  - [x] Create AppDots.vue
  - [x] Create AppDots.stories.ts
  - [x] Create AppDots.spec.ts
  - [x] Create index.ts barrel
  - [x] Add to packages/ui/src/index.ts
  - [x] Add to specs/design/README.md component inventory
  - [x] Run typecheck + test + stylelint
- Status: in-progress
- Blockers: —
