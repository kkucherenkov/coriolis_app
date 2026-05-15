import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppPanelTitle from './AppPanelTitle.vue';

const SIZES = ['sm', 'md', 'lg'] as const;
const LEVELS = ['h2', 'h3', 'h4'] as const;

describe('AppPanelTitle', () => {
  // ── Root + heading ─────────────────────────────────────────────────────────

  it('renders the app-panel-title root class', () => {
    const wrapper = mount(AppPanelTitle, { slots: { default: 'Crew' } });
    expect(wrapper.classes()).toContain('app-panel-title');
  });

  it('renders an <h3> heading by default', () => {
    const wrapper = mount(AppPanelTitle, { slots: { default: 'Crew' } });
    const heading = wrapper.find('h3.app-panel-title__heading');
    expect(heading.exists()).toBe(true);
    expect(heading.text()).toBe('Crew');
  });

  it.each(LEVELS)('renders the requested semantic heading level %s', (level) => {
    const wrapper = mount(AppPanelTitle, {
      props: { level },
      slots: { default: 'Crew' },
    });
    const heading = wrapper.find(`${level}.app-panel-title__heading`);
    expect(heading.exists()).toBe(true);
  });

  it('passes default slot content into the heading', () => {
    const wrapper = mount(AppPanelTitle, { slots: { default: 'Library' } });
    expect(wrapper.find('.app-panel-title__heading').text()).toBe('Library');
  });

  // ── Size modifiers ─────────────────────────────────────────────────────────

  it.each(SIZES)('applies BEM size modifier app-panel-title--%s', (size) => {
    const wrapper = mount(AppPanelTitle, {
      props: { size },
      slots: { default: 'X' },
    });
    expect(wrapper.classes()).toContain(`app-panel-title--${size}`);
  });

  it('defaults to size=md', () => {
    const wrapper = mount(AppPanelTitle, { slots: { default: 'X' } });
    expect(wrapper.classes()).toContain('app-panel-title--md');
  });

  // ── Paired swash ───────────────────────────────────────────────────────────

  it('renders an AppSwash beneath the heading', () => {
    const wrapper = mount(AppPanelTitle, { slots: { default: 'X' } });
    const swash = wrapper.find('.app-swash');
    expect(swash.exists()).toBe(true);
  });

  it('passes swash width=70 for size=sm', () => {
    const wrapper = mount(AppPanelTitle, {
      props: { size: 'sm' },
      slots: { default: 'X' },
    });
    expect(wrapper.find('.app-swash svg').attributes('width')).toBe('70');
  });

  it('passes swash width=70 for size=md', () => {
    const wrapper = mount(AppPanelTitle, {
      props: { size: 'md' },
      slots: { default: 'X' },
    });
    expect(wrapper.find('.app-swash svg').attributes('width')).toBe('70');
  });

  it('passes swash width=110 for size=lg', () => {
    const wrapper = mount(AppPanelTitle, {
      props: { size: 'lg' },
      slots: { default: 'X' },
    });
    expect(wrapper.find('.app-swash svg').attributes('width')).toBe('110');
  });

  it('uses the brass swash color (paired default)', () => {
    const wrapper = mount(AppPanelTitle, { slots: { default: 'X' } });
    expect(wrapper.find('.app-swash').classes()).toContain('app-swash--brass');
  });

  // ── Heading ordering inside the root ──────────────────────────────────────

  it('renders the heading before the swash for a sensible visual + DOM order', () => {
    const wrapper = mount(AppPanelTitle, { slots: { default: 'X' } });
    const root = wrapper.element;
    const headingIdx = [...root.children].findIndex((c) =>
      c.classList.contains('app-panel-title__heading'),
    );
    const swashIdx = [...root.children].findIndex((c) => c.classList.contains('app-swash'));
    expect(headingIdx).toBeGreaterThanOrEqual(0);
    expect(swashIdx).toBeGreaterThan(headingIdx);
  });
});
