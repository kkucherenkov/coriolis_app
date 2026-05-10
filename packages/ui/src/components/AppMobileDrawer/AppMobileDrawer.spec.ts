import { mount } from '@vue/test-utils';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import AppMobileDrawer from './AppMobileDrawer.vue';
import type { DrawerLabels, Props } from './AppMobileDrawer.vue';

// ── Fixtures ───────────────────────────────────────────────────────────────────

const LABELS: DrawerLabels = {
  ariaLabel: 'Navigation menu',
  closeAriaLabel: 'Close menu',
};

function mountDrawer(overrides: Partial<Props> = {}, slots: Record<string, string> = {}) {
  return mount(AppMobileDrawer, {
    props: {
      open: false,
      labels: LABELS,
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

// ── Closed state ───────────────────────────────────────────────────────────────

describe('AppMobileDrawer — closed state', () => {
  it('renders nothing when open=false', () => {
    const w = mountDrawer({ open: false });
    expect(w.find('[role="dialog"]').exists()).toBe(false);
    w.unmount();
  });
});

// ── Open state: dialog attributes ─────────────────────────────────────────────

describe('AppMobileDrawer — open state', () => {
  it('renders the dialog with role="dialog" and aria-modal="true" when open', () => {
    const w = mountDrawer({ open: true });
    const dialog = document.querySelector('[role="dialog"]');
    expect(dialog).not.toBeNull();
    expect(dialog?.getAttribute('aria-modal')).toBe('true');
    w.unmount();
  });

  it('aria-label matches labels.ariaLabel', () => {
    const w = mountDrawer({ open: true });
    const dialog = document.querySelector('[role="dialog"]');
    expect(dialog?.getAttribute('aria-label')).toBe(LABELS.ariaLabel);
    w.unmount();
  });
});

// ── Side prop ──────────────────────────────────────────────────────────────────

describe('AppMobileDrawer — side prop', () => {
  it('defaults to side="left" (applies left modifier class to overlay)', () => {
    const w = mountDrawer({ open: true });
    const overlay = document.querySelector('.app-mobile-drawer');
    expect(overlay?.classList.contains('app-mobile-drawer--left')).toBe(true);
    w.unmount();
  });

  it('side="right" applies the right-side modifier class', () => {
    const w = mountDrawer({ open: true, side: 'right' });
    const overlay = document.querySelector('.app-mobile-drawer');
    expect(overlay?.classList.contains('app-mobile-drawer--right')).toBe(true);
    w.unmount();
  });
});

// ── Overlay and close-button events ───────────────────────────────────────────

describe('AppMobileDrawer — close events', () => {
  it('overlay click emits update:open: false', async () => {
    const w = mountDrawer({ open: true });
    // Click directly on the overlay element (not the panel).
    const overlay = document.querySelector<HTMLElement>('.app-mobile-drawer');
    expect(overlay).not.toBeNull();
    // Simulate click on the overlay itself (target === currentTarget).
    overlay!.click();
    await w.vm.$nextTick();
    expect(w.emitted('update:open')).toBeTruthy();
    expect(w.emitted('update:open')![0]).toEqual([false]);
    w.unmount();
  });

  it('close button click emits update:open: false', async () => {
    const w = mountDrawer({ open: true });
    const closeBtn = document.querySelector<HTMLElement>('.app-mobile-drawer__close');
    expect(closeBtn).not.toBeNull();
    closeBtn!.click();
    await w.vm.$nextTick();
    expect(w.emitted('update:open')).toBeTruthy();
    expect(w.emitted('update:open')![0]).toEqual([false]);
    w.unmount();
  });

  it('ESC key emits update:open: false', async () => {
    const w = mountDrawer({ open: true });
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
    await w.vm.$nextTick();
    expect(w.emitted('update:open')).toBeTruthy();
    expect(w.emitted('update:open')![0]).toEqual([false]);
    w.unmount();
  });
});

// ── Default slot ───────────────────────────────────────────────────────────────

describe('AppMobileDrawer — default slot', () => {
  it('renders default slot content inside the panel', () => {
    const w = mountDrawer({ open: true }, { default: '<a href="/characters">Characters</a>' });
    const link = document.querySelector('a[href="/characters"]');
    expect(link).not.toBeNull();
    expect(link?.textContent).toContain('Characters');
    w.unmount();
  });
});

// ── Focus management ───────────────────────────────────────────────────────────

describe('AppMobileDrawer — focus management', () => {
  it('focuses the close button when open (first focusable element)', async () => {
    const w = mountDrawer({ open: true });
    await w.vm.$nextTick();
    const closeBtn = document.querySelector('.app-mobile-drawer__close');
    expect(document.activeElement).toBe(closeBtn);
    w.unmount();
  });

  it('Tab on the last focusable element wraps focus back to the close button (focus trap)', async () => {
    const w = mountDrawer({ open: true }, { default: '<button id="last-btn">Last</button>' });
    await w.vm.$nextTick();

    const closeBtn = document.querySelector<HTMLElement>('.app-mobile-drawer__close');
    const lastBtn = document.querySelector<HTMLElement>('#last-btn');
    expect(closeBtn).not.toBeNull();
    expect(lastBtn).not.toBeNull();

    // Simulate focus on the last button, then Tab.
    lastBtn!.focus();
    const tabEvent = new KeyboardEvent('keydown', { key: 'Tab', bubbles: true, cancelable: true });
    const panel = document.querySelector<HTMLElement>('.app-mobile-drawer__panel');
    panel!.dispatchEvent(tabEvent);
    await w.vm.$nextTick();

    expect(document.activeElement).toBe(closeBtn);
    w.unmount();
  });
});

// ── Body scroll-lock ───────────────────────────────────────────────────────────

describe('AppMobileDrawer — body scroll-lock', () => {
  beforeEach(() => {
    document.body.style.overflow = '';
  });

  afterEach(() => {
    document.body.style.overflow = '';
  });

  it('locks body overflow when open', async () => {
    const w = mountDrawer({ open: true });
    await w.vm.$nextTick();
    expect(document.body.style.overflow).toBe('hidden');
    w.unmount();
  });

  it('restores body overflow when closed', async () => {
    document.body.style.overflow = 'auto';
    const w = mountDrawer({ open: true });
    await w.vm.$nextTick();
    expect(document.body.style.overflow).toBe('hidden');
    await w.setProps({ open: false });
    await w.vm.$nextTick();
    expect(document.body.style.overflow).toBe('auto');
    w.unmount();
  });

  it('restores body overflow on unmount while open', async () => {
    document.body.style.overflow = 'scroll';
    const w = mountDrawer({ open: true });
    await w.vm.$nextTick();
    expect(document.body.style.overflow).toBe('hidden');
    w.unmount();
    expect(document.body.style.overflow).toBe('scroll');
  });

  it('does not lock body overflow when closed', () => {
    document.body.style.overflow = '';
    const w = mountDrawer({ open: false });
    expect(document.body.style.overflow).toBe('');
    w.unmount();
  });
});

// ── No console warnings ────────────────────────────────────────────────────────

describe('AppMobileDrawer — rendering stability', () => {
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

  it('emits no Vue warnings or errors on mount and unmount', async () => {
    const w = mountDrawer({ open: true });
    await w.vm.$nextTick();
    w.unmount();
    expect(consoleWarnSpy).not.toHaveBeenCalled();
    expect(consoleErrorSpy).not.toHaveBeenCalled();
  });
});
