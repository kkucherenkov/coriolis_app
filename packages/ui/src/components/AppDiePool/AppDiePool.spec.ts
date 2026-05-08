import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppDiePool from './AppDiePool.vue';

type DieValue = 1 | 2 | 3 | 4 | 5 | 6;

const SIZES = ['sm', 'md', 'lg'] as const;
const TONES = ['brass', 'mystic'] as const;

describe('AppDiePool', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a <div> root with the app-die-pool class', () => {
    const wrapper = mount(AppDiePool, { props: { values: [6, 3] as DieValue[] } });
    expect(wrapper.element.tagName).toBe('DIV');
    expect(wrapper.classes()).toContain('app-die-pool');
  });

  it('contains a <ul> with role="list"', () => {
    const wrapper = mount(AppDiePool, { props: { values: [6, 1] as DieValue[] } });
    const ul = wrapper.find('ul');
    expect(ul.exists()).toBe(true);
    expect(ul.attributes('role')).toBe('list');
  });

  // ── One AppDie per value ──────────────────────────────────────────────────

  it('renders one <li> per value', () => {
    const values: DieValue[] = [6, 3, 1, 5, 4, 6, 2, 4];
    const wrapper = mount(AppDiePool, { props: { values } });
    const items = wrapper.findAll('li.app-die-pool__item');
    expect(items).toHaveLength(values.length);
  });

  it('renders zero items for an empty values array', () => {
    const wrapper = mount(AppDiePool, { props: { values: [] } });
    expect(wrapper.findAll('li.app-die-pool__item')).toHaveLength(0);
  });

  it('renders one item for a single-value array', () => {
    const wrapper = mount(AppDiePool, { props: { values: [6] as DieValue[] } });
    expect(wrapper.findAll('li.app-die-pool__item')).toHaveLength(1);
  });

  // ── Hit count computation ─────────────────────────────────────────────────

  it('shows "2 hits" badge when two dice show 6', () => {
    const wrapper = mount(AppDiePool, {
      props: { values: [6, 3, 1, 5, 4, 6, 2, 4] as DieValue[] },
    });
    const badge = wrapper.find('.app-die-pool__count');
    expect(badge.exists()).toBe(true);
    expect(badge.text()).toContain('2 hits');
  });

  it('shows "0 hits" when no dice show 6', () => {
    const wrapper = mount(AppDiePool, {
      props: { values: [1, 2, 3, 4, 5] as DieValue[] },
    });
    expect(wrapper.find('.app-die-pool__count').text()).toContain('0 hits');
  });

  it('shows "1 hit" (singular) when exactly one die shows 6', () => {
    const wrapper = mount(AppDiePool, {
      props: { values: [6, 3, 2] as DieValue[] },
    });
    expect(wrapper.find('.app-die-pool__count').text()).toContain('1 hit');
  });

  it('counts pushed dice that show 6 toward hitCount', () => {
    // pushedIndices=[1] but values[1]=6 — pushed 6 still counts
    const wrapper = mount(AppDiePool, {
      props: { values: [6, 6, 2] as DieValue[], pushedIndices: [1] },
    });
    expect(wrapper.find('.app-die-pool__count').text()).toContain('2 hits');
  });

  // ── showHitCount prop ─────────────────────────────────────────────────────

  it('shows the hit count badge by default', () => {
    const wrapper = mount(AppDiePool, { props: { values: [6] as DieValue[] } });
    expect(wrapper.find('.app-die-pool__count').exists()).toBe(true);
  });

  it('hides the hit count badge when showHitCount=false', () => {
    const wrapper = mount(AppDiePool, {
      props: { values: [6, 3] as DieValue[], showHitCount: false },
    });
    expect(wrapper.find('.app-die-pool__count').exists()).toBe(false);
  });

  // ── Pushed state ──────────────────────────────────────────────────────────

  it('applies app-die-pool__item--pushed to items at pushed indices', () => {
    const wrapper = mount(AppDiePool, {
      props: { values: [6, 4, 2] as DieValue[], pushedIndices: [1] },
    });
    const items = wrapper.findAll('li.app-die-pool__item');
    expect(items[0]!.classes()).not.toContain('app-die-pool__item--pushed');
    expect(items[1]!.classes()).toContain('app-die-pool__item--pushed');
    expect(items[2]!.classes()).not.toContain('app-die-pool__item--pushed');
  });

  it('does not apply pushed class when pushedIndices is empty', () => {
    const wrapper = mount(AppDiePool, {
      props: { values: [6, 3] as DieValue[], pushedIndices: [] },
    });
    wrapper.findAll('li.app-die-pool__item').forEach((item) => {
      expect(item.classes()).not.toContain('app-die-pool__item--pushed');
    });
  });

  // ── Size modifiers ────────────────────────────────────────────────────────

  it.each(SIZES)('applies app-die-pool--%s for size=%s', (size) => {
    const wrapper = mount(AppDiePool, {
      props: { values: [6, 3] as DieValue[], size },
    });
    expect(wrapper.classes()).toContain(`app-die-pool--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppDiePool, { props: { values: [6] as DieValue[] } });
    expect(wrapper.classes()).toContain('app-die-pool--md');
  });

  // ── Tone modifiers ────────────────────────────────────────────────────────

  it.each(TONES)('applies app-die-pool--%s for tone=%s', (tone) => {
    const wrapper = mount(AppDiePool, {
      props: { values: [6] as DieValue[], tone },
    });
    expect(wrapper.classes()).toContain(`app-die-pool--${tone}`);
  });

  it('defaults to tone=brass', () => {
    const wrapper = mount(AppDiePool, { props: { values: [6] as DieValue[] } });
    expect(wrapper.classes()).toContain('app-die-pool--brass');
  });

  // ── aria-live on count ────────────────────────────────────────────────────

  it('sets aria-live=polite on the count element', () => {
    const wrapper = mount(AppDiePool, { props: { values: [6] as DieValue[] } });
    expect(wrapper.find('.app-die-pool__count').attributes('aria-live')).toBe('polite');
  });
});
