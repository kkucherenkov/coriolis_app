import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppArabesqueCorner from './AppArabesqueCorner.vue';
import type { ArabesqueOrientation } from './AppArabesqueCorner.vue';

const ORIENTATIONS: ArabesqueOrientation[] = ['tl', 'tr', 'bl', 'br'];
const SIZES = ['sm', 'md', 'lg'] as const;
const COLORS = ['brass', 'brass-deep'] as const;

describe('AppArabesqueCorner', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a <span> root element with the app-arabesque-corner class', () => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'tl' } });
    expect(wrapper.element.tagName).toBe('SPAN');
    expect(wrapper.classes()).toContain('app-arabesque-corner');
  });

  // ── SVG accessibility ─────────────────────────────────────────────────────

  it('renders an <svg> with role="presentation"', () => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'tl' } });
    const svg = wrapper.find('svg');
    expect(svg.exists()).toBe(true);
    expect(svg.attributes('role')).toBe('presentation');
  });

  it('sets aria-hidden="true" on the SVG', () => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'br' } });
    expect(wrapper.find('svg').attributes('aria-hidden')).toBe('true');
  });

  // ── Path rendering ────────────────────────────────────────────────────────

  it('renders a <path> element with the arabesque stroke', () => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'tl' } });
    const path = wrapper.find('path.app-arabesque-corner__path');
    expect(path.exists()).toBe(true);
    expect(path.attributes('d')).toBeTruthy();
  });

  // ── Orientation modifiers ─────────────────────────────────────────────────

  it.each(ORIENTATIONS)(
    'applies BEM orientation modifier app-arabesque-corner--%s',
    (orientation) => {
      const wrapper = mount(AppArabesqueCorner, { props: { orientation } });
      expect(wrapper.classes()).toContain(`app-arabesque-corner--${orientation}`);
    },
  );

  // ── Rotation per orientation ──────────────────────────────────────────────

  it('does not apply a transform for orientation=tl (canonical)', () => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'tl' } });
    const g = wrapper.find('g');
    expect(g.exists()).toBe(true);
    // tl has no rotation — transform should be absent or undefined
    const transform = g.attributes('transform');
    expect(transform).toBeFalsy();
  });

  it('applies rotate(90 50 50) for orientation=tr', () => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'tr' } });
    expect(wrapper.find('g').attributes('transform')).toBe('rotate(90 50 50)');
  });

  it('applies rotate(180 50 50) for orientation=br', () => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'br' } });
    expect(wrapper.find('g').attributes('transform')).toBe('rotate(180 50 50)');
  });

  it('applies rotate(270 50 50) for orientation=bl', () => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'bl' } });
    expect(wrapper.find('g').attributes('transform')).toBe('rotate(270 50 50)');
  });

  // ── Size modifiers ────────────────────────────────────────────────────────

  it.each(SIZES)('applies BEM size modifier app-arabesque-corner--%s', (size) => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'tl', size } });
    expect(wrapper.classes()).toContain(`app-arabesque-corner--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'tl' } });
    expect(wrapper.classes()).toContain('app-arabesque-corner--md');
  });

  it('sets width=36 for size=sm', () => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'tl', size: 'sm' } });
    expect(wrapper.find('svg').attributes('width')).toBe('36');
  });

  it('sets width=64 for size=md', () => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'tl', size: 'md' } });
    expect(wrapper.find('svg').attributes('width')).toBe('64');
  });

  it('sets width=96 for size=lg', () => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'tl', size: 'lg' } });
    expect(wrapper.find('svg').attributes('width')).toBe('96');
  });

  // ── Color modifiers ───────────────────────────────────────────────────────

  it.each(COLORS)('applies BEM color modifier app-arabesque-corner--%s', (color) => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'tl', color } });
    expect(wrapper.classes()).toContain(`app-arabesque-corner--${color}`);
  });

  it('defaults to color=brass', () => {
    const wrapper = mount(AppArabesqueCorner, { props: { orientation: 'tl' } });
    expect(wrapper.classes()).toContain('app-arabesque-corner--brass');
  });
});
