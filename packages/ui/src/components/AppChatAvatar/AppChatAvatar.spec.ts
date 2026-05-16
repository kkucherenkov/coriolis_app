import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppChatAvatar from './AppChatAvatar.vue';

describe('AppChatAvatar', () => {
  // ── BEM root ──────────────────────────────────────────────────────────────

  it('renders the BEM root class', () => {
    const wrapper = mount(AppChatAvatar);
    expect(wrapper.classes()).toContain('app-chat-avatar');
  });

  it('has data-testid="app-chat-avatar"', () => {
    const wrapper = mount(AppChatAvatar);
    expect(wrapper.attributes('data-testid')).toBe('app-chat-avatar');
  });

  // ── Size modifiers ────────────────────────────────────────────────────────

  it('applies app-chat-avatar--size-sm modifier for size="sm"', () => {
    const wrapper = mount(AppChatAvatar, { props: { size: 'sm' } });
    expect(wrapper.classes()).toContain('app-chat-avatar--size-sm');
  });

  it('applies app-chat-avatar--size-md modifier for size="md"', () => {
    const wrapper = mount(AppChatAvatar, { props: { size: 'md' } });
    expect(wrapper.classes()).toContain('app-chat-avatar--size-md');
  });

  it('defaults to size="md"', () => {
    const wrapper = mount(AppChatAvatar);
    expect(wrapper.classes()).toContain('app-chat-avatar--size-md');
  });

  it('applies exactly one size modifier', () => {
    const wrapper = mount(AppChatAvatar, { props: { size: 'sm' } });
    const sizeClasses = wrapper.classes().filter((c) => c.startsWith('app-chat-avatar--size-'));
    expect(sizeClasses).toHaveLength(1);
  });

  // ── Presence modifier ─────────────────────────────────────────────────────

  it('applies app-chat-avatar--presence-online modifier', () => {
    const wrapper = mount(AppChatAvatar, { props: { presence: 'online' } });
    expect(wrapper.classes()).toContain('app-chat-avatar--presence-online');
  });

  it('applies app-chat-avatar--presence-idle modifier', () => {
    const wrapper = mount(AppChatAvatar, { props: { presence: 'idle' } });
    expect(wrapper.classes()).toContain('app-chat-avatar--presence-idle');
  });

  it('applies app-chat-avatar--presence-offline modifier', () => {
    const wrapper = mount(AppChatAvatar, { props: { presence: 'offline' } });
    expect(wrapper.classes()).toContain('app-chat-avatar--presence-offline');
  });

  it('does not apply a presence modifier when presence is absent', () => {
    const wrapper = mount(AppChatAvatar);
    const presenceClasses = wrapper
      .classes()
      .filter((c) => c.startsWith('app-chat-avatar--presence-'));
    expect(presenceClasses).toHaveLength(0);
  });

  // ── Pip aria-label ────────────────────────────────────────────────────────

  it('renders the pip with aria-label="online" when presence="online"', () => {
    const wrapper = mount(AppChatAvatar, { props: { presence: 'online' } });
    const pip = wrapper.find('.app-chat-avatar__pip');
    expect(pip.exists()).toBe(true);
    expect(pip.attributes('aria-label')).toBe('online');
  });

  it('renders the pip with aria-label="idle" when presence="idle"', () => {
    const wrapper = mount(AppChatAvatar, { props: { presence: 'idle' } });
    expect(wrapper.find('.app-chat-avatar__pip').attributes('aria-label')).toBe('idle');
  });

  it('renders the pip with aria-label="offline" when presence="offline"', () => {
    const wrapper = mount(AppChatAvatar, { props: { presence: 'offline' } });
    expect(wrapper.find('.app-chat-avatar__pip').attributes('aria-label')).toBe('offline');
  });

  it('does not render the pip when presence is absent', () => {
    const wrapper = mount(AppChatAvatar);
    expect(wrapper.find('.app-chat-avatar__pip').exists()).toBe(false);
  });

  // ── AppPortrait integration ───────────────────────────────────────────────

  it('renders AppPortrait inside the root', () => {
    const wrapper = mount(AppChatAvatar, { props: { initials: 'AS' } });
    // AppPortrait renders a span[data-testid="app-portrait"]
    expect(wrapper.find('[data-testid="app-portrait"]').exists()).toBe(true);
  });
});
