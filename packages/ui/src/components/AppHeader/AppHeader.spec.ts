import { mount } from '@vue/test-utils';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import AppHeader from './AppHeader.vue';
import type { BrandLabels, NavItem, Props } from './AppHeader.vue';

// ── Fixtures ───────────────────────────────────────────────────────────────────

const NAV_ITEMS: NavItem[] = [
  { key: 'characters', href: '/app/characters', label: 'Characters' },
  { key: 'ships', href: '/app/ships', label: 'Ships' },
  { key: 'npcs', href: '/app/npcs', label: 'NPCs' },
  { key: 'sessions', href: '/app/sessions', label: 'Sessions' },
];

const BRAND: BrandLabels = {
  brandName: 'Coriolis · Companion',
  brandHomeAriaLabel: 'Go to dashboard',
  navAriaLabel: 'Main navigation',
};

function mountHeader(overrides: Partial<Props> = {}) {
  return mount(AppHeader, {
    props: {
      brand: BRAND,
      navItems: NAV_ITEMS,
      activeKey: 'characters',
      brandHref: '/app',
      ...overrides,
    },
  });
}

// ── Brand link ─────────────────────────────────────────────────────────────────

describe('AppHeader — brand link', () => {
  it('renders the brand link with brand.brandName text and brand.brandHomeAriaLabel', () => {
    const w = mountHeader();
    const brand = w.find('.app-header__brand');
    expect(brand.exists()).toBe(true);
    expect(brand.text()).toContain(BRAND.brandName);
    expect(brand.attributes('aria-label')).toBe(BRAND.brandHomeAriaLabel);
    w.unmount();
  });

  it('brand link href matches brandHref prop', () => {
    const w = mountHeader({ brandHref: '/app/dashboard' });
    const brand = w.find('.app-header__brand');
    expect(brand.attributes('href')).toBe('/app/dashboard');
    w.unmount();
  });

  it('brand link href defaults to "/app" when brandHref is not provided', () => {
    // Mount without brandHref — withDefaults sets it to '/app'
    const w = mount(AppHeader, {
      props: {
        brand: BRAND,
        navItems: NAV_ITEMS,
      },
    });
    const brand = w.find('.app-header__brand');
    expect(brand.attributes('href')).toBe('/app');
    w.unmount();
  });
});

// ── Nav link rendering ─────────────────────────────────────────────────────────

describe('AppHeader — nav links', () => {
  it('renders one <a> per navItems entry', () => {
    const w = mountHeader();
    const links = w.findAll('.app-header__nav-link');
    expect(links).toHaveLength(NAV_ITEMS.length);
    w.unmount();
  });

  it('each nav link href matches item.href and visible text matches item.label', () => {
    const w = mountHeader();
    const links = w.findAll('.app-header__nav-link');
    for (const [i, item] of NAV_ITEMS.entries()) {
      expect(links[i]?.attributes('href')).toBe(item.href);
      expect(links[i]?.text()).toContain(item.label);
    }
    w.unmount();
  });

  it('nav links are rendered in the order they appear in navItems', () => {
    const w = mountHeader();
    const links = w.findAll('.app-header__nav-link');
    const rendered = links.map((l) => l.text().trim());
    const expected = NAV_ITEMS.map((i) => i.label);
    expect(rendered).toEqual(expected);
    w.unmount();
  });
});

// ── Active link ────────────────────────────────────────────────────────────────

describe('AppHeader — active link', () => {
  it('active link gets aria-current="page" when activeKey matches', () => {
    const w = mountHeader({ activeKey: 'ships' });
    const links = w.findAll('.app-header__nav-link');
    const shipsLink = links.find((l) => l.text().includes('Ships'));
    expect(shipsLink).toBeDefined();
    expect(shipsLink!.attributes('aria-current')).toBe('page');
    w.unmount();
  });

  it('only the active link gets aria-current="page"; others have none', () => {
    const w = mountHeader({ activeKey: 'ships' });
    const links = w.findAll('.app-header__nav-link');
    const withAriaCurrent = links.filter(
      (l) => l.attributes('aria-current') === 'page',
    );
    expect(withAriaCurrent).toHaveLength(1);
    expect(withAriaCurrent[0]?.text()).toContain('Ships');
    w.unmount();
  });

  it('no nav link gets aria-current="page" when activeKey is undefined', () => {
    const w = mountHeader({ activeKey: undefined });
    const links = w.findAll('.app-header__nav-link');
    const withAriaCurrent = links.filter(
      (l) => l.attributes('aria-current') !== undefined,
    );
    expect(withAriaCurrent).toHaveLength(0);
    w.unmount();
  });
});

// ── Nav aria-label ─────────────────────────────────────────────────────────────

describe('AppHeader — nav landmark', () => {
  it('<nav> exposes aria-label matching brand.navAriaLabel', () => {
    const w = mountHeader();
    const nav = w.find('nav');
    expect(nav.exists()).toBe(true);
    expect(nav.attributes('aria-label')).toBe(BRAND.navAriaLabel);
    w.unmount();
  });
});

// ── Slots ──────────────────────────────────────────────────────────────────────

describe('AppHeader — slots', () => {
  it('user-menu slot renders when filled', () => {
    const w = mount(AppHeader, {
      props: { brand: BRAND, navItems: NAV_ITEMS },
      slots: {
        'user-menu': '<div data-testid="user-menu-stub">UserMenu</div>',
      },
    });
    expect(w.find('[data-testid="user-menu-stub"]').exists()).toBe(true);
    w.unmount();
  });

  it('mobile-toggle slot renders when filled (Block 3 will use this)', () => {
    const w = mount(AppHeader, {
      props: { brand: BRAND, navItems: NAV_ITEMS },
      slots: {
        'mobile-toggle': '<button data-testid="hamburger">Menu</button>',
      },
    });
    expect(w.find('[data-testid="hamburger"]').exists()).toBe(true);
    w.unmount();
  });
});

// ── Stability across rerenders ─────────────────────────────────────────────────

describe('AppHeader — rendering stability', () => {
  let consoleWarnSpy: ReturnType<typeof vi.spyOn>;
  let consoleErrorSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    consoleWarnSpy = vi.spyOn(console, 'warn').mockImplementation(vi.fn());
    consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(vi.fn());
  });

  afterEach(() => {
    consoleWarnSpy.mockRestore();
    consoleErrorSpy.mockRestore();
  });

  it('rendering is stable across rerenders with the same props (no key / Vue warnings)', async () => {
    const w = mountHeader({ activeKey: 'characters' });

    // Rerender with the same props twice to check stability
    await w.setProps({ activeKey: 'characters' });
    await w.setProps({ activeKey: 'characters' });

    expect(consoleWarnSpy).not.toHaveBeenCalled();
    expect(consoleErrorSpy).not.toHaveBeenCalled();

    // Sanity: the header still renders correctly after rerenders
    expect(w.find('.app-header__brand').exists()).toBe(true);
    expect(w.findAll('.app-header__nav-link')).toHaveLength(NAV_ITEMS.length);
    w.unmount();
  });
});
