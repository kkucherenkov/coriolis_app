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
