# Accessibility Audit — T-6.5.1

**Date:** 2026-05-09
**axe-core version:** 4.11.3 (via `axe-playwright`)
**Scope:** Web SPA (`apps/web`). Mobile (Flutter) and manual VoiceOver/NVDA pass are separate batches.

---

## 1. Storybook smoke (T-6.5.1.a)

306 component stories pass the `@storybook/addon-a11y` (axe-core) check in CI. No regressions introduced by this batch.

---

## 2. Contrast pass — T-6.5.1.c

### Method

Playwright + `axe-playwright` running `wcag2a`, `wcag2aa`, and `wcag21aa` rule sets. Spec file: `tests/e2e/a11y.spec.ts`.

Public pages are audited directly. Auth-gated pages require a valid session cookie; see the **Auth bypass strategy** section below.

### Per-page summary

| Page | Auth required | axe critical | axe serious | axe moderate | Status |
|------|:---:|:---:|:---:|:---:|---|
| `/` (landing) | No | 0 | — | — | Automated ✓ |
| `/login` | No | 0 | — | — | Automated ✓ |
| `/signup` | No | 0 | — | — | Automated ✓ |
| `/app/characters` (dashboard) | Yes | deferred | — | — | Deferred — pre-launch |
| `/app/characters/new` (wizard steps 1–6) | Yes | deferred | — | — | Deferred — pre-launch |
| `/app/characters/<id>` (sheet) | Yes | deferred | — | — | Deferred — pre-launch |
| `/app/settings` | Yes | deferred | — | — | Deferred — pre-launch |
| `/shared/character/<slug>` | No (public) | deferred | — | — | Deferred — stub endpoint |

### Notes on deferred pages

- **Auth-gated pages** (`/app/*`): the Docker dev stack uses cookie-based
  Better Auth sessions. A real session token must be captured from the
  browser DevTools after logging in, then passed as
  `CORIOLIS_E2E_SESSION_COOKIE=<token> pnpm e2e --grep a11y` to enable
  the auth-gated tests in `a11y.spec.ts`.

- **Share viewer** (`/shared/character/<slug>`): the public endpoint returns
  data for any unrevoked slug. In CI there is no seeded fixture, so the page
  renders the "not found" / 410 state which has its own accessible structure.
  A full audit requires a seeded test character with an active share link.

### Auth bypass strategy

1. Start the local Docker stack: `docker compose -f docker/compose.yml up -d`
2. Open `http://localhost:3001` in Chrome. Register or log in.
3. Open DevTools → Application → Cookies → `http://localhost:3001`.
   Copy the value of the `coriolis-session` cookie.
4. Run:
   ```sh
   CORIOLIS_E2E_SESSION_COOKIE=<paste-value-here> pnpm e2e --grep a11y
   ```
   The auth-gated tests in `tests/e2e/a11y.spec.ts` will execute.

### Fixes applied in this batch

| Component / Page | Issue | Fix |
|---|---|---|
| `AppButton` spinner | No `prefers-reduced-motion` fallback — continuous rotate under reduce preference | Added opacity-pulse animation under `@media (prefers-reduced-motion: reduce)` |
| `settings.vue` skeleton | Shimmer animation not suppressed under reduce | Added `animation: none` in reduce media query |
| `characters/index.vue` skeleton | Same as above | Same fix |
| `shared/character/[slug].vue` skeleton | Shimmer gradient animation not suppressed | Added `animation: none` + static gradient fallback |

---

## 3. High-contrast theme — T-6.5.1.d

`[data-theme="high-contrast"]` is applied to `document.documentElement` when
the user enables the toggle in `/app/settings`. Theme value is now persisted
server-side via `PATCH /api/v1/me { theme: "high-contrast" }` (spec v0.7.1).

A localStorage hint is read on page load and applied immediately to avoid a
flash of the default theme before the `/me` response arrives. The server value
reconciles the hint after load. Rollback is applied on PATCH error.

**Design tokens** for the high-contrast theme are defined in
`specs/design/tokens/` under the `[data-theme="high-contrast"]` selector,
following the W3C Design Token Community Group format.

