<!-- markdownlint-disable MD041 -->

## Summary

<!-- One paragraph: what changes, why, and which PRD/DESIGN section it implements. Cite section numbers. -->

## Type of change

- [ ] Spec change (touches `packages/specs/`)
- [ ] Backend (touches `apps/backend/`)
- [ ] Web (touches `apps/web/` or `packages/ui/`)
- [ ] Mobile (touches `apps/mobile/` or `packages/ui_flutter/`)
- [ ] Design tokens (touches `specs/design/tokens/`)
- [ ] Codegen-only (regenerated client files; see commit history for the source change)
- [ ] Chore / docs / CI

## Phase

<!-- Per PRD §11. Mark the phase this lands in. -->

- [ ] Phase 0 — Adoption
- [ ] Phase 1 — Foundation
- [ ] Phase 2 — Character Sheet
- [ ] Phase 3 — Sharing & Polish
- [ ] Phase 4 — Dice & Sessions
- [ ] Phase 5 — Ships
- [ ] Phase 6 — GM Tools
- [ ] Phase 7 — Hardening

## Quality gates (per PRD §12)

All of these must be green for merge.

- [ ] `pnpm spec:validate` — OpenAPI + AsyncAPI lint clean
- [ ] `codegen-drift` — `pnpm spec:codegen` produces no diff against the committed tree
- [ ] `express-openapi-validator` runtime tests pass for any new/changed routes
- [ ] Stylelint clean — no hex literals in `apps/web` or `packages/ui` SCSS, no `!important`, no inline `style=""` literals
- [ ] `@app/ui` component audit — every component folder has `*.vue + *.stories.ts + *.spec.ts + index.ts`
- [ ] `pnpm design:audit` — every token used is documented, every component listed in `specs/design/README.md`
- [ ] `pnpm check:i18n` — key parity across en / ru
- [ ] Vitest — backend coverage thresholds met; `@app/ui` and web specs green
- [ ] TruffleHog — no secrets in the diff
- [ ] `license-checker` — no dependencies outside the OSI-permissive allowlist

## Non-negotiables checklist (per AGENTS.md §3)

- [ ] No backend route exists outside `openapi.yaml`
- [ ] No `process.env.X` access outside `AppConfig`
- [ ] `GameSession` used for the GM-side concept (never `Session`)
- [ ] No edits to `packages/api-client-*/src/` (regenerated only)
- [ ] No edits to `*.generated.*` or `tokens.g.dart` (regenerated only)
- [ ] If a token was renamed or removed, an ADR was added in `docs/adr/`

## Visual changes (UI PRs only)

- [ ] Storybook addon-a11y panel is clean for every variant
- [ ] Light and dark mode both verified
- [ ] Reduced-motion variant verified for any animated component
- [ ] Matching `.jsx` mockup in `specs/design/mockups/` is consistent (or has been updated in the same PR)

## After merge

- [ ] Append `docs/done/<feature>.md` with the PR link and a one-line summary

## Risks / rollback

<!-- Anything reviewers should know about deployability or data migrations. Empty if N/A. -->
