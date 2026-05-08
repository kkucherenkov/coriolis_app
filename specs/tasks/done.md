# Done tasks

_Archive of shipped tasks. Never delete entries — cancelled tasks go here with reason._

## T-2026-05-08-002 — implement AppCard Coriolis primitive

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.h
- Result: PR #6 — merged at `b50b80f` (`docs(design): list AppCard in @app/ui component inventory`); preceded by `5beaabe` (specs + stories) and `c6dfee2` (component rewrite).
- Goal: Replace the boilerplate AppCard with a Coriolis-token-driven component (default / featured variants, optional header/footer slots, `as` polymorphic prop) that passes typecheck, Vitest, and Stylelint.
- Acceptance — all met:
  - [x] `pnpm --filter @app/ui typecheck` (vue-tsc) exits 0
  - [x] `pnpm --filter @app/ui test` (vitest, 185 tests) exits 0
  - [x] `pnpm stylelint "packages/ui/src/components/AppCard/**/*.{vue,scss,css}"` exits 0
  - [x] AppCard row appears in `specs/design/README.md` component inventory
- Sub-steps:
  - [x] Push task entry to active.md
  - [x] Rewrite AppCard.vue with Coriolis tokens (default + featured variants, header/footer slots, `as` prop)
  - [x] Write AppCard.stories.ts with 8 stories (Default, Featured, WithHeader, WithFooter, WithHeaderAndFooter, BodyWithLongText, Polymorphic, AllVariants)
  - [x] Write AppCard.spec.ts with full coverage (13 specs)
  - [x] Update specs/design/README.md component inventory
  - [x] Verify typecheck + test + stylelint green

## T-2026-05-08-001 — implement AppButton Coriolis primitive

- Created: 2026-05-08
- Completed: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.a
- Result: PR #3 — merged at `2708ce2` (`docs(design): list AppButton in @app/ui component inventory`); preceded by `1466dba` (specs + stories) and `127a157` (component rewrite).
- Goal: Replace the boilerplate AppButton with a Coriolis-token-driven component (primary / ghost / danger variants, sm / md / lg sizes) that passes typecheck, Vitest, and Stylelint.
- Acceptance — all met:
  - [x] `pnpm --filter @app/ui typecheck` (vue-tsc) exits 0
  - [x] `pnpm --filter @app/ui test` (vitest, 186 tests) exits 0
  - [x] `pnpm stylelint "packages/ui/**/*.{vue,scss,css}"` exits 0 for AppButton files
  - [x] AppButton row appears in `specs/design/README.md` component inventory
- Sub-steps:
  - [x] Push task entry to active.md
  - [x] Rewrite AppButton.vue with Coriolis tokens
  - [x] Rewrite AppButton.stories.ts with variant/size matrix (14 stories)
  - [x] Rewrite AppButton.spec.ts with full coverage (18 specs)
  - [x] Update specs/design/README.md component inventory
  - [x] Verify typecheck + test + stylelint green