---

## 4. Reduced-motion audit — T-6.5.1.e

All motion-bearing components have been verified against
`@media (prefers-reduced-motion: reduce)`.

| Component | Motion | Reduce fallback | Status |
|---|---|---|---|
| `AppSavePulse` | scale + opacity pulse (saving state) | fade-only (`app-save-pulse-fade` keyframe, no scale) | PASS |
| `AppPopover` | entrance scale+fade (`app-popover-enter`) | `animation: none` | PASS |
| `AppModal` | entrance/exit scale+fade (Vue `<Transition>`) | `scale: 1` — opacity-only transition | PASS |
| `Step3Icon` (wizard step 3) | aura pulse box-shadow | `animation: none` + static box-shadow at 0.4 opacity | PASS |
| `AppButton` spinner | continuous 360° rotation | opacity pulse (no rotation) — **fixed in this batch** | FIXED |
| `settings.vue` skeleton | opacity shimmer | `animation: none` — **fixed in this batch** | FIXED |
| `characters/index.vue` skeleton | opacity shimmer | `animation: none` — **fixed in this batch** | FIXED |
| `characters/new.vue` wizard spinner | continuous rotation | `animation: none` (static border) | PASS (pre-existing) |
| `characters/[id].vue` skeleton | opacity shimmer | `animation: none` (pre-existing) | PASS (pre-existing) |
| `shared/character/[slug].vue` skeleton | gradient shimmer | `animation: none` + static gradient — **fixed in this batch** | FIXED |

---

## 5. Manual screen-reader pass plan — T-6.5.1.b

**Status:** Deferred — requires a human tester with assistive technology.
The following checklist is ready to execute before public launch.

### Environment

- macOS: Safari + VoiceOver (VO).
- Windows: Chrome/Firefox + NVDA (latest stable).

### 5.1 Landmark structure

Test on: `/app/characters` (dashboard), `/app/characters/<id>` (sheet), `/app/characters/new` (wizard).

- [ ] Page has exactly one `<main>` landmark.
- [ ] Navigation links are inside a `<nav>` landmark or `role="navigation"`.
- [ ] Page title (`<title>`) is descriptive and unique per route.
- [ ] Skip-to-content link exists and is focusable by keyboard.

### 5.2 Focus trap — AppModal

Test: open the delete-account confirmation dialog in `/app/settings`.

- [ ] Focus moves into the dialog on open.
- [ ] Tab cycles within the dialog (Cancel → Confirm → back to input).
- [ ] Shift+Tab cycles in reverse.
- [ ] Escape closes the dialog and returns focus to the trigger button.
- [ ] Focus does NOT escape to background content while modal is open.
- [ ] SR announces `role="dialog"` and `aria-labelledby` or `aria-label` text.

### 5.3 Live regions — AppSavePulse and save feedback

Test: edit the display name field in `/app/settings`.

- [ ] `aria-live="polite"` region announces "Saving…", "Saved", "Save failed"
  without interrupting ongoing speech.
- [ ] The region is not `aria-hidden`.
- [ ] On error, the error message is also announced.

### 5.4 Dynamic announcements — conditions toggle

Test: toggle the high-contrast switch in `/app/settings`.

- [ ] Toggle state change ("on" / "off") is announced by SR.
- [ ] Any subsequent error message is announced via `role="alert"`.

### 5.5 Wizard focus management — `/app/characters/new`

- [ ] "Next" button click moves focus to the new step's heading or first
  interactive element.
- [ ] Step progress indicator reads current step number and total.
- [ ] Icon grid (step 3) has `role="radiogroup"` with `aria-label`;
  each icon cell reads `role="radio"` + `aria-checked`.

### 5.6 Share viewer — `/shared/character/<slug>`

- [ ] Page title includes character name.
- [ ] Stats are in a meaningful reading order (not purely visual table).
- [ ] "Gone" (410) and "Not Found" (404) states have descriptive headings
  and offer a navigation action.

---

## 6. Design README update

See `specs/design/README.md` for the high-contrast theme delta spec and
reduced-motion guarantee section added alongside this audit.
