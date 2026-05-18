/**
 * Capture the README screenshots.
 *
 * Run with: `pnpm screenshots:capture`
 *
 * Requires the local Docker stack to be up:
 *   docker compose -f docker/compose.yml up -d
 *
 * Writes 20 PNG files to docs/screenshots/{desktop,mobile}/.
 * See docs/superpowers/specs/2026-05-16-readme-product-facing-design.md
 * for the design and screen inventory.
 */

import { chromium, type Browser, type BrowserContext, type Page } from '@playwright/test';
import { mkdir, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

// ────────────────────────────────────────────────────────────────────
// Config
// ────────────────────────────────────────────────────────────────────

const WEB_BASE = process.env.WEB_BASE ?? 'http://localhost:3001';
const API_BASE = process.env.API_BASE ?? 'http://localhost:3010';

// Node 24 fetch resolves localhost to ::1 first; backend container binds v4.
// Force v4 resolution so cookies stay scoped on the "localhost" host and the
// Playwright context can replay them against the web app.
import { setDefaultResultOrder } from 'node:dns';
setDefaultResultOrder('ipv4first');
const DEMO_EMAIL = process.env.DEMO_EMAIL ?? 'demo+readme@coriolis.local';
const DEMO_PASSWORD = process.env.DEMO_PASSWORD ?? 'Demo!Readme!Pass123';
const DEMO_NAME = process.env.DEMO_NAME ?? 'Demo Reader';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const REPO_ROOT = path.resolve(__dirname, '..', '..');
const OUT_DIR = path.join(REPO_ROOT, 'docs', 'screenshots');

const DESKTOP = { width: 1280, height: 800 } as const;
const MOBILE = { width: 414, height: 896 } as const;

// ────────────────────────────────────────────────────────────────────
// Screen inventory
// ────────────────────────────────────────────────────────────────────

type ScreenName =
  | 'landing'
  | 'login'
  | 'signup'
  | 'dashboard'
  | 'characters-list'
  | 'character-sheet'
  | 'ship-sheet'
  | 'npc-editor'
  | 'game-session'
  | 'shared-character';

interface Screen {
  name: ScreenName;
  /** Returns a URL relative to WEB_BASE for the given seed-output ids. */
  url: (s: SeedOutput) => string;
  /** Whether the screen requires the authed session cookie. */
  authed: boolean;
}

const SCREENS: Screen[] = [
  { name: 'landing', url: () => '/', authed: false },
  { name: 'login', url: () => '/login', authed: false },
  { name: 'signup', url: () => '/signup', authed: false },
  { name: 'dashboard', url: () => '/app/dashboard', authed: true },
  { name: 'characters-list', url: () => '/app/characters', authed: true },
  { name: 'character-sheet', url: (s) => `/app/characters/${s.characterId}`, authed: true },
  { name: 'ship-sheet', url: (s) => `/app/ships/${s.shipId ?? 'missing'}`, authed: true },
  { name: 'npc-editor', url: (s) => `/app/npcs/${s.npcId}`, authed: true },
  // GM detail at /app/game-sessions/{id} is gated by `require-gm-role`
  // middleware that won't accept a freshly-minted demo user; show the GM
  // index instead — it lists the seeded session "The Long Night".
  { name: 'game-session', url: () => '/app/game-sessions', authed: true },
  { name: 'shared-character', url: (s) => `/shared/character/${s.shareSlug}`, authed: false },
];

// ────────────────────────────────────────────────────────────────────
// Tiny logger
// ────────────────────────────────────────────────────────────────────

const log = (msg: string) => {
  // eslint-disable-next-line no-console
  console.log(`▸ ${msg}`);
};
const warn = (msg: string) => {
  // eslint-disable-next-line no-console
  console.warn(`⚠ ${msg}`);
};
const die = (msg: string): never => {
  // eslint-disable-next-line no-console
  console.error(`✗ ${msg}`);
  process.exit(1);
};

// ────────────────────────────────────────────────────────────────────
// Cookie jar — Better Auth sets the session cookie via Set-Cookie
// ────────────────────────────────────────────────────────────────────

class CookieJar {
  private store = new Map<string, string>();

  ingest(setCookieHeaders: string[]): void {
    for (const raw of setCookieHeaders) {
      const [pair] = raw.split(';');
      if (!pair) continue;
      const eq = pair.indexOf('=');
      if (eq <= 0) continue;
      const k = pair.slice(0, eq).trim();
      const v = pair.slice(eq + 1).trim();
      if (v === '' || v === 'deleted') this.store.delete(k);
      else this.store.set(k, v);
    }
  }

  header(): string {
    return [...this.store.entries()].map(([k, v]) => `${k}=${v}`).join('; ');
  }

  asPlaywright(domain: string): { name: string; value: string; domain: string; path: string }[] {
    return [...this.store.entries()].map(([name, value]) => ({
      name,
      value,
      domain,
      path: '/',
    }));
  }
}

// ────────────────────────────────────────────────────────────────────
// HTTP helper (uses Node built-in fetch)
// ────────────────────────────────────────────────────────────────────

let BEARER: string | null = null;

async function api<T = unknown>(
  jar: CookieJar,
  method: string,
  pathname: string,
  body?: unknown,
  expectStatuses: number[] = [200, 201, 204],
): Promise<T> {
  const url = `${API_BASE}${pathname}`;
  const headers: Record<string, string> = {
    'content-type': 'application/json',
    accept: 'application/json',
    origin: WEB_BASE,
    cookie: jar.header(),
  };
  if (BEARER) headers.authorization = `Bearer ${BEARER}`;
  const res = await fetch(url, {
    method,
    headers,
    body: body === undefined ? undefined : JSON.stringify(body),
  });

  const setCookie = res.headers.getSetCookie?.() ?? [];
  if (setCookie.length > 0) jar.ingest(setCookie);

  if (!expectStatuses.includes(res.status)) {
    const text = await res.text();
    die(`${method} ${pathname} → ${res.status}\n${text}`);
  }

  if (res.status === 204) return undefined as T;
  const ct = res.headers.get('content-type') ?? '';
  if (!ct.includes('application/json')) return undefined as T;
  return (await res.json()) as T;
}

// ────────────────────────────────────────────────────────────────────
// Seed phase
// ────────────────────────────────────────────────────────────────────

interface SeedOutput {
  characterId: string;
  shipId: string | null;
  npcId: string;
  gameSessionId: string;
  shareSlug: string;
}

async function preflight(): Promise<void> {
  log('preflight: GET /api/v1/health');
  const res = await fetch(`${API_BASE}/api/v1/health`);
  if (!res.ok) die(`backend health check failed: ${res.status}`);
  const body = (await res.json()) as { status: string };
  if (body.status !== 'ok') die(`backend not healthy: ${JSON.stringify(body)}`);
}

async function authenticate(jar: CookieJar): Promise<string> {
  log(`auth: sign-up demo user (${DEMO_EMAIL})`);
  const signupRes = await fetch(`${API_BASE}/api/v1/auth/sign-up/email`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      origin: WEB_BASE,
      cookie: jar.header(),
    },
    body: JSON.stringify({ email: DEMO_EMAIL, password: DEMO_PASSWORD, name: DEMO_NAME }),
  });
  const sc = signupRes.headers.getSetCookie?.() ?? [];
  if (sc.length > 0) jar.ingest(sc);

  if (signupRes.ok) {
    const token = signupRes.headers.get('set-auth-token');
    if (!token) die('sign-up succeeded but set-auth-token header missing');
    return token!;
  }

  // Already exists → sign in instead.
  if (signupRes.status === 422 || signupRes.status === 409 || signupRes.status === 400) {
    log('auth: account exists → sign-in');
    const signinRes = await fetch(`${API_BASE}/api/v1/auth/sign-in/email`, {
      method: 'POST',
      headers: { 'content-type': 'application/json', origin: WEB_BASE },
      body: JSON.stringify({ email: DEMO_EMAIL, password: DEMO_PASSWORD }),
    });
    if (!signinRes.ok) {
      const text = await signinRes.text();
      die(`sign-in failed: ${signinRes.status}\n${text}`);
    }
    const sc2 = signinRes.headers.getSetCookie?.() ?? [];
    jar.ingest(sc2);
    const token = signinRes.headers.get('set-auth-token');
    if (!token) die('sign-in succeeded but set-auth-token header missing');
    return token!;
  }

  const text = await signupRes.text();
  die(`sign-up failed: ${signupRes.status}\n${text}`);
  return ''; // unreachable, satisfies TS
}

