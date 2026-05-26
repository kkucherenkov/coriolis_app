import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppStatPair from './AppStatPair.vue';

describe('AppStatPair', () => {
  // ── Rendering ────────────────────────────────────────────────────────────────

  it('renders the label text', () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 8, max: 12 } });
    expect(wrapper.find('.app-stat-pair__label').text()).toBe('Hull');
  });

  it('renders current value in the input', () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 8, max: 12 } });
    const input = wrapper.find<HTMLInputElement>('.app-stat-pair__input');
    expect(input.element.value).toBe('8');
  });

  it('renders max value in the max span', () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 8, max: 12 } });
    expect(wrapper.find('.app-stat-pair__max').text()).toBe('12');
  });

  it('renders a separator', () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 8, max: 12 } });
    expect(wrapper.find('.app-stat-pair__separator').exists()).toBe(true);
  });

  // ── Accessibility ─────────────────────────────────────────────────────────────

  it('has role="group" on the root', () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 8, max: 12 } });
    expect(wrapper.attributes('role')).toBe('group');
  });

  it('has aria-label on the root matching the label prop', () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 8, max: 12 } });
    expect(wrapper.attributes('aria-label')).toBe('Hull');
  });

  it('input has aria-valuetext with "label: current of max" text', () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 8, max: 12 } });
    expect(wrapper.find('.app-stat-pair__input').attributes('aria-valuetext')).toBe(
      'Hull: 8 of 12',
    );
  });

  it('decrement button has descriptive aria-label', () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 8, max: 12 } });
    const dec = wrapper.find('.app-stat-pair__btn--dec');
    expect(dec.attributes('aria-label')).toBe('Decrease Hull');
  });

  it('increment button has descriptive aria-label', () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 8, max: 12 } });
    const inc = wrapper.find('.app-stat-pair__btn--inc');
    expect(inc.attributes('aria-label')).toBe('Increase Hull');
  });

  // ── Stepper interactions ──────────────────────────────────────────────────────

  it('emits update:current with current-1 on decrement click', async () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 8, max: 12 } });
    await wrapper.find('.app-stat-pair__btn--dec').trigger('click');
    expect(wrapper.emitted('update:current')?.[0]).toEqual([7]);
  });

  it('emits update:current with current+1 on increment click', async () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 8, max: 12 } });
    await wrapper.find('.app-stat-pair__btn--inc').trigger('click');
    expect(wrapper.emitted('update:current')?.[0]).toEqual([9]);
  });

  it('clamps current to 0 — decrement is disabled at zero', async () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 0, max: 12 } });
    const dec = wrapper.find<HTMLButtonElement>('.app-stat-pair__btn--dec');
    expect(dec.element.disabled).toBe(true);
  });

  it('clamps current to max — increment is disabled at max', async () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 12, max: 12 } });
    const inc = wrapper.find<HTMLButtonElement>('.app-stat-pair__btn--inc');
    expect(inc.element.disabled).toBe(true);
  });

  it('does not emit below 0', async () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 0, max: 12 } });
    // Trigger via the click anyway (button is disabled, no emission expected)
    await wrapper.find('.app-stat-pair__btn--dec').trigger('click');
    expect(wrapper.emitted('update:current')).toBeUndefined();
  });

  it('does not emit above max', async () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 12, max: 12 } });
    await wrapper.find('.app-stat-pair__btn--inc').trigger('click');
    expect(wrapper.emitted('update:current')).toBeUndefined();
  });

  // ── Disabled ─────────────────────────────────────────────────────────────────

  it('applies --disabled modifier when disabled=true', () => {
    const wrapper = mount(AppStatPair, {
      props: { label: 'Hull', current: 8, max: 12, disabled: true },
    });
    expect(wrapper.classes()).toContain('app-stat-pair--disabled');
  });

  it('disables both buttons when disabled=true', () => {
    const wrapper = mount(AppStatPair, {
      props: { label: 'Hull', current: 8, max: 12, disabled: true },
    });
    const buttons = wrapper.findAll<HTMLButtonElement>('.app-stat-pair__btn');
    for (const btn of buttons) {
      expect(btn.element.disabled).toBe(true);
    }
  });

  it('does not emit when disabled and button clicked', async () => {
    const wrapper = mount(AppStatPair, {
      props: { label: 'Hull', current: 8, max: 12, disabled: true },
    });
    await wrapper.find('.app-stat-pair__btn--inc').trigger('click');
    expect(wrapper.emitted('update:current')).toBeUndefined();
  });

  // ── Tone modifier ──────────────────────────────────────────────────────────

  it('applies --brass modifier by default', () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 8, max: 12 } });
    expect(wrapper.classes()).toContain('app-stat-pair--brass');
  });

  it('applies --mystic modifier when tone=mystic', () => {
    const wrapper = mount(AppStatPair, {
      props: { label: 'Shields', current: 3, max: 6, tone: 'mystic' },
    });
    expect(wrapper.classes()).toContain('app-stat-pair--mystic');
  });

  // ── Blur forwarding ────────────────────────────────────────────────────────

  it('emits blur when the input loses focus', async () => {
    const wrapper = mount(AppStatPair, { props: { label: 'Hull', current: 8, max: 12 } });
    await wrapper.find('.app-stat-pair__input').trigger('blur');
    expect(wrapper.emitted('blur')).toBeTruthy();
  });
});
