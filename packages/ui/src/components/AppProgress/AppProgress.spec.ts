import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppProgress from './AppProgress.vue';

const TONES = ['brass', 'mystic', 'crimson', 'success', 'darkness'] as const;
const SIZES = ['sm', 'md', 'lg'] as const;

describe('AppProgress', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a <div> root element', () => {
    const wrapper = mount(AppProgress, { props: { value: 50 } });
    expect(wrapper.element.tagName).toBe('DIV');
  });

  it('applies the app-progress base class', () => {
    const wrapper = mount(AppProgress, { props: { value: 50 } });
    expect(wrapper.classes()).toContain('app-progress');
  });

  // ── Variant ───────────────────────────────────────────────────────────────

  it('applies app-progress--linear class by default', () => {
    const wrapper = mount(AppProgress, { props: { value: 50 } });
    expect(wrapper.classes()).toContain('app-progress--linear');
  });

  it('applies app-progress--linear class when variant="linear"', () => {
    const wrapper = mount(AppProgress, { props: { value: 50, variant: 'linear' } });
    expect(wrapper.classes()).toContain('app-progress--linear');
  });

  // ── ARIA ──────────────────────────────────────────────────────────────────

  it('sets role="progressbar" on the root element', () => {
    const wrapper = mount(AppProgress, { props: { value: 50 } });
    expect(wrapper.attributes('role')).toBe('progressbar');
  });

  it('sets aria-valuenow to clamped value', () => {
    const wrapper = mount(AppProgress, { props: { value: 60, max: 100 } });
    expect(wrapper.attributes('aria-valuenow')).toBe('60');
  });

  it('sets aria-valuemin to min prop', () => {
    const wrapper = mount(AppProgress, { props: { value: 50, min: 0 } });
    expect(wrapper.attributes('aria-valuemin')).toBe('0');
  });

  it('sets aria-valuemin to non-zero min prop', () => {
    const wrapper = mount(AppProgress, { props: { value: 15, min: 10, max: 20 } });
    expect(wrapper.attributes('aria-valuemin')).toBe('10');
  });

  it('sets aria-valuemax to max prop', () => {
    const wrapper = mount(AppProgress, { props: { value: 50, max: 200 } });
    expect(wrapper.attributes('aria-valuemax')).toBe('200');
  });

  it('sets aria-label when label prop is provided', () => {
    const wrapper = mount(AppProgress, { props: { value: 50, label: 'Hit Points' } });
    expect(wrapper.attributes('aria-label')).toBe('Hit Points');
  });

  it('omits aria-label when label prop is absent', () => {
    const wrapper = mount(AppProgress, { props: { value: 50 } });
    expect(wrapper.attributes('aria-label')).toBeUndefined();
  });

  // ── Clamping ──────────────────────────────────────────────────────────────

  it('clamps value above max and sets aria-valuenow to max', () => {
    const wrapper = mount(AppProgress, { props: { value: 999, max: 100 } });
    expect(wrapper.attributes('aria-valuenow')).toBe('100');
  });

  it('clamps value below min and sets aria-valuenow to min', () => {
    const wrapper = mount(AppProgress, { props: { value: -10, min: 0, max: 100 } });
    expect(wrapper.attributes('aria-valuenow')).toBe('0');
  });

  it('clamps value below non-zero min', () => {
    const wrapper = mount(AppProgress, { props: { value: 5, min: 10, max: 20 } });
    expect(wrapper.attributes('aria-valuenow')).toBe('10');
  });

  it('clamps value above max when max is non-default', () => {
    const wrapper = mount(AppProgress, { props: { value: 25, max: 14 } });
    expect(wrapper.attributes('aria-valuenow')).toBe('14');
  });

  // ── Percentage / fill width ───────────────────────────────────────────────

  it('computes 50% fill when value is half of max', () => {
    const wrapper = mount(AppProgress, { props: { value: 50, max: 100 } });
    const fill = wrapper.find('.app-progress__fill');
    expect(fill.attributes('style')).toContain('width: 50%');
  });

  it('computes 0% fill when value equals min', () => {
    const wrapper = mount(AppProgress, { props: { value: 0, max: 100 } });
    const fill = wrapper.find('.app-progress__fill');
    expect(fill.attributes('style')).toContain('width: 0%');
  });

  it('computes 100% fill when value equals max', () => {
    const wrapper = mount(AppProgress, { props: { value: 100, max: 100 } });
    const fill = wrapper.find('.app-progress__fill');
    expect(fill.attributes('style')).toContain('width: 100%');
  });

  it('computes correct percentage for non-zero min range', () => {
    // value=15, min=10, max=20 → (15-10)/(20-10) = 50%
    const wrapper = mount(AppProgress, { props: { value: 15, min: 10, max: 20 } });
    const fill = wrapper.find('.app-progress__fill');
    expect(fill.attributes('style')).toContain('width: 50%');
  });

  it('renders track and fill elements', () => {
    const wrapper = mount(AppProgress, { props: { value: 50 } });
    expect(wrapper.find('.app-progress__track').exists()).toBe(true);
    expect(wrapper.find('.app-progress__fill').exists()).toBe(true);
  });

  // ── BEM: tone modifiers ───────────────────────────────────────────────────

  it.each(TONES)('applies app-progress--%s modifier for tone=%s', (tone) => {
    const wrapper = mount(AppProgress, { props: { value: 50, tone } });
    expect(wrapper.classes()).toContain(`app-progress--${tone}`);
  });

  it('defaults to tone=brass', () => {
    const wrapper = mount(AppProgress, { props: { value: 50 } });
    expect(wrapper.classes()).toContain('app-progress--brass');
  });

  it('applies exactly one tone class', () => {
    const wrapper = mount(AppProgress, { props: { value: 50, tone: 'crimson' } });
    const toneClasses = wrapper
      .classes()
      .filter((c) => TONES.some((t) => c === `app-progress--${t}`));
    expect(toneClasses).toHaveLength(1);
    expect(toneClasses[0]).toBe('app-progress--crimson');
  });

  // ── BEM: size modifiers ───────────────────────────────────────────────────

  it.each(SIZES)('applies app-progress--%s modifier for size=%s', (size) => {
    const wrapper = mount(AppProgress, { props: { value: 50, size } });
    expect(wrapper.classes()).toContain(`app-progress--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppProgress, { props: { value: 50 } });
    expect(wrapper.classes()).toContain('app-progress--md');
  });

  it('applies exactly one size class', () => {
    const wrapper = mount(AppProgress, { props: { value: 50, size: 'lg' } });
    const sizeClasses = wrapper
      .classes()
      .filter((c) => SIZES.some((s) => c === `app-progress--${s}`));
    expect(sizeClasses).toHaveLength(1);
    expect(sizeClasses[0]).toBe('app-progress--lg');
  });

  // ── showLabel ─────────────────────────────────────────────────────────────

  it('does not render label element by default', () => {
    const wrapper = mount(AppProgress, { props: { value: 12, max: 14 } });
    expect(wrapper.find('.app-progress__label').exists()).toBe(false);
  });

  it('renders label element when showLabel=true', () => {
    const wrapper = mount(AppProgress, { props: { value: 12, max: 14, showLabel: true } });
    expect(wrapper.find('.app-progress__label').exists()).toBe(true);
  });

  it('renders "value / max" text in label', () => {
    const wrapper = mount(AppProgress, { props: { value: 12, max: 14, showLabel: true } });
    expect(wrapper.find('.app-progress__label').text()).toBe('12 / 14');
  });

  it('renders clamped value in label when value exceeds max', () => {
    const wrapper = mount(AppProgress, { props: { value: 99, max: 14, showLabel: true } });
    expect(wrapper.find('.app-progress__label').text()).toBe('14 / 14');
  });
});