async function seed(jar: CookieJar): Promise<SeedOutput> {
  log('seed: POST /characters');
  const character = await api<{ id: string }>(jar, 'POST', '/api/v1/characters', {
    name: 'Said al-Khatib',
    concept: 'operative',
    iconId: 'judge',
    upbringing: 'stationary',
    origin: 'Coriolis Station, Cinder Quarter',
    attributes: { strength: 4, agility: 4, wits: 3, empathy: 3 },
  });

  log('seed: POST /ships');
  const ship = await api<{ id: string }>(jar, 'POST', '/api/v1/ships', {
    name: 'Madara',
    class: 'courier-yacht',
  });
  const shipId: string = ship.id;

  log('seed: POST /npcs');
  const npc = await api<{ id: string }>(jar, 'POST', '/api/v1/npcs', {
    name: 'Elite Corsair Captain',
    description: 'Commander of the raiding wing, veteran of the Taoan conflict',
    attributes: { strength: 3, agility: 4, wits: 3, empathy: 2 },
  });

  log('seed: POST /game-sessions');
  const gameSession = await api<{ id: string }>(jar, 'POST', '/api/v1/game-sessions', {
    name: 'The Long Night',
    description: 'A campaign set in the Kua system.',
    ...(shipId ? { shipId } : {}),
  });

  log('seed: POST /game-sessions/{id}/dp delta=+3');
  await api(jar, 'POST', `/api/v1/game-sessions/${gameSession.id}/dp`, {
    delta: 3,
    reason: 'Initial campaign tension',
  });

  log('seed: POST /characters/{id}/rolls');
  await api(jar, 'POST', `/api/v1/characters/${character.id}/rolls`, {
    label: 'Pilot · Evade',
    pool: 5,
  });

  log('seed: POST /characters/{id}/share');
  const share = await api<{ slug: string }>(
    jar,
    'POST',
    `/api/v1/characters/${character.id}/share`,
    {},
  );

  return {
    characterId: character.id,
    shipId,
    npcId: npc.id,
    gameSessionId: gameSession.id,
    shareSlug: share.slug,
  };
}

