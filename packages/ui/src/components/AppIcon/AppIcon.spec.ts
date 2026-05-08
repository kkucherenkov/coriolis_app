import { mount } from '@vue/test-utils';
import { describe, expect, it, vi } from 'vitest';

import AppIcon from './AppIcon.vue';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;
const COLORS = ['brass', 'mystic', 'crimson', 'success', 'darkness'] as const;

describe('AppIcon', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a <span> root element', () => {
    const wrapper = mount(AppIcon, { props: { name: 'sword' } });
    expect(wrapper.element.tagName).toBe('SPAN');
  });

  it('applies the app-icon base class', () => {
    const wrapper = mount(AppIcon, { props: { name: 'sword' } });
    expect(wrapper.classes()).toContain('app-icon');
  });

  // ── Named Lucide component ────────────────────────────────────────────────

  it('renders the named Lucide icon component', () => {
    const wrapper = mount(AppIcon, { props: { name: 'sword' } });
    // The Lucide SVG component renders an <svg> inside the span wrapper.
    expect(wrapper.find('svg').exists()).toBe(true);
  });

  it('maps kebab-case to PascalCase for the icon lookup (multi-segment)', () => {
    // "arrow-up-right" → ArrowUpRight — valid Lucide icon
    const wrapper = mount(AppIcon, { props: { name: 'arrow-up-right' } });
    expect(wrapper.find('svg').exists()).toBe(true);
  });

  // ── Size BEM modifiers ────────────────────────────────────────────────────

  it.each(SIZES)('applies app-icon--%s modifier for size=%s', (size) => {
    const wrapper = mount(AppIcon, { props: { name: 'star', size } });
    expect(wrapper.classes()).toContain(`app-icon--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppIcon, { props: { name: 'star' } });
    expect(wrapper.classes()).toContain('app-icon--md');
  });

  // ── Color BEM modifiers ───────────────────────────────────────────────────

  it.each(COLORS)('applies app-icon--%s modifier for color=%s', (color) => {
    const wrapper = mount(AppIcon, { props: { name: 'star', color } });
    expect(wrapper.classes()).toContain(`app-icon--${color}`);
  });

  it('defaults to color=inherit (no color modifier class)', () => {
    const wrapper = mount(AppIcon, { props: { name: 'star' } });
    const colorClasses = wrapper.classes().filter((c) => COLORS.some((col) => c.endsWith(col)));
    expect(colorClasses).toHaveLength(0);
  });

  // ── stroke-width ──────────────────────────────────────────────────────────

  it('passes stroke-width 1.5 to the Lucide SVG by default (DESIGN §4.3)', () => {
    const wrapper = mount(AppIcon, { props: { name: 'shield' } });
    const svg = wrapper.find('svg');
    expect(svg.attributes('stroke-width')).toBe('1.5');
  });

  it('forwards a custom strokeWidth prop to the Lucide SVG', () => {
    const wrapper = mount(AppIcon, { props: { name: 'shield', strokeWidth: 2 } });
    const svg = wrapper.find('svg');
    expect(svg.attributes('stroke-width')).toBe('2');
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  it('marks the root span aria-hidden when no ariaLabel is provided (decorative)', () => {
    const wrapper = mount(AppIcon, { props: { name: 'cog' } });
    expect(wrapper.attributes('aria-hidden')).toBe('true');
    expect(wrapper.attributes('aria-label')).toBeUndefined();
  });

  it('exposes aria-label when provided and removes aria-hidden', () => {
    const wrapper = mount(AppIcon, { props: { name: 'shield', ariaLabel: 'Shield equipped' } });
    expect(wrapper.attributes('aria-label')).toBe('Shield equipped');
    expect(wrapper.attributes('aria-hidden')).toBeUndefined();
  });

  // ── Unknown icon fallback ─────────────────────────────────────────────────

  it('renders an empty span (no svg child) when the icon name is unknown', () => {
    const wrapper = mount(AppIcon, { props: { name: 'not-a-real-icon-xyz' } });
    expect(wrapper.find('svg').exists()).toBe(false);
  });

  it('logs a console.warn for an unknown icon name (no crash)', () => {
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => undefined);
    mount(AppIcon, { props: { name: 'not-a-real-icon-xyz' } });
    expect(warn).toHaveBeenCalledWith(
      expect.stringContaining('[AppIcon] Unknown Lucide icon'),
    );
    warn.mockRestore();
  });
});
