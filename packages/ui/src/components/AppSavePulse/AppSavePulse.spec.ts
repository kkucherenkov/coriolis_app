import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

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
});
