import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppDotInput from './AppDotInput.vue';

const TONES = ['brass', 'mystic', 'crimson', 'darkness'] as const;
const SIZES = ['sm', 'md', 'lg'] as const;

describe('AppDotInput', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a slider role on the root', () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 2 } });
    expect(wrapper.attributes('role')).toBe('slider');
  });

  it('applies the app-dot-input base class', () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 2 } });
    expect(wrapper.classes()).toContain('app-dot-input');
  });

  it('is focusable (tabindex 0) when enabled', () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 2 } });
    expect(wrapper.attributes('tabindex')).toBe('0');
  });

  // ── Dot rendering ───────────────────────────────────────────────────────────

  it('renders max dots total', () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 3, max: 5 } });
    expect(wrapper.findAll('.app-dot-input__dot')).toHaveLength(5);
  });

  it('fills the first value dots', () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 3, max: 5 } });
    expect(wrapper.findAll('.app-dot-input__dot--filled')).toHaveLength(3);
  });

  it('fills no dots when value is 0', () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 0, max: 5 } });
    expect(wrapper.findAll('.app-dot-input__dot--filled')).toHaveLength(0);
  });

  // ── ARIA value ────────────────────────────────────────────────────────────

  it('exposes aria-valuemin / max / now', () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 3, min: 1, max: 5 } });
    expect(wrapper.attributes('aria-valuemin')).toBe('1');
    expect(wrapper.attributes('aria-valuemax')).toBe('5');
    expect(wrapper.attributes('aria-valuenow')).toBe('3');
  });

  it('builds aria-valuetext from the label', () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 3, label: 'Strength' } });
    expect(wrapper.attributes('aria-valuetext')).toBe('Strength: 3');
  });

  // ── Click to set ────────────────────────────────────────────────────────────

  it('sets the value to the clicked dot', async () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 2, max: 5 } });
    await wrapper.findAll('.app-dot-input__hit')[3]!.trigger('click'); // dot 4
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([4]);
  });

  it('steps down by one when clicking the current top dot (star idiom)', async () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 3, max: 5 } });
    await wrapper.findAll('.app-dot-input__hit')[2]!.trigger('click'); // dot 3 == value
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([2]);
  });

  it('can set a lower value by clicking a lower dot', async () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 4, max: 5 } });
    await wrapper.findAll('.app-dot-input__hit')[1]!.trigger('click'); // dot 2
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([2]);
  });

  it('respects min when stepping down past it', async () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 1, min: 1, max: 5 } });
    await wrapper.findAll('.app-dot-input__hit')[0]!.trigger('click'); // dot 1 == value → 0, clamped to 1
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  it('allows skills (min 0) to reach 0', async () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 1, min: 0, max: 5 } });
    await wrapper.findAll('.app-dot-input__hit')[0]!.trigger('click'); // dot 1 == value → 0
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([0]);
  });

  // ── Keyboard ──────────────────────────────────────────────────────────────

  it('increments on ArrowRight / ArrowUp', async () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 2, max: 5 } });
    await wrapper.trigger('keydown', { key: 'ArrowRight' });
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([3]);
  });

  it('decrements on ArrowLeft / ArrowDown', async () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 2, max: 5 } });
    await wrapper.trigger('keydown', { key: 'ArrowDown' });
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([1]);
  });

  it('jumps to min on Home and max on End', async () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 2, min: 1, max: 5 } });
    await wrapper.trigger('keydown', { key: 'Home' });
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([1]);
    await wrapper.trigger('keydown', { key: 'End' });
    expect(wrapper.emitted('update:modelValue')?.[1]).toEqual([5]);
  });

  it('does not emit past max on ArrowRight', async () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 5, max: 5 } });
    await wrapper.trigger('keydown', { key: 'ArrowRight' });
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  // ── Disabled ──────────────────────────────────────────────────────────────

  it('is not focusable and emits nothing when disabled', async () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 2, disabled: true } });
    expect(wrapper.attributes('tabindex')).toBe('-1');
    await wrapper.findAll('.app-dot-input__hit')[3]!.trigger('click');
    await wrapper.trigger('keydown', { key: 'ArrowRight' });
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  // ── Clamping ──────────────────────────────────────────────────────────────

  it('clamps a value above max for the fill', () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 99, max: 5 } });
    expect(wrapper.findAll('.app-dot-input__dot--filled')).toHaveLength(5);
    expect(wrapper.attributes('aria-valuenow')).toBe('5');
  });

  // ── BEM modifiers ───────────────────────────────────────────────────────────

  it.each(TONES)('applies the --%s tone modifier', (tone) => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 2, tone } });
    expect(wrapper.classes()).toContain(`app-dot-input--${tone}`);
  });

  it.each(SIZES)('applies the --%s size modifier', (size) => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 2, size } });
    expect(wrapper.classes()).toContain(`app-dot-input--${size}`);
  });

  it('applies the --disabled modifier when disabled', () => {
    const wrapper = mount(AppDotInput, { props: { modelValue: 2, disabled: true } });
    expect(wrapper.classes()).toContain('app-dot-input--disabled');
  });
});
