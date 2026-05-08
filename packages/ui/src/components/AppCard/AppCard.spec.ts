import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppCard from './AppCard.vue';

describe('AppCard', () => {
  // ── Default slot ──────────────────────────────────────────────────────────

  it('renders default slot content', () => {
    const wrapper = mount(AppCard, { slots: { default: '<p>Body copy</p>' } });
    expect(wrapper.html()).toContain('Body copy');
    expect(wrapper.find('.app-card__body').exists()).toBe(true);
  });

  // ── Named slots ───────────────────────────────────────────────────────────

  it('renders the header slot when provided', () => {
    const wrapper = mount(AppCard, {
      slots: {
        default: 'body',
        header: '<h3>Section title</h3>',
      },
    });
    expect(wrapper.find('.app-card__header').exists()).toBe(true);
    expect(wrapper.html()).toContain('Section title');
  });

  it('does not render the header wrapper when header slot is absent', () => {
    const wrapper = mount(AppCard, { slots: { default: 'body' } });
    expect(wrapper.find('.app-card__header').exists()).toBe(false);
  });

  it('renders the footer slot when provided', () => {
    const wrapper = mount(AppCard, {
      slots: {
        default: 'body',
        footer: '<small>Footer text</small>',
      },
    });
    expect(wrapper.find('.app-card__footer').exists()).toBe(true);
    expect(wrapper.html()).toContain('Footer text');
  });

  it('does not render the footer wrapper when footer slot is absent', () => {
    const wrapper = mount(AppCard, { slots: { default: 'body' } });
    expect(wrapper.find('.app-card__footer').exists()).toBe(false);
  });

  it('renders both header and footer slots simultaneously', () => {
    const wrapper = mount(AppCard, {
      slots: {
        header: 'Header',
        default: 'Body',
        footer: 'Footer',
      },
    });
    expect(wrapper.find('.app-card__header').exists()).toBe(true);
    expect(wrapper.find('.app-card__body').exists()).toBe(true);
    expect(wrapper.find('.app-card__footer').exists()).toBe(true);
  });

  // ── BEM class application ─────────────────────────────────────────────────

  it('applies app-card base class', () => {
    const wrapper = mount(AppCard, { slots: { default: 'x' } });
    expect(wrapper.find('.app-card').exists()).toBe(true);
  });

  it('does not apply app-card--featured for the default variant', () => {
    const wrapper = mount(AppCard, {
      props: { variant: 'default' },
      slots: { default: 'x' },
    });
    expect(wrapper.find('.app-card--featured').exists()).toBe(false);
  });

  it('applies app-card--featured modifier for the featured variant', () => {
    const wrapper = mount(AppCard, {
      props: { variant: 'featured' },
      slots: { default: 'x' },
    });
    expect(wrapper.find('.app-card--featured').exists()).toBe(true);
  });

  it('defaults to variant=default', () => {
    const wrapper = mount(AppCard, { slots: { default: 'x' } });
    expect(wrapper.find('.app-card--featured').exists()).toBe(false);
  });

  // ── Polymorphic `as` prop ─────────────────────────────────────────────────

  it('renders as a <div> by default', () => {
    const wrapper = mount(AppCard, { slots: { default: 'x' } });
    expect(wrapper.find('.app-card').element.tagName).toBe('DIV');
  });

  it('renders as an <article> when as="article"', () => {
    const wrapper = mount(AppCard, {
      props: { as: 'article' },
      slots: { default: 'x' },
    });
    expect(wrapper.find('.app-card').element.tagName).toBe('ARTICLE');
  });

  it('renders as a <section> when as="section"', () => {
    const wrapper = mount(AppCard, {
      props: { as: 'section' },
      slots: { default: 'x' },
    });
    expect(wrapper.find('.app-card').element.tagName).toBe('SECTION');
  });
});
