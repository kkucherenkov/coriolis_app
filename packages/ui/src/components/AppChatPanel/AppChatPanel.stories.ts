import { ref } from 'vue';

import AppChatPanel from './AppChatPanel.vue';
import type { AppChatPanelRow, ChatTabModel } from './types';

import type { Meta, StoryObj } from '@storybook/vue3';

// ── Shared fixtures ───────────────────────────────────────────────────────────

const broadcastTab: ChatTabModel = {
  key: 'broadcast',
  label: 'All',
  kind: 'broadcast',
  unreadCount: 0,
};

function whisperTab(n: number, unread = 0): ChatTabModel {
  return {
    key: `w-${n}`,
    label: `Player ${n}`,
    kind: 'whisper',
    unreadCount: unread,
    presence: (['online', 'idle', 'offline'] as const)[n % 3],
  };
}

function broadcastOther(id: string, author: string, body: string, iso: string): AppChatPanelRow {
  return {
    id,
    variant: 'broadcast-other',
    payload: {
      variant: 'broadcast-other',
      authorDisplayName: author,
      authorPresence: 'online',
      body,
      createdAtIso: iso,
      ownByMe: false,
      ownByGm: false,
      canEdit: false,
      canDelete: true,
      canBlock: true,
    },
  };
}

function broadcastAuthor(id: string, body: string, iso: string): AppChatPanelRow {
  return {
    id,
    variant: 'broadcast-author',
    payload: {
      variant: 'broadcast-author',
      authorDisplayName: 'Me',
      body,
      createdAtIso: iso,
      ownByMe: true,
      ownByGm: false,
      canEdit: true,
      canDelete: true,
      canBlock: false,
    },
  };
}

function whisperMsg(id: string, body: string, iso: string, ownByMe: boolean): AppChatPanelRow {
  return {
    id,
    variant: 'whisper',
    payload: {
      variant: 'whisper',
      authorDisplayName: ownByMe ? 'Me' : 'Player One',
      body,
      createdAtIso: iso,
      ownByMe,
      ownByGm: false,
      canEdit: ownByMe,
      canDelete: ownByMe,
      canBlock: !ownByMe,
    },
  };
}

function divider(id: string, label: string): AppChatPanelRow {
  return { id, variant: 'day-divider', payload: { label } };
}

// 50 mixed broadcast messages + 2 day dividers for PrimaryBroadcast
function buildBroadcastMessages(): AppChatPanelRow[] {
  const yesterdayRows = Array.from({ length: 25 }, (_, idx) => {
    const i = idx + 1;
    const iso = `2024-01-14T${String(8 + Math.floor(i / 4)).padStart(2, '0')}:${String((i * 2) % 60).padStart(2, '0')}:00.000Z`;
    return i % 3 === 0
      ? broadcastAuthor(`m-y-${i}`, `My message #${i} from yesterday.`, iso)
      : broadcastOther(`m-y-${i}`, `Player ${(i % 4) + 1}`, `Hello world #${i}!`, iso);
  });

  const todayRows = Array.from({ length: 25 }, (_, idx) => {
    const i = idx + 1;
    const iso = `2024-01-15T${String(9 + Math.floor(i / 4)).padStart(2, '0')}:${String((i * 3) % 60).padStart(2, '0')}:00.000Z`;
    return i % 4 === 0
      ? broadcastAuthor(`m-t-${i}`, `My reply #${i} today.`, iso)
      : broadcastOther(`m-t-${i}`, `Player ${(i % 3) + 1}`, `Message #${i} today!`, iso);
  });

  return [
    divider('d-yesterday', 'YESTERDAY'),
    ...yesterdayRows,
    divider('d-today', 'TODAY'),
    ...todayRows,
  ];
}

// 15 whisper messages
function buildWhisperMessages(): AppChatPanelRow[] {
  const msgs = Array.from({ length: 15 }, (_, idx) => {
    const i = idx + 1;
    const iso = `2024-01-15T10:${String(i * 4).padStart(2, '0')}:00.000Z`;
    return whisperMsg(`wm-${i}`, `Whisper message #${i}.`, iso, i % 2 === 0);
  });
  return [divider('d-w-today', 'TODAY'), ...msgs];
}

// ── Meta ──────────────────────────────────────────────────────────────────────

