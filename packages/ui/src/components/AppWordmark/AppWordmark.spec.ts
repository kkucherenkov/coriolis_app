import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppWordmark from './AppWordmark.vue';

describe('AppWordmark', () => {
  // ── Root + accessible name ────────────────────────────────────────────────

  it('renders the app-wordmark root class', () => {
    const wrapper = mount(AppWordmark);
    expect(wrapper.classes()).toContain('app-wordmark');
  });

  it('exposes the lockup as a single img role with a combined accessible name', () => {
    const wrapper = mount(AppWordmark);
    const root = wrapper.find('[data-testid="app-wordmark"]');
    expect(root.attributes('role')).toBe('img');
    expect(root.attributes('aria-label')).toBe('Coriolis Companion');
  });

  it('reflects custom brand + eyebrow into the accessible name', () => {
    const wrapper = mount(AppWordmark, {
      props: { brand: 'Coriolis', eyebrow: 'Спутник' },
    });
    expect(wrapper.find('[data-testid="app-wordmark"]').attributes('aria-label')).toBe(
      'Coriolis Спутник',
    );
  });

  // ── Brand + eyebrow text ──────────────────────────────────────────────────

  it('renders "Coriolis" as the default brand text', () => {
    const wrapper = mount(AppWordmark);
    expect(wrapper.find('.app-wordmark__brand').text()).toBe('Coriolis');
  });

  it('renders "Companion" as the default eyebrow text', () => {
    const wrapper = mount(AppWordmark);
    expect(wrapper.find('.app-wordmark__eyebrow').text()).toBe('Companion');
  });

  it('allows overriding the eyebrow text (i18n)', () => {
    const wrapper = mount(AppWordmark, { props: { eyebrow: 'Спутник' } });
    expect(wrapper.find('.app-wordmark__eyebrow').text()).toBe('Спутник');
  });

  it('hides the visible brand/eyebrow text from screen readers (combined name only)', () => {
    const wrapper = mount(AppWordmark);
    expect(wrapper.find('.app-wordmark__brand').attributes('aria-hidden')).toBe('true');
    expect(wrapper.find('.app-wordmark__eyebrow').attributes('aria-hidden')).toBe('true');
  });

  // ── Size + auto-scaling ───────────────────────────────────────────────────

  it('defaults the brand size to 48px via CSS custom property', () => {
    const wrapper = mount(AppWordmark);
    const style = wrapper.find('[data-testid="app-wordmark"]').attributes('style') ?? '';
    expect(style).toContain('--app-wordmark-brand-size: 48px');
  });

  it('reflects a custom size into the brand CSS custom property', () => {
    const wrapper = mount(AppWordmark, { props: { size: 88 } });
    const style = wrapper.find('[data-testid="app-wordmark"]').attributes('style') ?? '';
    expect(style).toContain('--app-wordmark-brand-size: 88px');
  });

  it('auto-scales the eyebrow to size × 0.18 (handoff ratio)', () => {
    // size 100 → eyebrow 18px
    const wrapper = mount(AppWordmark, { props: { size: 100 } });
    const style = wrapper.find('[data-testid="app-wordmark"]').attributes('style') ?? '';
    expect(style).toContain('--app-wordmark-eyebrow-size: 18px');
  });

  it('floors the eyebrow at 10px so tiny lockups stay legible', () => {
    // size 24 → 24 × 0.18 = 4.32 → clamped to 10
    const wrapper = mount(AppWordmark, { props: { size: 24 } });
    const style = wrapper.find('[data-testid="app-wordmark"]').attributes('style') ?? '';
    expect(style).toContain('--app-wordmark-eyebrow-size: 10px');
  });

  // ── Paired swash ──────────────────────────────────────────────────────────

  it('renders an AppSwash between brand and eyebrow', () => {
    const wrapper = mount(AppWordmark);
    const swash = wrapper.find('.app-swash');
    expect(swash.exists()).toBe(true);
  });

  it('sizes the swash at size × 2.4 (handoff ratio)', () => {
    // size 50 → swash 120
    const wrapper = mount(AppWordmark, { props: { size: 50 } });
    expect(wrapper.find('.app-swash svg').attributes('width')).toBe('120');
  });

  it('uses the brass swash colour', () => {
    const wrapper = mount(AppWordmark);
    expect(wrapper.find('.app-swash').classes()).toContain('app-swash--brass');
  });

  // ── DOM order ─────────────────────────────────────────────────────────────

  it('renders brand → swash → eyebrow in DOM order', () => {
    const wrapper = mount(AppWordmark);
    const children = [...wrapper.find('.app-wordmark').element.children];
    const brandIdx = children.findIndex((c) => c.classList.contains('app-wordmark__brand'));
    const swashIdx = children.findIndex((c) => c.classList.contains('app-swash'));
    const eyebrowIdx = children.findIndex((c) => c.classList.contains('app-wordmark__eyebrow'));
    expect(brandIdx).toBeGreaterThanOrEqual(0);
    expect(swashIdx).toBeGreaterThan(brandIdx);
    expect(eyebrowIdx).toBeGreaterThan(swashIdx);
  });
});
