import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppSelect, { type AppSelectOption } from './AppSelect.vue';

// AppSelect wraps a native <select>; happy-dom provides HTMLSelectElement out of the box.

const STRING_OPTIONS: AppSelectOption[] = [
  { value: 'apple', label: 'Apple' },
  { value: 'banana', label: 'Banana' },
  { value: 'cherry', label: 'Cherry' },
] as const;

const OPTIONS_WITH_DISABLED: AppSelectOption[] = [
  { value: 'apple', label: 'Apple' },
  { value: 'banana', label: 'Banana' },
  { value: 'cherry', label: 'Cherry (seasonal)', disabled: true },
] as const;

const NUMBER_OPTIONS: AppSelectOption[] = [
  { value: 1, label: 'One' },
  { value: 2, label: 'Two' },
  { value: 3, label: 'Three' },
] as const;

const SIZES = ['sm', 'md', 'lg'] as const;

describe('AppSelect', () => {
  // ── Rendering ──────────────────────────────────────────────────────────────

  it('renders a root div with class app-select', () => {
    const wrapper = mount(AppSelect, { props: { modelValue: null, options: STRING_OPTIONS } });
    expect(wrapper.find('.app-select').exists()).toBe(true);
  });

  it('renders all options from the options prop', () => {
    const wrapper = mount(AppSelect, { props: { modelValue: null, options: STRING_OPTIONS } });
    const opts = wrapper.findAll('option');
    expect(opts).toHaveLength(STRING_OPTIONS.length);
    expect(opts.map((o) => o.attributes('value'))).toEqual(['apple', 'banana', 'cherry']);
  });

  it('renders option labels as text content', () => {
    const wrapper = mount(AppSelect, { props: { modelValue: null, options: STRING_OPTIONS } });
    const labels = wrapper.findAll('option').map((o) => o.text());
    expect(labels).toEqual(['Apple', 'Banana', 'Cherry']);
  });

  // ── Placeholder ────────────────────────────────────────────────────────────

  it('shows a disabled hidden placeholder option when placeholder prop is set and modelValue is null', () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: null, options: STRING_OPTIONS, placeholder: 'Pick one' },
    });
    const placeholder = wrapper.find('option[hidden]');
    expect(placeholder.exists()).toBe(true);
    expect(placeholder.text()).toBe('Pick one');
    expect(placeholder.attributes('disabled')).toBeDefined();
    expect(placeholder.attributes('value')).toBe('');
  });

  it('omits the placeholder option when no placeholder prop is passed', () => {
    const wrapper = mount(AppSelect, { props: { modelValue: null, options: STRING_OPTIONS } });
    expect(wrapper.find('option[hidden]').exists()).toBe(false);
  });

  it('has placeholder option count + options count when both are present', () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: null, options: STRING_OPTIONS, placeholder: 'Pick…' },
    });
    expect(wrapper.findAll('option')).toHaveLength(STRING_OPTIONS.length + 1);
  });

  // ── v-model / emit ─────────────────────────────────────────────────────────

  it('emits update:modelValue with string value when a string option is selected', async () => {
    const wrapper = mount(AppSelect, { props: { modelValue: 'apple', options: STRING_OPTIONS } });
    const select = wrapper.find('select');
    await select.setValue('banana');
    const events = wrapper.emitted('update:modelValue');
    expect(events).toHaveLength(1);
    expect(events?.[0]?.[0]).toBe('banana');
  });

  it('emits update:modelValue with a number when a number-valued option is selected', async () => {
    const wrapper = mount(AppSelect, { props: { modelValue: 1, options: NUMBER_OPTIONS } });
    const select = wrapper.find('select');
    await select.setValue('2');
    const events = wrapper.emitted('update:modelValue');
    expect(events).toHaveLength(1);
    expect(events?.[0]?.[0]).toBe(2);
    expect(typeof events?.[0]?.[0]).toBe('number');
  });

  it('does not emit when the placeholder sentinel is selected', async () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: null, options: STRING_OPTIONS, placeholder: 'Pick…' },
    });
    const select = wrapper.find('select');
    (select.element as HTMLSelectElement).value = '';
    await select.trigger('change');
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  // ── Disabled ───────────────────────────────────────────────────────────────

  it('does not emit when the select is disabled', async () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: 'apple', options: STRING_OPTIONS, disabled: true },
    });
    const select = wrapper.find('select');
    (select.element as HTMLSelectElement).value = 'banana';
    await select.trigger('change');
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  it('applies app-select--disabled modifier class when disabled', () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: null, options: STRING_OPTIONS, disabled: true },
    });
    expect(wrapper.find('.app-select--disabled').exists()).toBe(true);
  });

  it('sets the native disabled attribute on the <select> when disabled', () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: null, options: STRING_OPTIONS, disabled: true },
    });
    expect(wrapper.find('select').attributes('disabled')).toBeDefined();
  });

  it('sets aria-disabled="true" on the <select> when disabled', () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: null, options: STRING_OPTIONS, disabled: true },
    });
    expect(wrapper.find('select').attributes('aria-disabled')).toBe('true');
  });

  it('does not set aria-disabled when not disabled', () => {
    const wrapper = mount(AppSelect, { props: { modelValue: null, options: STRING_OPTIONS } });
    expect(wrapper.find('select').attributes('aria-disabled')).toBeUndefined();
  });

  // ── Invalid ────────────────────────────────────────────────────────────────

  it('applies app-select--invalid modifier class when invalid', () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: null, options: STRING_OPTIONS, invalid: true },
    });
    expect(wrapper.find('.app-select--invalid').exists()).toBe(true);
  });

  it('does not apply app-select--invalid when invalid=false', () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: null, options: STRING_OPTIONS, invalid: false },
    });
    expect(wrapper.find('.app-select--invalid').exists()).toBe(false);
  });

  it('sets aria-invalid="true" on the <select> when invalid', () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: null, options: STRING_OPTIONS, invalid: true },
    });
    expect(wrapper.find('select').attributes('aria-invalid')).toBe('true');
  });

  it('does not set aria-invalid when not invalid', () => {
    const wrapper = mount(AppSelect, { props: { modelValue: null, options: STRING_OPTIONS } });
    expect(wrapper.find('select').attributes('aria-invalid')).toBeUndefined();
  });

  // ── Size ───────────────────────────────────────────────────────────────────

  it.each(SIZES)('applies the size=%s modifier class', (size) => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: null, options: STRING_OPTIONS, size },
    });
    expect(wrapper.find(`.app-select--${size}`).exists()).toBe(true);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppSelect, { props: { modelValue: null, options: STRING_OPTIONS } });
    expect(wrapper.find('.app-select--md').exists()).toBe(true);
  });

  // ── Native attribute forwarding ────────────────────────────────────────────

  it('forwards selectId as id onto the native <select>', () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: null, options: STRING_OPTIONS, selectId: 'my-select' },
    });
    expect(wrapper.find('select').attributes('id')).toBe('my-select');
  });

  it('forwards name onto the native <select>', () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: null, options: STRING_OPTIONS, name: 'fruit' },
    });
    expect(wrapper.find('select').attributes('name')).toBe('fruit');
  });

  it('forwards required onto the native <select>', () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: null, options: STRING_OPTIONS, required: true },
    });
    expect(wrapper.find('select').attributes('required')).toBeDefined();
  });

  // ── Disabled option ────────────────────────────────────────────────────────

  it('marks disabled options with the native disabled attribute', () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: null, options: OPTIONS_WITH_DISABLED },
    });
    const cherry = wrapper.findAll('option').find((o) => o.attributes('value') === 'cherry');
    expect(cherry?.attributes('disabled')).toBeDefined();
  });

  // ── Chevron ────────────────────────────────────────────────────────────────

  it('renders the decorative chevron span with aria-hidden', () => {
    const wrapper = mount(AppSelect, { props: { modelValue: null, options: STRING_OPTIONS } });
    const chevron = wrapper.find('.app-select__chevron');
    expect(chevron.exists()).toBe(true);
    expect(chevron.attributes('aria-hidden')).toBe('true');
  });

  // ── modelValue reflection ──────────────────────────────────────────────────

  it('reflects a string modelValue in the native <select>', () => {
    const wrapper = mount(AppSelect, {
      props: { modelValue: 'banana', options: STRING_OPTIONS },
    });
    expect((wrapper.find('select').element as HTMLSelectElement).value).toBe('banana');
  });
});
