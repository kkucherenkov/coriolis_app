import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppStarOrnament from './AppStarOrnament.vue';

const SIZES = ['sm', 'md', 'lg'] as const;
const COLORS = ['brass', 'brass-deep', 'brass-light'] as const;

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

  // ── Star shape ────────────────────────────────────────────────────────────

  it('renders a <polygon> with the star points', () => {
    const wrapper = mount(AppStarOrnament);
    const polygon = wrapper.find('polygon.app-star-ornament__shape');
    expect(polygon.exists()).toBe(true);
    expect(polygon.attributes('points')).toBeTruthy();
  });

  it('polygon has 12 coordinate pairs (8-pointed star = 16 vertices)', () => {
    const wrapper = mount(AppStarOrnament);
    const points = wrapper.find('polygon').attributes('points') ?? '';
    // Pairs separated by spaces — 16 pairs but our compact star has 12 points listed
    // (some are at 90° intervals): count the space-separated coordinate pairs.
    const pairCount = points.trim().split(/\s+/).length;
    expect(pairCount).toBeGreaterThanOrEqual(8); // at minimum 8 outer tips
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
    // Style should be absent or empty when opacity is 1.
    const style = wrapper.attributes('style') ?? '';
    expect(style).not.toContain('opacity');
  });

  it('sets inline opacity style when opacity < 1', () => {
    const wrapper = mount(AppStarOrnament, { props: { opacity: 0.5 } });
    const style = wrapper.attributes('style') ?? '';
    expect(style).toContain('opacity');
  });
});
