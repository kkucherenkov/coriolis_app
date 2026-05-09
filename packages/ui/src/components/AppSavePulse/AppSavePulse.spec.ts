import { mount } from '@vue/test-utils';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import AppSavePulse from './AppSavePulse.vue';

describe('AppSavePulse', () => {
  // ── Default render ────────────────────────────────────────────────────────

  it('renders a dot element', () => {
    const wrapper = mount(AppSavePulse, { props: { state: 'idle' } });
    expect(wrapper.find('.app-save-pulse__dot').exists()).toBe(true);
  });

  it('is aria-hidden (decorative — sr-only sibling carries the label)', () => {
    const wrapper = mount(AppSavePulse, { props: { state: 'idle' } });
    const root = wrapper.find('.app-save-pulse');
    expect(root.attributes('aria-hidden')).toBe('true');
  });

  // ── BEM class per state ───────────────────────────────────────────────────

  it.each(['idle', 'saving', 'saved', 'error'] as const)(
    'applies modifier class app-save-pulse--%s',
    (state) => {
      const wrapper = mount(AppSavePulse, { props: { state } });
      expect(wrapper.find(`.app-save-pulse--${state}`).exists()).toBe(true);
    },
  );

  // ── Only one state modifier at a time ─────────────────────────────────────

  it('applies exactly one state modifier at a time', () => {
    const wrapper = mount(AppSavePulse, { props: { state: 'saving' } });
    const root = wrapper.find('.app-save-pulse');
    const classList = [...(root.element as HTMLElement).classList];
    const stateModifiers = classList.filter((c) =>
      /^app-save-pulse--(idle|saving|saved|error)$/.test(c),
    );
    expect(stateModifiers).toHaveLength(1);
    expect(stateModifiers[0]).toBe('app-save-pulse--saving');
  });

  // ── Prop update re-applies class ──────────────────────────────────────────

  it('switches class when state prop changes', async () => {
    const wrapper = mount(AppSavePulse, { props: { state: 'idle' } });
    expect(wrapper.find('.app-save-pulse--idle').exists()).toBe(true);

    await wrapper.setProps({ state: 'saved' });
    expect(wrapper.find('.app-save-pulse--idle').exists()).toBe(false);
    expect(wrapper.find('.app-save-pulse--saved').exists()).toBe(true);
  });

  // ── Reduced-motion awareness ───────────────────────────────────────────────
  // The CSS @media (prefers-reduced-motion: reduce) block swaps the spin
  // animation for a fade-only animation. JSDOM does not parse scoped styles,
  // so we verify the structural guarantee: the saving state renders a dot
  // element that can receive the fade animation class — i.e., the component
  // renders correctly in all states and does not crash with a mocked
  // matchMedia that returns reduce.

  describe('reduced-motion (matchMedia mock)', () => {
    let originalMatchMedia: typeof globalThis.matchMedia;

    beforeEach(() => {
      originalMatchMedia = globalThis.matchMedia;
      // Mock matchMedia to report prefers-reduced-motion: reduce.
      globalThis.matchMedia = vi.fn().mockImplementation((query: string) => ({
        matches: query === '(prefers-reduced-motion: reduce)',
        media: query,
        onchange: null,
        addListener: vi.fn(),
        removeListener: vi.fn(),
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        dispatchEvent: vi.fn(),
      }));
    });

    afterEach(() => {
      globalThis.matchMedia = originalMatchMedia;
    });

    it('renders saving state dot without throwing under reduce preference', () => {
      const wrapper = mount(AppSavePulse, { props: { state: 'saving' } });
      // Component must still render the dot — CSS reduces animation, not the DOM.
      expect(wrapper.find('.app-save-pulse__dot').exists()).toBe(true);
      expect(wrapper.find('.app-save-pulse--saving').exists()).toBe(true);
    });

    it('has a saving modifier when matchMedia reports reduce', () => {
      const wrapper = mount(AppSavePulse, { props: { state: 'saving' } });
      // The component structure is unchanged; the CSS media query handles animation.
      const root = wrapper.find('.app-save-pulse');
      expect(root.exists()).toBe(true);
      expect(globalThis.matchMedia('(prefers-reduced-motion: reduce)').matches).toBe(true);
    });
  });
});
