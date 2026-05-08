import { mount } from '@vue/test-utils';
import { describe, expect, it, vi } from 'vitest';

import AppIconCoriolis from './AppIconCoriolis.vue';
import type { IconCoriolisName } from './AppIconCoriolis.vue';

const ALL_NAMES: IconCoriolisName[] = [
  'lady-of-tears',
  'traveler',
  'messenger',
  'merchant',
  'dancer',
  'gambler',
  'judge',
  'faceless-one',
  'deckhand',
];

const SIZES = ['sm', 'md', 'lg'] as const;
const COLORS = ['brass', 'mystic'] as const;

describe('AppIconCoriolis', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a <span> root element with the app-icon-coriolis class', () => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name: 'traveler', ariaLabel: 'The Traveler' },
    });
    expect(wrapper.element.tagName).toBe('SPAN');
    expect(wrapper.classes()).toContain('app-icon-coriolis');
  });

  it('contains an <svg> with role="img"', () => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name: 'traveler', ariaLabel: 'The Traveler' },
    });
    const svg = wrapper.find('svg');
    expect(svg.exists()).toBe(true);
    expect(svg.attributes('role')).toBe('img');
  });

  // ── SVG per name ──────────────────────────────────────────────────────────

  it.each(ALL_NAMES)('renders non-empty SVG content for name="%s"', (name) => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name, ariaLabel: name },
    });
    const svg = wrapper.find('svg');
    expect(svg.exists()).toBe(true);
    // SVG should have inner HTML (the path/shape content)
    expect(svg.html()).not.toBe('<svg></svg>');
  });

  it.each(ALL_NAMES)('applies BEM name modifier app-icon-coriolis--%s', (name) => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name, ariaLabel: name },
    });
    expect(wrapper.classes()).toContain(`app-icon-coriolis--${name}`);
  });

  // ── Aria-label ────────────────────────────────────────────────────────────

  it('renders the aria-label on the SVG element', () => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name: 'judge', ariaLabel: 'The Judge' },
    });
    expect(wrapper.find('svg').attributes('aria-label')).toBe('The Judge');
  });

  it('renders a localized aria-label when provided', () => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name: 'dancer', ariaLabel: 'Танцор' },
    });
    expect(wrapper.find('svg').attributes('aria-label')).toBe('Танцор');
  });

  // ── Size modifiers ────────────────────────────────────────────────────────

  it.each(SIZES)('applies BEM size modifier app-icon-coriolis--%s', (size) => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name: 'merchant', size, ariaLabel: 'The Merchant' },
    });
    expect(wrapper.classes()).toContain(`app-icon-coriolis--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name: 'gambler', ariaLabel: 'The Gambler' },
    });
    expect(wrapper.classes()).toContain('app-icon-coriolis--md');
  });

  it('applies exactly one size class', () => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name: 'deckhand', size: 'lg', ariaLabel: 'The Deckhand' },
    });
    const sizeClasses = wrapper.classes().filter((c) => SIZES.some((s) => c === `app-icon-coriolis--${s}`));
    expect(sizeClasses).toHaveLength(1);
    expect(sizeClasses[0]).toBe('app-icon-coriolis--lg');
  });

  // ── SVG size attribute ────────────────────────────────────────────────────

  it('sets width/height to 24 for size=sm', () => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name: 'traveler', size: 'sm', ariaLabel: 'The Traveler' },
    });
    const svg = wrapper.find('svg');
    expect(svg.attributes('width')).toBe('24');
    expect(svg.attributes('height')).toBe('24');
  });

  it('sets width/height to 32 for size=md', () => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name: 'traveler', size: 'md', ariaLabel: 'The Traveler' },
    });
    const svg = wrapper.find('svg');
    expect(svg.attributes('width')).toBe('32');
    expect(svg.attributes('height')).toBe('32');
  });

  it('sets width/height to 64 for size=lg', () => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name: 'messenger', size: 'lg', ariaLabel: 'The Messenger' },
    });
    const svg = wrapper.find('svg');
    expect(svg.attributes('width')).toBe('64');
    expect(svg.attributes('height')).toBe('64');
  });

  // ── Color modifiers ───────────────────────────────────────────────────────

  it.each(COLORS)('applies BEM color modifier app-icon-coriolis--%s', (color) => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name: 'faceless-one', color, ariaLabel: 'The Faceless One' },
    });
    expect(wrapper.classes()).toContain(`app-icon-coriolis--${color}`);
  });

  it('defaults to color=brass', () => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name: 'lady-of-tears', ariaLabel: 'The Lady of Tears' },
    });
    expect(wrapper.classes()).toContain('app-icon-coriolis--brass');
  });

  // ── Unknown name warning ──────────────────────────────────────────────────

  it('emits a console.warn for an unknown name', () => {
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => undefined);
    mount(AppIconCoriolis, {
      props: { name: 'unknown-icon' as unknown as IconCoriolisName, ariaLabel: 'Unknown' },
    });
    expect(warn).toHaveBeenCalledWith(expect.stringContaining('[AppIconCoriolis]'));
    warn.mockRestore();
  });

  // ── SVG viewBox ───────────────────────────────────────────────────────────

  it('uses a 24×24 viewBox', () => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name: 'traveler', ariaLabel: 'The Traveler' },
    });
    expect(wrapper.find('svg').attributes('viewBox')).toBe('0 0 24 24');
  });

  // ── stroke-width ──────────────────────────────────────────────────────────

  it('sets stroke-width to 1.5', () => {
    const wrapper = mount(AppIconCoriolis, {
      props: { name: 'dancer', ariaLabel: 'The Dancer' },
    });
    expect(wrapper.find('svg').attributes('stroke-width')).toBe('1.5');
  });
});
