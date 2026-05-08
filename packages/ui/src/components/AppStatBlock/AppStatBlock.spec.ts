import { mount } from '@vue/test-utils';
import { describe, expect, it, vi } from 'vitest';

import AppStatBlock from './AppStatBlock.vue';

describe('AppStatBlock', () => {
  // ── Label + value ─────────────────────────────────────────────────────────

  it('renders the label', () => {
    const wrapper = mount(AppStatBlock, { props: { label: 'Strength', value: 3 } });
    expect(wrapper.find('.app-stat-block__label').text()).toBe('Strength');
  });

  it('renders the numeric value', () => {
    const wrapper = mount(AppStatBlock, { props: { label: 'Strength', value: 3 } });
    expect(wrapper.find('.app-stat-block__value').text()).toBe('3');
  });

  // ── Dots row ──────────────────────────────────────────────────────────────

  it('renders dots row by default', () => {
    const wrapper = mount(AppStatBlock, { props: { label: 'AGI', value: 4 } });
    expect(wrapper.find('.app-dots').exists()).toBe(true);
  });

  it('hides dots row when hideDots=true', () => {
    const wrapper = mount(AppStatBlock, {
      props: { label: 'HP', value: 11, max: 12, hideDots: true },
    });
    expect(wrapper.find('.app-dots').exists()).toBe(false);
  });

  // ── Emit: select ──────────────────────────────────────────────────────────

  it('emits select on click when not disabled', async () => {
    const wrapper = mount(AppStatBlock, { props: { label: 'STR', value: 3 } });
    await wrapper.trigger('click');
    expect(wrapper.emitted('select')).toHaveLength(1);
  });

  it('does NOT emit select when disabled', async () => {
    const wrapper = mount(AppStatBlock, {
      props: { label: 'STR', value: 3, disabled: true },
    });
    await wrapper.trigger('click');
    expect(wrapper.emitted('select')).toBeUndefined();
  });

  // ── Element role ──────────────────────────────────────────────────────────

  it('renders as <button> when not disabled', () => {
    const wrapper = mount(AppStatBlock, { props: { label: 'WIT', value: 2 } });
    expect(wrapper.element.tagName).toBe('BUTTON');
  });

  it('renders as <div> when disabled (no button role)', () => {
    const wrapper = mount(AppStatBlock, {
      props: { label: 'WIT', value: 2, disabled: true },
    });
    expect(wrapper.element.tagName).toBe('DIV');
  });

  // ── aria-label ────────────────────────────────────────────────────────────

  it('defaults aria-label to "${label} ${value} of ${max}"', () => {
    const wrapper = mount(AppStatBlock, {
      props: { label: 'Empathy', value: 3, max: 5 },
    });
    expect(wrapper.attributes('aria-label')).toBe('Empathy 3 of 5');
  });

  it('uses custom aria-label when ariaLabel prop is provided', () => {
    const wrapper = mount(AppStatBlock, {
      props: { label: 'EMP', value: 3, ariaLabel: 'Empathy attribute 3 out of 5' },
    });
    expect(wrapper.attributes('aria-label')).toBe('Empathy attribute 3 out of 5');
  });

  // ── BEM modifiers ─────────────────────────────────────────────────────────

  it('applies --brass modifier by default', () => {
    const wrapper = mount(AppStatBlock, { props: { label: 'STR', value: 1 } });
    expect(wrapper.classes()).toContain('app-stat-block--brass');
  });

  it('applies --mystic modifier when tone=mystic', () => {
    const wrapper = mount(AppStatBlock, {
      props: { label: 'Pilot', value: 5, tone: 'mystic' },
    });
    expect(wrapper.classes()).toContain('app-stat-block--mystic');
  });

  it('applies --md size modifier by default', () => {
    const wrapper = mount(AppStatBlock, { props: { label: 'AGI', value: 4 } });
    expect(wrapper.classes()).toContain('app-stat-block--md');
  });

  it('applies --sm size modifier when size=sm', () => {
    const wrapper = mount(AppStatBlock, {
      props: { label: 'HP', value: 11, size: 'sm' },
    });
    expect(wrapper.classes()).toContain('app-stat-block--sm');
  });

  it('applies --disabled modifier when disabled', () => {
    const wrapper = mount(AppStatBlock, {
      props: { label: 'STR', value: 2, disabled: true },
    });
    expect(wrapper.classes()).toContain('app-stat-block--disabled');
  });

  // ── select not emitted via click handler when disabled ────────────────────

  it('click handler guard prevents select emission when disabled prop is reactive', async () => {
    const handler = vi.fn();
    const wrapper = mount(AppStatBlock, {
      props: { label: 'STR', value: 3, disabled: true },
    });
    wrapper.vm.$on?.('select', handler);
    await wrapper.trigger('click');
    expect(handler).not.toHaveBeenCalled();
  });
});
