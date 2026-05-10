import { mount } from '@vue/test-utils';
import { nextTick } from 'vue';
import { describe, expect, it } from 'vitest';

import UserMenu from './UserMenu.vue';
import type { Locale, MenuLabels } from './UserMenu.vue';

// ── Test fixtures ──────────────────────────────────────────────────────────────

const LOCALES: Locale[] = [
  { code: 'en', name: 'English' },
  { code: 'ru', name: 'Русский' },
  { code: 'uk', name: 'Українська' },
];

const LABELS: MenuLabels = {
  triggerAriaLabel: 'Open user menu',
  languageLabel: 'Language',
  settingsLabel: 'Settings',
  signOutLabel: 'Sign out',
};

function mountMenu(
  props: Partial<InstanceType<typeof UserMenu>['$props']> = {},
) {
  return mount(UserMenu, {
    props: {
      displayName: 'Zara al-Khatib',
      avatarUrl: null,
      locales: LOCALES,
      currentLocale: 'en',
      labels: LABELS,
      open: false,
      ...props,
    },
    attachTo: document.body,
  });
}

// ── Trigger aria attributes ───────────────────────────────────────────────────

describe('UserMenu — trigger aria attributes', () => {
  it('has aria-haspopup="menu" on the trigger button', () => {
    const w = mountMenu();
    const btn = w.find('.user-menu__trigger');
    expect(btn.attributes('aria-haspopup')).toBe('menu');
    w.unmount();
  });

  it('has aria-expanded="false" when closed', () => {
    const w = mountMenu({ open: false });
    const btn = w.find('.user-menu__trigger');
    expect(btn.attributes('aria-expanded')).toBe('false');
    w.unmount();
  });

  it('has aria-expanded="true" when open', () => {
    const w = mountMenu({ open: true });
    const btn = w.find('.user-menu__trigger');
    expect(btn.attributes('aria-expanded')).toBe('true');
    w.unmount();
  });
});

// ── Avatar / initials rendering ───────────────────────────────────────────────

describe('UserMenu — avatar rendering', () => {
  it('shows initials when avatarUrl is null', () => {
    const w = mountMenu({ avatarUrl: null, displayName: 'Zara al-Khatib' });
    expect(w.find('.user-menu__avatar-initials').exists()).toBe(true);
    expect(w.find('.user-menu__avatar-img').exists()).toBe(false);
    w.unmount();
  });

  it('shows initials when avatarUrl is empty string', () => {
    const w = mountMenu({ avatarUrl: '', displayName: 'Zara al-Khatib' });
    expect(w.find('.user-menu__avatar-initials').exists()).toBe(true);
    w.unmount();
  });

  it('shows <img> when avatarUrl is provided', () => {
    const w = mountMenu({
      avatarUrl: 'data:image/png;base64,iVBORw0KGgo=',
      displayName: 'Zara al-Khatib',
    });
    expect(w.find('.user-menu__avatar-img').exists()).toBe(true);
    expect(w.find('.user-menu__avatar-initials').exists()).toBe(false);
    w.unmount();
  });
});

// ── Initials helper ───────────────────────────────────────────────────────────

describe('UserMenu — initials helper', () => {
  it('produces "Z" for a single-word name', () => {
    const w = mountMenu({ avatarUrl: null, displayName: 'Zara' });
    expect(w.find('.user-menu__avatar-initials').text()).toBe('Z');
    w.unmount();
  });

  it('produces "ZK" for a two-word name', () => {
    const w = mountMenu({ avatarUrl: null, displayName: 'Zara Khatib' });
    expect(w.find('.user-menu__avatar-initials').text()).toBe('ZK');
    w.unmount();
  });

  it('caps at 2 chars for a three-word name', () => {
    const w = mountMenu({ avatarUrl: null, displayName: 'Zara al-Khatib' });
    // "Zara" → Z, "al-Khatib" → a → "ZA"
    expect(w.find('.user-menu__avatar-initials').text()).toHaveLength(2);
    w.unmount();
  });

  it('returns "?" for an empty displayName', () => {
    const w = mountMenu({ avatarUrl: null, displayName: '' });
    expect(w.find('.user-menu__avatar-initials').text()).toBe('?');
    w.unmount();
  });

  it('returns "?" for a whitespace-only displayName', () => {
    const w = mountMenu({ avatarUrl: null, displayName: '   ' });
    expect(w.find('.user-menu__avatar-initials').text()).toBe('?');
    w.unmount();
  });
});

