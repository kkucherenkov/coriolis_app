/**
 * T-6.5.1.c — Page-level axe-core accessibility audit.
 *
 * Runs axe against the public routes that can be reached without
 * authentication. Auth-gated routes (dashboard, sheet, wizard, settings)
 * are documented as deferred in docs/A11Y_AUDIT.md and must be re-run
 * with a real session cookie before public launch.
 *
 * Execution: `pnpm e2e --grep a11y` (requires local Docker stack on :3001).
 */
import AxeBuilder from 'axe-playwright';
import { expect, test } from '@playwright/test';

// ── Helper ─────────────────────────────────────────────────────────────────────

async function runAxe(page: Parameters<typeof AxeBuilder>[0]) {
  const results = await new AxeBuilder({ page })
    // Exclude third-party embedded widgets (none in scope yet, but defensive).
    .exclude('[data-axe-ignore]')
    // wcag2a + wcag2aa are our baseline; wcag21aa covers SC 1.3.4, 1.4.10–13.
    .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
    .analyze();
  return results;
}

// ── Public routes (no auth required) ──────────────────────────────────────────

test.describe('a11y — public pages', () => {
  test('/ (landing) — no critical axe violations', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    const results = await runAxe(page);

    // Log per-page summary for the audit document.
    if (results.violations.length > 0) {
      console.log(`Landing page violations (${results.violations.length}):`);
      results.violations.forEach((v) => {
        console.log(`  [${v.impact}] ${v.id}: ${v.description}`);
      });
    }

    expect(
      results.violations.filter((v) => v.impact === 'critical'),
      'No critical axe violations on landing page',
    ).toHaveLength(0);
  });

  test('/login — no critical axe violations', async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');

    const results = await runAxe(page);

    if (results.violations.length > 0) {
      console.log(`Login page violations (${results.violations.length}):`);
      results.violations.forEach((v) => {
        console.log(`  [${v.impact}] ${v.id}: ${v.description}`);
      });
    }

    expect(
      results.violations.filter((v) => v.impact === 'critical'),
      'No critical axe violations on login page',
    ).toHaveLength(0);
  });

  test('/signup — no critical axe violations', async ({ page }) => {
    await page.goto('/signup');
    await page.waitForLoadState('networkidle');

    const results = await runAxe(page);

    if (results.violations.length > 0) {
      console.log(`Signup page violations (${results.violations.length}):`);
      results.violations.forEach((v) => {
        console.log(`  [${v.impact}] ${v.id}: ${v.description}`);
      });
    }

    expect(
      results.violations.filter((v) => v.impact === 'critical'),
      'No critical axe violations on signup page',
    ).toHaveLength(0);
  });
});

// ── Auth-gated routes (documented as deferred) ─────────────────────────────────
//
// The tests below require an authenticated session. They are skipped by
// default; to run locally, set CORIOLIS_E2E_SESSION_COOKIE to a valid
// session token captured from the running stack.
//
// See docs/A11Y_AUDIT.md §Auth bypass strategy for instructions.
//
// Deferred pages: /app/characters, /app/characters/new, /app/characters/<id>,
// /app/settings, /shared/character/<slug>

test.describe('a11y — auth-gated pages (deferred)', () => {
  const sessionCookie = process.env.CORIOLIS_E2E_SESSION_COOKIE;

  test.skip(!sessionCookie, 'Set CORIOLIS_E2E_SESSION_COOKIE to run auth-gated axe tests');

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

  test('/app/characters (dashboard) — no critical violations', async ({ page }) => {
    await page.goto('/app/characters');
    await page.waitForLoadState('networkidle');
    const results = await runAxe(page);
    expect(results.violations.filter((v) => v.impact === 'critical')).toHaveLength(0);
  });

  test('/app/characters/new (wizard step 1) — no critical violations', async ({ page }) => {
    await page.goto('/app/characters/new');
    await page.waitForLoadState('networkidle');
    const results = await runAxe(page);
    expect(results.violations.filter((v) => v.impact === 'critical')).toHaveLength(0);
  });
});
