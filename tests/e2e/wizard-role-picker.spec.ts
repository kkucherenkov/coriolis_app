/**
 * T-2026-05-10-017 — wizard role picker e2e smoke.
 *
 * Walks the character-creation wizard end-to-end and verifies that the
 * role-picker step (T-2026-05-10-011 Block 2) lands a non-null role on
 * the forged character. Auth-gated; mirrors the
 * `CORIOLIS_E2E_SESSION_COOKIE` skip pattern used by `a11y.spec.ts`.
 *
 * Run locally:
 *
 *   docker compose -f docker/compose.yml up -d
 *   CORIOLIS_E2E_SESSION_COOKIE=<token> pnpm e2e --grep wizard-role-picker
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
const backendUrl = process.env.E2E_BACKEND_URL ?? 'http://localhost:3010';

test.describe('wizard — role picker', () => {
  test.skip(!sessionCookie, 'Set CORIOLIS_E2E_SESSION_COOKIE to run wizard tests');

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

  test('forge a pilot/driver character — role lands on the server', async ({ page, request }) => {
    // Canonical wizard order per `specs/design/CHARACTER_WIZARD.md` §2:
    //   1 Biography → 2 Concept → 3 Role → 4 Attributes → 5 Skills →
    //   6 Talents → 7 Icon.
    await page.goto('/app/characters/new');
    await expect(page.locator('body')).toBeVisible();

    // Step 1 — Biography. Defaults are valid; advance immediately.
    await page.getByRole('button', { name: /^next$|^далее$/i }).click(); // → 2 Concept

    // Step 2 — Concept + name. Type a deterministic name so we can
    // assert it later, then pick the pilot concept card.
    const characterName = `e2e-role-picker-${Date.now()}`;
    await page.getByLabel(/character name|имя персонажа/i).fill(characterName);
    await page.getByRole('button', { name: /^pilot$|^пилот$/i }).click();
    await page.getByRole('button', { name: /^next$|^далее$/i }).click(); // → 3 Role

    // Step 3 — Role picker. Pick "driver" (Pilot's first role:
    // ace / driver / trucker — order from CONCEPT_ROLES).
    await page.getByRole('radio', { name: /^driver$|^водитель$/i }).click();

    await page.getByRole('button', { name: /^next$|^далее$/i }).click(); // → 4 Attributes
    await page.getByRole('button', { name: /^next$|^далее$/i }).click(); // → 5 Skills
    await page.getByRole('button', { name: /^next$|^далее$/i }).click(); // → 6 Talents
    await page.getByRole('button', { name: /^next$|^далее$/i }).click(); // → 7 Icon

    // Last step — forge.
    await page.getByRole('button', { name: /^forge|^создать персонажа/i }).click();

    // Forge navigates to /app/characters/<id> on success.
    await page.waitForURL(/\/app\/characters\/[^/]+$/);

    const url = page.url();
    const id = url.split('/').at(-1);
    expect(id).toBeTruthy();

    // Verify via API: the forged character carries `role: 'driver'`
    // and `roleUnmigrated: false`. (T-011 Block 5 surfaces the latter
    // on the wire; backend Block E logic clears it on first role write.)
    const res = await request.get(`${backendUrl}/api/v1/characters/${id}`, {
      headers: { Cookie: `coriolis-session=${sessionCookie}` },
    });
    expect(res.ok()).toBeTruthy();
    const body = (await res.json()) as {
      role: string | null;
      roleUnmigrated?: boolean;
      concept: string | null;
      name: string;
    };
    expect(body.name).toBe(characterName);
    expect(body.concept).toBe('pilot');
    expect(body.role).toBe('driver');
    expect(body.roleUnmigrated).toBe(false);
  });
});
