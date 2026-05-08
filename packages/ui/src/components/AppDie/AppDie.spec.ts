import { mount } from '@vue/test-utils';
import { describe, expect, it, vi } from 'vitest';

import AppDie from './AppDie.vue';

const VALUES = [1, 2, 3, 4, 5, 6] as const;
const STATES = ['normal', 'hit', 'pushed', 'failed'] as const;
const SIZES = ['sm', 'md', 'lg'] as const;

/** Expected pip counts per die value. */
const PIP_COUNTS: Record<number, number> = { 1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6 };

describe('AppDie', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a <span> root element with the app-die class', () => {
    const wrapper = mount(AppDie, { props: { value: 1 } });
    expect(wrapper.element.tagName).toBe('SPAN');
    expect(wrapper.classes()).toContain('app-die');
  });

  it('contains an <svg> with role="img"', () => {
    const wrapper = mount(AppDie, { props: { value: 3 } });
    const svg = wrapper.find('svg');
    expect(svg.exists()).toBe(true);
    expect(svg.attributes('role')).toBe('img');
  });

  // ── BEM size modifiers ────────────────────────────────────────────────────

  it.each(SIZES)('applies app-die--%s for size=%s', (size) => {
    const wrapper = mount(AppDie, { props: { value: 1, size } });
    expect(wrapper.classes()).toContain(`app-die--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppDie, { props: { value: 1 } });
    expect(wrapper.classes()).toContain('app-die--md');
  });

  it('applies exactly one size class', () => {
    const wrapper = mount(AppDie, { props: { value: 1, size: 'lg' } });
    const sizeClasses = wrapper.classes().filter((c) => SIZES.some((s) => c === `app-die--${s}`));
    expect(sizeClasses).toHaveLength(1);
    expect(sizeClasses[0]).toBe('app-die--lg');
  });

  // ── BEM state modifiers ───────────────────────────────────────────────────

  it.each(STATES)('applies app-die--state-%s for state=%s', (state) => {
    const wrapper = mount(AppDie, { props: { value: 6, state } });
    expect(wrapper.classes()).toContain(`app-die--state-${state}`);
  });

  it('defaults to state=normal', () => {
    const wrapper = mount(AppDie, { props: { value: 4 } });
    expect(wrapper.classes()).toContain('app-die--state-normal');
  });

  it('applies exactly one state class', () => {
    const wrapper = mount(AppDie, { props: { value: 5, state: 'hit' } });
    const stateClasses = wrapper
      .classes()
      .filter((c) => STATES.some((s) => c === `app-die--state-${s}`));
    expect(stateClasses).toHaveLength(1);
    expect(stateClasses[0]).toBe('app-die--state-hit');
  });

  // ── Pip counts ────────────────────────────────────────────────────────────

  it.each(VALUES)('renders %i pip(s) for value=%i', (v) => {
    const wrapper = mount(AppDie, { props: { value: v } });
    const circles = wrapper.findAll('circle.app-die__pip');
    // PIP_COUNTS is keyed 1-6; v is from VALUES so the lookup always exists.
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- safe: v is always 1–6
    expect(circles).toHaveLength(PIP_COUNTS[v]!);
  });

  // ── Aria-label — default ──────────────────────────────────────────────────

  it('generates default aria-label "Die showing <value>" for state=normal', () => {
    const wrapper = mount(AppDie, { props: { value: 4 } });
    expect(wrapper.find('svg').attributes('aria-label')).toBe('Die showing 4');
  });

  it.each(STATES.filter((s) => s !== 'normal'))(
    'appends state to aria-label for state=%s',
    (state) => {
      const wrapper = mount(AppDie, { props: { value: 6, state } });
      const label = wrapper.find('svg').attributes('aria-label');
      expect(label).toMatch(/Die showing 6 — /);
    },
  );

  it('includes capitalised state name in the default aria-label', () => {
    const wrapper = mount(AppDie, { props: { value: 6, state: 'hit' } });
    expect(wrapper.find('svg').attributes('aria-label')).toBe('Die showing 6 — Hit');
  });

  // ── Aria-label — custom ───────────────────────────────────────────────────

  it('uses custom ariaLabel when provided', () => {
    const wrapper = mount(AppDie, {
      props: { value: 6, ariaLabel: 'Custom label' },
    });
    expect(wrapper.find('svg').attributes('aria-label')).toBe('Custom label');
  });

  it('ignores state in aria-label when ariaLabel prop is set', () => {
    const wrapper = mount(AppDie, {
      props: { value: 6, state: 'failed', ariaLabel: 'My label' },
    });
    expect(wrapper.find('svg').attributes('aria-label')).toBe('My label');
  });

  // ── Out-of-range value warning ────────────────────────────────────────────

  it('emits a console.warn for an out-of-range value', () => {
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => undefined);
    // Cast required to bypass TypeScript — deliberate bad-value test.
    mount(AppDie, { props: { value: 0 as unknown as 1 } });
    expect(warn).toHaveBeenCalledWith(
      expect.stringContaining('[AppDie] Invalid value'),
    );
    warn.mockRestore();
  });

  // ── Hit state filter ──────────────────────────────────────────────────────

  it('renders a <filter> element for state=hit', () => {
    const wrapper = mount(AppDie, { props: { value: 6, state: 'hit' } });
    expect(wrapper.find('filter').exists()).toBe(true);
  });

  it('does not render a <filter> element for state=normal', () => {
    const wrapper = mount(AppDie, { props: { value: 6, state: 'normal' } });
    expect(wrapper.find('filter').exists()).toBe(false);
  });

  it('renders halo <rect> for state=hit', () => {
    const wrapper = mount(AppDie, { props: { value: 6, state: 'hit' } });
    expect(wrapper.find('rect.app-die__halo').exists()).toBe(true);
  });

  it('does not render halo <rect> for state=normal', () => {
    const wrapper = mount(AppDie, { props: { value: 4, state: 'normal' } });
    expect(wrapper.find('rect.app-die__halo').exists()).toBe(false);
  });
});
