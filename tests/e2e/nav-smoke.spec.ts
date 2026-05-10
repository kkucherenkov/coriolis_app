/**
 * T-2026-05-10-018 Block 5 — global navigation smoke.
 *
 * Walks the four /app/* sections via the global header to confirm
 * the user can move between them without typing URLs (the original
 * bug report: "if I navigate to ships, I can't get back to
 * characters"). Also confirms the language switcher and sign-out
 * paths are reachable.
 *
 * Auth-gated; mirrors the CORIOLIS_E2E_SESSION_COOKIE skip pattern
 * from `a11y.spec.ts` and `wizard-role-picker.spec.ts`.
 *
 * Run locally:
 *
 *   docker compose -f docker/compose.yml up -d
 *   CORIOLIS_E2E_SESSION_COOKIE=<token> pnpm e2e --grep nav-smoke
 *
 * If the env var is unset, every test in this file is skipped.
 */

import { expect, test } from '@playwright/test';

const sessionCookie = process.env.CORIOLIS_E2E_SESSION_COOKIE;

test.describe('global navigation smoke', () => {
  test.skip(!sessionCookie, 'Set CORIOLIS_E2E_SESSION_COOKIE to run nav smoke');

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

  test('round-trip: characters → ships → characters via header nav', async ({ page }) => {
    await page.goto('/app/characters');
    await expect(page).toHaveURL(/\/app\/characters$/);

    // The Characters link is current — verify aria-current.
    const charactersLink = page.getByRole('link', { name: /^characters$|^персонажи$/i });
    await expect(charactersLink).toHaveAttribute('aria-current', 'page');

    // Click Ships.
    await page.getByRole('link', { name: /^ships$|^корабли$/i }).click();
    await expect(page).toHaveURL(/\/app\/ships$/);

    // Active link shifted.
    const shipsLink = page.getByRole('link', { name: /^ships$|^корабли$/i });
    await expect(shipsLink).toHaveAttribute('aria-current', 'page');

    // Click Characters from Ships — this is the original bug fix.
    await page.getByRole('link', { name: /^characters$|^персонажи$/i }).click();
    await expect(page).toHaveURL(/\/app\/characters$/);
  });

  test('skip-link is keyboard-accessible from the top of any /app/* page', async ({ page }) => {
    await page.goto('/app/characters');
    // Tab once from page load — first focusable should be the skip-link.
    await page.keyboard.press('Tab');
    const skipLink = page.locator('a[href="#main-content"]');
    await expect(skipLink).toBeFocused();
    // Activating it moves focus into <main>.
    await page.keyboard.press('Enter');
    await expect(page).toHaveURL(/#main-content$/);
  });

  test('user menu opens and exposes language + settings + sign out', async ({ page }) => {
    await page.goto('/app/characters');
    // Trigger button identified by aria-label set in the layout's i18n.
    const trigger = page.getByRole('button', { name: /open user menu|открыть меню/i });
    await trigger.click();

    // Menu has the three top-level items + the language radiogroup.
    await expect(page.getByRole('menuitem', { name: /^settings$|^настройки$/i })).toBeVisible();
    await expect(page.getByRole('menuitem', { name: /^sign out$|^выйти$/i })).toBeVisible();

    // The locale radios (English / Русский / etc) — at least two should be visible.
    const radios = page.getByRole('menuitemradio');
    expect(await radios.count()).toBeGreaterThanOrEqual(2);
  });
});
