# Active tasks

## T-2026-05-08-001 — implement AppButton Coriolis primitive

- Created: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.a
- Goal: Replace the boilerplate AppButton with a Coriolis-token-driven component (primary / ghost / danger variants, sm / md / lg sizes) that passes typecheck, Vitest, and Stylelint.
- Acceptance:
  - `pnpm --filter @app/ui typecheck` exits 0
  - `pnpm --filter @app/ui test` exits 0
  - `pnpm stylelint "packages/ui/**/*.{vue,scss,css}"` exits 0 for AppButton files
  - AppButton row appears in `specs/design/README.md` component inventory
- Spec diff: none
- Codegen impact: no
- Design impact: new @app/ui component (AppButton)
- Tests: Vitest unit + Storybook stories
- Sub-steps:
  - [x] Push task entry to active.md
  - [ ] Rewrite AppButton.vue with Coriolis tokens
  - [ ] Rewrite AppButton.stories.ts with variant/size matrix
  - [ ] Rewrite AppButton.spec.ts with full coverage
  - [ ] Update specs/design/README.md component inventory
  - [ ] Verify typecheck + test + stylelint green
- Status: in-progress
- Blockers: —
