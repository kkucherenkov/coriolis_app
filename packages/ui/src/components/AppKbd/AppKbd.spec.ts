import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppKbd from './AppKbd.vue';

const SIZES = ['sm', 'md'] as const;

describe('AppKbd', () => {
  // ── Root element ───────────────────────────────────────────────────────────

  it('renders a <kbd> root element', () => {
    const wrapper = mount(AppKbd, { props: { keys: 'N' } });
    expect(wrapper.element.tagName).toBe('KBD');
  });

  it('applies the app-kbd base class', () => {
    const wrapper = mount(AppKbd, { props: { keys: 'N' } });
    expect(wrapper.classes()).toContain('app-kbd');
  });

  // ── Single key ─────────────────────────────────────────────────────────────

  it('renders a single key as text content — no inner <kbd>', () => {
    const wrapper = mount(AppKbd, { props: { keys: 'N' } });
    // No inner .app-kbd__key elements for a single key.
    expect(wrapper.findAll('.app-kbd__key')).toHaveLength(0);
    expect(wrapper.text()).toContain('N');
  });

  it('renders a single key from a one-element array', () => {
    const wrapper = mount(AppKbd, { props: { keys: ['N'] } });
    expect(wrapper.findAll('.app-kbd__key')).toHaveLength(0);
    expect(wrapper.text()).toContain('N');
  });

  // ── Multi-key combo ────────────────────────────────────────────────────────

  it('renders multiple keys as multiple inner <kbd> elements', () => {
    const wrapper = mount(AppKbd, { props: { keys: ['Ctrl', 'K'] } });
    const innerKbds = wrapper.findAll('.app-kbd__key');
    expect(innerKbds).toHaveLength(2);
    expect(innerKbds[0]!.text()).toBe('Ctrl');
    expect(innerKbds[1]!.text()).toBe('K');
  });

  it('renders three-key combo as three inner <kbd> elements', () => {
    const wrapper = mount(AppKbd, { props: { keys: ['Ctrl', 'Shift', 'P'] } });
    const innerKbds = wrapper.findAll('.app-kbd__key');
    expect(innerKbds).toHaveLength(3);
  });

  it('renders separators between keys', () => {
    const wrapper = mount(AppKbd, { props: { keys: ['Ctrl', 'K'] } });
    const seps = wrapper.findAll('.app-kbd__sep');
    // n keys → n-1 separators
    expect(seps).toHaveLength(1);
    expect(seps[0]!.text()).toBe('+');
  });

  it('renders two separators for three keys', () => {
    const wrapper = mount(AppKbd, { props: { keys: ['Ctrl', 'Shift', 'P'] } });
    expect(wrapper.findAll('.app-kbd__sep')).toHaveLength(2);
  });

  // ── Size BEM modifiers ─────────────────────────────────────────────────────

  it.each(SIZES)('applies app-kbd--%s class for size=%s', (size) => {
    const wrapper = mount(AppKbd, { props: { keys: 'N', size } });
    expect(wrapper.classes()).toContain(`app-kbd--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppKbd, { props: { keys: 'N' } });
    expect(wrapper.classes()).toContain('app-kbd--md');
  });

  it('applies exactly one size class', () => {
    const wrapper = mount(AppKbd, { props: { keys: 'N', size: 'sm' } });
    const sizeClasses = wrapper.classes().filter((c) => SIZES.some((s) => c === `app-kbd--${s}`));
    expect(sizeClasses).toHaveLength(1);
    expect(sizeClasses[0]).toBe('app-kbd--sm');
  });

  // ── Symbols ────────────────────────────────────────────────────────────────

  it('renders special symbol keys correctly', () => {
    const symbols = ['⏎', '⌘', '⌥', '?'];
    for (const sym of symbols) {
      const wrapper = mount(AppKbd, { props: { keys: sym } });
      expect(wrapper.text()).toContain(sym);
    }
  });
});
