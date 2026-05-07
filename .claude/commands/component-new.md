---
description: Scaffold a new @app/ui component (Vue + Flutter) per the design loop
argument-hint: <ComponentName> — e.g. AppDpCounter
---

Scaffold the component `$ARGUMENTS` following the design loop in `AGENTS.md` §5. Both the Vue and Flutter sides must land in the same PR.

## Vue side — `packages/ui/src/components/$ARGUMENTS/`

Create exactly these four files. CI's `@app/ui audit` rejects misses.

1. `$ARGUMENTS.vue` — the component. SCSS uses BEM and design tokens only. No hex literals, no `!important`, no inline style literals. If this is a behavior wrapper over Nuxt UI, the boilerplate naming is `AppXxx` outside, `UXxx` inside (DESIGN §11.4).
2. `$ARGUMENTS.stories.ts` — Storybook story covering every variant in light **and** dark. Add a reduced-motion variant if the component animates.
3. `$ARGUMENTS.spec.ts` — Vitest spec covering rendering, a11y smoke (via `@storybook/addon-a11y`'s axe runner or equivalent), every variant, and reduced-motion behavior where relevant.
4. `index.ts` — re-export the component as the default and named export.

Append the component to `packages/ui/src/index.ts` so consumers can import it.

## Flutter side — `packages/ui_flutter/lib/src/widgets/`

Mirror the widget. Tokens come from `tokens.g.dart`. Tap targets ≥ 44×44px. Add a widget test under `packages/ui_flutter/test/widgets/`.

## Inventory

Update `specs/design/README.md` — add the component under the right §11 bucket (foundation primitive, Coriolis-specific primitive, composition, or behavior-wrapping). `pnpm design:audit` checks the inventory matches the actual folder.

## Mockup

If the component appears in any screen mockup, ensure the matching `.jsx` in `specs/design/mockups/` references it with the same prop shape. Per DESIGN §12, the JSX wins over the `.md` on conflict — keep them honest.

## Verify

```bash
pnpm design:build
pnpm design:audit
pnpm --filter @app/ui test
pnpm --filter @app/ui storybook
```

Open Storybook, confirm the addon-a11y panel is clean for every variant, then run `/precheck`.