// ── Trigger click emits update:open ──────────────────────────────────────────

describe('UserMenu — trigger click', () => {
  it('emits update:open=true when clicking the trigger while closed', async () => {
    const w = mountMenu({ open: false });
    await w.find('.user-menu__trigger').trigger('click');
    const emitted = w.emitted('update:open') as boolean[][];
    expect(emitted).toBeDefined();
    expect(emitted[0]).toEqual([true]);
    w.unmount();
  });

  it('emits update:open=false when clicking the trigger while open', async () => {
    const w = mountMenu({ open: true });
    await w.find('.user-menu__trigger').trigger('click');
    const emitted = w.emitted('update:open') as boolean[][];
    expect(emitted).toBeDefined();
    expect(emitted[0]).toEqual([false]);
    w.unmount();
  });
});

// ── Menu panel role & orientation ────────────────────────────────────────────

describe('UserMenu — menu panel', () => {
  it('renders the menu panel with role="menu" and aria-orientation="vertical" when open', () => {
    const w = mountMenu({ open: true });
    const panel = w.find('[role="menu"]');
    expect(panel.exists()).toBe(true);
    expect(panel.attributes('aria-orientation')).toBe('vertical');
    w.unmount();
  });

  it('does not render the menu panel when closed', () => {
    const w = mountMenu({ open: false });
    expect(w.find('[role="menu"]').exists()).toBe(false);
    w.unmount();
  });
});

// ── Locale items as menuitemradio ─────────────────────────────────────────────

describe('UserMenu — locale items', () => {
  it('renders each locale as role="menuitemradio"', () => {
    const w = mountMenu({ open: true });
    const radios = w.findAll('[role="menuitemradio"]');
    expect(radios).toHaveLength(LOCALES.length);
    w.unmount();
  });

  it('sets aria-checked="true" for the current locale only', () => {
    const w = mountMenu({ open: true, currentLocale: 'ru' });
    const radios = w.findAll('[role="menuitemradio"]');
    const checked = radios.filter((r) => r.attributes('aria-checked') === 'true');
    const unchecked = radios.filter((r) => r.attributes('aria-checked') === 'false');
    expect(checked).toHaveLength(1);
    expect(unchecked).toHaveLength(LOCALES.length - 1);
    expect(checked[0]?.text()).toContain('Русский');
    w.unmount();
  });

  it('emits language-change with new code AND update:open=false when clicking a non-current locale', async () => {
    const w = mountMenu({ open: true, currentLocale: 'en' });
    const radios = w.findAll('[role="menuitemradio"]');
    // Click 'ru' locale (index 1)
    await radios[1]?.trigger('click');
    const langEmitted = w.emitted('language-change') as string[][];
    const openEmitted = w.emitted('update:open') as boolean[][];
    expect(langEmitted).toBeDefined();
    expect(langEmitted[0]).toEqual(['ru']);
    expect(openEmitted).toBeDefined();
    expect(openEmitted[0]).toEqual([false]);
    w.unmount();
  });

  /**
   * Spec choice: clicking the current locale closes the menu (update:open=false)
   * but does NOT emit language-change — the language did not change.
   */
  it('does NOT emit language-change but DOES emit update:open=false when clicking the current locale', async () => {
    const w = mountMenu({ open: true, currentLocale: 'en' });
    const radios = w.findAll('[role="menuitemradio"]');
    // Click 'en' locale (index 0) — same as currentLocale
    await radios[0]?.trigger('click');
    expect(w.emitted('language-change')).toBeUndefined();
    const openEmitted = w.emitted('update:open') as boolean[][];
    expect(openEmitted).toBeDefined();
    expect(openEmitted[0]).toEqual([false]);
    w.unmount();
  });
});

// ── Settings and sign-out ─────────────────────────────────────────────────────

