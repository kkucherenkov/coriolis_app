import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';
import { defineComponent, h, type PropType } from 'vue';

import AppField from './AppField.vue';

type FieldSize = 'sm' | 'md';

// Harness spreads slotAttrs onto a plain <input> — mirrors how a real consumer
// wires AppInput or a native control inside AppField.
const Harness = defineComponent({
  props: {
    label: { type: String, required: true },
    for: { type: String, default: undefined },
    required: { type: Boolean, default: false },
    helpText: { type: String, default: undefined },
    error: { type: String, default: undefined },
    size: { type: String as PropType<FieldSize>, default: 'md' },
  },
  setup(props) {
    return () =>
      h(
        AppField,
        {
          label: props.label,
          for: props.for,
          required: props.required,
          helpText: props.helpText,
          error: props.error,
          size: props.size,
        },
        {
          default: (slotProps: Record<string, unknown>) =>
            h('input', { type: 'text', ...slotProps, 'data-testid': 'input' }),
        },
      );
  },
});

describe('AppField', () => {
  // ── Label rendering ──────────────────────────────────────────────────────────

  it('renders the label text', () => {
    const wrapper = mount(Harness, { props: { label: 'Email address' } });
    expect(wrapper.find('.app-field__label').exists()).toBe(true);
    expect(wrapper.find('.app-field__label').text()).toContain('Email address');
  });

  it('renders a <label> element (not a generic element)', () => {
    const wrapper = mount(Harness, { props: { label: 'Name' } });
    expect(wrapper.find('label.app-field__label').exists()).toBe(true);
  });

  it('links <label for> to the slotted input id', () => {
    const wrapper = mount(Harness, { props: { label: 'Name' } });
    const label = wrapper.find('label');
    const input = wrapper.find('[data-testid="input"]');
    const id = input.attributes('id');
    expect(id).toBeTruthy();
    expect(label.attributes('for')).toBe(id);
  });

  it('uses the explicit `for` prop as the field id when provided', () => {
    const wrapper = mount(Harness, { props: { label: 'Ship name', for: 'ship-name-field' } });
    const input = wrapper.find('[data-testid="input"]');
    expect(input.attributes('id')).toBe('ship-name-field');
    expect(wrapper.find('label').attributes('for')).toBe('ship-name-field');
  });

  it('auto-generates a non-empty id when no `for` prop is given', () => {
    const wrapper = mount(Harness, { props: { label: 'A' } });
    const id = wrapper.find('[data-testid="input"]').attributes('id');
    // The id must be a non-empty string; the label must reference it.
    expect(id).toBeTruthy();
    expect(wrapper.find('label').attributes('for')).toBe(id);
  });

  // ── Required marker ──────────────────────────────────────────────────────────

  it('renders the required star when required=true', () => {
    const wrapper = mount(Harness, { props: { label: 'Email', required: true } });
    const star = wrapper.find('.app-field__required');
    expect(star.exists()).toBe(true);
    expect(star.text()).toBe('*');
  });

  it('hides the required star when required=false', () => {
    const wrapper = mount(Harness, { props: { label: 'Email', required: false } });
    expect(wrapper.find('.app-field__required').exists()).toBe(false);
  });

  it('sets aria-required on the slotted input when required', () => {
    const wrapper = mount(Harness, { props: { label: 'E', required: true } });
    expect(wrapper.find('[data-testid="input"]').attributes('aria-required')).toBe('true');
  });

  it('does not set aria-required on the slotted input when not required', () => {
    const wrapper = mount(Harness, { props: { label: 'E', required: false } });
    expect(wrapper.find('[data-testid="input"]').attributes('aria-required')).toBeUndefined();
  });

  // ── Help text ────────────────────────────────────────────────────────────────

  it('shows helpText when provided and no error is set', () => {
    const wrapper = mount(Harness, { props: { label: 'E', helpText: 'A helpful hint' } });
    const help = wrapper.find('.app-field__help');
    expect(help.exists()).toBe(true);
    expect(help.text()).toBe('A helpful hint');
  });

  it('does not render an error span when only helpText is set', () => {
    const wrapper = mount(Harness, { props: { label: 'E', helpText: 'Hint' } });
    expect(wrapper.find('.app-field__error').exists()).toBe(false);
  });

  it('gives the help span a deterministic id', () => {
    const wrapper = mount(Harness, { props: { label: 'E', helpText: 'Hint' } });
    const help = wrapper.find('.app-field__help');
    const inputId = wrapper.find('[data-testid="input"]').attributes('id');
    expect(help.attributes('id')).toBe(`${inputId}-help`);
  });

  it('links the slotted input to the help span via aria-describedby', () => {
    const wrapper = mount(Harness, { props: { label: 'E', helpText: 'Hint' } });
    const input = wrapper.find('[data-testid="input"]');
    const helpId = wrapper.find('.app-field__help').attributes('id');
    expect(input.attributes('aria-describedby')).toBe(helpId);
  });

  // ── Error text ───────────────────────────────────────────────────────────────

  it('shows the error span when error is set', () => {
    const wrapper = mount(Harness, { props: { label: 'E', error: 'Required field' } });
    const error = wrapper.find('.app-field__error');
    expect(error.exists()).toBe(true);
    expect(error.text()).toBe('Required field');
  });

  it('hides helpText when error is also set (error wins)', () => {
    const wrapper = mount(Harness, {
      props: { label: 'E', helpText: 'A hint', error: 'Bad value' },
    });
    expect(wrapper.find('.app-field__help').exists()).toBe(false);
    expect(wrapper.find('.app-field__error').exists()).toBe(true);
    expect(wrapper.find('.app-field__error').text()).toBe('Bad value');
  });

  it('gives the error span role="alert" so screen readers announce it', () => {
    const wrapper = mount(Harness, { props: { label: 'E', error: 'Oops' } });
    expect(wrapper.find('.app-field__error').attributes('role')).toBe('alert');
  });

  it('gives the error span a deterministic id', () => {
    const wrapper = mount(Harness, { props: { label: 'E', error: 'Oops' } });
    const error = wrapper.find('.app-field__error');
    const inputId = wrapper.find('[data-testid="input"]').attributes('id');
    expect(error.attributes('id')).toBe(`${inputId}-error`);
  });

  it('links the slotted input to the error span via aria-describedby when errored', () => {
    const wrapper = mount(Harness, { props: { label: 'E', error: 'Bad' } });
    const input = wrapper.find('[data-testid="input"]');
    const errorId = wrapper.find('.app-field__error').attributes('id');
    expect(input.attributes('aria-describedby')).toBe(errorId);
  });

  it('sets aria-invalid on the slotted input when error is set', () => {
    const wrapper = mount(Harness, { props: { label: 'E', error: 'Bad' } });
    expect(wrapper.find('[data-testid="input"]').attributes('aria-invalid')).toBe('true');
  });

  it('does not set aria-invalid when there is no error', () => {
    const wrapper = mount(Harness, { props: { label: 'E' } });
    expect(wrapper.find('[data-testid="input"]').attributes('aria-invalid')).toBeUndefined();
  });

  // ── No help or error ─────────────────────────────────────────────────────────

  it('does not set aria-describedby when neither helpText nor error is provided', () => {
    const wrapper = mount(Harness, { props: { label: 'E' } });
    expect(wrapper.find('[data-testid="input"]').attributes('aria-describedby')).toBeUndefined();
  });

  // ── BEM modifiers ────────────────────────────────────────────────────────────

  it('adds --invalid modifier class when error is set', () => {
    const wrapper = mount(Harness, { props: { label: 'E', error: 'Bad' } });
    expect(wrapper.find('.app-field--invalid').exists()).toBe(true);
  });

  it('does not add --invalid when no error is set', () => {
    const wrapper = mount(Harness, { props: { label: 'E' } });
    expect(wrapper.find('.app-field--invalid').exists()).toBe(false);
  });

  it('adds --required modifier class when required is true', () => {
    const wrapper = mount(Harness, { props: { label: 'E', required: true } });
    expect(wrapper.find('.app-field--required').exists()).toBe(true);
  });

  it.each(['sm', 'md'] as const)('applies size modifier .app-field--%s', (size) => {
    const wrapper = mount(Harness, { props: { label: 'E', size } });
    expect(wrapper.find(`.app-field--${size}`).exists()).toBe(true);
  });
});
