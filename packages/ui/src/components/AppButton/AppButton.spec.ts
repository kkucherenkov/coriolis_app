import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppButton from './AppButton.vue';

describe('AppButton', () => {
  // ── Slot rendering ────────────────────────────────────────────────────────

  it('renders default slot content', () => {
    const wrapper = mount(AppButton, { slots: { default: 'Submit' } });
    expect(wrapper.text()).toContain('Submit');
  });

  it('renders icon-leading slot when provided', () => {
    const wrapper = mount(AppButton, {
      slots: {
        default: 'Go',
        'icon-leading': '<svg data-testid="lead" />',
      },
    });
    expect(wrapper.find('.app-button__icon--leading').exists()).toBe(true);
  });

  it('renders icon-trailing slot when provided', () => {
    const wrapper = mount(AppButton, {
      slots: {
        default: 'Next',
        'icon-trailing': '<svg data-testid="trail" />',
      },
    });
    expect(wrapper.find('.app-button__icon--trailing').exists()).toBe(true);
  });

  it('hides icon-leading slot while loading (spinner replaces it)', () => {
    const wrapper = mount(AppButton, {
      props: { loading: true },
      slots: {
        default: 'Saving',
        'icon-leading': '<svg data-testid="lead" />',
      },
    });
    expect(wrapper.find('.app-button__icon--leading').exists()).toBe(false);
    expect(wrapper.find('.app-button__spinner').exists()).toBe(true);
  });

  // ── BEM class application ─────────────────────────────────────────────────

  it.each(['primary', 'ghost', 'danger'] as const)(
    'applies variant modifier class for variant=%s',
    (variant) => {
      const wrapper = mount(AppButton, { props: { variant }, slots: { default: 'X' } });
      expect(wrapper.find(`.app-button--${variant}`).exists()).toBe(true);
    },
  );

  it.each(['sm', 'md', 'lg'] as const)('applies size modifier class for size=%s', (size) => {
    const wrapper = mount(AppButton, { props: { size }, slots: { default: 'X' } });
    expect(wrapper.find(`.app-button--${size}`).exists()).toBe(true);
  });

  it('defaults to variant=primary and size=md', () => {
    const wrapper = mount(AppButton, { slots: { default: 'X' } });
    expect(wrapper.find('.app-button--primary').exists()).toBe(true);
    expect(wrapper.find('.app-button--md').exists()).toBe(true);
  });

  it('applies app-button--disabled modifier when disabled', () => {
    const wrapper = mount(AppButton, { props: { disabled: true }, slots: { default: 'X' } });
    expect(wrapper.find('.app-button--disabled').exists()).toBe(true);
  });

  it('applies app-button--disabled modifier when loading', () => {
    const wrapper = mount(AppButton, { props: { loading: true }, slots: { default: 'X' } });
    expect(wrapper.find('.app-button--disabled').exists()).toBe(true);
  });

  // ── Click emission ────────────────────────────────────────────────────────

  it('emits click with the original MouseEvent', async () => {
    const wrapper = mount(AppButton, { slots: { default: 'Click' } });
    await wrapper.find('button').trigger('click');
    const events = wrapper.emitted('click');
    expect(events).toHaveLength(1);
    expect(events?.[0]?.[0]).toBeInstanceOf(MouseEvent);
  });

  it('does not emit click when disabled', async () => {
    const wrapper = mount(AppButton, {
      props: { disabled: true },
      slots: { default: 'Off' },
    });
    const button = wrapper.find('button');
    expect(button.attributes('disabled')).toBeDefined();
    await button.trigger('click');
    expect(wrapper.emitted('click')).toBeUndefined();
  });

  it('does not emit click when loading', async () => {
    const wrapper = mount(AppButton, {
      props: { loading: true },
      slots: { default: 'Saving' },
    });
    await wrapper.find('button').trigger('click');
    expect(wrapper.emitted('click')).toBeUndefined();
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  it('renders a <button> element for keyboard navigation', () => {
    const wrapper = mount(AppButton, { slots: { default: 'Go' } });
    const button = wrapper.find('button');
    expect(button.exists()).toBe(true);
    expect(button.element.tagName).toBe('BUTTON');
  });

  it('sets aria-disabled=true when disabled', () => {
    const wrapper = mount(AppButton, {
      props: { disabled: true },
      slots: { default: 'Off' },
    });
    expect(wrapper.find('button').attributes('aria-disabled')).toBe('true');
  });

  it('sets aria-disabled=true when loading', () => {
    const wrapper = mount(AppButton, {
      props: { loading: true },
      slots: { default: 'Saving' },
    });
    expect(wrapper.find('button').attributes('aria-disabled')).toBe('true');
  });

  it('sets aria-busy=true when loading', () => {
    const wrapper = mount(AppButton, {
      props: { loading: true },
      slots: { default: 'Saving' },
    });
    expect(wrapper.find('button').attributes('aria-busy')).toBe('true');
  });

  it('does not set aria-busy when not loading', () => {
    const wrapper = mount(AppButton, { slots: { default: 'X' } });
    expect(wrapper.find('button').attributes('aria-busy')).toBeUndefined();
  });

  it('has a type=button attribute by default (prevents accidental form submit)', () => {
    const wrapper = mount(AppButton, { slots: { default: 'X' } });
    expect(wrapper.find('button').attributes('type')).toBe('button');
  });

  it('accepts type=submit', () => {
    const wrapper = mount(AppButton, {
      props: { type: 'submit' },
      slots: { default: 'Save' },
    });
    expect(wrapper.find('button').attributes('type')).toBe('submit');
  });
});
