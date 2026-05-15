import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppSwash from './AppSwash.vue';

const COLORS = ['brass', 'brass-deep', 'brass-light'] as const;

describe('AppSwash', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a <span> root element with the app-swash class', () => {
    const wrapper = mount(AppSwash);
    expect(wrapper.element.tagName).toBe('SPAN');
    expect(wrapper.classes()).toContain('app-swash');
  });

  // ── SVG accessibility ─────────────────────────────────────────────────────

  it('renders an <svg> with role="presentation"', () => {
    const wrapper = mount(AppSwash);
    const svg = wrapper.find('svg');
    expect(svg.exists()).toBe(true);
    expect(svg.attributes('role')).toBe('presentation');
  });

  it('sets aria-hidden="true" on the SVG', () => {
    const wrapper = mount(AppSwash);
    expect(wrapper.find('svg').attributes('aria-hidden')).toBe('true');
  });

  // ── Path + dot rendering ──────────────────────────────────────────────────

  it('renders a <path> with the swash stroke', () => {
    const wrapper = mount(AppSwash);
    const path = wrapper.find('path.app-swash__path');
    expect(path.exists()).toBe(true);
    expect(path.attributes('d')).toBeTruthy();
  });

  it('renders a centre <circle> dot at (60, 5)', () => {
    const wrapper = mount(AppSwash);
    const dot = wrapper.find('circle.app-swash__dot');
    expect(dot.exists()).toBe(true);
    expect(dot.attributes('cx')).toBe('60');
    expect(dot.attributes('cy')).toBe('5');
  });

  // ── Width prop ────────────────────────────────────────────────────────────

  it('defaults to width=80', () => {
    const wrapper = mount(AppSwash);
    expect(wrapper.find('svg').attributes('width')).toBe('80');
  });

  it('forwards a custom width to the SVG', () => {
    const wrapper = mount(AppSwash, { props: { width: 220 } });
    expect(wrapper.find('svg').attributes('width')).toBe('220');
  });

  it('keeps the height fixed at 10 regardless of width', () => {
    const wrapper = mount(AppSwash, { props: { width: 220 } });
    expect(wrapper.find('svg').attributes('height')).toBe('10');
  });

  // ── Color modifiers ───────────────────────────────────────────────────────

  it.each(COLORS)('applies BEM color modifier app-swash--%s', (color) => {
    const wrapper = mount(AppSwash, { props: { color } });
    expect(wrapper.classes()).toContain(`app-swash--${color}`);
  });

  it('defaults to color=brass', () => {
    const wrapper = mount(AppSwash);
    expect(wrapper.classes()).toContain('app-swash--brass');
  });
});
