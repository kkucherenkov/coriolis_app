import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppChatDayDivider from './AppChatDayDivider.vue';

describe('AppChatDayDivider', () => {
  // ── BEM root ──────────────────────────────────────────────────────────────

  it('renders the BEM root class', () => {
    const wrapper = mount(AppChatDayDivider, { props: { label: 'TODAY' } });
    expect(wrapper.classes()).toContain('app-chat-day-divider');
  });

  // ── Separator role ────────────────────────────────────────────────────────

  it('has role="separator"', () => {
    const wrapper = mount(AppChatDayDivider, { props: { label: 'TODAY' } });
    expect(wrapper.attributes('role')).toBe('separator');
  });

  // ── Label rendering ───────────────────────────────────────────────────────

  it('renders the label text', () => {
    const wrapper = mount(AppChatDayDivider, { props: { label: 'TODAY' } });
    expect(wrapper.find('.app-chat-day-divider__label').text()).toBe('TODAY');
  });

  it('renders arbitrary label text', () => {
    const wrapper = mount(AppChatDayDivider, { props: { label: 'MAY 16' } });
    expect(wrapper.find('.app-chat-day-divider__label').text()).toBe('MAY 16');
  });

  it('renders YESTERDAY as label', () => {
    const wrapper = mount(AppChatDayDivider, { props: { label: 'YESTERDAY' } });
    expect(wrapper.find('.app-chat-day-divider__label').text()).toBe('YESTERDAY');
  });

  // ── Hairlines ─────────────────────────────────────────────────────────────

  it('renders two hairline elements', () => {
    const wrapper = mount(AppChatDayDivider, { props: { label: 'TODAY' } });
    expect(wrapper.findAll('.app-chat-day-divider__line')).toHaveLength(2);
  });

  it('marks hairlines as aria-hidden', () => {
    const wrapper = mount(AppChatDayDivider, { props: { label: 'TODAY' } });
    for (const line of wrapper.findAll('.app-chat-day-divider__line')) {
      expect(line.attributes('aria-hidden')).toBe('true');
    }
  });
});
