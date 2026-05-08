import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppLabel from './AppLabel.vue';

const TONES = ['default', 'eyebrow', 'stat-block'] as const;

describe('AppLabel', () => {
  // ── Root element — conditional label vs span ───────────────────────────────

  it('renders a <span> root element when "for" prop is absent', () => {
    const wrapper = mount(AppLabel, { slots: { default: 'Strength' } });
    expect(wrapper.element.tagName).toBe('SPAN');
  });

  it('renders a <label> root element when "for" prop is provided', () => {
    const wrapper = mount(AppLabel, { props: { for: 'input-id' }, slots: { default: 'Strength' } });
    expect(wrapper.element.tagName).toBe('LABEL');
  });

  it('sets the `for` attribute on the <label> element', () => {
    const wrapper = mount(AppLabel, { props: { for: 'my-input' }, slots: { default: 'Name' } });
    expect(wrapper.attributes('for')).toBe('my-input');
  });

  it('does not set a `for` attribute when prop is absent', () => {
    const wrapper = mount(AppLabel, { slots: { default: 'Name' } });
    expect(wrapper.attributes('for')).toBeUndefined();
  });

  // ── Base class ────────────────────────────────────────────────────────────

  it('applies the app-label base class', () => {
    const wrapper = mount(AppLabel, { slots: { default: 'Label' } });
    expect(wrapper.classes()).toContain('app-label');
  });

  // ── Tone BEM modifiers ────────────────────────────────────────────────────

  it.each(TONES)('applies app-label--%s modifier for tone=%s', (tone) => {
    const wrapper = mount(AppLabel, { props: { tone }, slots: { default: 'Label' } });
    expect(wrapper.classes()).toContain(`app-label--${tone}`);
  });

  it('defaults to tone=default', () => {
    const wrapper = mount(AppLabel, { slots: { default: 'Label' } });
    expect(wrapper.classes()).toContain('app-label--default');
  });

  it('applies exactly one tone class', () => {
    const wrapper = mount(AppLabel, { props: { tone: 'eyebrow' }, slots: { default: 'Label' } });
    const toneClasses = wrapper.classes().filter((c) => TONES.some((t) => c === `app-label--${t}`));
    expect(toneClasses).toHaveLength(1);
    expect(toneClasses[0]).toBe('app-label--eyebrow');
  });

  // ── Default slot ──────────────────────────────────────────────────────────

  it('renders default slot content inside .app-label__text', () => {
    const wrapper = mount(AppLabel, { slots: { default: 'Agility' } });
    expect(wrapper.find('.app-label__text').text()).toContain('Agility');
  });

  // ── Required marker ───────────────────────────────────────────────────────

  it('does not render the required marker by default', () => {
    const wrapper = mount(AppLabel, { slots: { default: 'Label' } });
    expect(wrapper.find('.app-label__required').exists()).toBe(false);
  });

  it('renders the required marker when required=true', () => {
    const wrapper = mount(AppLabel, { props: { required: true }, slots: { default: 'Email' } });
    const marker = wrapper.find('.app-label__required');
    expect(marker.exists()).toBe(true);
    expect(marker.text()).toBe('*');
  });

  it('sets aria-label="required" on the required marker', () => {
    const wrapper = mount(AppLabel, { props: { required: true }, slots: { default: 'Email' } });
    const marker = wrapper.find('.app-label__required');
    expect(marker.attributes('aria-label')).toBe('required');
  });

  // ── Help text ─────────────────────────────────────────────────────────────

  it('does not render .app-label__help when helpText is absent', () => {
    const wrapper = mount(AppLabel, { slots: { default: 'Label' } });
    expect(wrapper.find('.app-label__help').exists()).toBe(false);
  });

  it('renders .app-label__help when helpText is provided', () => {
    const wrapper = mount(AppLabel, {
      props: { helpText: 'Max 64 characters' },
      slots: { default: 'Character name' },
    });
    const help = wrapper.find('.app-label__help');
    expect(help.exists()).toBe(true);
    expect(help.text()).toBe('Max 64 characters');
  });

  it('applies app-label--with-help modifier when helpText is provided', () => {
    const wrapper = mount(AppLabel, {
      props: { helpText: 'Hint' },
      slots: { default: 'Label' },
    });
    expect(wrapper.classes()).toContain('app-label--with-help');
  });

  it('does not apply app-label--with-help modifier when helpText is absent', () => {
    const wrapper = mount(AppLabel, { slots: { default: 'Label' } });
    expect(wrapper.classes()).not.toContain('app-label--with-help');
  });

  // ── Combination: required + helpText ─────────────────────────────────────

  it('renders both required marker and helpText together', () => {
    const wrapper = mount(AppLabel, {
      props: { required: true, helpText: 'Required field' },
      slots: { default: 'Password' },
    });
    expect(wrapper.find('.app-label__required').exists()).toBe(true);
    expect(wrapper.find('.app-label__help').exists()).toBe(true);
  });

  // ── For + tone combination ────────────────────────────────────────────────

  it('renders as <label> with eyebrow tone when both for and tone="eyebrow" are set', () => {
    const wrapper = mount(AppLabel, {
      props: { for: 'stat-input', tone: 'eyebrow' },
      slots: { default: 'Strength' },
    });
    expect(wrapper.element.tagName).toBe('LABEL');
    expect(wrapper.classes()).toContain('app-label--eyebrow');
    expect(wrapper.attributes('for')).toBe('stat-input');
  });
});
