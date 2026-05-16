import { mount } from '@vue/test-utils';
import { describe, expect, it, vi } from 'vitest';

import AppChatTab from './AppChatTab.vue';

describe('AppChatTab', () => {
  // ── Spec 1: broadcast hides the close × ────────────────────────────────────

  it('broadcast kind does not render the close button', () => {
    const wrapper = mount(AppChatTab, {
      props: { label: 'Broadcast', kind: 'broadcast', active: false },
    });
    expect(wrapper.find('.app-chat-tab__close').exists()).toBe(false);
  });

  // ── Spec 2: broadcast hides the presence dot ───────────────────────────────

  it('broadcast kind does not render the presence dot even when presence prop is set', () => {
    const wrapper = mount(AppChatTab, {
      props: { label: 'Broadcast', kind: 'broadcast', active: false, presence: 'online' },
    });
    expect(wrapper.findComponent({ name: 'AppChatPresenceDot' }).exists()).toBe(false);
  });

  // ── Spec 3: click on row emits select ──────────────────────────────────────

  it('clicking the root button emits select', async () => {
    const wrapper = mount(AppChatTab, {
      props: { label: 'Broadcast', kind: 'broadcast', active: false },
    });
    await wrapper.find('button.app-chat-tab').trigger('click');
    expect(wrapper.emitted('select')).toHaveLength(1);
  });

  // ── Spec 4: close button emits close and NOT select ────────────────────────

  it('clicking the close button emits close and does not bubble select', async () => {
    const onSelect = vi.fn();
    const wrapper = mount(AppChatTab, {
      props: { label: 'Yuki', kind: 'whisper', active: false },
      attrs: { onSelect },
    });
    const closeBtn = wrapper.find('.app-chat-tab__close');
    expect(closeBtn.exists()).toBe(true);
    await closeBtn.trigger('click');
    expect(wrapper.emitted('close')).toHaveLength(1);
    expect(onSelect).not.toHaveBeenCalled();
  });

  // ── Spec 5: unreadCount=0 hides badge; >0 shows it ────────────────────────

  it('does not render the badge when unreadCount is 0', () => {
    const wrapper = mount(AppChatTab, {
      props: { label: 'Yuki', kind: 'whisper', active: false, unreadCount: 0 },
    });
    expect(wrapper.find('.app-chat-tab__badge').exists()).toBe(false);
  });

  it('renders the badge when unreadCount > 0', () => {
    const wrapper = mount(AppChatTab, {
      props: { label: 'Yuki', kind: 'whisper', active: false, unreadCount: 3 },
    });
    expect(wrapper.find('.app-chat-tab__badge').exists()).toBe(true);
  });

  // ── Spec 6: active modifier and aria-selected ──────────────────────────────

  it('applies --active modifier class when active=true', () => {
    const wrapper = mount(AppChatTab, {
      props: { label: 'Broadcast', kind: 'broadcast', active: true },
    });
    expect(wrapper.classes()).toContain('app-chat-tab--active');
  });

  it('sets aria-selected="true" when active=true', () => {
    const wrapper = mount(AppChatTab, {
      props: { label: 'Broadcast', kind: 'broadcast', active: true },
    });
    expect(wrapper.attributes('aria-selected')).toBe('true');
  });

  it('sets aria-selected="false" when active=false', () => {
    const wrapper = mount(AppChatTab, {
      props: { label: 'Broadcast', kind: 'broadcast', active: false },
    });
    expect(wrapper.attributes('aria-selected')).toBe('false');
  });

  // ── Additional: whisper kind shows presence dot when presence is set ────────

  it('whisper kind renders presence dot when presence prop is provided', () => {
    const wrapper = mount(AppChatTab, {
      props: { label: 'Yuki', kind: 'whisper', active: false, presence: 'online' },
    });
    expect(wrapper.findComponent({ name: 'AppChatPresenceDot' }).exists()).toBe(true);
  });

  it('whisper kind does not render presence dot when presence prop is absent', () => {
    const wrapper = mount(AppChatTab, {
      props: { label: 'Yuki', kind: 'whisper', active: false },
    });
    expect(wrapper.findComponent({ name: 'AppChatPresenceDot' }).exists()).toBe(false);
  });

  // ── BEM: kind modifier classes ─────────────────────────────────────────────

  it('applies --kind-broadcast modifier for broadcast kind', () => {
    const wrapper = mount(AppChatTab, {
      props: { label: 'All', kind: 'broadcast', active: false },
    });
    expect(wrapper.classes()).toContain('app-chat-tab--kind-broadcast');
  });

  it('applies --kind-whisper modifier for whisper kind', () => {
    const wrapper = mount(AppChatTab, {
      props: { label: 'Yuki', kind: 'whisper', active: false },
    });
    expect(wrapper.classes()).toContain('app-chat-tab--kind-whisper');
  });

  // ── Root element ───────────────────────────────────────────────────────────

  it('root element has role="tab"', () => {
    const wrapper = mount(AppChatTab, {
      props: { label: 'Broadcast', kind: 'broadcast', active: false },
    });
    expect(wrapper.attributes('role')).toBe('tab');
  });

  it('root element has type="button"', () => {
    const wrapper = mount(AppChatTab, {
      props: { label: 'Broadcast', kind: 'broadcast', active: false },
    });
    expect(wrapper.attributes('type')).toBe('button');
  });
});
