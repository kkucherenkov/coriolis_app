/**
 * Smoke: Settings → Data → Download a copy of my data
 *
 * Verifies that the export endpoint returns a downloadable JSON file
 * with the expected coriolis-export-<userId>-<YYYY-MM-DD>.json
 * filename pattern.
 *
 * Auth-gated; mirrors the CORIOLIS_E2E_SESSION_COOKIE skip pattern
 * from `wizard-role-picker.spec.ts` and `nav-smoke.spec.ts`.
 *
 * Run locally:
 *
 *   docker compose -f docker/compose.yml up -d
 *   CORIOLIS_E2E_SESSION_COOKIE=<token> pnpm e2e --grep settings-export
 *
 * The cookie is captured from a running browser session against the
 * dev stack — open DevTools → Application → Cookies → `coriolis-session`.
 *
 * If the env var is unset, every test in this file is skipped — the
 * suite still parses / lints / type-checks, so structural issues
 * surface in regular CI even without a live session.
 */

import { expect, test } from '@playwright/test';

const sessionCookie = process.env.CORIOLIS_E2E_SESSION_COOKIE;

test.describe('Settings — export', () => {
  test.skip(!sessionCookie, 'Set CORIOLIS_E2E_SESSION_COOKIE to run settings-export tests');

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

  test('downloads a JSON bundle with the expected filename', async ({ page }) => {
    await page.goto('/app/settings');

    // The "Data" section eyebrow label uses t('sectionData').
    // Match either English or Russian locale rendering.
    await expect(page.getByText(/^(Data|Данные)$/)).toBeVisible();

    const [download] = await Promise.all([
      page.waitForEvent('download'),
      page
        .getByRole('button', {
          name: /Download a copy of my data|Скачать копию моих данных/,
        })
        .click(),
    ]);

    expect(download.suggestedFilename()).toMatch(/^coriolis-export-.+-\d{4}-\d{2}-\d{2}\.json$/);
  });
});
