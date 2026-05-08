import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppConditionPill from './AppConditionPill.vue';

const CONDITIONS = ['exhausted', 'sleepless', 'thirsty', 'hungry'] as const;
const SIZES = ['sm', 'md'] as const;

/** Expected Lucide icon name per condition. */
const ICON_MAP: Record<string, string> = {
  exhausted: 'battery-low',
  sleepless: 'moon',
  thirsty: 'droplet',
  hungry: 'apple',
};

describe('AppConditionPill', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a <button> root element', () => {
    const wrapper = mount(AppConditionPill, { props: { condition: 'exhausted' } });
    expect(wrapper.element.tagName).toBe('BUTTON');
  });

  it('has type="button" on the root element', () => {
    const wrapper = mount(AppConditionPill, { props: { condition: 'exhausted' } });
    expect(wrapper.attributes('type')).toBe('button');
  });

  it('applies the app-condition-pill base class', () => {
    const wrapper = mount(AppConditionPill, { props: { condition: 'exhausted' } });
    expect(wrapper.classes()).toContain('app-condition-pill');
  });

  // ── BEM condition modifiers ───────────────────────────────────────────────

  it.each(CONDITIONS)('applies app-condition-pill--%s for condition=%s', (condition) => {
    const wrapper = mount(AppConditionPill, { props: { condition } });
    expect(wrapper.classes()).toContain(`app-condition-pill--${condition}`);
  });

  it('applies exactly one condition class', () => {
    const wrapper = mount(AppConditionPill, { props: { condition: 'thirsty' } });
    const condClasses = wrapper
      .classes()
      .filter((c) => CONDITIONS.some((k) => c === `app-condition-pill--${k}`));
    expect(condClasses).toHaveLength(1);
    expect(condClasses[0]).toBe('app-condition-pill--thirsty');
  });

  // ── BEM size modifiers ────────────────────────────────────────────────────

  it.each(SIZES)('applies app-condition-pill--%s for size=%s', (size) => {
    const wrapper = mount(AppConditionPill, { props: { condition: 'exhausted', size } });
    expect(wrapper.classes()).toContain(`app-condition-pill--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppConditionPill, { props: { condition: 'hungry' } });
    expect(wrapper.classes()).toContain('app-condition-pill--md');
  });

  // ── aria-pressed ──────────────────────────────────────────────────────────

  it('sets aria-pressed="false" when modelValue is false', () => {
    const wrapper = mount(AppConditionPill, {
      props: { condition: 'exhausted', modelValue: false },
    });
    expect(wrapper.attributes('aria-pressed')).toBe('false');
  });

  it('sets aria-pressed="true" when modelValue is true', () => {
    const wrapper = mount(AppConditionPill, {
      props: { condition: 'exhausted', modelValue: true },
    });
    expect(wrapper.attributes('aria-pressed')).toBe('true');
  });

  // ── Active state ──────────────────────────────────────────────────────────

  it('applies app-condition-pill--active when modelValue is true', () => {
    const wrapper = mount(AppConditionPill, {
      props: { condition: 'sleepless', modelValue: true },
    });
    expect(wrapper.classes()).toContain('app-condition-pill--active');
  });

  it('does not apply app-condition-pill--active when modelValue is false', () => {
    const wrapper = mount(AppConditionPill, {
      props: { condition: 'sleepless', modelValue: false },
    });
    expect(wrapper.classes()).not.toContain('app-condition-pill--active');
  });

  // ── Toggle / emit ─────────────────────────────────────────────────────────

  it('emits update:modelValue with true when clicked while inactive', async () => {
    const wrapper = mount(AppConditionPill, {
      props: { condition: 'exhausted', modelValue: false },
    });
    await wrapper.trigger('click');
    expect(wrapper.emitted('update:modelValue')).toEqual([[true]]);
  });

  it('emits update:modelValue with false when clicked while active', async () => {
    const wrapper = mount(AppConditionPill, {
      props: { condition: 'exhausted', modelValue: true },
    });
    await wrapper.trigger('click');
    expect(wrapper.emitted('update:modelValue')).toEqual([[false]]);
  });

  it('does not emit update:modelValue when disabled', async () => {
    const wrapper = mount(AppConditionPill, {
      props: { condition: 'exhausted', modelValue: false, disabled: true },
    });
    await wrapper.trigger('click');
    expect(wrapper.emitted('update:modelValue')).toBeUndefined();
  });

  // ── Disabled state ────────────────────────────────────────────────────────

  it('applies app-condition-pill--disabled when disabled', () => {
    const wrapper = mount(AppConditionPill, {
      props: { condition: 'hungry', disabled: true },
    });
    expect(wrapper.classes()).toContain('app-condition-pill--disabled');
  });

  it('has the disabled attribute when disabled', () => {
    const wrapper = mount(AppConditionPill, {
      props: { condition: 'hungry', disabled: true },
    });
    expect(wrapper.attributes('disabled')).toBeDefined();
  });

  // ── Icon per condition ────────────────────────────────────────────────────

  it.each(CONDITIONS)('renders the correct icon for condition=%s', (condition) => {
    const wrapper = mount(AppConditionPill, { props: { condition } });
    // AppIcon receives the name as a prop; find the inner span with class app-icon
    const iconWrapper = wrapper.findComponent({ name: 'AppIcon' });
    expect(iconWrapper.exists()).toBe(true);
    expect(iconWrapper.props('name')).toBe(ICON_MAP[condition]);
  });

  // ── Default label (no slot) ───────────────────────────────────────────────

  it.each(CONDITIONS)(
    'renders capitalised condition name as default label for %s',
    (condition) => {
      const wrapper = mount(AppConditionPill, { props: { condition } });
      const label = wrapper.find('.app-condition-pill__label');
      const expected = condition.charAt(0).toUpperCase() + condition.slice(1);
      expect(label.text()).toContain(expected);
    },
  );

  // ── Slot label ────────────────────────────────────────────────────────────

  it('renders custom slot content in the label', () => {
    const wrapper = mount(AppConditionPill, {
      props: { condition: 'exhausted' },
      slots: { default: 'Истощение' },
    });
    expect(wrapper.find('.app-condition-pill__label').text()).toContain('Истощение');
  });

  it('prefers slot content over the default label', () => {
    const wrapper = mount(AppConditionPill, {
      props: { condition: 'sleepless' },
      slots: { default: 'Custom' },
    });
    const label = wrapper.find('.app-condition-pill__label');
    expect(label.text()).not.toContain('Sleepless');
    expect(label.text()).toContain('Custom');
  });
});
