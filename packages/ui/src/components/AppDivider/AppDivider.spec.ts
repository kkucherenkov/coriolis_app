import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppDivider from './AppDivider.vue';

const TONES = ['brass-deep', 'brass-shadow', 'brass'] as const;
const WEIGHTS = ['hairline', 'thin', 'medium'] as const;

describe('AppDivider', () => {
  // ── Horizontal (default) ──────────────────────────────────────────────────

  it('renders <hr> for horizontal orientation', () => {
    const wrapper = mount(AppDivider);
    expect(wrapper.element.tagName).toBe('HR');
  });

  it('horizontal <hr> has implicit role via native element', () => {
    const wrapper = mount(AppDivider);
    // <hr> carries implicit role="separator" — we verify the element tag
    expect(wrapper.element.tagName).toBe('HR');
  });

  it('applies app-divider base class for horizontal', () => {
    const wrapper = mount(AppDivider);
    expect(wrapper.classes()).toContain('app-divider');
  });

  it('applies app-divider--horizontal modifier by default', () => {
    const wrapper = mount(AppDivider);
    expect(wrapper.classes()).toContain('app-divider--horizontal');
  });

  it('defaults to tone=brass-deep', () => {
    const wrapper = mount(AppDivider);
    expect(wrapper.classes()).toContain('app-divider--brass-deep');
  });

  it('defaults to weight=hairline', () => {
    const wrapper = mount(AppDivider);
    expect(wrapper.classes()).toContain('app-divider--hairline');
  });

  it('does not apply app-divider--inset by default', () => {
    const wrapper = mount(AppDivider);
    expect(wrapper.classes()).not.toContain('app-divider--inset');
  });

  // ── Vertical ───────────────────────────────────────────────────────────────

  it('renders <div> for vertical orientation', () => {
    const wrapper = mount(AppDivider, { props: { orientation: 'vertical' } });
    expect(wrapper.element.tagName).toBe('DIV');
  });

  it('vertical element has role="separator"', () => {
    const wrapper = mount(AppDivider, { props: { orientation: 'vertical' } });
    expect(wrapper.attributes('role')).toBe('separator');
  });

  it('vertical element has aria-orientation="vertical"', () => {
    const wrapper = mount(AppDivider, { props: { orientation: 'vertical' } });
    expect(wrapper.attributes('aria-orientation')).toBe('vertical');
  });

  it('applies app-divider--vertical modifier', () => {
    const wrapper = mount(AppDivider, { props: { orientation: 'vertical' } });
    expect(wrapper.classes()).toContain('app-divider--vertical');
  });

  it('vertical does not also have app-divider--horizontal class', () => {
    const wrapper = mount(AppDivider, { props: { orientation: 'vertical' } });
    expect(wrapper.classes()).not.toContain('app-divider--horizontal');
  });

  // ── Tone modifiers ────────────────────────────────────────────────────────

  it.each(TONES)('applies app-divider--%s modifier for tone=%s', (tone) => {
    const wrapper = mount(AppDivider, { props: { tone } });
    expect(wrapper.classes()).toContain(`app-divider--${tone}`);
  });

  it('applies exactly one tone class', () => {
    const wrapper = mount(AppDivider, { props: { tone: 'brass' } });
    const toneClasses = wrapper
      .classes()
      .filter((c) => TONES.some((t) => c === `app-divider--${t}`));
    expect(toneClasses).toHaveLength(1);
    expect(toneClasses[0]).toBe('app-divider--brass');
  });

  // ── Weight modifiers ──────────────────────────────────────────────────────

  it.each(WEIGHTS)('applies app-divider--%s modifier for weight=%s', (weight) => {
    const wrapper = mount(AppDivider, { props: { weight } });
    expect(wrapper.classes()).toContain(`app-divider--${weight}`);
  });

  it('applies exactly one weight class', () => {
    const wrapper = mount(AppDivider, { props: { weight: 'medium' } });
    const weightClasses = wrapper
      .classes()
      .filter((c) => WEIGHTS.some((w) => c === `app-divider--${w}`));
    expect(weightClasses).toHaveLength(1);
    expect(weightClasses[0]).toBe('app-divider--medium');
  });

  // ── Inset modifier ────────────────────────────────────────────────────────

  it('applies app-divider--inset when inset=true', () => {
    const wrapper = mount(AppDivider, { props: { inset: true } });
    expect(wrapper.classes()).toContain('app-divider--inset');
  });

  it('does not apply app-divider--inset when inset=false', () => {
    const wrapper = mount(AppDivider, { props: { inset: false } });
    expect(wrapper.classes()).not.toContain('app-divider--inset');
  });

  // ── No slot ───────────────────────────────────────────────────────────────

  it('renders no child nodes for horizontal (line only)', () => {
    const wrapper = mount(AppDivider);
    expect(wrapper.element.childNodes.length).toBe(0);
  });

  it('renders no child nodes for vertical (line only)', () => {
    const wrapper = mount(AppDivider, { props: { orientation: 'vertical' } });
    expect(wrapper.element.childNodes.length).toBe(0);
  });
});
