import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppSwitch from './AppSwitch.vue';

const SIZES = ['sm', 'md'] as const;

describe('AppSwitch', () => {
  // ── Role & aria-checked ─────────────────────────────────────────────────

  it('renders with role="switch" and aria-checked="false" when modelValue=false', () => {
    const wrapper = mount(AppSwitch, { props: { modelValue: false } });
    const control = wrapper.find('[role="switch"]');
    expect(control.exists()).toBe(true);
    expect(control.attributes('aria-checked')).toBe('false');
  });

  it('renders aria-checked="true" when modelValue=true', () => {
    const wrapper = mount(AppSwitch, { props: { modelValue: true } });
    expect(wrapper.find('[role="switch"]').attributes('aria-checked')).toBe('true');
  });

  it('applies the --checked modifier class when modelValue=true', () => {
    const wrapper = mount(AppSwitch, { props: { modelValue: true } });
    expect(wrapper.find('.app-switch--checked').exists()).toBe(true);
  });

  it('does not apply --checked modifier when modelValue=false', () => {
    const wrapper = mount(AppSwitch, { props: { modelValue: false } });
    expect(wrapper.find('.app-switch--checked').exists()).toBe(false);
  });

  // ── Emit update:modelValue ──────────────────────────────────────────────

  it('emits update:modelValue with true when clicked in off state', async () => {
    const wrapper = mount(AppSwitch, { props: { modelValue: false } });
    await wrapper.find('[role="switch"]').trigger('click');
    const events = wrapper.emitted('update:modelValue');
    expect(events).toHaveLength(1);
    expect(events?.[0]?.[0]).toBe(true);
  });

  it('emits update:modelValue with false when clicked in on state', async () => {
    const wrapper = mount(AppSwitch, { props: { modelValue: true } });
    await wrapper.find('[role="switch"]').trigger('click');
    const events = wrapper.emitted('update:modelValue');
    expect(events).toHaveLength(1);
    expect(events?.[0]?.[0]).toBe(false);
  });

  it('emits update:modelValue on Space keydown', async () => {
    const wrapper = mount(AppSwitch, { props: { modelValue: false } });
    await wrapper.find('[role="switch"]').trigger('keydown', { key: ' ' });
    const events = wrapper.emitted('update:modelValue');
    expect(events).toHaveLength(1);
    expect(events?.[0]?.[0]).toBe(true);
  });

  // ── Disabled ────────────────────────────────────────────────────────────

  it('does not emit when disabled and clicked', async () => {
    const wrapper = mount(AppSwitch, { props: { modelValue: false, disabled: true } });
    await wrapper.find('[role="switch"]').trigger('click');
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  it('does not emit when disabled and Space is pressed', async () => {
    const wrapper = mount(AppSwitch, { props: { modelValue: false, disabled: true } });
    await wrapper.find('[role="switch"]').trigger('keydown', { key: ' ' });
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  it('sets aria-disabled when disabled', () => {
    const wrapper = mount(AppSwitch, { props: { modelValue: false, disabled: true } });
    const control = wrapper.find('[role="switch"]');
    expect(control.attributes('aria-disabled')).toBe('true');
  });

  it('applies --disabled modifier class when disabled', () => {
    const wrapper = mount(AppSwitch, { props: { modelValue: false, disabled: true } });
    expect(wrapper.find('.app-switch--disabled').exists()).toBe(true);
  });

  // ── Size modifiers ──────────────────────────────────────────────────────

  it.each(SIZES)('applies --$s size class for size="%s"', (size) => {
    const wrapper = mount(AppSwitch, { props: { modelValue: false, size } });
    expect(wrapper.find(`.app-switch--${size}`).exists()).toBe(true);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppSwitch, { props: { modelValue: false } });
    expect(wrapper.find('.app-switch--md').exists()).toBe(true);
  });

  // ── Structural nodes ────────────────────────────────────────────────────

  it('renders __track and __thumb nodes', () => {
    const wrapper = mount(AppSwitch, { props: { modelValue: false } });
    expect(wrapper.find('.app-switch__track').exists()).toBe(true);
    expect(wrapper.find('.app-switch__thumb').exists()).toBe(true);
  });

  // ── Label prop ──────────────────────────────────────────────────────────

  it('renders a <label> wrapper and visible __label span when label prop is set', () => {
    const wrapper = mount(AppSwitch, {
      props: { modelValue: false, label: 'Push notifications' },
    });
    expect(wrapper.find('label.app-switch').exists()).toBe(true);
    expect(wrapper.find('.app-switch__label').text()).toBe('Push notifications');
  });

  it('uses a bare <button> root when no label or slot is provided', () => {
    const wrapper = mount(AppSwitch, { props: { modelValue: false } });
    expect(wrapper.find('label.app-switch').exists()).toBe(false);
    // Root element should be a button with role="switch"
    expect(wrapper.find('button[role="switch"]').exists()).toBe(true);
  });

  // ── Default slot ────────────────────────────────────────────────────────

  it('renders slot content inside __label and ignores the label prop when both provided', () => {
    const wrapper = mount(AppSwitch, {
      props: { modelValue: false, label: 'Prop label' },
      slots: { default: '<strong>Slot label</strong>' },
    });
    expect(wrapper.find('label.app-switch').exists()).toBe(true);
    const labelSpan = wrapper.find('.app-switch__label');
    // Slot content wins
    expect(labelSpan.html()).toContain('<strong>Slot label</strong>');
    // Prop text should NOT appear as rendered text
    expect(labelSpan.text()).not.toBe('Prop label');
  });

  it('renders slot content when only a slot is provided (no label prop)', () => {
    const wrapper = mount(AppSwitch, {
      props: { modelValue: false },
      slots: { default: 'Toggle dark mode' },
    });
    expect(wrapper.find('label.app-switch').exists()).toBe(true);
    expect(wrapper.find('.app-switch__label').text()).toContain('Toggle dark mode');
  });

  // ── name prop ───────────────────────────────────────────────────────────

  it('forwards the name prop to the button element', () => {
    const wrapper = mount(AppSwitch, {
      props: { modelValue: false, name: 'notifications' },
    });
    expect(wrapper.find('[role="switch"]').attributes('name')).toBe('notifications');
  });
});
