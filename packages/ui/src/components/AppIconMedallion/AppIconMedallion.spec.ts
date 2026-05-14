import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppIconMedallion from './AppIconMedallion.vue';

describe('AppIconMedallion', () => {
  // ── Root rendering ────────────────────────────────────────────────────────

  it('renders the BEM root class', () => {
    const wrapper = mount(AppIconMedallion, { props: { letter: 'T' } });
    expect(wrapper.classes()).toContain('app-icon-medallion');
  });

  it('renders the monogram letter inside the SVG <text>', () => {
    const wrapper = mount(AppIconMedallion, { props: { letter: 'T' } });
    expect(wrapper.find('.app-icon-medallion__letter').text()).toBe('T');
  });

  // ── Size + scaling ────────────────────────────────────────────────────────

  it('defaults the medallion to 64 CSS pixels', () => {
    const wrapper = mount(AppIconMedallion, { props: { letter: 'T' } });
    const root = wrapper.find('[data-testid="app-icon-medallion"]');
    expect(root.attributes('style')).toContain('--app-icon-medallion-size: 64px');
    const svg = wrapper.find('.app-icon-medallion__svg');
    expect(svg.attributes('width')).toBe('64');
    expect(svg.attributes('height')).toBe('64');
  });

  it('reflects a custom size into both CSS var and SVG attrs', () => {
    const wrapper = mount(AppIconMedallion, { props: { letter: 'F', size: 48 } });
    const root = wrapper.find('[data-testid="app-icon-medallion"]');
    expect(root.attributes('style')).toContain('--app-icon-medallion-size: 48px');
    const svg = wrapper.find('.app-icon-medallion__svg');
    expect(svg.attributes('width')).toBe('48');
    expect(svg.attributes('height')).toBe('48');
  });

  it('scales the letter font-size at size × 0.5 (handoff ratio)', () => {
    const wrapper = mount(AppIconMedallion, { props: { letter: 'T', size: 64 } });
    // 64 × 0.5 = 32
    expect(wrapper.find('.app-icon-medallion__letter').attributes('font-size')).toBe('32');
  });

  // ── Astrolabe geometry ────────────────────────────────────────────────────

  it('renders exactly 16 astrolabe tick marks', () => {
    const wrapper = mount(AppIconMedallion, { props: { letter: 'T' } });
    expect(wrapper.findAll('.app-icon-medallion__tick')).toHaveLength(16);
  });

  it('renders the outer + inner concentric astrolabe rings', () => {
    const wrapper = mount(AppIconMedallion, { props: { letter: 'T' } });
    expect(wrapper.find('.app-icon-medallion__ring--outer').exists()).toBe(true);
    expect(wrapper.find('.app-icon-medallion__ring--inner').exists()).toBe(true);
  });

  // ── Glow state ────────────────────────────────────────────────────────────

  it('does not render the halo by default', () => {
    const wrapper = mount(AppIconMedallion, { props: { letter: 'T' } });
    expect(wrapper.find('.app-icon-medallion__halo').exists()).toBe(false);
    expect(wrapper.classes()).not.toContain('app-icon-medallion--glow');
  });

  it('layers a mystic halo when glow=true (selected Icon)', () => {
    const wrapper = mount(AppIconMedallion, {
      props: { letter: 'F', glow: true, label: 'The Faceless One' },
    });
    expect(wrapper.find('.app-icon-medallion__halo').exists()).toBe(true);
    expect(wrapper.classes()).toContain('app-icon-medallion--glow');
  });

  // ── Gradient id isolation (multiple instances) ────────────────────────────

  it('uses a unique radialGradient id per instance to avoid collisions', () => {
    // Mount two medallions inside a single host so Vue's useId() shares the
    // sequence across instances (a fresh `mount()` resets the counter and
    // would produce the same `v-0` id twice).
    const host = mount({
      components: { AppIconMedallion },
      template: '<div><AppIconMedallion letter="T" /><AppIconMedallion letter="T" /></div>',
    });
    const gradients = host.findAll('radialGradient');
    expect(gradients).toHaveLength(2);
    const idA = gradients[0]?.attributes('id');
    const idB = gradients[1]?.attributes('id');
    expect(idA).toBeTruthy();
    expect(idB).toBeTruthy();
    expect(idA).not.toBe(idB);
  });

  it('points the disc fill at its own gradient id', () => {
    const wrapper = mount(AppIconMedallion, { props: { letter: 'T' } });
    const gradId = wrapper.find('radialGradient').attributes('id')!;
    const discFill = wrapper.find('circle[r="30"]').attributes('fill');
    expect(discFill).toBe(`url(#${gradId})`);
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  it('exposes the medallion as role="img" with the label when provided', () => {
    const wrapper = mount(AppIconMedallion, {
      props: { letter: 'T', label: 'The Traveler' },
    });
    const root = wrapper.find('[data-testid="app-icon-medallion"]');
    expect(root.attributes('role')).toBe('img');
    expect(root.attributes('aria-label')).toBe('The Traveler');
    expect(root.attributes('aria-hidden')).toBeUndefined();
  });

  it('is decorative (aria-hidden) when no label is given', () => {
    const wrapper = mount(AppIconMedallion, { props: { letter: 'T' } });
    const root = wrapper.find('[data-testid="app-icon-medallion"]');
    expect(root.attributes('aria-hidden')).toBe('true');
    expect(root.attributes('role')).toBeUndefined();
  });
});
