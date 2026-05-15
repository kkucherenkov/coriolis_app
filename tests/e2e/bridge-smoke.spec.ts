/**
 * T-2026-05-14-004 follow-up — Bridge dashboard smoke.
 *
 * Walks an authenticated user onto `/app/dashboard` and confirms the
 * three Bridge cards (cycle / sync / roster) plus the aphorism footer
 * are on first paint. Mirrors the auth-gated skip pattern used by
 * `nav-smoke.spec.ts` and `wizard-role-picker.spec.ts` — the smoke is
 * intentionally lightweight and survives the live realtime hooks
 * landing (the assertions don't depend on the cycle clock value, just
 * on its container being rendered).
 *
 * Run locally:
 *
 *   docker compose -f docker/compose.yml up -d
 *   CORIOLIS_E2E_SESSION_COOKIE=<token> pnpm e2e --grep bridge-smoke
 *
 * If the env var is unset, every test in this file is skipped.
 */

import { expect, test } from '@playwright/test';

const sessionCookie = process.env.CORIOLIS_E2E_SESSION_COOKIE;

test.describe('Bridge dashboard smoke', () => {
  test.skip(!sessionCookie, 'Set CORIOLIS_E2E_SESSION_COOKIE to run bridge smoke');

  test.beforeEach(async ({ page }) => {
    if (sessionCookie) {
      await page.context().addCookies([
        {
          name: 'coriolis-session',
          value: sessionCookie,
          domain: 'localhost',
          path: '/',
          httpOnly: true,
          secure: false,
        },
      ]);
    }
  });

  test('lands on /app/dashboard after auth redirect from /', async ({ page }) => {
    await page.goto('/');
    // The root redirects to /app/dashboard for authenticated users (T-BRIDGE
    // redirect flip). Don't assert the URL the redirect was issued from —
    // just that we end up on the Bridge.
    await expect(page).toHaveURL(/\/app\/dashboard$/);
  });

  test('renders the three Bridge cards + aphorism footer on first paint', async ({ page }) => {
    await page.goto('/app/dashboard');
    await expect(page).toHaveURL(/\/app\/dashboard$/);

    // The Bridge container is the section labelled by the dashboard's
    // wizardLabel i18n key — text differs per locale, but the section
    // is the page's primary aria-labelled landmark.
    const bridge = page.locator('section.bridge');
    await expect(bridge).toBeVisible();

    // Three cards — labelled by the canonical IDs (locale-invariant).
    await expect(page.locator('[aria-labelledby="bridge-cycle-title"]')).toBeVisible();
    await expect(page.locator('[aria-labelledby="bridge-sync-title"]')).toBeVisible();
    await expect(page.locator('[aria-labelledby="bridge-roster-title"]')).toBeVisible();

    // Cycle card surfaces a live-region stat — the precise text varies
    // (locale + clock minute) but the live-region polite container must
    // be there for the screen-reader announcement to work.
    await expect(
      page.locator('[aria-labelledby="bridge-cycle-title"] [aria-live="polite"]'),
    ).toBeVisible();

    // Sync card has the on/off dot — present regardless of network state.
    await expect(page.locator('.bridge__sync-dot')).toBeVisible();

    // Roster card renders either a count, the empty CTA, or a loader.
    // The card itself is enough for first-paint coverage.
    await expect(page.locator('[aria-labelledby="bridge-roster-title"]')).toBeVisible();

    // The aphorism footer is the closing Coriolis line — always present.
    await expect(page.locator('footer[aria-label="aphorism"]')).toBeVisible();

    // At least one arabesque corner is rendered (decorative; tl + tr in v1).
    expect(await page.locator('.bridge__corner').count()).toBeGreaterThanOrEqual(2);
  });
});
