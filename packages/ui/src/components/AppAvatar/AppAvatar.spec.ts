import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppAvatar from './AppAvatar.vue';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;
const TONES = ['brass', 'mystic', 'crimson', 'darkness'] as const;
const SHAPES = ['circle', 'squircle'] as const;

describe('AppAvatar', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a <span> root element', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'Tariq al-Asari' } });
    expect(wrapper.element.tagName).toBe('SPAN');
  });

  it('applies the app-avatar base class', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'Tariq al-Asari' } });
    expect(wrapper.classes()).toContain('app-avatar');
  });

  // ── Initials computation ──────────────────────────────────────────────────

  it('computes initials from a two-word name', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'Tariq Asari' } });
    expect(wrapper.find('.app-avatar__initials').text()).toBe('TA');
  });

  it('computes initials from a three-word name (max 2)', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'Tariq al-Asari the Exile' } });
    expect(wrapper.find('.app-avatar__initials').text()).toBe('TA');
  });

  it('computes initials from a single-word name (1 char)', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'Nexus' } });
    expect(wrapper.find('.app-avatar__initials').text()).toBe('N');
  });

  it('produces uppercase initials', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'tariq asari' } });
    expect(wrapper.find('.app-avatar__initials').text()).toBe('TA');
  });

  it('handles single non-Latin character (Cyrillic)', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'Тарик аль-Асари' } });
    expect(wrapper.find('.app-avatar__initials').text()).toBe('ТА');
  });

  it('handles Arabic-origin name (multi-word) correctly', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'Tariq al-Asari' } });
    // 'Tariq' → 'T', 'al-Asari' → 'a' → uppercase 'A'
    expect(wrapper.find('.app-avatar__initials').text()).toBe('TA');
  });

  // ── Image mode ────────────────────────────────────────────────────────────

  it('renders <img> when src is provided', () => {
    const wrapper = mount(AppAvatar, {
      props: { name: 'Tariq al-Asari', src: 'https://example.com/photo.jpg' },
    });
    expect(wrapper.find('.app-avatar__image').exists()).toBe(true);
  });

  it('sets loading="lazy" on the image', () => {
    const wrapper = mount(AppAvatar, {
      props: { name: 'Tariq al-Asari', src: 'https://example.com/photo.jpg' },
    });
    expect(wrapper.find('.app-avatar__image').attributes('loading')).toBe('lazy');
  });

  it('sets decoding="async" on the image', () => {
    const wrapper = mount(AppAvatar, {
      props: { name: 'Tariq al-Asari', src: 'https://example.com/photo.jpg' },
    });
    expect(wrapper.find('.app-avatar__image').attributes('decoding')).toBe('async');
  });

  it('does not render <img> when src is absent', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'Tariq al-Asari' } });
    expect(wrapper.find('.app-avatar__image').exists()).toBe(false);
  });

  it('renders initials when src is absent', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'Tariq al-Asari' } });
    expect(wrapper.find('.app-avatar__initials').exists()).toBe(true);
  });

  // ── Image error fallback ──────────────────────────────────────────────────

  it('falls back to initials on image @error', async () => {
    const wrapper = mount(AppAvatar, {
      props: { name: 'Tariq al-Asari', src: 'https://broken.invalid/photo.jpg' },
    });
    // Confirm image is rendered initially
    expect(wrapper.find('.app-avatar__image').exists()).toBe(true);
    // Simulate error event
    await wrapper.find('.app-avatar__image').trigger('error');
    // Image gone, initials shown
    expect(wrapper.find('.app-avatar__image').exists()).toBe(false);
    expect(wrapper.find('.app-avatar__initials').text()).toBe('TA');
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  it('sets aria-hidden on the initials span', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'Tariq al-Asari' } });
    const initials = wrapper.find('.app-avatar__initials');
    expect(initials.attributes('aria-hidden')).toBe('true');
  });

  it('places the full name in the SR span', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'Tariq al-Asari' } });
    expect(wrapper.find('.app-avatar__sr').text()).toBe('Tariq al-Asari');
  });

  it('sets role="img" and aria-label on the root', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'Tariq al-Asari' } });
    expect(wrapper.attributes('role')).toBe('img');
    expect(wrapper.attributes('aria-label')).toBe('Tariq al-Asari');
  });

  // ── BEM size modifiers ────────────────────────────────────────────────────

  it.each(SIZES)('applies app-avatar--%s modifier for size=%s', (size) => {
    const wrapper = mount(AppAvatar, { props: { name: 'X', size } });
    expect(wrapper.classes()).toContain(`app-avatar--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'X' } });
    expect(wrapper.classes()).toContain('app-avatar--md');
  });

  // ── BEM tone modifiers ────────────────────────────────────────────────────

  it.each(TONES)('applies app-avatar--%s modifier for tone=%s', (tone) => {
    const wrapper = mount(AppAvatar, { props: { name: 'X', tone } });
    expect(wrapper.classes()).toContain(`app-avatar--${tone}`);
  });

  it('defaults to tone=brass', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'X' } });
    expect(wrapper.classes()).toContain('app-avatar--brass');
  });

  // ── BEM shape modifiers ───────────────────────────────────────────────────

  it.each(SHAPES)('applies app-avatar--%s modifier for shape=%s', (shape) => {
    const wrapper = mount(AppAvatar, { props: { name: 'X', shape } });
    expect(wrapper.classes()).toContain(`app-avatar--${shape}`);
  });

  it('defaults to shape=circle', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'X' } });
    expect(wrapper.classes()).toContain('app-avatar--circle');
  });

  // ── No modifier collisions ────────────────────────────────────────────────

  it('applies exactly one size class', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'X', size: 'xl' } });
    const sizeClasses = wrapper
      .classes()
      .filter((c) => SIZES.some((s) => c === `app-avatar--${s}`));
    expect(sizeClasses).toHaveLength(1);
    expect(sizeClasses[0]).toBe('app-avatar--xl');
  });

  it('applies exactly one tone class', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'X', tone: 'crimson' } });
    const toneClasses = wrapper
      .classes()
      .filter((c) => TONES.some((t) => c === `app-avatar--${t}`));
    expect(toneClasses).toHaveLength(1);
    expect(toneClasses[0]).toBe('app-avatar--crimson');
  });

  it('applies exactly one shape class', () => {
    const wrapper = mount(AppAvatar, { props: { name: 'X', shape: 'squircle' } });
    const shapeClasses = wrapper
      .classes()
      .filter((c) => SHAPES.some((s) => c === `app-avatar--${s}`));
    expect(shapeClasses).toHaveLength(1);
    expect(shapeClasses[0]).toBe('app-avatar--squircle');
  });
});
