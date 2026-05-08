# Active tasks

## T-2026-05-08-015 — Add rules-engine module and wire derived stats into CharactersModule

- Created: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md Feature 3.2 Story 3.2.2, T-3.2.2.a..d
- Goal: Replace placeholder constants (hp.max=14, mp.max=10, encumbrance.max=5) with computed Coriolis rules-engine functions and add server-side guard against setting read-only derived fields.
- Sub-steps:
  - [x] Push task entry to active.md
  - [x] Create rules-engine module with pure functions and barrel
  - [x] Wire rules-engine into character.repo.ts read mapper
  - [x] Add ReadOnlyFieldError and server-side guard in update-character.handler.ts
  - [x] Write 39 unit specs (33 rules-engine + 6 ReadOnlyFieldError)
  - [x] Run typecheck + test (144 total, all green)
- Status: in-progress
- Blockers: —

## T-2026-05-08-018 — build AppSelect primitive (Epic 2 Feature 2.1)

- Created: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.1
- Sub-steps: complete (28 specs, 10+ stories)
- Status: in-progress
- Blockers: —

## T-2026-05-08-016 — implement AppLabel primitive

- Created: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2 Feature 2.1
- Sub-steps: complete (21 specs, 11 stories)
- Status: in-progress
- Blockers: —

## T-2026-05-08-017 — AppField primitive

- Created: 2026-05-08
- Owner: claude
- Spec: IMPLEMENTATION_PLAN.md Epic 2 Feature 2.1
- Sub-steps: complete (26 specs, 11 stories; Vue 3.5 useId; sm/md only)
- Status: in-progress
- Blockers: —
