import AppChatMessage from './AppChatMessage.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppChatMessage> = {
  title: 'Coriolis/AppChatMessage',
  component: AppChatMessage,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['broadcast-author', 'broadcast-other', 'whisper', 'system'],
    },
    authorPresence: { control: 'select', options: ['online', 'idle', 'offline'] },
  },
  parameters: {
    docs: {
      description: {
        component:
          'Chat message bubble — four variants (broadcast-author, broadcast-other, whisper, system). Composes AppChatAvatar + AppPopover kebab menu for edit/delete/block actions. Alignment: author/ownByMe=right; other/!ownByMe=left; system=centred.',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppChatMessage>;

const bg = (): string =>
  `padding:32px 48px;background:var(--surface-void);display:flex;flex-direction:column;gap:8px;max-width:640px;`;

const NOW = '2026-05-16T14:30:00.000Z';
const EDITED = '2026-05-16T14:45:00.000Z';
const DELETED = '2026-05-16T15:00:00.000Z';

// ── BroadcastAuthor ───────────────────────────────────────────────────────────

export const BroadcastAuthor: Story = {
  name: 'BroadcastAuthor — right-aligned own message',
  render: () => ({
    components: { AppChatMessage },
    setup() {
      return { NOW };
    },
    template: `
      <div style="${bg()}">
        <AppChatMessage
          variant="broadcast-author"
          authorDisplayName="Aelyn Skarn"
          authorPresence="online"
          body="The Zenith Gate is open — we move in five minutes."
          :createdAtIso="NOW"
          :ownByMe="true"
          :ownByGm="false"
          :canEdit="true"
          :canDelete="true"
          :canBlock="false"
        />
      </div>
    `,
  }),
};

// ── BroadcastOther ────────────────────────────────────────────────────────────

export const BroadcastOther: Story = {
  name: 'BroadcastOther — left-aligned with avatar',
  render: () => ({
    components: { AppChatMessage },
    setup() {
      return { NOW };
    },
    template: `
      <div style="${bg()}">
        <AppChatMessage
          variant="broadcast-other"
          authorDisplayName="Junad Vex"
          authorPresence="idle"
          body="Copy that. Engines at forty percent — ready when you are."
          :createdAtIso="NOW"
          :ownByMe="false"
          :ownByGm="false"
          :canEdit="false"
          :canDelete="false"
          :canBlock="true"
        />
      </div>
    `,
  }),
};

// ── WhisperFromMe ─────────────────────────────────────────────────────────────

export const WhisperFromMe: Story = {
  name: 'WhisperFromMe — right-aligned whisper',
  render: () => ({
    components: { AppChatMessage },
    setup() {
      return { NOW };
    },
    template: `
      <div style="${bg()}">
        <AppChatMessage
          variant="whisper"
          authorDisplayName="Aelyn Skarn"
          authorPresence="online"
          body="Meet me at the docking ring after the session."
          :createdAtIso="NOW"
          :ownByMe="true"
          :ownByGm="false"
          :canEdit="true"
          :canDelete="true"
          :canBlock="false"
        />
      </div>
    `,
  }),
};

// ── WhisperToMe ───────────────────────────────────────────────────────────────

export const WhisperToMe: Story = {
  name: 'WhisperToMe — left-aligned whisper from other',
  render: () => ({
    components: { AppChatMessage },
    setup() {
      return { NOW };
    },
    template: `
      <div style="${bg()}">
        <AppChatMessage
          variant="whisper"
          authorDisplayName="Junad Vex"
          authorPresence="online"
          body="I think the GM is planning something."
          :createdAtIso="NOW"
          :ownByMe="false"
          :ownByGm="false"
          :canEdit="false"
          :canDelete="false"
          :canBlock="true"
        />
      </div>
    `,
  }),
};

// ── System ────────────────────────────────────────────────────────────────────

export const System: Story = {
  name: 'System — resolved system label',
  render: () => ({
    components: { AppChatMessage },
    setup() {
      return { NOW };
    },
    template: `
      <div style="${bg()}">
        <AppChatMessage
          variant="system"
          systemLabel="Aelyn Skarn joined the session"
          :createdAtIso="NOW"
          :ownByMe="false"
          :ownByGm="false"
          :canEdit="false"
          :canDelete="false"
          :canBlock="false"
        />
      </div>
    `,
  }),
};

// ── Edited ────────────────────────────────────────────────────────────────────

export const Edited: Story = {
  name: 'Edited — with editedAtIso mark',
  render: () => ({
    components: { AppChatMessage },
    setup() {
      return { NOW, EDITED };
    },
    template: `
      <div style="${bg()}">
        <AppChatMessage
          variant="broadcast-author"
          authorDisplayName="Aelyn Skarn"
          authorPresence="online"
          body="The Zenith Gate is open — corrected waypoint included."
          :createdAtIso="NOW"
          :editedAtIso="EDITED"
          :ownByMe="true"
          :ownByGm="false"
          :canEdit="true"
          :canDelete="true"
          :canBlock="false"
        />
      </div>
    `,
  }),
};

// ── Deleted ───────────────────────────────────────────────────────────────────

export const Deleted: Story = {
  name: 'Deleted — body replaced with placeholder',
  render: () => ({
    components: { AppChatMessage },
    setup() {
      return { NOW, DELETED };
    },
    template: `
      <div style="${bg()}">
        <AppChatMessage
          variant="broadcast-other"
          authorDisplayName="Junad Vex"
          authorPresence="offline"
          body="This should not appear"
          :createdAtIso="NOW"
          :deletedAtIso="DELETED"
          :ownByMe="false"
          :ownByGm="false"
          :canEdit="false"
          :canDelete="false"
          :canBlock="false"
        />
      </div>
    `,
  }),
};

// ── Reduced Motion ────────────────────────────────────────────────────────────

export const ReducedMotion: Story = {
  name: 'Reduced motion — bubble appear animation disabled',
  parameters: {
    reducedMotion: 'reduce',
  },
  render: () => ({
    components: { AppChatMessage },
    setup() {
      return { NOW };
    },
    template: `
      <div style="${bg()}">
        <AppChatMessage
          variant="broadcast-other"
          authorDisplayName="Junad Vex"
          authorPresence="idle"
          body="Copy that. Engines at forty percent — ready when you are."
          :createdAtIso="NOW"
          :ownByMe="false"
          :ownByGm="false"
          :canEdit="false"
          :canDelete="false"
          :canBlock="true"
        />
      </div>
    `,
  }),
};