// ────────────────────────────────────────────────────────────────────
// Capture phase
// ────────────────────────────────────────────────────────────────────

async function settle(page: Page): Promise<void> {
  // Nuxt SPA mounts inside #__nuxt; wait for it to have content, then for
  // network to quiesce, then a short grace for fonts/icons.
  await page
    .waitForFunction(
      () => {
        const root = document.querySelector('#__nuxt');
        return !!root && (root.childElementCount > 0 || root.textContent !== '');
      },
      undefined,
      { timeout: 20000 },
    )
    .catch(() => {
      /* tolerate timeout */
    });
  await page.waitForLoadState('networkidle', { timeout: 10000 }).catch(() => {
    /* tolerate timeout */
  });
  await page.waitForTimeout(1200);

  // Hide the Nuxt devtools floating chip. Probed real DOM:
  //   <nuxt-devtools-inspect-panel> + <nuxt-devtools-frame> +
  //   <div id="nuxt-devtools-container">.
  await page
    .addStyleTag({
      content: `
        #nuxt-devtools-container, nuxt-devtools-inspect-panel,
        nuxt-devtools-frame, nuxt-devtools-anchor,
        [class*="nuxt-devtools"] { display: none !important; visibility: hidden !important; }
      `,
    })
    .catch(() => {
      /* page may have navigated; ignore */
    });
}

