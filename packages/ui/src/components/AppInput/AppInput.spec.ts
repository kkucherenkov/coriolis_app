import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppInput from './AppInput.vue';

describe('AppInput', () => {
  // ── Rendering ──────────────────────────────────────────────────────────────

  it('renders a native <input> element', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '' } });
    expect(wrapper.element.tagName).toBe('INPUT');
  });

  it('applies the app-input BEM block class', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '' } });
    expect(wrapper.classes()).toContain('app-input');
  });

  it('reflects modelValue into the native value', () => {
    const wrapper = mount(AppInput, { props: { modelValue: 'hello' } });
    expect((wrapper.element as HTMLInputElement).value).toBe('hello');
  });

  it('renders null modelValue as an empty string', () => {
    const wrapper = mount(AppInput, { props: { modelValue: null } });
    expect((wrapper.element as HTMLInputElement).value).toBe('');
  });

  // ── emit update:modelValue ─────────────────────────────────────────────────

  it('emits update:modelValue with string on input', async () => {
    const wrapper = mount(AppInput, { props: { modelValue: '' } });
    const el = wrapper.element as HTMLInputElement;
    el.value = 'typed';
    await wrapper.trigger('input');
    const events = wrapper.emitted('update:modelValue');
    expect(events).toHaveLength(1);
    expect(events?.[0]).toEqual(['typed']);
  });

  it('emits null when input is cleared', async () => {
    const wrapper = mount(AppInput, { props: { modelValue: 'existing' } });
    const el = wrapper.element as HTMLInputElement;
    el.value = '';
    await wrapper.trigger('input');
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([null]);
  });

  it('emits a number when type="number" and value is non-empty', async () => {
    const wrapper = mount(AppInput, { props: { modelValue: '', type: 'number' } });
    const el = wrapper.element as HTMLInputElement;
    el.value = '42';
    await wrapper.trigger('input');
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([42]);
  });

  it('emits null when type="number" and value is cleared', async () => {
    const wrapper = mount(AppInput, { props: { modelValue: 1, type: 'number' } });
    const el = wrapper.element as HTMLInputElement;
    el.value = '';
    await wrapper.trigger('input');
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([null]);
  });

  it('does not emit when disabled', async () => {
    const wrapper = mount(AppInput, { props: { modelValue: '', disabled: true } });
    const el = wrapper.element as HTMLInputElement;
    el.value = 'attempt';
    await wrapper.trigger('input');
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  // ── BEM class modifiers ────────────────────────────────────────────────────

  it('defaults to size=md modifier', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '' } });
    expect(wrapper.classes()).toContain('app-input--md');
  });

  it.each(['sm', 'md', 'lg'] as const)('applies size modifier for size=%s', (size) => {
    const wrapper = mount(AppInput, { props: { modelValue: '', size } });
    expect(wrapper.classes()).toContain(`app-input--${size}`);
  });

  it('applies app-input--invalid modifier when invalid=true', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '', invalid: true } });
    expect(wrapper.classes()).toContain('app-input--invalid');
  });

  it('does not apply app-input--invalid modifier when invalid=false', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '', invalid: false } });
    expect(wrapper.classes()).not.toContain('app-input--invalid');
  });

  it('applies app-input--disabled modifier when disabled=true', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '', disabled: true } });
    expect(wrapper.classes()).toContain('app-input--disabled');
  });

  // ── Accessibility attributes ───────────────────────────────────────────────

  it('sets aria-invalid="true" when invalid', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '', invalid: true } });
    expect(wrapper.attributes('aria-invalid')).toBe('true');
  });

  it('does not set aria-invalid when not invalid', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '' } });
    expect(wrapper.attributes('aria-invalid')).toBeUndefined();
  });

  it('sets aria-disabled="true" when disabled', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '', disabled: true } });
    expect(wrapper.attributes('aria-disabled')).toBe('true');
  });

  it('does not set aria-disabled when not disabled', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '' } });
    expect(wrapper.attributes('aria-disabled')).toBeUndefined();
  });

  it('sets aria-readonly="true" when readonly', () => {
    const wrapper = mount(AppInput, { props: { modelValue: 'ro', readonly: true } });
    expect(wrapper.attributes('aria-readonly')).toBe('true');
  });

  it('does not set aria-readonly when not readonly', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '' } });
    expect(wrapper.attributes('aria-readonly')).toBeUndefined();
  });

  // ── Native attribute forwarding ────────────────────────────────────────────

  it('defaults to type="text"', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '' } });
    expect(wrapper.attributes('type')).toBe('text');
  });

  it('forwards type prop to the native element', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '', type: 'email' } });
    expect(wrapper.attributes('type')).toBe('email');
  });

  it('forwards inputmode prop to the native element', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '', inputmode: 'numeric' } });
    expect(wrapper.attributes('inputmode')).toBe('numeric');
  });

  it('forwards autocomplete prop to the native element', () => {
    const wrapper = mount(AppInput, {
      props: { modelValue: '', autocomplete: 'email' },
    });
    expect(wrapper.attributes('autocomplete')).toBe('email');
  });

  it('forwards inputId as id to the native element', () => {
    const wrapper = mount(AppInput, {
      props: { modelValue: '', inputId: 'my-field' },
    });
    expect(wrapper.attributes('id')).toBe('my-field');
  });

  it('sets the native disabled attribute when disabled', () => {
    const wrapper = mount(AppInput, { props: { modelValue: '', disabled: true } });
    expect(wrapper.attributes('disabled')).toBeDefined();
  });

  it('sets the native readonly attribute when readonly', () => {
    const wrapper = mount(AppInput, { props: { modelValue: 'ro', readonly: true } });
    expect(wrapper.attributes('readonly')).toBeDefined();
    // readonly must not disable the control
    expect(wrapper.attributes('disabled')).toBeUndefined();
  });

  it('forwards placeholder to the native element', () => {
    const wrapper = mount(AppInput, {
      props: { modelValue: '', placeholder: 'Enter callsign' },
    });
    expect(wrapper.attributes('placeholder')).toBe('Enter callsign');
  });
});
