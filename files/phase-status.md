---
description: Report current phase progress against PRD §11 roadmap
---

Read `docs/done/` and the most recent git tag matching `phase-*-complete`, then produce a status report:

1. **Current phase**: the next phase after the most recent `phase-N-complete` tag. If no tag exists, current phase is **Phase 0 — Adoption**.
2. **Roadmap**: render the PRD §11 table inline.
3. **Phase 0 checklist** (only if current phase is 0):
   - [ ] `scripts/setup.sh` substitutions landed
   - [ ] Domain Prisma schema seeded (PRD §8.2)
   - [ ] Design tokens seeded (DESIGN §2)
   - [ ] OpenAPI skeleton seeded (PRD §9, Phase 0/1 surface)
   - [ ] Placeholder copy replaced (en + ru parity)
   - [ ] Full quality-gate sweep green
   - [ ] `phase-0-complete` tag pushed
4. **Recent shipped features**: list the last 10 entries in `docs/done/` (most recent first), with PR link and one-line summary.
5. **Open quality-gate failures on `main`**: report the latest CI run's status. If any gate is red, list which one.

Format as a single markdown report. Don't editorialize about velocity or estimates — just report state.
