import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppBadge from './AppBadge.vue';

const VARIANTS = ['brass', 'mystic', 'crimson', 'success', 'darkness'] as const;
const SIZES = ['sm', 'md'] as const;

describe('AppBadge', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a <span> root element', () => {
    const wrapper = mount(AppBadge);
    expect(wrapper.element.tagName).toBe('SPAN');
  });

  it('applies the app-badge base class', () => {
    const wrapper = mount(AppBadge);
    expect(wrapper.classes()).toContain('app-badge');
  });

  // ── Variant BEM modifiers ─────────────────────────────────────────────────

  it.each(VARIANTS)('applies app-badge--%s modifier for variant=%s', (variant) => {
    const wrapper = mount(AppBadge, { props: { variant } });
    expect(wrapper.classes()).toContain(`app-badge--${variant}`);
  });

  it('defaults to variant=brass', () => {
    const wrapper = mount(AppBadge);
    expect(wrapper.classes()).toContain('app-badge--brass');
  });

  // ── Size BEM modifiers ────────────────────────────────────────────────────

  it.each(SIZES)('applies app-badge--%s modifier for size=%s', (size) => {
    const wrapper = mount(AppBadge, { props: { size } });
    expect(wrapper.classes()).toContain(`app-badge--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppBadge);
    expect(wrapper.classes()).toContain('app-badge--md');
  });

  // ── Default slot ──────────────────────────────────────────────────────────

  it('renders default slot content', () => {
    const wrapper = mount(AppBadge, { slots: { default: 'Wounded' } });
    expect(wrapper.text()).toContain('Wounded');
  });

  // ── Icon slot ─────────────────────────────────────────────────────────────

  it('renders the icon slot wrapper when icon slot is provided', () => {
    const wrapper = mount(AppBadge, {
      slots: { icon: '<svg data-testid="icon" />' },
    });
    expect(wrapper.find('.app-badge__icon').exists()).toBe(true);
  });

  it('does not render the icon slot wrapper when icon slot is absent', () => {
    const wrapper = mount(AppBadge);
    expect(wrapper.find('.app-badge__icon').exists()).toBe(false);
  });

  // ── No variant + size class collision ────────────────────────────────────

  it('applies exactly one variant class', () => {
    const wrapper = mount(AppBadge, { props: { variant: 'crimson' } });
    const variantClasses = wrapper.classes().filter((c) => c.startsWith('app-badge--') && VARIANTS.some((v) => c.endsWith(v)));
    expect(variantClasses).toHaveLength(1);
    expect(variantClasses[0]).toBe('app-badge--crimson');
  });

  it('applies exactly one size class', () => {
    const wrapper = mount(AppBadge, { props: { size: 'sm' } });
    const sizeClasses = wrapper.classes().filter((c) => SIZES.some((s) => c === `app-badge--${s}`));
    expect(sizeClasses).toHaveLength(1);
    expect(sizeClasses[0]).toBe('app-badge--sm');
  });
});
