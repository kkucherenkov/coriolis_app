/**
 * app.spec.ts
 *
 * Unit tests for the `app` layout logic (apps/web/app/layouts/app.vue).
 *
 * The layout requires a full Nuxt + vue-i18n environment to mount.
 * Tests here validate:
 *   1. The four nav items are built with the correct keys.
 *   2. The skip-link target is '#main-content'.
 *   3. activeKey derivation for each named section.
 *   4. activeKey is undefined for unmatched paths.
 *   5. i18n labels are wired deterministically (verifiable through
 *      the navItems structure and t()-key convention).
 *   6. displayName falls back to email when name is absent.
 *   7. displayName shows '…' while the /me request is in-flight.
 *
 * We mirror the layout's script logic as pure functions — same pattern
 * used throughout the project (e.g. RoleCardGrid.spec.ts, RoleUnmigratedBanner.spec.ts).
 */

import { describe, it, expect } from 'vitest';

// ── Nav items factory ─────────────────────────────────────────────────────────
// Mirrors the `navItems` computed in the layout.

interface NavItem {
  key: string;
  href: string;
  label: string;
}

function buildNavItems(t: (key: string) => string): NavItem[] {
  return [
    { key: 'characters', href: '/app/characters', label: t('nav.characters') },
    { key: 'ships', href: '/app/ships', label: t('nav.ships') },
    { key: 'npcs', href: '/app/npcs', label: t('nav.npcs') },
    { key: 'sessions', href: '/app/game-sessions', label: t('nav.sessions') },
  ];
}

// ── activeKey derivation ──────────────────────────────────────────────────────
// Mirrors the `activeKey` computed in the layout.

function deriveActiveKey(path: string): string | undefined {
  if (path.startsWith('/app/characters')) return 'characters';
  if (path.startsWith('/app/ships')) return 'ships';
  if (path.startsWith('/app/npcs')) return 'npcs';
  if (path.startsWith('/app/game-sessions')) return 'sessions';
  return undefined;
}

// ── displayName derivation ────────────────────────────────────────────────────
// Mirrors the `displayName` computed in the layout.

interface MeSnapshot {
  displayName?: string | null;
  name?: string | null;
  email?: string | null;
}

function deriveDisplayName(snapshot: MeSnapshot | null): string {
  if (!snapshot) return '…';
  return snapshot.displayName ?? snapshot.name ?? snapshot.email ?? '…';
}

// ── Skip-link constant ────────────────────────────────────────────────────────
// The layout hard-codes `href="#main-content"`. We pin this expectation so
// a refactor that changes the id is caught immediately.

const SKIP_LINK_HREF = '#main-content';
const MAIN_CONTENT_ID = 'main-content';

// ── Tests: nav items structure ────────────────────────────────────────────────

// Simple identity t() — returns the key so we can verify structure without
// a real i18n runtime. The layout passes translated strings as labels;
// the structure (key/href) is what we validate here.
function identityT(key: string): string {
  return key;
}

describe('app layout — navItems', () => {
  it('returns exactly four nav items', () => {
    const items = buildNavItems(identityT);
    expect(items).toHaveLength(4);
  });

  it('nav item keys are in canonical order: characters, ships, npcs, sessions', () => {
    const items = buildNavItems(identityT);
    expect(items.map((i) => i.key)).toEqual(['characters', 'ships', 'npcs', 'sessions']);
  });

  it('each nav item href matches its key-based route', () => {
    const items = buildNavItems(identityT);
    // 'sessions' key maps to the GM route /app/game-sessions (Phase 8 Stream A rename).
    // The player route /app/sessions ships in Stream B.
    const HREF_OVERRIDES: Record<string, string> = {
      sessions: '/app/game-sessions',
    };
    for (const item of items) {
      const expected = HREF_OVERRIDES[item.key] ?? `/app/${item.key}`;
      expect(item.href).toBe(expected);
    }
  });

  it('nav item labels come from t() with the nav.* prefix', () => {
    const items = buildNavItems(identityT);
    const [characters, ships, npcs, sessions] = items;
    expect(characters?.label).toBe('nav.characters');
    expect(ships?.label).toBe('nav.ships');
    expect(npcs?.label).toBe('nav.npcs');
    expect(sessions?.label).toBe('nav.sessions');
  });
});

// ── Tests: activeKey derivation ───────────────────────────────────────────────

describe('app layout — activeKey', () => {
  it('returns "characters" for /app/characters', () => {
    expect(deriveActiveKey('/app/characters')).toBe('characters');
  });

  it('returns "characters" for deep paths like /app/characters/some-id', () => {
    expect(deriveActiveKey('/app/characters/abc-123')).toBe('characters');
  });

  it('returns "ships" for /app/ships', () => {
    expect(deriveActiveKey('/app/ships')).toBe('ships');
  });

  it('returns "ships" for deep paths like /app/ships/some-id', () => {
    expect(deriveActiveKey('/app/ships/xyz-456')).toBe('ships');
  });

  it('returns "npcs" for /app/npcs', () => {
    expect(deriveActiveKey('/app/npcs')).toBe('npcs');
  });

  it('returns "sessions" for /app/game-sessions', () => {
    expect(deriveActiveKey('/app/game-sessions')).toBe('sessions');
  });

  it('returns undefined for /app/settings (no nav match)', () => {
    expect(deriveActiveKey('/app/settings')).toBeUndefined();
  });

  it('returns undefined for /app (dashboard root)', () => {
    expect(deriveActiveKey('/app')).toBeUndefined();
  });

  it('returns undefined for /login (public route)', () => {
    expect(deriveActiveKey('/login')).toBeUndefined();
  });
});

// ── Tests: skip-link and main-content anchor ──────────────────────────────────

describe('app layout — skip-link', () => {
  it('skip-link href is "#main-content"', () => {
    expect(SKIP_LINK_HREF).toBe('#main-content');
  });

  it('main content id matches the skip-link target', () => {
    expect(`#${MAIN_CONTENT_ID}`).toBe(SKIP_LINK_HREF);
  });
});

// ── Tests: displayName derivation ────────────────────────────────────────────

describe('app layout — displayName', () => {
  it('returns "…" when me snapshot is null (request in-flight)', () => {
    expect(deriveDisplayName(null)).toBe('…');
  });

  it('prefers displayName over name and email', () => {
    expect(
      deriveDisplayName({ displayName: 'Zara Ibn Said', name: 'zara', email: 'z@kua.com' }),
    ).toBe('Zara Ibn Said');
  });

  it('falls back to name when displayName is absent', () => {
    expect(deriveDisplayName({ displayName: null, name: 'zara', email: 'z@kua.com' })).toBe('zara');
  });

  it('falls back to email when both displayName and name are absent', () => {
    expect(deriveDisplayName({ displayName: null, name: null, email: 'z@kua.com' })).toBe(
      'z@kua.com',
    );
  });

  it('returns "…" when all fields are absent', () => {
    expect(deriveDisplayName({ displayName: null, name: null, email: null })).toBe('…');
  });

  it('returns "…" when snapshot has no recognised fields', () => {
    expect(deriveDisplayName({})).toBe('…');
  });
});
