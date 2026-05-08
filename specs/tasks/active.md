# Active tasks

## T-2026-05-08-012 · AppSwitch Coriolis primitive

**Epic:** 2.1.e  
**Branch:** `feat/phase-1/app-switch`  
**Started:** 2026-05-08  
**Status:** in-progress

### Scope

Rebuild `packages/ui/src/components/AppSwitch/` to the Coriolis brass-on-night
design: track `--surface-night` (off) / `--brand-brass` (on), thumb always
`--brand-brass-light`, transitions via `--motion-duration-fast`
`--motion-ease-standard`. Props: `modelValue`, `disabled`, `size` (sm|md),
`label`, `name`. Default slot wins over `label` prop when both present.
Root element is `<button role="switch">`.

### Checklist

- [x] Push task to `active.md`
- [ ] Write `AppSwitch.vue`
- [ ] Write `AppSwitch.stories.ts` (10+ stories)
- [ ] Write `AppSwitch.spec.ts` (12+ specs)
- [ ] Update `index.ts`
- [ ] Add row to `specs/design/README.md`
- [ ] `pnpm --filter @app/ui typecheck` green
- [ ] `pnpm --filter @app/ui test` green
- [ ] `pnpm stylelint "packages/ui/src/components/AppSwitch/**/*.{vue,scss,css}"` green
- [ ] Commits on branch (3 commits)
