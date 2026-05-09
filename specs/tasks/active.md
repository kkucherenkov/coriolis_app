## T-2026-05-10-001 — T-005 + T-004 follow-ups before next epic

- Created: 2026-05-10
- Owner: claude
- Spec: carried-over follow-ups recorded on T-2026-05-09-005 and
  T-2026-05-09-004 in `specs/tasks/done.md`.
- Goal: Close the three open code follow-ups from the character-creation
  rules-alignment and signup-page tasks so the next epic starts on a clean
  slate. Translator-pass items (uk/el copy) are explicitly out of scope —
  they need a human translator, not code, and are tracked here only so they
  do not get lost.
- Acceptance:
  - The character sheet renders catalog talents (kind ≠ `personal`) in the
    user's active i18n locale, falling back to the stored name/description
    only for user-authored talents.
  - The wizard's Step 6 personal-talent picker can be narrowed to talents
    typical for the chosen amplua, with an opt-out switch that restores the
    full 26-talent list.
  - The login card shows a "Forgot password?" link that drives the Better
    Auth `forgetPassword` flow, with a follow-up reset page that consumes
    the token from the email.
- Spec diff: TBD per block — Block 1 likely zero (frontend-only catalog
  lookup); Block 3 likely zero (Better Auth handles the wire). If a block
  needs a spec change it gets its own validate/bundle/codegen pass.
- Codegen impact: probably none — assess per block.
- Design impact: zero new components; reuse `AppButton`, `AppInput`,
  `AppField`, the existing `page-login` / `page-signup` shells.
- Tests: per-block — at minimum a vitest spec asserting locale switch
  flips a forged talent's rendered name (Block 1) and a wizard spec
  asserting the amplua filter shrinks the personal pool (Block 2).
- Sub-blocks (one commit + push + new session per block, per
  `feedback_block_workflow.md`):
  - [ ] Block 1 — Locale-aware talent rendering on the character sheet
        (`apps/web/app/pages/app/characters/[id].vue`). Match
        `kind ≠ personal` talents against the `@app/specs` catalog by
        kebab-cased name and use the localised entry; user-edited or
        unknown rows fall through to the stored name/description.
  - [ ] Block 2 — Personal-talent pool filtered by amplua in
        `Step6Talents.vue`. Add a `recommendedFor?: ConceptCode[]` field to
        `PersonalTalentCatalogEntry`, populate it from the rulebook
        (ГЛАВА 2 + ГЛАВА 4), and gate the picker behind an opt-in
        "Show only talents recommended for {amplua}" toggle (default ON,
        toggle OFF restores the full 26).
  - [ ] Block 3 — "Forgot password?" link on `login.vue` + a new
        `/auth/reset-password` page that consumes the Better Auth reset
        token and calls `auth.resetPassword`. Wire `auth.forgetPassword`
        and the email template through Better Auth config; smoke against
        the Mailpit container in `docker/`.
- Deferred (translator pass — not a code block):
  - uk/el strings on `/signup`, `/login`, `/auth/reset-password` —
    currently `[uk-todo]/[el-todo]` placeholders.
  - uk/el entries in `packages/specs/src/talents.ts` — same shape, same
    reason.
- Status: in-progress
- Blockers: —
