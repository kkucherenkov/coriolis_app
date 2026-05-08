import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppTab from './AppTab.vue';

const SIZES = ['sm', 'md'] as const;
const TONES = ['brass', 'mystic'] as const;

describe('AppTab', () => {
  // ── Root element ─────────────────────────────────────────────────────────

  it('renders a <button> root element', () => {
    const wrapper = mount(AppTab, { slots: { default: 'Stats' } });
    expect(wrapper.element.tagName).toBe('BUTTON');
  });

  it('has type="button" on the root element', () => {
    const wrapper = mount(AppTab, { slots: { default: 'Stats' } });
    expect(wrapper.attributes('type')).toBe('button');
  });

  it('has role="tab" on the root element', () => {
    const wrapper = mount(AppTab, { slots: { default: 'Stats' } });
    expect(wrapper.attributes('role')).toBe('tab');
  });

  it('applies the app-tab base class', () => {
    const wrapper = mount(AppTab, { slots: { default: 'Stats' } });
    expect(wrapper.classes()).toContain('app-tab');
  });

  // ── aria-selected ─────────────────────────────────────────────────────────

  it('sets aria-selected="true" when active is true', () => {
    const wrapper = mount(AppTab, { props: { active: true }, slots: { default: 'Stats' } });
    expect(wrapper.attributes('aria-selected')).toBe('true');
  });

  it('sets aria-selected="false" when active is false', () => {
    const wrapper = mount(AppTab, { props: { active: false }, slots: { default: 'Stats' } });
    expect(wrapper.attributes('aria-selected')).toBe('false');
  });

  it('defaults to aria-selected="false"', () => {
    const wrapper = mount(AppTab, { slots: { default: 'Stats' } });
    expect(wrapper.attributes('aria-selected')).toBe('false');
  });

  // ── tabindex ──────────────────────────────────────────────────────────────

  it('has tabindex="0" when active', () => {
    const wrapper = mount(AppTab, { props: { active: true }, slots: { default: 'Stats' } });
    expect(wrapper.attributes('tabindex')).toBe('0');
  });

  it('has tabindex="-1" when inactive', () => {
    const wrapper = mount(AppTab, { props: { active: false }, slots: { default: 'Stats' } });
    expect(wrapper.attributes('tabindex')).toBe('-1');
  });

  // ── BEM: active modifier ──────────────────────────────────────────────────

  it('applies app-tab--active class when active is true', () => {
    const wrapper = mount(AppTab, { props: { active: true }, slots: { default: 'Stats' } });
    expect(wrapper.classes()).toContain('app-tab--active');
  });

  it('does not apply app-tab--active class when active is false', () => {
    const wrapper = mount(AppTab, { props: { active: false }, slots: { default: 'Stats' } });
    expect(wrapper.classes()).not.toContain('app-tab--active');
  });

  // ── BEM: size modifiers ───────────────────────────────────────────────────

  it.each(SIZES)('applies app-tab--%s modifier for size=%s', (size) => {
    const wrapper = mount(AppTab, { props: { size }, slots: { default: 'x' } });
    expect(wrapper.classes()).toContain(`app-tab--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppTab, { slots: { default: 'x' } });
    expect(wrapper.classes()).toContain('app-tab--md');
  });

  it('applies exactly one size class', () => {
    const wrapper = mount(AppTab, { props: { size: 'sm' }, slots: { default: 'x' } });
    const sizeClasses = wrapper.classes().filter((c) => SIZES.some((s) => c === `app-tab--${s}`));
    expect(sizeClasses).toHaveLength(1);
    expect(sizeClasses[0]).toBe('app-tab--sm');
  });

  // ── BEM: tone modifiers ───────────────────────────────────────────────────

  it.each(TONES)('applies app-tab--%s modifier for tone=%s', (tone) => {
    const wrapper = mount(AppTab, { props: { tone }, slots: { default: 'x' } });
    expect(wrapper.classes()).toContain(`app-tab--${tone}`);
  });

  it('defaults to tone=brass', () => {
    const wrapper = mount(AppTab, { slots: { default: 'x' } });
    expect(wrapper.classes()).toContain('app-tab--brass');
  });

  it('applies exactly one tone class', () => {
    const wrapper = mount(AppTab, { props: { tone: 'mystic' }, slots: { default: 'x' } });
    const toneClasses = wrapper
      .classes()
      .filter((c) => TONES.some((t) => c === `app-tab--${t}`));
    expect(toneClasses).toHaveLength(1);
    expect(toneClasses[0]).toBe('app-tab--mystic');
  });

  // ── BEM: disabled modifier ────────────────────────────────────────────────

  it('applies app-tab--disabled class when disabled', () => {
    const wrapper = mount(AppTab, { props: { disabled: true }, slots: { default: 'x' } });
    expect(wrapper.classes()).toContain('app-tab--disabled');
  });

  it('has the disabled attribute when disabled', () => {
    const wrapper = mount(AppTab, { props: { disabled: true }, slots: { default: 'x' } });
    expect(wrapper.attributes('disabled')).toBeDefined();
  });

  // ── Emit: click ───────────────────────────────────────────────────────────

  it('emits click when clicked while enabled', async () => {
    const wrapper = mount(AppTab, { props: { active: false }, slots: { default: 'Stats' } });
    await wrapper.trigger('click');
    expect(wrapper.emitted('click')).toHaveLength(1);
  });

  it('does not emit click when disabled', async () => {
    const wrapper = mount(AppTab, {
      props: { active: false, disabled: true },
      slots: { default: 'Stats' },
    });
    await wrapper.trigger('click');
    expect(wrapper.emitted('click')).toBeUndefined();
  });

  // ── Slots ─────────────────────────────────────────────────────────────────

  it('renders default slot content inside __label', () => {
    const wrapper = mount(AppTab, { slots: { default: 'Inventory' } });
    expect(wrapper.find('.app-tab__label').text()).toContain('Inventory');
  });

  it('renders icon-leading slot inside __icon when provided', () => {
    const wrapper = mount(AppTab, {
      slots: {
        default: 'Stats',
        'icon-leading': '<span class="test-icon">★</span>',
      },
    });
    expect(wrapper.find('.app-tab__icon').exists()).toBe(true);
    expect(wrapper.find('.app-tab__icon .test-icon').exists()).toBe(true);
  });

  it('does not render __icon element when icon-leading slot is absent', () => {
    const wrapper = mount(AppTab, { slots: { default: 'Stats' } });
    expect(wrapper.find('.app-tab__icon').exists()).toBe(false);
  });
});
