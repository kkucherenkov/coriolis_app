# Active tasks

## T-2026-05-08-019 — AppTextarea primitive

**Branch:** `feat/phase-1/app-textarea`
**Epic/Feature:** Epic 2, Feature 2.1 (Vue foundation primitives)
**Status:** in-progress

### Checklist

- [x] Push task entry to `active.md`
- [x] `AppTextarea.vue` — multi-line counterpart to AppInput; exact token/BEM/prop parity
- [x] `AppTextarea.stories.ts` — 12+ stories covering variant × size matrix + states + autosize TODO
- [x] `AppTextarea.spec.ts` — 14+ vitest specs mirroring AppInput coverage
- [x] `index.ts` — barrel export
- [x] `specs/design/README.md` — add `AppTextarea` row (alphabetical order)
- [ ] typecheck, test, stylelint green
- [ ] Move to `done.md` on merge

### Notes

`autosize` prop is accepted and sets `--autosize` BEM modifier. The actual
grow-to-content behaviour is **deferred** (TODO comment in component). Plain
`rows` baseline is the must-have for v1. A JS recompute polyfill + CSS
`field-sizing: content` can be layered in a follow-up task.
