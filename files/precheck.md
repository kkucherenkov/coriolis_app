---
description: Run the full local quality-gate sweep before pushing
---

Run the local equivalent of the CI quality gates in this order. Stop on the first failure and report which gate failed plus the relevant output. Do not commit or push until every gate is green.

```bash
pnpm spec:validate
pnpm spec:codegen        # then verify `git status` is clean — codegen-drift check
pnpm lint
pnpm typecheck
pnpm test
pnpm design:audit
pnpm check:i18n
```

After running:

1. If `pnpm spec:codegen` produced any uncommitted diff, that **is** a failure — stage and commit the regenerated client files in their own commit per `AGENTS.md` §4.
2. If Stylelint flags hex literals, `!important`, or inline `style=""` literals, fix at the token level — don't suppress the rule.
3. If `pnpm design:audit` flags an unlisted component or token, update `specs/design/README.md` to match.
4. If `pnpm check:i18n` flags missing keys, add them to **both** `en` and `ru`. A `[ru-todo]` placeholder is acceptable mid-feature but must be resolved before a release tag.
5. If Vitest coverage drops below the backend threshold, add tests — don't lower the threshold.

Print a one-line summary at the end: ✅ all gates green, or ❌ <gate-name> failed.
