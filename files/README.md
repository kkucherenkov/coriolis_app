# `docs/done/` — Shipped feature log

Per PRD §11, every feature merged to `main` gets a markdown entry here. The log is the human-readable history of what's actually in the product, separate from the git log.

## File naming

`<phase>-<short-slug>.md` — e.g. `phase-0.md`, `phase-2-attribute-editing.md`, `phase-4-darkness-points.md`.

Phase-level summary entries (`phase-N.md`) collect the per-feature PRs that landed in that phase, written when the `phase-N-complete` tag is cut.

## Entry template

```markdown
# <Feature title>

**Phase:** <0-7>
**PR:** #<number>
**Tag:** <phase-N-complete | unreleased>
**PRD section:** §<x.y>
**Date:** YYYY-MM-DD

## What shipped

<One paragraph. The user-facing behavior, not the implementation.>

## Notable decisions

<Bullets. Trade-offs that future PRs should know about. Link ADRs in docs/adr/ where relevant.>

## Follow-ups

<Bullets. Known gaps explicitly deferred. Link issues.>
```

## Why this exists

`AGENTS.md` directs Claude Code to consult `docs/done/` for prior precedent before making decisions on similar features. The log is most useful when entries are short, honest about deferred work, and dated — not when they're marketing copy.
