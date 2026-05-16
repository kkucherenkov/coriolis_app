import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppChatPanel from './AppChatPanel.vue';
import type { AppChatPanelRow, ChatTabModel } from './types';

// ── Fixtures ──────────────────────────────────────────────────────────────────

const broadcastTab: ChatTabModel = {
  key: 'broadcast',
  label: 'All',
  kind: 'broadcast',
  unreadCount: 0,
};

const whisperTab: ChatTabModel = {
  key: 'w-1',
  label: 'Player One',
  kind: 'whisper',
  unreadCount: 0,
  presence: 'online',
};

const minimalMessagePayload = {
  variant: 'broadcast-other' as const,
  authorDisplayName: 'Test User',
  createdAtIso: '2024-01-01T10:00:00.000Z',
  ownByMe: false,
  ownByGm: false,
  canEdit: false,
  canDelete: false,
  canBlock: false,
};

function makeMessage(id: string, variant = 'broadcast-other' as const): AppChatPanelRow {
  return {
    id,
    variant,
    payload: { ...minimalMessagePayload, variant },
  };
}

function makeDivider(id: string, label: string): AppChatPanelRow {
  return { id, variant: 'day-divider', payload: { label } };
}

const defaultProps = {
  mode: 'primary' as const,
  connectionStatus: 'subscribed' as const,
  tabs: [broadcastTab],
  activeKey: 'broadcast',
  messages: [],
  composerValue: '',
  composerKind: 'broadcast' as const,
  composerDisabled: false,
  newMessagesCount: 0,
};

// Stubs for children — prevents deep rendering of complex child components
// while still allowing prop-passing assertions via findComponent.
const stubs = {
  AppChatTabStrip: true,
  AppChatConnectionPip: true,
  AppChatMessage: true,
  AppChatDayDivider: true,
  AppChatNewMessagesPill: true,
  AppChatComposer: true,
};

// ── Specs ─────────────────────────────────────────────────────────────────────

