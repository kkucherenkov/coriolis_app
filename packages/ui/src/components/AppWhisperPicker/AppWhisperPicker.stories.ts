import { ref } from 'vue';

import AppWhisperPicker from './AppWhisperPicker.vue';
import type { WhisperPickerMember } from './types';

import type { Meta, StoryObj } from '@storybook/vue3';

function member(n: number, extra: Partial<WhisperPickerMember> = {}): WhisperPickerMember {
  return {
    membershipId: `m-${n}`,
    displayName: `Member ${n}`,
    presence: 'online',
    blockedByMe: false,
    ...extra,
  };
}

const meta: Meta<typeof AppWhisperPicker> = {
  title: 'Chat/AppWhisperPicker',
  component: AppWhisperPicker,
  tags: ['autodocs'],
  parameters: {
    docs: {
      description: {
        component:
          'Modal for selecting a session member to open a whisper channel with. Blocked members are filtered from the DOM. Arrow-key navigation + Enter to pick.',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppWhisperPicker>;

// ── EmptyState ────────────────────────────────────────────────────────────────

export const EmptyState: Story = {
  name: 'Empty state',
  render: () => ({
    components: { AppWhisperPicker },
    setup() {
      const open = ref(true);
      return { open, members: [] };
    },
    template: `<AppWhisperPicker :open="open" :members="members" @close="open = false" @pick="open = false" />`,
  }),
};

// ── ThreeMembers ──────────────────────────────────────────────────────────────

export const ThreeMembers: Story = {
  name: 'Three members',
  render: () => ({
    components: { AppWhisperPicker },
    setup() {
      const open = ref(true);
      const members = [
        member(1, {
          displayName: 'Tariq al-Asari',
          characterName: 'The Navigator',
          presence: 'online',
        }),
        member(2, { displayName: 'Sina Makuu', characterName: 'Bounty Hunter', presence: 'idle' }),
        member(3, { displayName: 'Adisa Eze', presence: 'offline' }),
      ];
      return { open, members };
    },
    template: `<AppWhisperPicker :open="open" :members="members" @close="open = false" @pick="(id) => { console.log('pick', id); open = false; }" />`,
  }),
};

// ── OneBlockedFiltered ────────────────────────────────────────────────────────

export const OneBlockedFiltered: Story = {
  name: 'One blocked — filtered out',
  render: () => ({
    components: { AppWhisperPicker },
    setup() {
      const open = ref(true);
      const members = [
        member(1, { displayName: 'Tariq al-Asari', presence: 'online' }),
        member(2, { displayName: 'Blocked Person', presence: 'online', blockedByMe: true }),
        member(3, { displayName: 'Sina Makuu', presence: 'idle' }),
      ];
      return { open, members };
    },
    template: `<AppWhisperPicker :open="open" :members="members" @close="open = false" @pick="open = false" />`,
  }),
};

// ── MixedPresences ────────────────────────────────────────────────────────────

export const MixedPresences: Story = {
  name: 'Mixed presences',
  render: () => ({
    components: { AppWhisperPicker },
    setup() {
      const open = ref(true);
      const members = [
        member(1, {
          displayName: 'Tariq al-Asari',
          characterName: 'The Navigator',
          presence: 'online',
        }),
        member(2, { displayName: 'Sina Makuu', presence: 'idle' }),
        member(3, { displayName: 'Adisa Eze', characterName: 'Pilot', presence: 'offline' }),
        member(4, { displayName: 'Leila Nkosi', presence: 'online' }),
      ];
      return { open, members };
    },
    template: `<AppWhisperPicker :open="open" :members="members" @close="open = false" @pick="(id) => { console.log('pick', id); open = false; }" />`,
  }),
};
