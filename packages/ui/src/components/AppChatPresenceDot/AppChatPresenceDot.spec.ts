import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppChatPresenceDot from './AppChatPresenceDot.vue';

const PRESENCES = ['online', 'idle', 'offline'] as const;

describe('AppChatPresenceDot', () => {
  // ── BEM root ──────────────────────────────────────────────────────────────

  it('renders the BEM root class', () => {
    const wrapper = mount(AppChatPresenceDot, { props: { presence: 'online' } });
    expect(wrapper.classes()).toContain('app-chat-presence-dot');
  });

  // ── Presence → class routing ──────────────────────────────────────────────

  it.each(PRESENCES)('applies the --%s modifier for presence="%s"', (presence) => {
    const wrapper = mount(AppChatPresenceDot, { props: { presence } });
    expect(wrapper.classes()).toContain(`app-chat-presence-dot--${presence}`);
  });

  it('applies exactly one presence modifier', () => {
    const wrapper = mount(AppChatPresenceDot, { props: { presence: 'idle' } });
    const presenceClasses = wrapper
      .classes()
      .filter((c) => PRESENCES.some((p) => c === `app-chat-presence-dot--${p}`));
    expect(presenceClasses).toHaveLength(1);
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  it('has role="img"', () => {
    const wrapper = mount(AppChatPresenceDot, { props: { presence: 'online' } });
    expect(wrapper.attributes('role')).toBe('img');
  });

  it('has aria-label="online" when presence="online"', () => {
    const wrapper = mount(AppChatPresenceDot, { props: { presence: 'online' } });
    expect(wrapper.attributes('aria-label')).toBe('online');
  });

  it('has aria-label="idle" when presence="idle"', () => {
    const wrapper = mount(AppChatPresenceDot, { props: { presence: 'idle' } });
    expect(wrapper.attributes('aria-label')).toBe('idle');
  });

  it('has aria-label="offline" when presence="offline"', () => {
    const wrapper = mount(AppChatPresenceDot, { props: { presence: 'offline' } });
    expect(wrapper.attributes('aria-label')).toBe('offline');
  });
});