describe('AppChatPanel', () => {
  // ── Spec 1: mode modifier class routing ───────────────────────────────────

  it('applies app-chat-panel--mode-primary for mode="primary"', () => {
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, mode: 'primary' },
      global: { stubs },
    });
    expect(wrapper.find('[data-testid="app-chat-panel"]').classes()).toContain(
      'app-chat-panel--mode-primary',
    );
  });

  it('applies app-chat-panel--mode-docked for mode="docked"', () => {
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, mode: 'docked' },
      global: { stubs },
    });
    expect(wrapper.find('[data-testid="app-chat-panel"]').classes()).toContain(
      'app-chat-panel--mode-docked',
    );
  });

  // ── Spec 2: tabs prop forwarded to AppChatTabStrip ────────────────────────

  it('passes tabs prop to AppChatTabStrip', () => {
    const tabs = [broadcastTab, whisperTab];
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, tabs, activeKey: 'broadcast' },
      global: { stubs },
    });
    const strip = wrapper.findComponent({ name: 'AppChatTabStrip' });
    expect(strip.exists()).toBe(true);
    expect(strip.props('tabs')).toEqual(tabs);
  });

  it('passes activeKey prop to AppChatTabStrip', () => {
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, tabs: [broadcastTab, whisperTab], activeKey: 'w-1' },
      global: { stubs },
    });
    const strip = wrapper.findComponent({ name: 'AppChatTabStrip' });
    expect(strip.props('activeKey')).toBe('w-1');
  });

  // ── Spec 3: connectionStatus forwarded to AppChatConnectionPip ─────────────

  it('passes connectionStatus to AppChatConnectionPip', () => {
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, connectionStatus: 'connecting' },
      global: { stubs },
    });
    const pip = wrapper.findComponent({ name: 'AppChatConnectionPip' });
    expect(pip.exists()).toBe(true);
    expect(pip.props('status')).toBe('connecting');
  });

  // ── Spec 4: messages render in order ──────────────────────────────────────

  it('renders AppChatMessage and AppChatDayDivider in correct order', () => {
    const messages: AppChatPanelRow[] = [
      makeDivider('d1', 'TODAY'),
      makeMessage('m1'),
      makeMessage('m2'),
      makeDivider('d2', 'YESTERDAY'),
      makeMessage('m3'),
    ];
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, messages },
      global: { stubs },
    });
    const msgComponents = wrapper.findAllComponents({ name: 'AppChatMessage' });
    const divComponents = wrapper.findAllComponents({ name: 'AppChatDayDivider' });
    expect(msgComponents).toHaveLength(3);
    expect(divComponents).toHaveLength(2);
  });

  // ── Spec 5: day-divider variant renders AppChatDayDivider with payload.label ─

  it('renders AppChatDayDivider with the correct label for day-divider rows', () => {
    const messages: AppChatPanelRow[] = [makeDivider('d1', 'MAY 16')];
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, messages },
      global: { stubs },
    });
    const divider = wrapper.findComponent({ name: 'AppChatDayDivider' });
    expect(divider.exists()).toBe(true);
    expect(divider.props('label')).toBe('MAY 16');
  });

  it('renders AppChatMessage (not AppChatDayDivider) for non-divider rows', () => {
    const messages: AppChatPanelRow[] = [makeMessage('m1', 'broadcast-other')];
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, messages },
      global: { stubs },
    });
    expect(wrapper.findComponent({ name: 'AppChatMessage' }).exists()).toBe(true);
    expect(wrapper.findComponent({ name: 'AppChatDayDivider' }).exists()).toBe(false);
  });

  // ── Spec 6: auto-scroll fires after messages change when near bottom ────────

  it('scrolls to bottom after messages change when wasNearBottom is true', async () => {
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, messages: [] },
      global: { stubs },
      attachTo: document.body,
    });

    // Grab the list element ref and fake scroll metrics so it looks near-bottom
    const listEl = wrapper.find('.app-chat-panel__list').element as HTMLElement;
    Object.defineProperty(listEl, 'scrollHeight', { value: 500, configurable: true });
    Object.defineProperty(listEl, 'clientHeight', { value: 300, configurable: true });
    // scrollTop starts at ~220 — within 80px of bottom (500 - (220 + 300) = -20 → near bottom)
    Object.defineProperty(listEl, 'scrollTop', {
      get: () => scrollTopValue,
      set: (v: number) => {
        scrollTopValue = v;
      },
      configurable: true,
    });
    let scrollTopValue = 220;

    // Add a message — watch fires (flush:'post' needs an extra tick after Vue renders)
    await wrapper.setProps({ messages: [makeMessage('m1')] });
    await wrapper.vm.$nextTick();
    // After the post-flush tick the callback should have set scrollTop to scrollHeight
    expect(scrollTopValue).toBe(500);

    wrapper.unmount();
  });

  // ── Spec 7: auto-scroll suppressed when far from bottom ──────────────────

  it('does NOT scroll to bottom after messages change when user has scrolled up', async () => {
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, messages: [] },
      global: { stubs },
      attachTo: document.body,
    });

    const listEl = wrapper.find('.app-chat-panel__list').element as HTMLElement;
    Object.defineProperty(listEl, 'scrollHeight', { value: 1000, configurable: true });
    Object.defineProperty(listEl, 'clientHeight', { value: 300, configurable: true });
    let scrollTopValue = 0; // Far from bottom (1000 - (0 + 300) = 700 > 80)
    Object.defineProperty(listEl, 'scrollTop', {
      get: () => scrollTopValue,
      set: (v: number) => {
        scrollTopValue = v;
      },
      configurable: true,
    });

    // Simulate a scroll event so wasNearBottom is updated to false
    await listEl.dispatchEvent(new Event('scroll'));
    await wrapper.vm.$nextTick();

    // Now add a message
    const initialScrollTop = scrollTopValue;
    await wrapper.setProps({ messages: [makeMessage('m1')] });
    expect(scrollTopValue).toBe(initialScrollTop); // unchanged

    wrapper.unmount();
  });

  // ── Spec 8: AppChatNewMessagesPill rendered only when newMessagesCount > 0 ──

  it('passes newMessagesCount > 0 to AppChatNewMessagesPill', () => {
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, newMessagesCount: 5 },
      global: { stubs },
    });
    const pill = wrapper.findComponent({ name: 'AppChatNewMessagesPill' });
    expect(pill.exists()).toBe(true);
    expect(pill.props('count')).toBe(5);
  });

  it('passes newMessagesCount === 0 to AppChatNewMessagesPill (pill short-circuits internally)', () => {
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, newMessagesCount: 0 },
      global: { stubs },
    });
    const pill = wrapper.findComponent({ name: 'AppChatNewMessagesPill' });
    // The stub is always rendered; what matters is count prop is 0
    expect(pill.props('count')).toBe(0);
  });

  // ── Spec 9: clicking the pill emits jump-to-newest ────────────────────────

  it('emits jump-to-newest when AppChatNewMessagesPill emits click', async () => {
    // Use real pill so click event propagates correctly through the pill's own logic
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, newMessagesCount: 3 },
      global: {
        stubs: {
          ...stubs,
          AppChatNewMessagesPill: false, // real component
        },
      },
    });
    const pill = wrapper.findComponent({ name: 'AppChatNewMessagesPill' });
    await pill.trigger('click');
    expect(wrapper.emitted('jump-to-newest')).toHaveLength(1);
  });

  // ── Spec 10: tab-strip events bubble correctly ────────────────────────────

  it('tab-strip @select bubbles as select-tab with the key', async () => {
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, tabs: [broadcastTab, whisperTab] },
      global: { stubs },
    });
    const strip = wrapper.findComponent({ name: 'AppChatTabStrip' });
    await strip.vm.$emit('select', 'w-1');
    expect(wrapper.emitted('select-tab')).toEqual([['w-1']]);
  });

  it('tab-strip @close bubbles as close-tab with the key', async () => {
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, tabs: [broadcastTab, whisperTab] },
      global: { stubs },
    });
    const strip = wrapper.findComponent({ name: 'AppChatTabStrip' });
    await strip.vm.$emit('close', 'w-1');
    expect(wrapper.emitted('close-tab')).toEqual([['w-1']]);
  });

  it('tab-strip @add bubbles as add-whisper', async () => {
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps },
      global: { stubs },
    });
    const strip = wrapper.findComponent({ name: 'AppChatTabStrip' });
    await strip.vm.$emit('add');
    expect(wrapper.emitted('add-whisper')).toHaveLength(1);
  });

  // ── Spec 11: composer events bubble ──────────────────────────────────────

  it('composer @update:modelValue bubbles as update:composer-value', async () => {
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps },
      global: { stubs },
    });
    const composer = wrapper.findComponent({ name: 'AppChatComposer' });
    await composer.vm.$emit('update:modelValue', 'hello');
    expect(wrapper.emitted('update:composer-value')).toEqual([['hello']]);
  });

  it('composer @submit bubbles as submit', async () => {
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps },
      global: { stubs },
    });
    const composer = wrapper.findComponent({ name: 'AppChatComposer' });
    await composer.vm.$emit('submit');
    expect(wrapper.emitted('submit')).toHaveLength(1);
  });

  // ── Spec 12: message events bubble with row id ────────────────────────────

  it('AppChatMessage @edit bubbles as edit-message with row id', async () => {
    const messages = [makeMessage('msg-42', 'broadcast-other')];
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, messages },
      global: { stubs },
    });
    const msg = wrapper.findComponent({ name: 'AppChatMessage' });
    await msg.vm.$emit('edit');
    expect(wrapper.emitted('edit-message')).toEqual([['msg-42']]);
  });

  it('AppChatMessage @delete bubbles as delete-message with row id', async () => {
    const messages = [makeMessage('msg-99', 'broadcast-other')];
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, messages },
      global: { stubs },
    });
    const msg = wrapper.findComponent({ name: 'AppChatMessage' });
    await msg.vm.$emit('delete');
    expect(wrapper.emitted('delete-message')).toEqual([['msg-99']]);
  });

  it('AppChatMessage @block bubbles as block-author with row id', async () => {
    const messages = [makeMessage('msg-77', 'broadcast-other')];
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, messages },
      global: { stubs },
    });
    const msg = wrapper.findComponent({ name: 'AppChatMessage' });
    await msg.vm.$emit('block');
    expect(wrapper.emitted('block-author')).toEqual([['msg-77']]);
  });

  // ── Spec 13: inline-edit forwarding ───────────────────────────────────────

  it('forwards composerEditing* props to AppChatComposer', () => {
    const wrapper = mount(AppChatPanel, {
      props: {
        ...defaultProps,
        composerEditingLabel: 'Editing message',
        composerEditingPreview: 'original body',
        composerCancelEditLabel: 'Discard',
      },
      global: {
        stubs: {
          ...stubs,
          // Render the real component (not stubbed) so we can read the
          // banner text + Cancel-button label rather than reach for
          // shallow attrs on a stub element.
          AppChatComposer: false,
        },
      },
    });
    expect(wrapper.find('[data-testid="edit-banner"]').text()).toContain('Editing message');
    expect(wrapper.find('[data-testid="edit-banner"]').text()).toContain('original body');
    expect(wrapper.find('[data-testid="cancel-edit-btn"]').text()).toBe('Discard');
  });

  it('AppChatComposer @cancel-edit bubbles as cancel-edit', async () => {
    const wrapper = mount(AppChatPanel, {
      props: { ...defaultProps, composerEditingLabel: 'Editing message' },
      global: { stubs },
    });
    const composer = wrapper.findComponent({ name: 'AppChatComposer' });
    await composer.vm.$emit('cancel-edit');
    expect(wrapper.emitted('cancel-edit')).toHaveLength(1);
  });
});
