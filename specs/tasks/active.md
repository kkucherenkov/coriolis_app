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
  - [x] Block 1 — Locale-aware talent rendering on the character sheet
        (`0dc1f87`). Resolved in the renderer rather than via a Talent
        `catalogId` migration: `@app/specs` gained
        `findCatalogTalentByName(name, kind)` + `pickLocalized(field,
locale)`, and `apps/web` grew a `useTalentLocalization`
        composable shared by `[id].vue` and `AppShareViewer.vue`. Tests
        430/430 backend, 53/53 web. Both surfaces now switch catalog
        talent name **and** description on locale change; user-edited
        rows fall through to stored fields. Touches: `AppShareViewer`,
        `[id].vue`, new `useTalentLocalization.ts`, `talents.ts` index + helpers, 5 new specs in `talents-catalog.spec.ts`.
  - [x] Block 2 — Personal-talent pool filtered by amplua in
        `Step6Talents.vue` (`41f61c5`). Implemented as a separate
        `RECOMMENDED_PERSONAL_TALENTS_BY_CONCEPT` map in `@app/specs`
        rather than a `recommendedFor` field on each entry — keeps the
        rulebook source-of-truth in one place and lets the helper
        return entries in the order the rulebook prints them.
        Toggle defaults ON when an amplua is set, auto-drops if the
        player swaps amplua to one whose recommended list does not
        contain their already-picked talent. Tests 434/434 backend
        (430 → 434), 53/53 web. uk/el strings ship as
        `[uk-todo]/[el-todo]` placeholders consistent with the
        deferred translator pass.
  - [x] Block 3 — "Forgot password?" link on `login.vue` + new
        `/forgot-password` and `/reset-password` pages — kept the
        `/auth/...` prefix off to mirror the existing flat
        `/login`/`/signup` convention. SDK-method naming follows BA's
        actual surface: `auth.requestPasswordReset(...)` (not
        `forgetPassword` — that name is reserved for BA's email-OTP
        plugin) and `auth.resetPassword(...)`. Backend was already
        wired (`sendResetPassword` → mailer → Coriolis-voice templates
        from T-005). Smoke: curl POST
        `/api/v1/auth/request-password-reset` returned 200 with the
        privacy-preserving message and the mock mailer rendered the
        email correctly. Full browser smoke deferred to a Playwright
        e2e spec — same pattern as the rest of the auth surface.
- Deferred (translator pass — not a code block):
  - uk/el strings on `/signup`, `/login`, `/auth/reset-password` —
    currently `[uk-todo]/[el-todo]` placeholders.
  - uk/el entries in `packages/specs/src/talents.ts` — same shape, same
    reason.
- Status: done — ready to archive (move to `done.md` next session)
- Blockers: —
