# Active tasks

## T-2026-05-08-014 — Build AppProgress Coriolis primitive

- Created: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md T-2.1.1.f; docs/DESIGN.md §6.8, §10, §11.1
- Goal: Ship a fully-tokenised, accessible progress bar primitive for HP/MP visualisation and wizard step progress.
- Acceptance:
  - `AppProgress` renders a horizontal bar with correct fill percentage
  - `role="progressbar"` with `aria-valuenow`, `aria-valuemin`, `aria-valuemax` attributes present
  - Value clamped to `[min, max]` range without throwing
  - Five tones (brass, mystic, crimson, success, darkness) and three sizes (sm, md, lg) apply correct BEM modifiers
  - Optional label renders as accessible text
  - Width transition uses motion tokens
  - 12+ Storybook stories covering all variants
  - 14+ Vitest specs passing
  - Entry in `specs/design/README.md` and `packages/ui/src/index.ts`
- Sub-steps:
  - [x] Push task to active.md
  - [x] Create AppProgress.vue (linear variant only — circular deferred, see judgement note)
  - [x] Create AppProgress.stories.ts (13 stories)
  - [x] Create AppProgress.spec.ts (36 specs)
  - [x] Create index.ts barrel
  - [x] Add to packages/ui/src/index.ts
  - [x] Add row to specs/design/README.md
  - [x] Run typecheck + tests + stylelint
- Status: in-progress
- Blockers: —
- Notes: Circular variant deferred to v2. The SVG arc approach is sound but expands scope; the wizard-icon.jsx and sheet-desktop.jsx patterns only require the linear bar.

## T-2026-05-08-012 — AppSwitch Coriolis primitive

- Created: 2026-05-08
- Owner: claude
- Epic: 2.1.e
- Branch: `feat/phase-1/app-switch`
- Goal: Rebuild `packages/ui/src/components/AppSwitch/` to the Coriolis brass-on-night design: track `--surface-night` (off) / `--brand-brass` (on), thumb always `--brand-brass-light`, transitions via `--motion-duration-fast` `--motion-ease-standard`. Props: `modelValue`, `disabled`, `size` (sm|md), `label`, `name`. Default slot wins over `label` prop when both present. Root element is `<button role="switch">`.
- Sub-steps:
  - [x] Push task to `active.md`
  - [x] Write `AppSwitch.vue`
  - [x] Write `AppSwitch.stories.ts` (11 stories)
  - [x] Write `AppSwitch.spec.ts` (19 specs)
  - [x] Update `index.ts`
  - [x] Add row to `specs/design/README.md`
  - [x] `pnpm --filter @app/ui typecheck` green
  - [x] `pnpm --filter @app/ui test` green
  - [x] `pnpm stylelint` green
  - [x] Commits on branch (3 commits)
- Status: in-progress
- Blockers: —
