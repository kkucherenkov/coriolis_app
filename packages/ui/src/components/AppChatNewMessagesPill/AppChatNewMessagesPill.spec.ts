import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppChatNewMessagesPill from './AppChatNewMessagesPill.vue';

describe('AppChatNewMessagesPill', () => {
  // ── count === 0 → nothing rendered ────────────────────────────────────────

  it('renders nothing when count is 0', () => {
    const wrapper = mount(AppChatNewMessagesPill, { props: { count: 0 } });
    expect(wrapper.find('[data-testid="app-chat-new-messages-pill"]').exists()).toBe(false);
  });

  it('renders nothing when count is 0 (text check)', () => {
    const wrapper = mount(AppChatNewMessagesPill, { props: { count: 0 } });
    expect(wrapper.text()).toBe('');
  });

  // ── count > 0 → pill rendered ─────────────────────────────────────────────

  it('renders the pill when count is 1', () => {
    const wrapper = mount(AppChatNewMessagesPill, { props: { count: 1 } });
    expect(wrapper.find('[data-testid="app-chat-new-messages-pill"]').exists()).toBe(true);
  });

  it('renders the pill when count is 3', () => {
    const wrapper = mount(AppChatNewMessagesPill, { props: { count: 3 } });
    expect(wrapper.find('[data-testid="app-chat-new-messages-pill"]').exists()).toBe(true);
  });

  it('renders the pill when count is 99', () => {
    const wrapper = mount(AppChatNewMessagesPill, { props: { count: 99 } });
    expect(wrapper.find('[data-testid="app-chat-new-messages-pill"]').exists()).toBe(true);
  });

  // ── BEM root class ────────────────────────────────────────────────────────

  it('applies the BEM root class', () => {
    const wrapper = mount(AppChatNewMessagesPill, { props: { count: 5 } });
    expect(wrapper.find('[data-testid="app-chat-new-messages-pill"]').classes()).toContain(
      'app-chat-new-messages-pill',
    );
  });

  // ── Count displayed ───────────────────────────────────────────────────────

  it('displays the count in the label', () => {
    const wrapper = mount(AppChatNewMessagesPill, { props: { count: 7 } });
    expect(wrapper.find('.app-chat-new-messages-pill__label').text()).toContain('7');
  });

  it('displays 99 in the label', () => {
    const wrapper = mount(AppChatNewMessagesPill, { props: { count: 99 } });
    expect(wrapper.find('.app-chat-new-messages-pill__label').text()).toContain('99');
  });

  // ── Click emit ────────────────────────────────────────────────────────────

  it('emits "click" when the pill is clicked', async () => {
    const wrapper = mount(AppChatNewMessagesPill, { props: { count: 3 } });
    await wrapper.find('[data-testid="app-chat-new-messages-pill"]').trigger('click');
    expect(wrapper.emitted('click')).toHaveLength(1);
  });

  it('does not emit "click" when count is 0 (pill absent)', async () => {
    const wrapper = mount(AppChatNewMessagesPill, { props: { count: 0 } });
    // Nothing to click; just verify emitted is empty.
    expect(wrapper.emitted('click')).toBeUndefined();
  });

  // ── Type attribute ────────────────────────────────────────────────────────

  it('is a <button> with type="button"', () => {
    const wrapper = mount(AppChatNewMessagesPill, { props: { count: 1 } });
    const btn = wrapper.find('[data-testid="app-chat-new-messages-pill"]');
    expect(btn.element.tagName).toBe('BUTTON');
    expect(btn.attributes('type')).toBe('button');
  });

  // ── Arrow decoration ──────────────────────────────────────────────────────

  it('renders the arrow span as aria-hidden', () => {
    const wrapper = mount(AppChatNewMessagesPill, { props: { count: 2 } });
    expect(wrapper.find('.app-chat-new-messages-pill__arrow').attributes('aria-hidden')).toBe(
      'true',
    );
  });
});
