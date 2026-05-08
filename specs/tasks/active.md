# Active tasks

## T-2026-05-08-006 — Add /api/v1/characters CRUD + nested items/talents to OpenAPI spec

- Created: 2026-05-08
- Owner: claude
- Spec: [docs/IMPLEMENTATION_PLAN.md Feature 3.1, T-3.1.1.a..d](../docs/IMPLEMENTATION_PLAN.md)
- Goal: Define the full character API surface in OpenAPI so backend and generated clients have an unambiguous contract to implement against.
- Acceptance:
  - `pnpm spec:validate` passes with zero errors
  - `GET /api/v1/characters`, `POST /api/v1/characters`, `GET/PATCH/DELETE /api/v1/characters/{id}`, `POST /characters/{id}/duplicate`, `GET /characters/{id}/export` are all present
  - `POST /characters/{id}/items`, `PATCH /items/{id}`, `DELETE /items/{id}` are present
  - `POST /characters/{id}/talents`, `PATCH /talents/{id}`, `DELETE /talents/{id}` are present
  - Every 4xx returns `application/problem+json` with the `Problem` schema
  - `info.version` is `0.3.0`
- Sub-steps:
  - [x] Push task to active.md
  - [x] Create branch feat/phase-1/characters-spec
  - [x] Add enum schemas (IconId, ItemRange, ItemSlotType, RelationshipKind, CriticalInjurySeverity)
  - [x] Add object schemas (Attributes, Skills, ConditionFlags, CriticalInjury, Talent, Relationship, ItemBase + 6 variants, Item discriminated, CharacterList, Character, CharacterCreate, CharacterUpdate)
  - [x] Add tag `characters`
  - [x] Add 13 paths
  - [x] Bump info.version to 0.3.0
  - [x] Run pnpm spec:validate — green
- Status: in-progress
- Blockers: —

## T-2026-05-08-005 — build AppBadge Coriolis primitive

- Created: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md §Feature 2.1 T-2.1.1.b
- Goal: Replace the boilerplate AppBadge (wrapping Nuxt UI UBadge) with a native Coriolis-token badge chip covering 5 state-color variants and 2 sizes, with story + spec.
- Acceptance:
  - `pnpm --filter @app/ui typecheck` passes
  - `pnpm --filter @app/ui test` passes for AppBadge.spec.ts
  - `pnpm stylelint "packages/ui/src/components/AppBadge/**/*.{vue,scss,css}"` passes (no hex literals, no !important)
  - AppBadge is listed in specs/design/README.md inventory
  - AppBadge.stories.ts covers variant × size matrix (10 stories) + WithIcon + LongLabel + InlineWithText
- Sub-steps:
  - [x] Replace AppBadge.vue — native <span>, SCSS BEM, 5 variants × 2 sizes, token-only
  - [x] Replace AppBadge.stories.ts — 10 variant/size stories + WithIcon + LongLabel + InlineWithText
  - [x] Replace AppBadge.spec.ts — vitest BEM, root tag, slot, defaults
  - [x] Update index.ts barrel
  - [x] Add AppBadge row to specs/design/README.md
  - [x] Push task entry to active.md
- Status: in-progress
- Blockers: —

## T-2026-05-08-004 — Replace AppInput with Coriolis-token implementation

- Created: 2026-05-08
- Owner: claude
- Spec: docs/IMPLEMENTATION_PLAN.md Epic 2.1.d; docs/DESIGN.md §11.1
- Goal: Deliver a fully-styled AppInput primitive that uses Coriolis design tokens, matching the cor-input / cor-input--invalid contract from primitives.jsx, with the full test and Storybook surface required by CI.
- Acceptance:
  - AppInput renders with surface-night background, brass-shadow border, brass-light text
  - Invalid state shows crimson border and focus ring
  - Size variants sm/md/lg scale padding and font via space/type tokens
  - disabled blocks pointer events and applies opacity-disabled
  - readonly sets aria-readonly without opacity
  - Storybook shows 12+ stories covering variant × size matrix, states, and types
  - 15+ vitest specs pass
- Sub-steps:
  - [x] Push task entry to active.md
  - [x] Write AppInput.vue with Coriolis tokens
  - [x] Write AppInput.stories.ts (12+ stories)
  - [x] Write AppInput.spec.ts (15+ specs)
  - [x] Update specs/design/README.md inventory
  - [x] Verify typecheck + test + stylelint
- Status: in-progress
- Blockers: —
