import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppTextarea from './AppTextarea.vue';

describe('AppTextarea', () => {
  // ── Rendering ──────────────────────────────────────────────────────────────

  it('renders a native <textarea> element', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '' } });
    expect(wrapper.element.tagName).toBe('TEXTAREA');
  });

  it('applies the app-textarea BEM block class', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '' } });
    expect(wrapper.classes()).toContain('app-textarea');
  });

  it('reflects modelValue into the native value', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: 'hello' } });
    expect((wrapper.element as HTMLTextAreaElement).value).toBe('hello');
  });

  it('renders null modelValue as an empty string', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: null } });
    expect((wrapper.element as HTMLTextAreaElement).value).toBe('');
  });

  // ── emit update:modelValue ─────────────────────────────────────────────────

  it('emits update:modelValue with string on input', async () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '' } });
    const el = wrapper.element as HTMLTextAreaElement;
    el.value = 'typed text';
    await wrapper.trigger('input');
    const events = wrapper.emitted('update:modelValue');
    expect(events).toHaveLength(1);
    expect(events?.[0]).toEqual(['typed text']);
  });

  it('emits null when textarea is cleared', async () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: 'existing' } });
    const el = wrapper.element as HTMLTextAreaElement;
    el.value = '';
    await wrapper.trigger('input');
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([null]);
  });

  it('does not emit when disabled', async () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '', disabled: true } });
    const el = wrapper.element as HTMLTextAreaElement;
    el.value = 'attempt';
    await wrapper.trigger('input');
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  // ── BEM class modifiers ────────────────────────────────────────────────────

  it('defaults to size=md modifier', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '' } });
    expect(wrapper.classes()).toContain('app-textarea--md');
  });

  it.each(['sm', 'md', 'lg'] as const)('applies size modifier for size=%s', (size) => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '', size } });
    expect(wrapper.classes()).toContain(`app-textarea--${size}`);
  });

  it('applies app-textarea--invalid modifier when invalid=true', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '', invalid: true } });
    expect(wrapper.classes()).toContain('app-textarea--invalid');
  });

  it('does not apply app-textarea--invalid modifier when invalid=false', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '', invalid: false } });
    expect(wrapper.classes()).not.toContain('app-textarea--invalid');
  });

  it('applies app-textarea--disabled modifier when disabled=true', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '', disabled: true } });
    expect(wrapper.classes()).toContain('app-textarea--disabled');
  });

  it('applies app-textarea--autosize modifier when autosize=true', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '', autosize: true } });
    expect(wrapper.classes()).toContain('app-textarea--autosize');
  });

  it('does not apply app-textarea--autosize modifier by default', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '' } });
    expect(wrapper.classes()).not.toContain('app-textarea--autosize');
  });

  // ── Accessibility attributes ───────────────────────────────────────────────

  it('sets aria-invalid="true" when invalid', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '', invalid: true } });
    expect(wrapper.attributes('aria-invalid')).toBe('true');
  });

  it('does not set aria-invalid when not invalid', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '' } });
    expect(wrapper.attributes('aria-invalid')).toBeUndefined();
  });

  it('sets aria-disabled="true" when disabled', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '', disabled: true } });
    expect(wrapper.attributes('aria-disabled')).toBe('true');
  });

  it('does not set aria-disabled when not disabled', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '' } });
    expect(wrapper.attributes('aria-disabled')).toBeUndefined();
  });

  it('sets aria-readonly="true" when readonly', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: 'ro', readonly: true } });
    expect(wrapper.attributes('aria-readonly')).toBe('true');
  });

  it('does not set aria-readonly when not readonly', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '' } });
    expect(wrapper.attributes('aria-readonly')).toBeUndefined();
  });

  // ── Native attribute forwarding ────────────────────────────────────────────

  it('forwards inputId as id to the native element', () => {
    const wrapper = mount(AppTextarea, {
      props: { modelValue: '', inputId: 'notes-field' },
    });
    expect(wrapper.attributes('id')).toBe('notes-field');
  });

  it('forwards placeholder to the native element', () => {
    const wrapper = mount(AppTextarea, {
      props: { modelValue: '', placeholder: 'Enter session notes…' },
    });
    expect(wrapper.attributes('placeholder')).toBe('Enter session notes…');
  });

  it('forwards rows prop (default=4)', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '' } });
    expect(wrapper.attributes('rows')).toBe('4');
  });

  it('forwards explicit rows prop', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '', rows: 8 } });
    expect(wrapper.attributes('rows')).toBe('8');
  });

  it('forwards maxlength to the native element when provided', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '', maxlength: 500 } });
    expect(wrapper.attributes('maxlength')).toBe('500');
  });

  it('does not set maxlength when not provided', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '' } });
    expect(wrapper.attributes('maxlength')).toBeUndefined();
  });

  it('sets the native disabled attribute when disabled', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: '', disabled: true } });
    expect(wrapper.attributes('disabled')).toBeDefined();
  });

  it('sets the native readonly attribute when readonly', () => {
    const wrapper = mount(AppTextarea, { props: { modelValue: 'ro', readonly: true } });
    expect(wrapper.attributes('readonly')).toBeDefined();
    // readonly must not disable the control
    expect(wrapper.attributes('disabled')).toBeUndefined();
  });
});
