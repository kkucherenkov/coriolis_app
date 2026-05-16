import AppChatTab from './AppChatTab.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppChatTab> = {
  title: 'Chat/AppChatTab',
  component: AppChatTab,
  tags: ['autodocs'],
  argTypes: {
    kind: { control: 'select', options: ['broadcast', 'whisper'] },
    presence: { control: 'select', options: ['online', 'idle', 'offline'] },
    active: { control: 'boolean' },
    unreadCount: { control: 'number' },
    label: { control: 'text' },
  },
  args: {
    label: 'All',
    kind: 'broadcast',
    active: false,
    unreadCount: 0,
  },
  render: (args) => ({
    components: { AppChatTab },
    setup() {
      return { args };
    },
    template: `<div role="tablist" style="display:flex;padding:var(--space-4);background:var(--surface-night);"><AppChatTab v-bind="args" /></div>`,
  }),
};

export default meta;

type Story = StoryObj<typeof AppChatTab>;

// ── Broadcast ─────────────────────────────────────────────────────────────────

export const BroadcastActive: Story = {
  name: 'Broadcast — active',
  args: { label: 'All', kind: 'broadcast', active: true },
};

export const BroadcastInactive: Story = {
  name: 'Broadcast — inactive',
  args: { label: 'All', kind: 'broadcast', active: false },
};

// ── Whisper ───────────────────────────────────────────────────────────────────

export const WhisperOnline: Story = {
  name: 'Whisper — online',
  args: { label: 'Yuki Tanaka', kind: 'whisper', active: true, presence: 'online' },
};

export const WhisperWithUnread: Story = {
  name: 'Whisper — with unread badge',
  args: {
    label: 'Tariq al-Asari',
    kind: 'whisper',
    active: false,
    presence: 'online',
    unreadCount: 5,
  },
};

export const WhisperIdleInactive: Story = {
  name: 'Whisper — idle, inactive',
  args: { label: 'Sina Makuu', kind: 'whisper', active: false, presence: 'idle' },
};

export const WhisperOfflineActive: Story = {
  name: 'Whisper — offline, active',
  args: { label: 'Adisa Eze', kind: 'whisper', active: true, presence: 'offline' },
};

// ── Strip composition preview ─────────────────────────────────────────────────

export const StripPreview: Story = {
  name: 'Strip composition preview',
  render: () => ({
    components: { AppChatTab },
    template: `
      <div role="tablist" style="display:flex;gap:0;padding:var(--space-2) var(--space-4);background:var(--surface-night);border-bottom:1px solid var(--brand-brass-deep);">
        <AppChatTab label="All" kind="broadcast" :active="true" />
        <AppChatTab label="Yuki Tanaka" kind="whisper" :active="false" presence="online" :unreadCount="2" />
        <AppChatTab label="Tariq al-Asari" kind="whisper" :active="false" presence="idle" />
        <AppChatTab label="Sina Makuu" kind="whisper" :active="false" presence="offline" />
      </div>
    `,
  }),
};
