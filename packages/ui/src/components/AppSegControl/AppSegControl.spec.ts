import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppSegControl from './AppSegControl.vue';

const SIZES = ['sm', 'md', 'lg'] as const;

const binaryOptions = [
  { value: 'yes', label: 'Yes' },
  { value: 'no', label: 'No' },
];

const ternaryOptions = [
  { value: 'a', label: 'Alpha' },
  { value: 'b', label: 'Beta' },
  { value: 'c', label: 'Gamma' },
];

const optionsWithDisabled = [
  { value: 'a', label: 'Alpha' },
  { value: 'b', label: 'Beta', disabled: true },
  { value: 'c', label: 'Gamma' },
];

describe('AppSegControl', () => {
  // ── Root element ───────────────────────────────────────────────────────────

  it('renders a root div with role="radiogroup"', () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes' },
    });
    expect(wrapper.element.tagName).toBe('DIV');
    expect(wrapper.attributes('role')).toBe('radiogroup');
  });

  it('applies the app-seg-control base class', () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes' },
    });
    expect(wrapper.classes()).toContain('app-seg-control');
  });

  // ── Options rendered ───────────────────────────────────────────────────────

  it('renders one button per option', () => {
    const wrapper = mount(AppSegControl, {
      props: { options: ternaryOptions, modelValue: 'a' },
    });
    const buttons = wrapper.findAll('.app-seg-control__option');
    expect(buttons).toHaveLength(3);
  });

  it('each option button has role="radio"', () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes' },
    });
    const buttons = wrapper.findAll('.app-seg-control__option');
    buttons.forEach((btn) => {
      expect(btn.attributes('role')).toBe('radio');
    });
  });

  it('renders option labels as button text', () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes' },
    });
    const buttons = wrapper.findAll('.app-seg-control__option');
    expect(buttons[0]!.text()).toBe('Yes');
    expect(buttons[1]!.text()).toBe('No');
  });

  // ── aria-checked ──────────────────────────────────────────────────────────

  it('sets aria-checked="true" on the checked option', () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes' },
    });
    const buttons = wrapper.findAll('.app-seg-control__option');
    expect(buttons[0]!.attributes('aria-checked')).toBe('true');
    expect(buttons[1]!.attributes('aria-checked')).toBe('false');
  });

  it('updates aria-checked when modelValue changes', async () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes' },
    });
    await wrapper.setProps({ modelValue: 'no' });
    const buttons = wrapper.findAll('.app-seg-control__option');
    expect(buttons[0]!.attributes('aria-checked')).toBe('false');
    expect(buttons[1]!.attributes('aria-checked')).toBe('true');
  });

  // ── emit update:modelValue ────────────────────────────────────────────────

  it('emits update:modelValue with the selected value on click', async () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes' },
    });
    const buttons = wrapper.findAll('.app-seg-control__option');
    await buttons[1]!.trigger('click');
    expect(wrapper.emitted('update:modelValue')).toEqual([['no']]);
  });

  it('emits the correct value for ternary options', async () => {
    const wrapper = mount(AppSegControl, {
      props: { options: ternaryOptions, modelValue: 'a' },
    });
    await wrapper.findAll('.app-seg-control__option')[2]!.trigger('click');
    expect(wrapper.emitted('update:modelValue')).toEqual([['c']]);
  });

  it('emits update:modelValue even when the already-checked option is clicked', async () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes' },
    });
    // The component emits regardless — the parent manages duplicate-value handling.
    await wrapper.findAll('.app-seg-control__option')[0]!.trigger('click');
    expect(wrapper.emitted('update:modelValue')).toEqual([['yes']]);
  });

  // ── Disabled: whole group ─────────────────────────────────────────────────

  it('does not emit when the group is disabled', async () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes', disabled: true },
    });
    await wrapper.findAll('.app-seg-control__option')[1]!.trigger('click');
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  it('applies app-seg-control--disabled class when disabled', () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes', disabled: true },
    });
    expect(wrapper.classes()).toContain('app-seg-control--disabled');
  });

  it('sets aria-disabled="true" on the radiogroup when disabled', () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes', disabled: true },
    });
    expect(wrapper.attributes('aria-disabled')).toBe('true');
  });

  // ── Disabled: individual option ───────────────────────────────────────────

  it('does not emit when a disabled individual option is clicked', async () => {
    const wrapper = mount(AppSegControl, {
      props: { options: optionsWithDisabled, modelValue: 'a' },
    });
    await wrapper.findAll('.app-seg-control__option')[1]!.trigger('click');
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  it('applies app-seg-control__option--disabled to a disabled option', () => {
    const wrapper = mount(AppSegControl, {
      props: { options: optionsWithDisabled, modelValue: 'a' },
    });
    expect(wrapper.findAll('.app-seg-control__option')[1]!.classes()).toContain(
      'app-seg-control__option--disabled',
    );
  });

  // ── Active BEM class ──────────────────────────────────────────────────────

  it('applies app-seg-control__option--active to the checked option', () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'no' },
    });
    const buttons = wrapper.findAll('.app-seg-control__option');
    expect(buttons[0]!.classes()).not.toContain('app-seg-control__option--active');
    expect(buttons[1]!.classes()).toContain('app-seg-control__option--active');
  });

  // ── Size BEM modifiers ────────────────────────────────────────────────────

  it.each(SIZES)('applies app-seg-control--%s class for size=%s', (size) => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes', size },
    });
    expect(wrapper.classes()).toContain(`app-seg-control--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes' },
    });
    expect(wrapper.classes()).toContain('app-seg-control--md');
  });

  it('applies the size modifier class to each option button', () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes', size: 'lg' },
    });
    wrapper.findAll('.app-seg-control__option').forEach((btn) => {
      expect(btn.classes()).toContain('app-seg-control__option--lg');
    });
  });

  // ── Roving focus / tabindex ───────────────────────────────────────────────

  it('gives tabindex=0 to the checked option and -1 to others', () => {
    const wrapper = mount(AppSegControl, {
      props: { options: ternaryOptions, modelValue: 'b' },
    });
    const buttons = wrapper.findAll('.app-seg-control__option');
    expect(buttons[0]!.attributes('tabindex')).toBe('-1');
    expect(buttons[1]!.attributes('tabindex')).toBe('0');
    expect(buttons[2]!.attributes('tabindex')).toBe('-1');
  });

  it('gives tabindex=0 to the first enabled option when modelValue is null', () => {
    const wrapper = mount(AppSegControl, {
      props: { options: ternaryOptions, modelValue: null },
    });
    const buttons = wrapper.findAll('.app-seg-control__option');
    expect(buttons[0]!.attributes('tabindex')).toBe('0');
    expect(buttons[1]!.attributes('tabindex')).toBe('-1');
    expect(buttons[2]!.attributes('tabindex')).toBe('-1');
  });

  it('updates tabindex distribution when modelValue changes', async () => {
    const wrapper = mount(AppSegControl, {
      props: { options: binaryOptions, modelValue: 'yes' },
    });
    await wrapper.setProps({ modelValue: 'no' });
    const buttons = wrapper.findAll('.app-seg-control__option');
    expect(buttons[0]!.attributes('tabindex')).toBe('-1');
    expect(buttons[1]!.attributes('tabindex')).toBe('0');
  });

  // ── Arrow key navigation ──────────────────────────────────────────────────

  it('emits the next option on ArrowRight keydown', async () => {
    const wrapper = mount(AppSegControl, {
      props: { options: ternaryOptions, modelValue: 'a' },
    });
    await wrapper.findAll('.app-seg-control__option')[0]!.trigger('keydown', {
      key: 'ArrowRight',
    });
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['b']);
  });

  it('emits the previous option on ArrowLeft keydown', async () => {
    const wrapper = mount(AppSegControl, {
      props: { options: ternaryOptions, modelValue: 'b' },
    });
    await wrapper.findAll('.app-seg-control__option')[1]!.trigger('keydown', {
      key: 'ArrowLeft',
    });
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['a']);
  });

  it('wraps around to the first option when pressing ArrowRight on the last', async () => {
    const wrapper = mount(AppSegControl, {
      props: { options: ternaryOptions, modelValue: 'c' },
    });
    await wrapper.findAll('.app-seg-control__option')[2]!.trigger('keydown', {
      key: 'ArrowRight',
    });
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['a']);
  });

  it('skips a disabled option in ArrowRight navigation', async () => {
    const wrapper = mount(AppSegControl, {
      props: { options: optionsWithDisabled, modelValue: 'a' },
    });
    // ArrowRight from 'a' should skip 'b' (disabled) and land on 'c'.
    await wrapper.findAll('.app-seg-control__option')[0]!.trigger('keydown', {
      key: 'ArrowRight',
    });
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['c']);
  });
});