async function captureScreen(
  context: BrowserContext,
  screen: Screen,
  seed: SeedOutput,
  outFile: string,
): Promise<void> {
  const page = await context.newPage();
  const targetUrl = `${WEB_BASE}${screen.url(seed)}`;
  try {
    await page.goto(targetUrl, { waitUntil: 'domcontentloaded', timeout: 15000 });
    await settle(page);
    await page.screenshot({ path: outFile, fullPage: false });
    log(`  ${screen.name} → ${path.relative(REPO_ROOT, outFile)}`);
  } catch (err) {
    warn(`  ${screen.name} failed: ${(err as Error).message}`);
    try {
      await page.screenshot({ path: outFile.replace(/\.png$/, '-error.png') });
    } catch {
      /* ignore */
    }
  } finally {
    await page.close();
  }
}

async function buildContext(
  browser: Browser,
  viewport: { width: number; height: number },
  isMobile: boolean,
  authed: boolean,
  jar: CookieJar,
): Promise<BrowserContext> {
  const context = await browser.newContext({
    viewport,
    isMobile,
    hasTouch: isMobile,
    deviceScaleFactor: isMobile ? 2 : 1,
    userAgent: isMobile
      ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1'
      : undefined,
    colorScheme: 'dark',
  });

  // Hide the Nuxt devtools floating chip; it shows up in dev mode and clutters
  // README screenshots. Matches the v2/v3 anchor IDs.
  await context.addInitScript(() => {
    const inject = () => {
      if (!document.head) return false;
      const style = document.createElement('style');
      style.textContent =
        '#nuxt-devtools-anchor,#__nuxt-devtools__,nuxt-devtools-anchor,nuxt-devtools-iframe,#__nuxt_devtools_panel__{display:none!important;visibility:hidden!important}';
      document.head.appendChild(style);
      return true;
    };
    if (!inject()) {
      document.addEventListener('DOMContentLoaded', () => inject(), { once: true });
    }
  });

  if (authed) {
    await context.addCookies(jar.asPlaywright('localhost'));
    if (BEARER) {
      // Better Auth on web reads the bearer from localStorage under this key
      // (apps/web/app/composables/useAuth.ts → BEARER_TOKEN_KEY).
      const token = BEARER;
      await context.addInitScript(
        ([k, v]: [string, string]) => {
          try {
            window.localStorage.setItem(k, v);
          } catch {
            /* SSR or restricted context — ignore */
          }
        },
        ['app.auth.bearerToken', token],
      );
    }
  }
  return context;
}

// ────────────────────────────────────────────────────────────────────
// Main
// ────────────────────────────────────────────────────────────────────

async function main(): Promise<void> {
  await preflight();
  await mkdir(path.join(OUT_DIR, 'desktop'), { recursive: true });
  await mkdir(path.join(OUT_DIR, 'mobile'), { recursive: true });

  const jar = new CookieJar();
  BEARER = await authenticate(jar);
  log(`auth: bearer captured (${BEARER.slice(0, 8)}…)`);
  const seedOut = await seed(jar);
  log(`seed complete: ${JSON.stringify(seedOut)}`);

  const browser = await chromium.launch({ headless: true });

  for (const [tier, viewport, isMobile] of [
    ['desktop', DESKTOP, false],
    ['mobile', MOBILE, true],
  ] as const) {
    log(`tier: ${tier} (${viewport.width}x${viewport.height})`);
    const authedCtx = await buildContext(browser, viewport, isMobile, true, jar);
    const anonCtx = await buildContext(browser, viewport, isMobile, false, jar);

    for (const screen of SCREENS) {
      if (screen.name === 'ship-sheet' && !seedOut.shipId) {
        warn(`  skipping ${screen.name} (no shipId)`);
        continue;
      }
      const out = path.join(OUT_DIR, tier, `${screen.name}.png`);
      const ctx = screen.authed ? authedCtx : anonCtx;
      await captureScreen(ctx, screen, seedOut, out);
    }

    await authedCtx.close();
    await anonCtx.close();
  }

  await browser.close();

  // Drop a tiny manifest so the README can refer to the screen list
  // programmatically if it ever needs to.
  const manifest = SCREENS.map((s) => ({
    name: s.name,
    desktop: `docs/screenshots/desktop/${s.name}.png`,
    mobile: `docs/screenshots/mobile/${s.name}.png`,
  }));
  await writeFile(path.join(OUT_DIR, 'manifest.json'), JSON.stringify(manifest, null, 2) + '\n');

  log('done.');
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error(err);
  process.exit(1);
});
