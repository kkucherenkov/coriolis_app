import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppStarOrnament from './AppStarOrnament.vue';

const SIZES = ['sm', 'md', 'lg'] as const;
const COLORS = ['brass', 'brass-deep', 'brass-light'] as const;
const VARIANTS = ['filled', 'outlined'] as const;

describe('AppStarOrnament', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a <span> root element with the app-star-ornament class', () => {
    const wrapper = mount(AppStarOrnament);
    expect(wrapper.element.tagName).toBe('SPAN');
    expect(wrapper.classes()).toContain('app-star-ornament');
  });

  // ── SVG accessibility ─────────────────────────────────────────────────────

  it('renders an <svg> with role="presentation"', () => {
    const wrapper = mount(AppStarOrnament);
    const svg = wrapper.find('svg');
    expect(svg.exists()).toBe(true);
    expect(svg.attributes('role')).toBe('presentation');
  });

  it('sets aria-hidden="true" on the SVG', () => {
    const wrapper = mount(AppStarOrnament);
    expect(wrapper.find('svg').attributes('aria-hidden')).toBe('true');
  });

  // ── Star shape — handoff geometry (two rects + centre dot) ───────────────

  it('renders two <rect> elements forming the overlapping squares', () => {
    const wrapper = mount(AppStarOrnament);
    const rects = wrapper.findAll('rect');
    expect(rects).toHaveLength(2);
  });

  it('rotates the second rect 45° around the centre (16,16)', () => {
    const wrapper = mount(AppStarOrnament);
    const rects = wrapper.findAll('rect');
    expect(rects[0]!.attributes('transform')).toBeFalsy();
    expect(rects[1]!.attributes('transform')).toBe('rotate(45 16 16)');
  });

  it('renders a centre dot <circle>', () => {
    const wrapper = mount(AppStarOrnament);
    const circle = wrapper.find('circle.app-star-ornament__dot');
    expect(circle.exists()).toBe(true);
    expect(circle.attributes('cx')).toBe('16');
    expect(circle.attributes('cy')).toBe('16');
  });

  it('uses viewBox 0 0 32 32 (handoff canvas)', () => {
    const wrapper = mount(AppStarOrnament);
    // SVG attributes are case-sensitive; jsdom preserves the mixed-case
    // `viewBox` form. We probe both keys for resilience against test-utils
    // version-to-version casing changes.
    const attrs = wrapper.find('svg').attributes();
    expect(attrs.viewBox ?? attrs.viewbox).toBe('0 0 32 32');
  });

  // ── Variant prop (T-AUDIT-2026-05-15-STAR-VARIANT) ───────────────────────

  it.each(VARIANTS)('applies BEM variant modifier app-star-ornament--%s', (variant) => {
    const wrapper = mount(AppStarOrnament, { props: { variant } });
    expect(wrapper.classes()).toContain(`app-star-ornament--${variant}`);
  });

  it('defaults to variant=filled', () => {
    const wrapper = mount(AppStarOrnament);
    expect(wrapper.classes()).toContain('app-star-ornament--filled');
  });

  it('filled variant centre dot has radius 2 (handoff StarFilled)', () => {
    const wrapper = mount(AppStarOrnament, { props: { variant: 'filled' } });
    expect(wrapper.find('circle').attributes('r')).toBe('2');
  });

  it('outlined variant centre dot has radius 2.2 (handoff StarOrnament)', () => {
    const wrapper = mount(AppStarOrnament, { props: { variant: 'outlined' } });
    expect(wrapper.find('circle').attributes('r')).toBe('2.2');
  });

  // ── Size modifiers ────────────────────────────────────────────────────────

  it.each(SIZES)('applies BEM size modifier app-star-ornament--%s', (size) => {
    const wrapper = mount(AppStarOrnament, { props: { size } });
    expect(wrapper.classes()).toContain(`app-star-ornament--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppStarOrnament);
    expect(wrapper.classes()).toContain('app-star-ornament--md');
  });

  it('sets width=16 for size=sm', () => {
    const wrapper = mount(AppStarOrnament, { props: { size: 'sm' } });
    expect(wrapper.find('svg').attributes('width')).toBe('16');
  });

  it('sets width=24 for size=md', () => {
    const wrapper = mount(AppStarOrnament, { props: { size: 'md' } });
    expect(wrapper.find('svg').attributes('width')).toBe('24');
  });

  it('sets width=56 for size=lg', () => {
    const wrapper = mount(AppStarOrnament, { props: { size: 'lg' } });
    expect(wrapper.find('svg').attributes('width')).toBe('56');
  });

  // ── Color modifiers ───────────────────────────────────────────────────────

  it.each(COLORS)('applies BEM color modifier app-star-ornament--%s', (color) => {
    const wrapper = mount(AppStarOrnament, { props: { color } });
    expect(wrapper.classes()).toContain(`app-star-ornament--${color}`);
  });

  it('defaults to color=brass', () => {
    const wrapper = mount(AppStarOrnament);
    expect(wrapper.classes()).toContain('app-star-ornament--brass');
  });

  // ── Opacity prop ──────────────────────────────────────────────────────────

  it('does not set inline style when opacity=1 (default)', () => {
    const wrapper = mount(AppStarOrnament, { props: { opacity: 1 } });
    const style = wrapper.attributes('style') ?? '';
    expect(style).not.toContain('opacity');
  });

  it('sets inline opacity style when opacity < 1', () => {
    const wrapper = mount(AppStarOrnament, { props: { opacity: 0.5 } });
    const style = wrapper.attributes('style') ?? '';
    expect(style).toContain('opacity');
  });
});
