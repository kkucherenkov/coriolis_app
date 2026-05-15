# Active tasks

## T-2026-05-15-PHASE-8-STREAM-A — Phase 8 / Stream A — Foundation (route move + memberships + invite)

- Created: 2026-05-15
- Owner: claude
- Spec: [docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md](../../docs/superpowers/specs/2026-05-15-phase-8-implementation-design.md) §6 Stream A
- Plan: [docs/IMPLEMENTATION_PLAN_PHASE_8.md](../../docs/IMPLEMENTATION_PLAN_PHASE_8.md) Feature 11.1
- Goal: ship the foundation for Phase 8 — rename GM routes `/app/sessions/*` → `/app/game-sessions/*`, add `GameSessionMembership` table + invite fields on `GameSession`, backfill GM-role memberships, ship invite endpoints + GM-side `AppInviteManager` UI. Players cannot join yet; chat does not yet exist; realtime ACL is unchanged.
- Spec diff:
  - `packages/specs/openapi/openapi.yaml` — new routes: `POST /api/v1/game-sessions/{id}/invite/rotate`, `DELETE /api/v1/game-sessions/{id}/invite`, `GET /api/v1/game-sessions/{id}/invite`, `GET /api/v1/game-sessions/{id}/members`, `PATCH /api/v1/game-sessions/{id}/members/{membershipId}`, `DELETE /api/v1/game-sessions/{id}/members/{membershipId}`. New schema: `GameSessionMembership`. Extend `GameSession` response with `memberships[]`.
  - (Stream B will add the `/invites/{token}/*` and `/me/memberships` routes.)
- Codegen impact: yes (TS + Dart clients regenerate from the new routes/schema).
- Sub-steps:
  - [x] T-11.1.0.a — route move web (`apps/web/app/pages/app/sessions/` → `app/game-sessions/`) + grep-and-replace all internal `navigateTo` / `<NuxtLink>` references + add `app/middleware/redirect-legacy-session.global.ts` 301 redirect (removed in Stream B).
  - [x] T-11.1.0.b — route move mobile (`apps/mobile/lib/features/sessions/` → `lib/features/game_sessions/`) + update all Dart imports.
  - [x] T-11.1.0.c — document the URL naming policy in `AGENTS.md` (GameSession TS/Dart/DB → `/game-sessions/*` for GM, `/sessions/*` for player).
  - [x] T-11.1.1.a — OpenAPI: invite-rotate, invite-revoke, invite-metadata, members-list, member-patch, member-delete. Run `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen`.
  - [x] T-11.1.1.f — Prisma migration: add `inviteTokenHash`, `inviteRotatedAt`, `inviteCreatedById` to `GameSession`; create `GameSessionMembership(@@unique gameSessionId,userId)`; backfill GM-role `GameSessionMembership` for every existing `GameSession`. Wrap migration in a transaction.
  - [x] T-11.1.1.d — invite-token generator: 22-char URL-safe `nanoid`, SHA-256 hash at rest, plaintext only in the rotate-response body.
  - [x] T-11.1.1.b — `MembershipsModule` (CQRS) with `RotateInviteCommand`, `RevokeInviteCommand`, `KickMemberCommand`, `LeaveSessionCommand`, `LinkCharacterCommand` (commands); `ListMembershipsQuery`, `GetInviteMetadataQuery` (queries); `MemberJoinedEvent`, `MemberLeftEvent`, `MemberKickedEvent`, `CharacterLinkedEvent` (events). _Stream B adds `AcceptInviteCommand`, `GetMyMembershipsQuery`, `GetInvitePreviewQuery`._
  - [x] T-11.1.1.c — extend `GameSessionsModule.get` to include `memberships[]` in the response.
  - [ ] T-11.1.1.g — `AppInviteManager` panel on GM Overview tab (`@app/ui` component per handoff `invite-manager.jsx`). States: `none` / `active` / `just-generated` / `just-rotated`. Reveal as `role="alertdialog"`, **no auto-dismiss**, explicit "I've copied it — close" CTA.
  - [x] T-11.1.1.g.2 — `AppSessionShareLinkCard` reusable one-shot URL card (`@app/ui` per `session-share-link-card.jsx`).
  - [ ] T-11.1.1.j (partial) — `Kick` action on GM members list with `AppConfirm`. (Member self-`Leave` is Stream B; same modal pattern.)
  - [ ] T-11.1.2 — Dashboard `Running | Playing in` segmented control per handoff `dashboard.jsx` (web + mobile). _Playing-in count is 0 until Stream B ships `GetMyMembershipsQuery`._
  - [ ] T-11.1.1.m (Stream A subset) — backend tests: rotate invalidates previous hash; revoke nullifies field; character-ownership rejection (placeholder, full test in Stream B); membership uniqueness; migration backfill produces one GM membership per pre-existing `GameSession`.
  - [ ] T-11.1.1.m.2 — `@app/ui` component specs: `AppInviteManager` four states; `AppSessionShareLinkCard` copy-button behaviour; Storybook a11y addon green on both.
  - [ ] precheck before PR: `pnpm spec:validate && pnpm spec:bundle && pnpm spec:codegen` clean; `turbo run lint test typecheck`; `pnpm --filter @app/ui storybook` builds; `flutter analyze lib` 0 issues.
- Status: in-progress
- Blockers: —
- Notes:
  - JSX is the spec (project rule #8). When this entry says "per handoff X.jsx", that file under `/tmp/coriolis-handoff/coriolis-app/project/screens/` is canonical.
  - Stream A explicitly excludes: chat, player join flow, realtime ACL widening, mobile deep-link binding, `characterIds` cleanup. Those are Streams B–E in the design doc.
