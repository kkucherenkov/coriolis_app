# Active tasks

_No tasks in progress. Start here when beginning new work._

## T-2026-05-08-007: Codegen follow-up for /api/v1/characters

Phase 1.1 follow-up. Regenerate TypeScript and Dart clients against the merged
/api/v1/characters spec (commit 691e9de, version 0.3.0).

- [x] pnpm spec:validate (spec valid)
- [x] pnpm spec:bundle (bundled to dist/openapi.json)
- [x] pnpm spec:codegen (13 new operations, Character + Item + Talent types)
- [x] Sanity check diff (only packages/api-client-*, packages/specs/src/openapi-types.ts changed)
- [x] Commit artefacts (3bf29f6)

Status: Ready for PR.
