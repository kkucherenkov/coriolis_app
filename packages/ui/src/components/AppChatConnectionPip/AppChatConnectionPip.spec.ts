import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppChatConnectionPip from './AppChatConnectionPip.vue';

const STATUSES = ['connecting', 'subscribed', 'unrecoverable', 'disconnected'] as const;

describe('AppChatConnectionPip', () => {
  // ── BEM root ──────────────────────────────────────────────────────────────

  it('renders the BEM root class', () => {
    const wrapper = mount(AppChatConnectionPip, { props: { status: 'subscribed' } });
    expect(wrapper.classes()).toContain('app-chat-connection-pip');
  });

  // ── Status → class routing ────────────────────────────────────────────────

  it.each(STATUSES)('applies the --%s modifier for status="%s"', (status) => {
    const wrapper = mount(AppChatConnectionPip, { props: { status } });
    expect(wrapper.classes()).toContain(`app-chat-connection-pip--${status}`);
  });

  it('applies exactly one status modifier', () => {
    const wrapper = mount(AppChatConnectionPip, { props: { status: 'connecting' } });
    const statusClasses = wrapper
      .classes()
      .filter((c) => STATUSES.some((s) => c === `app-chat-connection-pip--${s}`));
    expect(statusClasses).toHaveLength(1);
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  it('has role="status"', () => {
    const wrapper = mount(AppChatConnectionPip, { props: { status: 'subscribed' } });
    expect(wrapper.attributes('role')).toBe('status');
  });

  it('has aria-live="polite"', () => {
    const wrapper = mount(AppChatConnectionPip, { props: { status: 'subscribed' } });
    expect(wrapper.attributes('aria-live')).toBe('polite');
  });

  it('has aria-label matching the status label for "subscribed"', () => {
    const wrapper = mount(AppChatConnectionPip, { props: { status: 'subscribed' } });
    expect(wrapper.attributes('aria-label')).toBe('Live');
  });

  it('has aria-label matching the status label for "connecting"', () => {
    const wrapper = mount(AppChatConnectionPip, { props: { status: 'connecting' } });
    expect(wrapper.attributes('aria-label')).toBe('Connecting…');
  });

  it('has aria-label matching the status label for "unrecoverable"', () => {
    const wrapper = mount(AppChatConnectionPip, { props: { status: 'unrecoverable' } });
    expect(wrapper.attributes('aria-label')).toBe('Reconnecting');
  });

  it('has aria-label matching the status label for "disconnected"', () => {
    const wrapper = mount(AppChatConnectionPip, { props: { status: 'disconnected' } });
    expect(wrapper.attributes('aria-label')).toBe('Offline');
  });
});
