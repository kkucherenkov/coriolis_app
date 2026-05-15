import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppPortrait from './AppPortrait.vue';

describe('AppPortrait', () => {
  // ── Root rendering ────────────────────────────────────────────────────────

  it('renders the BEM root class', () => {
    const wrapper = mount(AppPortrait, { props: { name: 'Aelyn Skarn' } });
    expect(wrapper.classes()).toContain('app-portrait');
  });

  it('renders 24 astrolabe ticks ringing the disc', () => {
    const wrapper = mount(AppPortrait, { props: { name: 'Aelyn Skarn' } });
    expect(wrapper.findAll('.app-portrait__tick')).toHaveLength(24);
  });

  it('renders the outer brass ring circle', () => {
    const wrapper = mount(AppPortrait, { props: { name: 'Aelyn Skarn' } });
    expect(wrapper.find('.app-portrait__ring-circle').exists()).toBe(true);
  });

  // ── Initials derivation ───────────────────────────────────────────────────

  it('derives initials from name (first letters of up to 2 words)', () => {
    const wrapper = mount(AppPortrait, { props: { name: 'Aelyn Skarn' } });
    expect(wrapper.find('.app-portrait__initials').text()).toBe('AS');
  });

  it('uses only the first 2 words when more are present', () => {
    const wrapper = mount(AppPortrait, {
      props: { name: 'Captain Aelyn Skarn of Algol' },
    });
    expect(wrapper.find('.app-portrait__initials').text()).toBe('CA');
  });

  it('uppercases derived initials', () => {
    const wrapper = mount(AppPortrait, { props: { name: 'aelyn skarn' } });
    expect(wrapper.find('.app-portrait__initials').text()).toBe('AS');
  });

  it('handles single-word names with a single initial', () => {
    const wrapper = mount(AppPortrait, { props: { name: 'Skarn' } });
    expect(wrapper.find('.app-portrait__initials').text()).toBe('S');
  });

  it('preserves Cyrillic / non-Latin scripts via code-point iteration', () => {
    const wrapper = mount(AppPortrait, { props: { name: 'Айлин Скарн' } });
    expect(wrapper.find('.app-portrait__initials').text()).toBe('АС');
  });

  it('falls back to "NA" when neither name nor initials are provided', () => {
    const wrapper = mount(AppPortrait);
    expect(wrapper.find('.app-portrait__initials').text()).toBe('NA');
  });

  // ── Initials override ─────────────────────────────────────────────────────

  it('honours the explicit `initials` override over `name`', () => {
    const wrapper = mount(AppPortrait, {
      props: { name: 'Aelyn Skarn', initials: 'XY' },
    });
    expect(wrapper.find('.app-portrait__initials').text()).toBe('XY');
  });

  it('trims an `initials` override longer than 2 characters', () => {
    const wrapper = mount(AppPortrait, { props: { initials: 'ABCDE' } });
    expect(wrapper.find('.app-portrait__initials').text()).toBe('AB');
  });

  // ── Size + scaling ────────────────────────────────────────────────────────

  it('defaults the medallion to 96 CSS pixels via CSS vars + SVG attrs', () => {
    const wrapper = mount(AppPortrait, { props: { name: 'Aelyn Skarn' } });
    const root = wrapper.find('[data-testid="app-portrait"]');
    expect(root.attributes('style')).toContain('--app-portrait-size: 96px');
    // 96 * 0.36 = 34.56
    expect(root.attributes('style')).toContain('--app-portrait-initials-size: 34.56px');
    const svg = wrapper.find('.app-portrait__ring');
    expect(svg.attributes('width')).toBe('96');
    expect(svg.attributes('height')).toBe('96');
  });

  it('scales the initials font-size at size × 0.36 (handoff ratio)', () => {
    // 100 * 0.36 = 36
    const wrapper = mount(AppPortrait, { props: { name: 'AB', size: 100 } });
    expect(wrapper.find('[data-testid="app-portrait"]').attributes('style')).toContain(
      '--app-portrait-initials-size: 36px',
    );
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  it('exposes the portrait as role="img" with name as aria-label', () => {
    const wrapper = mount(AppPortrait, { props: { name: 'Aelyn Skarn' } });
    const root = wrapper.find('[data-testid="app-portrait"]');
    expect(root.attributes('role')).toBe('img');
    expect(root.attributes('aria-label')).toBe('Aelyn Skarn');
  });

  it('uses the explicit `label` override when provided', () => {
    const wrapper = mount(AppPortrait, {
      props: { name: 'Aelyn Skarn', label: 'Player character — Aelyn Skarn' },
    });
    expect(wrapper.find('[data-testid="app-portrait"]').attributes('aria-label')).toBe(
      'Player character — Aelyn Skarn',
    );
  });

  it('falls back to the rendered initials when no name or label is given', () => {
    const wrapper = mount(AppPortrait, { props: { initials: 'NA' } });
    expect(wrapper.find('[data-testid="app-portrait"]').attributes('aria-label')).toBe('NA');
  });

  it('hides the duplicate visual initials from assistive tech', () => {
    const wrapper = mount(AppPortrait, { props: { name: 'Aelyn Skarn' } });
    expect(wrapper.find('.app-portrait__initials').attributes('aria-hidden')).toBe('true');
    expect(wrapper.find('.app-portrait__ring').attributes('aria-hidden')).toBe('true');
  });
});
