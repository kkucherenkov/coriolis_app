import { ref } from 'vue';

import AppChatTabStrip from './AppChatTabStrip.vue';
import type { ChatTabModel } from './types';

import type { Meta, StoryObj } from '@storybook/vue3';

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

const meta: Meta<typeof AppChatTabStrip> = {
  title: 'Chat/AppChatTabStrip',
  component: AppChatTabStrip,
  tags: ['autodocs'],
  parameters: {
    docs: {
      description: {
        component:
          'Horizontal tab strip for the chat panel. Broadcast tab is always pinned first. Whisper tabs beyond visibleWhisperLimit collapse into a +N chip backed by AppPopover.',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppChatTabStrip>;

// ── JustBroadcast ─────────────────────────────────────────────────────────────

export const JustBroadcast: Story = {
  name: 'Just broadcast',
  render: () => ({
    components: { AppChatTabStrip },
    setup() {
      const activeKey = ref('broadcast');
      return { tabs: [broadcast], activeKey };
    },
    template: `
      <div style="padding:var(--space-4);background:var(--surface-night);border-bottom:1px solid var(--brand-brass-deep);">
        <AppChatTabStrip :tabs="tabs" :active-key="activeKey" @select="activeKey = $event" />
      </div>
    `,
  }),
};

// ── BroadcastPlus2Whispers ────────────────────────────────────────────────────

export const BroadcastPlus2Whispers: Story = {
  name: 'Broadcast + 2 whispers',
  render: () => ({
    components: { AppChatTabStrip },
    setup() {
      const tabs = [
        broadcast,
        whisper(1, { presence: 'online' }),
        whisper(2, { presence: 'idle', unreadCount: 3 }),
      ];
      const activeKey = ref('broadcast');
      return { tabs, activeKey };
    },
    template: `
      <div style="padding:var(--space-4);background:var(--surface-night);border-bottom:1px solid var(--brand-brass-deep);">
        <AppChatTabStrip :tabs="tabs" :active-key="activeKey" @select="activeKey = $event" @close="console.log('close', $event)" @add="console.log('add')" />
      </div>
    `,
  }),
};

// ── BroadcastPlus5Whispers ────────────────────────────────────────────────────

export const BroadcastPlus5Whispers: Story = {
  name: 'Broadcast + 5 whispers (overflow chip)',
  render: () => ({
    components: { AppChatTabStrip },
    setup() {
      const tabs = [
        broadcast,
        whisper(1, { presence: 'online' }),
        whisper(2, { presence: 'idle', unreadCount: 2 }),
        whisper(3, { presence: 'offline' }),
        whisper(4, { presence: 'online', unreadCount: 1 }),
        whisper(5, { presence: 'idle' }),
      ];
      const activeKey = ref('broadcast');
      return { tabs, activeKey };
    },
    template: `
      <div style="padding:var(--space-4);background:var(--surface-night);border-bottom:1px solid var(--brand-brass-deep);">
        <AppChatTabStrip :tabs="tabs" :active-key="activeKey" @select="activeKey = $event" @close="console.log('close', $event)" @add="console.log('add')" />
      </div>
    `,
  }),
};

// ── BroadcastPlus5WhispersActiveOverflowed ────────────────────────────────────

export const BroadcastPlus5WhispersActiveOverflowed: Story = {
  name: 'Broadcast + 5 whispers — active in overflow',
  render: () => ({
    components: { AppChatTabStrip },
    setup() {
      const tabs = [
        broadcast,
        whisper(1, { presence: 'online' }),
        whisper(2, { presence: 'idle' }),
        whisper(3, { presence: 'offline' }),
        whisper(4, { presence: 'online' }),
        whisper(5, { presence: 'idle' }),
      ];
      // Active key points at a collapsed whisper
      const activeKey = ref('w-4');
      return { tabs, activeKey };
    },
    template: `
      <div style="padding:var(--space-4);background:var(--surface-night);border-bottom:1px solid var(--brand-brass-deep);">
        <AppChatTabStrip :tabs="tabs" :active-key="activeKey" @select="activeKey = $event" @close="console.log('close', $event)" @add="console.log('add')" />
      </div>
    `,
  }),
};

// ── CustomLimit ───────────────────────────────────────────────────────────────

export const CustomLimit: Story = {
  name: 'Custom visibleWhisperLimit=5',
  render: () => ({
    components: { AppChatTabStrip },
    setup() {
      const tabs = [
        broadcast,
        whisper(1, { presence: 'online' }),
        whisper(2, { presence: 'idle' }),
        whisper(3, { presence: 'online' }),
        whisper(4, { presence: 'offline' }),
      ];
      const activeKey = ref('broadcast');
      return { tabs, activeKey };
    },
    template: `
      <div style="padding:var(--space-4);background:var(--surface-night);border-bottom:1px solid var(--brand-brass-deep);">
        <AppChatTabStrip :tabs="tabs" :active-key="activeKey" :visible-whisper-limit="5" @select="activeKey = $event" @close="console.log('close', $event)" @add="console.log('add')" />
      </div>
    `,
  }),
};
