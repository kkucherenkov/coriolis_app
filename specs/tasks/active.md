# Active tasks

## T-2026-05-08-002 — implement AppCard Coriolis primitive

- Created: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.h
- Goal: Replace the boilerplate AppCard with a Coriolis-token-driven component (default / featured variants, optional header/footer slots, `as` polymorphic prop) that passes typecheck, Vitest, and Stylelint.
- Acceptance:
  - `pnpm --filter @app/ui typecheck` exits 0
  - `pnpm --filter @app/ui test` exits 0 for AppCard specs
  - `pnpm stylelint "packages/ui/src/components/AppCard/**/*.{vue,scss,css}"` exits 0
  - AppCard row appears in `specs/design/README.md` component inventory
- Spec diff: none
- Codegen impact: no
- Design impact: new @app/ui component (AppCard)
- Tests: Vitest unit + Storybook stories
- Sub-steps:
  - [x] Push task entry to active.md
  - [x] Rewrite AppCard.vue with Coriolis tokens (default + featured variants, header/footer slots, `as` prop)
  - [x] Write AppCard.stories.ts with Default / Featured / WithHeader / WithFooter / WithHeaderAndFooter / BodyWithLongText / Polymorphic stories
  - [x] Write AppCard.spec.ts with full coverage (slots, BEM, variants, `as` prop)
  - [x] Update specs/design/README.md component inventory
  - [ ] Verify typecheck + test + stylelint green
- Status: in-progress
- Blockers: —
