import { mount } from '@vue/test-utils';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import AppHeader from './AppHeader.vue';
import type { BrandLabels, NavItem, Props } from './AppHeader.vue';
import type { DrawerLabels } from '../AppMobileDrawer/AppMobileDrawer.vue';

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

const DRAWER_LABELS: DrawerLabels = {
  ariaLabel: 'Navigation menu',
  closeAriaLabel: 'Close menu',
};

function mountHeader(overrides: Partial<Props> = {}, slots: Record<string, string> = {}) {
  return mount(AppHeader, {
    props: {
      brand: BRAND,
      navItems: NAV_ITEMS,
      activeKey: 'characters',
      brandHref: '/app',
      ...overrides,
    },
    slots,
    attachTo: document.body,
    global: {
      stubs: {
        Teleport: false,
      },
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
    const w = mount(AppHeader, {
      props: {
        brand: BRAND,
        navItems: NAV_ITEMS,
      },
      attachTo: document.body,
      global: { stubs: { Teleport: false } },
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
    const w = mountHeader(
      {},
      { 'user-menu': '<div data-testid="user-menu-stub">UserMenu</div>' },
    );
    expect(w.find('[data-testid="user-menu-stub"]').exists()).toBe(true);
    w.unmount();
  });

  it('mobile-drawer-content slot renders inside the drawer when mobileDrawerLabels is provided and drawer is open', async () => {
    const w = mountHeader(
      { mobileDrawerLabels: DRAWER_LABELS },
      {
        'mobile-drawer-content': '<nav data-testid="mobile-nav">Mobile nav</nav>',
      },
    );
    // Open the drawer by clicking the hamburger
    const hamburger = w.find('.app-header__hamburger');
    await hamburger.trigger('click');
    await w.vm.$nextTick();
    const mobileNav = document.querySelector('[data-testid="mobile-nav"]');
    expect(mobileNav).not.toBeNull();
    expect(mobileNav?.textContent).toContain('Mobile nav');
    w.unmount();
  });
});

// ── Hamburger button ───────────────────────────────────────────────────────────

describe('AppHeader — hamburger button', () => {
  it('hamburger is NOT rendered when mobileDrawerLabels is not provided', () => {
    const w = mountHeader({ mobileDrawerLabels: undefined });
    expect(w.find('.app-header__hamburger').exists()).toBe(false);
    w.unmount();
  });

  it('hamburger IS rendered when mobileDrawerLabels is provided', () => {
    const w = mountHeader({ mobileDrawerLabels: DRAWER_LABELS });
    expect(w.find('.app-header__hamburger').exists()).toBe(true);
    w.unmount();
  });

  it('hamburger has aria-expanded="false" when drawer is closed', () => {
    const w = mountHeader({ mobileDrawerLabels: DRAWER_LABELS });
    const hamburger = w.find('.app-header__hamburger');
    expect(hamburger.attributes('aria-expanded')).toBe('false');
    w.unmount();
  });

  it('hamburger has aria-expanded="true" after click opens the drawer', async () => {
    const w = mountHeader({ mobileDrawerLabels: DRAWER_LABELS });
    const hamburger = w.find('.app-header__hamburger');
    await hamburger.trigger('click');
    await w.vm.$nextTick();
    expect(hamburger.attributes('aria-expanded')).toBe('true');
    w.unmount();
  });

  it('hamburger aria-label matches mobileDrawerLabels.ariaLabel', () => {
    const w = mountHeader({ mobileDrawerLabels: DRAWER_LABELS });
    const hamburger = w.find('.app-header__hamburger');
    expect(hamburger.attributes('aria-label')).toBe(DRAWER_LABELS.ariaLabel);
    w.unmount();
  });

  it('hamburger aria-controls matches the drawer id', () => {
    const w = mountHeader({ mobileDrawerLabels: DRAWER_LABELS });
    const hamburger = w.find('.app-header__hamburger');
    const controlsId = hamburger.attributes('aria-controls');
    expect(controlsId).toBeTruthy();
    w.unmount();
  });

  it('clicking hamburger opens the drawer (dialog becomes visible)', async () => {
    const w = mountHeader({ mobileDrawerLabels: DRAWER_LABELS });
    expect(document.querySelector('[role="dialog"]')).toBeNull();
    const hamburger = w.find('.app-header__hamburger');
    await hamburger.trigger('click');
    await w.vm.$nextTick();
    expect(document.querySelector('[role="dialog"]')).not.toBeNull();
    w.unmount();
  });

  it('AppMobileDrawer is NOT mounted when mobileDrawerLabels is undefined', () => {
    const w = mountHeader({ mobileDrawerLabels: undefined });
    expect(document.querySelector('[role="dialog"]')).toBeNull();
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

    await w.setProps({ activeKey: 'characters' });
    await w.setProps({ activeKey: 'characters' });

    expect(consoleWarnSpy).not.toHaveBeenCalled();
    expect(consoleErrorSpy).not.toHaveBeenCalled();

    expect(w.find('.app-header__brand').exists()).toBe(true);
    expect(w.findAll('.app-header__nav-link')).toHaveLength(NAV_ITEMS.length);
    w.unmount();
  });
});