describe('UserMenu — Settings and Sign out', () => {
  it('clicking Settings emits settings-click AND update:open=false', async () => {
    const w = mountMenu({ open: true });
    const settingsBtn = w.findAll('[role="menuitem"]').find((el) =>
      el.text().includes('Settings'),
    );
    expect(settingsBtn).toBeDefined();
    await settingsBtn!.trigger('click');
    expect(w.emitted('settings-click')).toBeDefined();
    const openEmitted = w.emitted('update:open') as boolean[][];
    expect(openEmitted[0]).toEqual([false]);
    w.unmount();
  });

  it('clicking Sign out emits sign-out-click AND update:open=false', async () => {
    const w = mountMenu({ open: true });
    const signOutBtn = w.findAll('[role="menuitem"]').find((el) =>
      el.text().includes('Sign out'),
    );
    expect(signOutBtn).toBeDefined();
    await signOutBtn!.trigger('click');
    expect(w.emitted('sign-out-click')).toBeDefined();
    const openEmitted = w.emitted('update:open') as boolean[][];
    expect(openEmitted[0]).toEqual([false]);
    w.unmount();
  });
});

// ── ESC closes the menu ───────────────────────────────────────────────────────

describe('UserMenu — ESC key', () => {
  it('emits update:open=false on Escape when open (via AppPopover delegation)', async () => {
    const w = mountMenu({ open: true });
    // AppPopover listens on document; simulate that.
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
    await w.vm.$nextTick();
    const openEmitted = w.emitted('update:open') as boolean[][];
    expect(openEmitted).toBeDefined();
    expect(openEmitted[0]).toEqual([false]);
    w.unmount();
  });
});

// ── ArrowDown moves focus ─────────────────────────────────────────────────────

/**
 * Helper: returns menu items in DOM order using the same querySelectorAll
 * selector as the component's getMenuItems() function. This avoids the
 * findAll()-with-compound-selector ordering issue in Vue Test Utils.
 */
function getMenuItemsFromPanel(w: ReturnType<typeof mountMenu>): HTMLElement[] {
  const panel = w.find('[role="menu"]').element;
  return [
    ...panel.querySelectorAll<HTMLElement>(
      '[role="menuitem"], [role="menuitemradio"]',
    ),
  ];
}

describe('UserMenu — keyboard navigation', () => {
  it('ArrowDown from the first item moves focus to the second item', async () => {
    const w = mountMenu({ open: true });
    const panel = w.find('[role="menu"]');
    const items = getMenuItemsFromPanel(w);

    // Focus the first item (await nextTick so the open-watcher's auto-focus
    // has already fired and we can override it cleanly).
    await nextTick();
    items[0]?.focus();
    expect(document.activeElement).toBe(items[0]);

    // Dispatch ArrowDown on the panel
    await panel.trigger('keydown', { key: 'ArrowDown' });

    expect(document.activeElement).toBe(items[1]);
    w.unmount();
  });

  it('ArrowUp from the second item moves focus to the first item', async () => {
    const w = mountMenu({ open: true });
    const panel = w.find('[role="menu"]');
    const items = getMenuItemsFromPanel(w);

    await nextTick();
    items[1]?.focus();
    await panel.trigger('keydown', { key: 'ArrowUp' });
    expect(document.activeElement).toBe(items[0]);
    w.unmount();
  });

  it('Home moves focus to the first item regardless of current position', async () => {
    const w = mountMenu({ open: true });
    const panel = w.find('[role="menu"]');
    const items = getMenuItemsFromPanel(w);
    const last = items.at(-1);

    await nextTick();
    last?.focus();
    await panel.trigger('keydown', { key: 'Home' });
    expect(document.activeElement).toBe(items[0]);
    w.unmount();
  });

  it('End moves focus to the last item regardless of current position', async () => {
    const w = mountMenu({ open: true });
    const panel = w.find('[role="menu"]');
    const items = getMenuItemsFromPanel(w);
    const last = items.at(-1);

    await nextTick();
    items[0]?.focus();
    await panel.trigger('keydown', { key: 'End' });
    expect(document.activeElement).toBe(last);
    w.unmount();
  });

  it('ArrowDown wraps from the last item to the first', async () => {
    const w = mountMenu({ open: true });
    const panel = w.find('[role="menu"]');
    const items = getMenuItemsFromPanel(w);
    const last = items.at(-1);

    await nextTick();
    last?.focus();
    await panel.trigger('keydown', { key: 'ArrowDown' });
    expect(document.activeElement).toBe(items[0]);
    w.unmount();
  });
});

// ── Display name rendered in trigger ─────────────────────────────────────────

describe('UserMenu — display name', () => {
  it('renders the displayName inside the trigger', () => {
    const w = mountMenu({ displayName: 'Ibrahim al-Sayed' });
    expect(w.find('.user-menu__name').text()).toBe('Ibrahim al-Sayed');
    w.unmount();
  });
});