const meta: Meta<typeof AppChatPanel> = {
  title: 'Coriolis/AppChatPanel',
  component: AppChatPanel,
  tags: ['autodocs'],
  parameters: {
    docs: {
      description: {
        component:
          'Composition root that owns layout, auto-scroll, the new-messages pill, and the connection-pip slot. All state comes from the consumer. Props in, events out.',
      },
    },
    layout: 'fullscreen',
  },
};

export default meta;

type Story = StoryObj<typeof AppChatPanel>;

// ── Story 1: PrimaryBroadcast ─────────────────────────────────────────────────

export const PrimaryBroadcast: Story = {
  name: 'Primary — broadcast (50 messages)',
  render: () => ({
    components: { AppChatPanel },
    setup() {
      const messages = buildBroadcastMessages();
      const tabs = [broadcastTab, whisperTab(1, 2), whisperTab(2, 0)];
      const activeKey = ref('broadcast');
      const composerValue = ref('');
      const newMessagesCount = ref(0);

      return { messages, tabs, activeKey, composerValue, newMessagesCount };
    },
    template: `
      <div style="height:100vh;display:flex;">
        <AppChatPanel
          mode="primary"
          connection-status="subscribed"
          :tabs="tabs"
          :active-key="activeKey"
          :messages="messages"
          :composer-value="composerValue"
          composer-kind="broadcast"
          :composer-disabled="false"
          :new-messages-count="newMessagesCount"
          @select-tab="activeKey = $event"
          @close-tab="console.log('close-tab', $event)"
          @add-whisper="console.log('add-whisper')"
          @update:composer-value="composerValue = $event"
          @submit="console.log('submit', composerValue); composerValue = ''"
          @edit-message="console.log('edit-message', $event)"
          @delete-message="console.log('delete-message', $event)"
          @block-author="console.log('block-author', $event)"
          @jump-to-newest="newMessagesCount = 0"
        />
      </div>
    `,
  }),
};

// ── Story 2: PrimaryWhisper ───────────────────────────────────────────────────

export const PrimaryWhisper: Story = {
  name: 'Primary — whisper conversation',
  render: () => ({
    components: { AppChatPanel },
    setup() {
      const messages = buildWhisperMessages();
      const tabs = [broadcastTab, whisperTab(1, 0)];
      const activeKey = ref('w-1');
      const composerValue = ref('');
      const newMessagesCount = ref(0);

      return { messages, tabs, activeKey, composerValue, newMessagesCount };
    },
    template: `
      <div style="height:100vh;display:flex;">
        <AppChatPanel
          mode="primary"
          connection-status="subscribed"
          :tabs="tabs"
          :active-key="activeKey"
          :messages="messages"
          :composer-value="composerValue"
          composer-kind="whisper"
          composer-partner-display-name="Player One"
          :composer-disabled="false"
          :new-messages-count="newMessagesCount"
          @select-tab="activeKey = $event"
          @close-tab="console.log('close-tab', $event)"
          @add-whisper="console.log('add-whisper')"
          @update:composer-value="composerValue = $event"
          @submit="console.log('submit', composerValue); composerValue = ''"
          @edit-message="console.log('edit-message', $event)"
          @delete-message="console.log('delete-message', $event)"
          @block-author="console.log('block-author', $event)"
          @jump-to-newest="newMessagesCount = 0"
        />
      </div>
    `,
  }),
};

// ── Story 3: DockedEmpty ──────────────────────────────────────────────────────

export const DockedEmpty: Story = {
  name: 'Docked — empty (broadcast only)',
  render: () => ({
    components: { AppChatPanel },
    setup() {
      const composerValue = ref('');

      return { composerValue };
    },
    template: `
      <div style="height:100vh;display:flex;justify-content:flex-end;background:var(--surface-night);">
        <AppChatPanel
          mode="docked"
          connection-status="subscribed"
          :tabs="[{ key: 'broadcast', label: 'All', kind: 'broadcast', unreadCount: 0 }]"
          active-key="broadcast"
          :messages="[]"
          :composer-value="composerValue"
          composer-kind="broadcast"
          :composer-disabled="false"
          :new-messages-count="0"
          @update:composer-value="composerValue = $event"
          @submit="console.log('submit')"
        />
      </div>
    `,
  }),
};
