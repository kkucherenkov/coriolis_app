# 0004 — Typography token schema: atom-refs + project role names

- **Status:** accepted
- **Date:** 2026-05-14
- **Deciders:** @kirill
- **Tags:** design-system, tokens, frontend, mobile

## Context

`specs/design/tokens/typography.json` and the design-handoff bundle at
`/tmp/coriolis-handoff/coriolis-app/project/tokens/typography.json` diverged
on three axes:

1. **Atom layer.** The project file inlines literal values inside each
   composite role (`fontSize: "48px"`, `letterSpacing: "0.06em"`); the
   handoff file defines explicit atom scales (`font.size.{9..64}`,
   `font.line-height.{tight,snug,…,loose}`, `font.tracking.{04,06,…,30}`)
   and composite roles reference atoms via DTCG `{font.size.16}` syntax.
2. **Top-level namespace.** Project: `type`. Handoff: `typography`.
3. **Role-name vocabulary.** Project: `display-{xl,lg,md,sm}` / `body-{lg,md,sm}`
   / `mono-stat-{md,xl}` (9 roles). Handoff: `display-{hero,title,section}` /
   `body-{default,small}` / `eyebrow` / `label` / `numeric-stat` (8 roles).

The audit (`docs/audits/design-2026-05-14.md` §1.2) flagged this as a
**decision-blocker for every downstream design-token consumer** in
`T-2026-05-14-003` onward, and recommended the handoff atom-refs schema
for maintainability.

A survey of consumers (`grep --type-* --font-* AppTypography.*` across
`apps/{web,mobile}` and `packages/{ui,ui_flutter}`) returned:

- ~1300 references to `--type-<role>-*` CSS vars; nine role names actively
  in use, of which two (`body-xs`, `label-sm`) are referenced but
  **undefined** in tokens — silent fallback to inherited values.
- 120 `AppTypography.<role>` references across 32 Dart files.
- ~260 `--font-*` references; 29 references to `--font-weight-*` and
  `--font-sans` that point at undefined vars (pipeline emits `--fw-*` and
  `--font-body`).

## Decision

Adopt the handoff **atom-refs schema** (option A in alternatives).
Concretely:

1. `specs/design/tokens/typography.json` gains atom scales:
   - `font.size.{9,10,11,12,13,14,15,16,18,20,24,28,32,40,48,64}` (DTCG `dimension`)
   - `font.line-height.{tight,snug,normal,relaxed,loose}` (DTCG `number`)
   - `font.tracking.{tight,normal,04,06,08,10,12,14,16,18,20,30}` (DTCG `dimension`)
2. Composite roles use DTCG reference syntax for every property:
   `fontFamily: "{font.family.display}"`, `fontSize: "{font.size.48}"`,
   `lineHeight: "{font.line-height.tight}"`, `letterSpacing:
"{font.tracking.06}"`, `fontWeight: "{font.weight.regular}"`.
3. **Top-level role bucket renamed from `type` to `typography`** to match
   the handoff and W3C DTCG examples. `TokenBundle.typography` (file slot)
   stays — composites now read `tokens.typography.typography.<role>`.
4. **Role-name vocabulary stays project-canonical** for v1:
   `display-{xl,lg,md,sm}`, `body-{lg,md,sm}`, `mono-stat-{xl,md}`.
   Handoff role names (`display-hero/title/section`, `eyebrow`, `label`,
   `numeric-stat`) are deliberately **not adopted now** — they would
   force a rename across ~50 consumer files and a real visual diff
   (handoff `body-default` is 14px, project `body-md` is 16px). The
   handoff vocabulary is documented in the gap log
   (`specs/design/README.md`) for a future migration.
5. Two roles referenced-but-undefined by current consumers are added:
   - `body-xs` — Inter 12px, line-height `normal`, weight `regular`
   - `label-sm` — Inter 12px, line-height `normal`, weight `medium`,
     tracking `06`, uppercase

The pipeline (`packages/design-tokens/src/{load,parse,types,emit-*}.ts`)
gains a token-resolver that walks `{path.to.atom}` references in
typography composites and substitutes the leaf `$value` before emit.

## Consequences

### Positive

- Single source of truth for the size, line-height, and tracking scales.
  Adding a new role no longer means hand-copying literals.
- Catches drift at validate time: an unknown `{font.size.42}` is a hard
  error in `pnpm design:build`, not a silent typo on a CSS class.
- DTCG-standard syntax → external tooling (Figma Tokens Studio, Style
  Dictionary, etc.) reads the file without a custom parser.
- Atom layer is a prerequisite for the v1 atom components in
  `T-2026-05-14-003` (`AppPanelTitle`, `AppWordmark`, `AppSkillRow`).
- Two undefined-but-used roles (`body-xs`, `label-sm`) become real,
  removing 26 silently broken CSS-var references.

### Negative

- Pipeline complexity grows: `parse.ts` gains a generic ref-resolver, and
  each emit pass walks composites through it before rendering.
- The audit's recommendation to also adopt handoff role names is
  **deferred**, so the project still carries a vocabulary that diverges
  from the handoff. The gap is documented but not closed.
- One more cycle of dual-vocabulary risk: anyone reading the handoff
  needs the name-map in the README to translate.

### Neutral

- Generated CSS output is unchanged for the 9 existing roles — the same
  `--type-<role>-{font-size,line-height,font-weight,letter-spacing}`
  vars are emitted, only their authoring shape changed. Consumers don't
  move.
- Adding `body-xs` and `label-sm` is purely additive — no existing role
  is altered.

## Alternatives considered

### Option A — Handoff atom-refs schema (accepted)

See **Decision** above. Maintainable, DTCG-compliant, future-proof, but
requires pipeline ref-resolution.

### Option B — Project inlined-literals schema (rejected)

Keep the current shape: each composite role inlines its `fontSize`,
`lineHeight`, `letterSpacing` literals. Pipeline stays trivial. Rejected
because the audit identified this as the lower-maintainability path —
size-scale changes have no central point of edit, drift between roles is
silent, and external tooling can't traverse references.

### Option C — Full handoff adoption (atom-refs **and** role names) (rejected)

Adopt both the atom layer and the handoff role vocabulary
(`display-hero/title/section`, `body-default/small`, `eyebrow`, `label`,
`numeric-stat`). Rejected for v1 because:

- ~50 Vue/Dart files would change in the same PR, fighting for review
  attention with the actual schema decision.
- Real visual deltas land alongside a "schema-only" change: handoff
  `body-default` (14px) is **not** equivalent to project `body-md`
  (16px), and `display-section` (24px uppercase) doesn't match any
  existing role — adopting wholesale produces visible regressions that
  belong in a separate, design-reviewed PR.
- A future migration is cheaper once the atom layer is in place: adding
  a handoff role is one composite entry referencing existing atoms.

## Related

- [ADR-0001](0001-phase-0-design-pipeline-rewrite.md) — establishes the
  DTCG-based pipeline and explains why typography composites live in
  `typography.json`.
- `docs/audits/design-2026-05-14.md` §1.2 — audit that surfaced the
  divergence and ranked it a decision-blocker.
- `specs/tasks/active.md` — `T-2026-05-14-002` (this work).
- Handoff source: `/tmp/coriolis-handoff/coriolis-app/project/tokens/typography.json`.
