import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppChip from './AppChip.vue';

const VARIANTS = ['brass', 'mystic', 'crimson', 'success', 'darkness'] as const;
const SIZES = ['sm', 'md'] as const;

describe('AppChip', () => {
  // ── Root element ─────────────────────────────────────────────────────────

  it('renders a <button> root element', () => {
    const wrapper = mount(AppChip, { slots: { default: 'Test' } });
    expect(wrapper.element.tagName).toBe('BUTTON');
  });

  it('has type="button" on the root element', () => {
    const wrapper = mount(AppChip, { slots: { default: 'Test' } });
    expect(wrapper.attributes('type')).toBe('button');
  });

  it('applies the app-chip base class', () => {
    const wrapper = mount(AppChip, { slots: { default: 'Test' } });
    expect(wrapper.classes()).toContain('app-chip');
  });

  // ── Variant BEM modifiers ─────────────────────────────────────────────────

  it.each(VARIANTS)('applies app-chip--%s modifier for variant=%s', (variant) => {
    const wrapper = mount(AppChip, { props: { variant }, slots: { default: 'x' } });
    expect(wrapper.classes()).toContain(`app-chip--${variant}`);
  });

  it('defaults to variant=brass', () => {
    const wrapper = mount(AppChip, { slots: { default: 'x' } });
    expect(wrapper.classes()).toContain('app-chip--brass');
  });

  it('applies exactly one variant class', () => {
    const wrapper = mount(AppChip, { props: { variant: 'crimson' }, slots: { default: 'x' } });
    const variantClasses = wrapper
      .classes()
      .filter((c) => VARIANTS.some((v) => c === `app-chip--${v}`));
    expect(variantClasses).toHaveLength(1);
    expect(variantClasses[0]).toBe('app-chip--crimson');
  });

  // ── Size BEM modifiers ────────────────────────────────────────────────────

  it.each(SIZES)('applies app-chip--%s modifier for size=%s', (size) => {
    const wrapper = mount(AppChip, { props: { size }, slots: { default: 'x' } });
    expect(wrapper.classes()).toContain(`app-chip--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppChip, { slots: { default: 'x' } });
    expect(wrapper.classes()).toContain('app-chip--md');
  });

  it('applies exactly one size class', () => {
    const wrapper = mount(AppChip, { props: { size: 'sm' }, slots: { default: 'x' } });
    const sizeClasses = wrapper.classes().filter((c) => SIZES.some((s) => c === `app-chip--${s}`));
    expect(sizeClasses).toHaveLength(1);
    expect(sizeClasses[0]).toBe('app-chip--sm');
  });

  // ── aria-pressed / active state ───────────────────────────────────────────

  it('sets aria-pressed="false" when modelValue is false', () => {
    const wrapper = mount(AppChip, { props: { modelValue: false }, slots: { default: 'x' } });
    expect(wrapper.attributes('aria-pressed')).toBe('false');
  });

  it('sets aria-pressed="true" when modelValue is true', () => {
    const wrapper = mount(AppChip, { props: { modelValue: true }, slots: { default: 'x' } });
    expect(wrapper.attributes('aria-pressed')).toBe('true');
  });

  it('applies app-chip--active class when modelValue is true', () => {
    const wrapper = mount(AppChip, { props: { modelValue: true }, slots: { default: 'x' } });
    expect(wrapper.classes()).toContain('app-chip--active');
  });

  it('does not apply app-chip--active class when modelValue is false', () => {
    const wrapper = mount(AppChip, { props: { modelValue: false }, slots: { default: 'x' } });
    expect(wrapper.classes()).not.toContain('app-chip--active');
  });

  // ── Toggle behaviour ──────────────────────────────────────────────────────

  it('emits update:modelValue with true when clicked while inactive', async () => {
    const wrapper = mount(AppChip, { props: { modelValue: false }, slots: { default: 'x' } });
    await wrapper.trigger('click');
    expect(wrapper.emitted('update:modelValue')).toEqual([[true]]);
  });

  it('emits update:modelValue with false when clicked while active', async () => {
    const wrapper = mount(AppChip, { props: { modelValue: true }, slots: { default: 'x' } });
    await wrapper.trigger('click');
    expect(wrapper.emitted('update:modelValue')).toEqual([[false]]);
  });

  it('does not emit update:modelValue when disabled', async () => {
    const wrapper = mount(AppChip, {
      props: { modelValue: false, disabled: true },
      slots: { default: 'x' },
    });
    await wrapper.trigger('click');
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  // ── Disabled state ────────────────────────────────────────────────────────

  it('applies app-chip--disabled when disabled', () => {
    const wrapper = mount(AppChip, { props: { disabled: true }, slots: { default: 'x' } });
    expect(wrapper.classes()).toContain('app-chip--disabled');
  });

  it('has the disabled attribute when disabled', () => {
    const wrapper = mount(AppChip, { props: { disabled: true }, slots: { default: 'x' } });
    expect(wrapper.attributes('disabled')).toBeDefined();
  });

  // ── Removable / × button ──────────────────────────────────────────────────

  it('does not render the remove button when removable is false', () => {
    const wrapper = mount(AppChip, { props: { removable: false }, slots: { default: 'x' } });
    expect(wrapper.find('.app-chip__remove').exists()).toBe(false);
  });

  it('renders the remove button when removable is true', () => {
    const wrapper = mount(AppChip, { props: { removable: true }, slots: { default: 'x' } });
    expect(wrapper.find('.app-chip__remove').exists()).toBe(true);
  });

  it('applies app-chip--removable class when removable', () => {
    const wrapper = mount(AppChip, { props: { removable: true }, slots: { default: 'x' } });
    expect(wrapper.classes()).toContain('app-chip--removable');
  });

  it('emits remove when the × button is clicked', async () => {
    const wrapper = mount(AppChip, {
      props: { removable: true, modelValue: false },
      slots: { default: 'x' },
    });
    await wrapper.find('.app-chip__remove').trigger('click');
    expect(wrapper.emitted('remove')).toHaveLength(1);
  });

  it('does not emit update:modelValue when × is clicked', async () => {
    const wrapper = mount(AppChip, {
      props: { removable: true, modelValue: false },
      slots: { default: 'x' },
    });
    await wrapper.find('.app-chip__remove').trigger('click');
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  it('does not emit remove when disabled and × is clicked', async () => {
    const wrapper = mount(AppChip, {
      props: { removable: true, disabled: true, modelValue: false },
      slots: { default: 'x' },
    });
    // disabled chips have pointer-events: none so we simulate directly
    const removeEl = wrapper.find('.app-chip__remove');
    // handleRemove guards on props.disabled
    await removeEl.trigger('click');
    expect(wrapper.emitted('remove')).toBeUndefined();
  });

  // ── Default slot ──────────────────────────────────────────────────────────

  it('renders default slot content inside __label', () => {
    const wrapper = mount(AppChip, { slots: { default: 'Exhausted' } });
    expect(wrapper.find('.app-chip__label').text()).toContain('Exhausted');
  });

  // ── Remove control label ──────────────────────────────────────────────────

  it('defaults the remove control aria-label to "Remove"', () => {
    const wrapper = mount(AppChip, { props: { removable: true } });
    expect(wrapper.find('.app-chip__remove').attributes('aria-label')).toBe('Remove');
  });

  it('uses the removeLabel prop for the remove control aria-label', () => {
    const wrapper = mount(AppChip, { props: { removable: true, removeLabel: 'Убрать' } });
    expect(wrapper.find('.app-chip__remove').attributes('aria-label')).toBe('Убрать');
  });
});
