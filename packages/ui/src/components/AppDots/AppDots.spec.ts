import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppDots from './AppDots.vue';

const TONES = ['brass', 'mystic', 'crimson', 'darkness'] as const;
const SIZES = ['sm', 'md', 'lg'] as const;

describe('AppDots', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a <div> root element', () => {
    const wrapper = mount(AppDots, { props: { value: 2 } });
    expect(wrapper.element.tagName).toBe('DIV');
  });

  it('applies the app-dots base class', () => {
    const wrapper = mount(AppDots, { props: { value: 2 } });
    expect(wrapper.classes()).toContain('app-dots');
  });

  // ── Dot count ─────────────────────────────────────────────────────────────

  it('renders max dots total', () => {
    const wrapper = mount(AppDots, { props: { value: 3, max: 5 } });
    const dots = wrapper.findAll('.app-dots__dot');
    expect(dots).toHaveLength(5);
  });

  it('renders max dots when max is non-default', () => {
    const wrapper = mount(AppDots, { props: { value: 4, max: 8 } });
    const dots = wrapper.findAll('.app-dots__dot');
    expect(dots).toHaveLength(8);
  });

  // ── Filled dots ───────────────────────────────────────────────────────────

  it('fills the first value dots', () => {
    const wrapper = mount(AppDots, { props: { value: 3, max: 5 } });
    const filled = wrapper.findAll('.app-dots__dot--filled');
    expect(filled).toHaveLength(3);
  });

  it('fills no dots when value is 0', () => {
    const wrapper = mount(AppDots, { props: { value: 0, max: 5 } });
    const filled = wrapper.findAll('.app-dots__dot--filled');
    expect(filled).toHaveLength(0);
  });

  it('fills all dots when value equals max', () => {
    const wrapper = mount(AppDots, { props: { value: 5, max: 5 } });
    const filled = wrapper.findAll('.app-dots__dot--filled');
    expect(filled).toHaveLength(5);
  });

  // ── Clamping ──────────────────────────────────────────────────────────────

  it('clamps value above max without throwing', () => {
    const wrapper = mount(AppDots, { props: { value: 99, max: 5 } });
    const filled = wrapper.findAll('.app-dots__dot--filled');
    expect(filled).toHaveLength(5);
  });

  it('clamps negative value to 0 without throwing', () => {
    const wrapper = mount(AppDots, { props: { value: -3, max: 5 } });
    const filled = wrapper.findAll('.app-dots__dot--filled');
    expect(filled).toHaveLength(0);
  });

  // ── ARIA ──────────────────────────────────────────────────────────────────

  it('sets role="meter" on the root element', () => {
    const wrapper = mount(AppDots, { props: { value: 2 } });
    expect(wrapper.attributes('role')).toBe('meter');
  });

  it('sets aria-valuenow to clamped value', () => {
    const wrapper = mount(AppDots, { props: { value: 3, max: 5 } });
    expect(wrapper.attributes('aria-valuenow')).toBe('3');
  });

  it('sets aria-valuenow to max when value exceeds max', () => {
    const wrapper = mount(AppDots, { props: { value: 10, max: 5 } });
    expect(wrapper.attributes('aria-valuenow')).toBe('5');
  });

  it('sets aria-valuemin to 0', () => {
    const wrapper = mount(AppDots, { props: { value: 2 } });
    expect(wrapper.attributes('aria-valuemin')).toBe('0');
  });

  it('sets aria-valuemax to max prop', () => {
    const wrapper = mount(AppDots, { props: { value: 2, max: 7 } });
    expect(wrapper.attributes('aria-valuemax')).toBe('7');
  });

  it('sets aria-label when label prop is provided', () => {
    const wrapper = mount(AppDots, { props: { value: 2, label: 'Strength' } });
    expect(wrapper.attributes('aria-label')).toBe('Strength');
  });

  it('omits aria-label when label prop is absent', () => {
    const wrapper = mount(AppDots, { props: { value: 2 } });
    expect(wrapper.attributes('aria-label')).toBeUndefined();
  });

  // ── BEM: tone modifiers ───────────────────────────────────────────────────

  it.each(TONES)('applies app-dots--%s modifier for tone=%s', (tone) => {
    const wrapper = mount(AppDots, { props: { value: 2, tone } });
    expect(wrapper.classes()).toContain(`app-dots--${tone}`);
  });

  it('defaults to tone=brass', () => {
    const wrapper = mount(AppDots, { props: { value: 2 } });
    expect(wrapper.classes()).toContain('app-dots--brass');
  });

  // ── BEM: size modifiers ───────────────────────────────────────────────────

  it.each(SIZES)('applies app-dots--%s modifier for size=%s', (size) => {
    const wrapper = mount(AppDots, { props: { value: 2, size } });
    expect(wrapper.classes()).toContain(`app-dots--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppDots, { props: { value: 2 } });
    expect(wrapper.classes()).toContain('app-dots--md');
  });

  // ── No class collision ────────────────────────────────────────────────────

  it('applies exactly one tone class', () => {
    const wrapper = mount(AppDots, { props: { value: 2, tone: 'crimson' } });
    const toneClasses = wrapper.classes().filter((c) => TONES.some((t) => c === `app-dots--${t}`));
    expect(toneClasses).toHaveLength(1);
    expect(toneClasses[0]).toBe('app-dots--crimson');
  });

  it('applies exactly one size class', () => {
    const wrapper = mount(AppDots, { props: { value: 2, size: 'lg' } });
    const sizeClasses = wrapper.classes().filter((c) => SIZES.some((s) => c === `app-dots--${s}`));
    expect(sizeClasses).toHaveLength(1);
    expect(sizeClasses[0]).toBe('app-dots--lg');
  });
});
