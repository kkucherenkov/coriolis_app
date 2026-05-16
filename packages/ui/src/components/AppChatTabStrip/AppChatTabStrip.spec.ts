import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppChatTabStrip from './AppChatTabStrip.vue';
import type { ChatTabModel } from './types';

const broadcast: ChatTabModel = {
  key: 'broadcast',
  label: 'All',
  kind: 'broadcast',
  unreadCount: 0,
};

function whisper(n: number, extra: Partial<ChatTabModel> = {}): ChatTabModel {
  return {
    key: `w-${n}`,
    label: `Member ${n}`,
    kind: 'whisper',
    unreadCount: 0,
    presence: 'online',
    ...extra,
  };
}

describe('AppChatTabStrip', () => {
  // ── Spec 1: empty tabs does not crash ──────────────────────────────────────

  it('renders the root container with zero tabs without crashing', () => {
    const wrapper = mount(AppChatTabStrip, {
      props: { tabs: [], activeKey: '' },
    });
    expect(wrapper.find('.app-chat-tab-strip').exists()).toBe(true);
  });

  // ── Spec 2: 1 broadcast + 2 whispers → 3 inline, no overflow chip ─────────

  it('renders 3 inline tabs and no overflow chip when 1 broadcast + 2 whispers', () => {
    const wrapper = mount(AppChatTabStrip, {
      props: {
        tabs: [broadcast, whisper(1), whisper(2)],
        activeKey: 'broadcast',
      },
    });
    expect(wrapper.findAllComponents({ name: 'AppChatTab' })).toHaveLength(3);
    expect(wrapper.find('.app-chat-tab-strip__overflow-chip').exists()).toBe(false);
  });

  // ── Spec 3: 1 broadcast + 5 whispers → broadcast + 3 whispers inline + +2 chip ──

  it('shows broadcast + 3 inline whispers + "+2 more" chip when 5 whispers present', () => {
    const wrapper = mount(AppChatTabStrip, {
      props: {
        tabs: [broadcast, whisper(1), whisper(2), whisper(3), whisper(4), whisper(5)],
        activeKey: 'broadcast',
      },
    });
    // 4 AppChatTab components: 1 broadcast + 3 visible whispers
    expect(wrapper.findAllComponents({ name: 'AppChatTab' })).toHaveLength(4);
    const chip = wrapper.find('.app-chat-tab-strip__overflow-chip');
    expect(chip.exists()).toBe(true);
    expect(chip.text()).toContain('+2 more');
  });

  it('overflow chip does not contain the collapsed whispers as inline AppChatTab', () => {
    const wrapper = mount(AppChatTabStrip, {
      props: {
        tabs: [broadcast, whisper(1), whisper(2), whisper(3), whisper(4), whisper(5)],
        activeKey: 'broadcast',
      },
    });
    // Only 4 AppChatTab instances rendered inline (1 broadcast + 3 whispers)
    const inlineTabs = wrapper.findAllComponents({ name: 'AppChatTab' });
    expect(inlineTabs).toHaveLength(4);
    // Collapsed whispers w-4 and w-5 must NOT appear as AppChatTab
    const labels = inlineTabs.map((t) => t.props('label') as string);
    expect(labels).not.toContain('Member 4');
    expect(labels).not.toContain('Member 5');
  });

  // ── Spec 4: clicking a tab emits select with its key ──────────────────────

  it('clicking an inline tab emits select with the correct key', async () => {
    const wrapper = mount(AppChatTabStrip, {
      props: {
        tabs: [broadcast, whisper(1)],
        activeKey: 'broadcast',
      },
    });
    await wrapper.findAllComponents({ name: 'AppChatTab' })[1]!.trigger('click');
    const emitted = wrapper.emitted('select') as string[][];
    expect(emitted).toBeDefined();
    expect(emitted[0]).toEqual(['w-1']);
  });

  // ── Spec 5: clicking a tab close emits close with its key (not select) ─────

  it('clicking a whisper tab close emits close with key and does not emit select', async () => {
    const wrapper = mount(AppChatTabStrip, {
      props: {
        tabs: [broadcast, whisper(1)],
        activeKey: 'broadcast',
      },
    });
    const closeBtn = wrapper.find('.app-chat-tab__close');
    expect(closeBtn.exists()).toBe(true);
    await closeBtn.trigger('click');
    expect(wrapper.emitted('close')?.[0]).toEqual(['w-1']);
    expect(wrapper.emitted('select')).toBeUndefined();
  });

  // ── Spec 6: + button emits add ────────────────────────────────────────────

  it('clicking the + button emits add', async () => {
    const wrapper = mount(AppChatTabStrip, {
      props: { tabs: [broadcast], activeKey: 'broadcast' },
    });
    await wrapper.find('.app-chat-tab-strip__add').trigger('click');
    expect(wrapper.emitted('add')).toHaveLength(1);
  });

  // ── Spec 7: activeKey determines which tab has active=true ────────────────

  it('broadcast tab is active when activeKey matches broadcast key', () => {
    const wrapper = mount(AppChatTabStrip, {
      props: {
        tabs: [broadcast, whisper(1)],
        activeKey: 'broadcast',
      },
    });
    const tabs = wrapper.findAllComponents({ name: 'AppChatTab' });
    expect(tabs[0]!.props('active')).toBe(true);
    expect(tabs[1]!.props('active')).toBe(false);
  });

  it('whisper tab is active when activeKey matches its key', () => {
    const wrapper = mount(AppChatTabStrip, {
      props: {
        tabs: [broadcast, whisper(1)],
        activeKey: 'w-1',
      },
    });
    const tabs = wrapper.findAllComponents({ name: 'AppChatTab' });
    expect(tabs[0]!.props('active')).toBe(false);
    expect(tabs[1]!.props('active')).toBe(true);
  });

  // ── Spec 8: overflow popover opens; clicking a row emits select ───────────

  it('overflow chip opens popover and clicking a row emits select with correct key', async () => {
    const wrapper = mount(AppChatTabStrip, {
      props: {
        tabs: [broadcast, whisper(1), whisper(2), whisper(3), whisper(4), whisper(5)],
        activeKey: 'broadcast',
      },
      attachTo: document.body,
    });

    // Click the overflow chip to open the popover
    await wrapper.find('.app-chat-tab-strip__overflow-chip').trigger('click');
    await wrapper.vm.$nextTick();

    // The overflow rows should now be visible
    const rows = wrapper.findAll('.app-chat-tab-strip__overflow-row');
    expect(rows.length).toBeGreaterThan(0);

    // Click the first overflow row (w-4)
    await rows[0]!.trigger('click');
    const emitted = wrapper.emitted('select') as string[][];
    expect(emitted).toBeDefined();
    const keys = emitted.map((e) => e[0]);
    expect(keys).toContain('w-4');

    wrapper.unmount();
  });

  // ── Spec 9: custom visibleWhisperLimit ─────────────────────────────────────

  it('no overflow chip when whisper count <= visibleWhisperLimit=5', () => {
    const wrapper = mount(AppChatTabStrip, {
      props: {
        tabs: [broadcast, whisper(1), whisper(2), whisper(3), whisper(4)],
        activeKey: 'broadcast',
        visibleWhisperLimit: 5,
      },
    });
    expect(wrapper.find('.app-chat-tab-strip__overflow-chip').exists()).toBe(false);
    // All 5 tabs rendered inline
    expect(wrapper.findAllComponents({ name: 'AppChatTab' })).toHaveLength(5);
  });
});
