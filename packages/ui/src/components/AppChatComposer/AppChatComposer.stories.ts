import { ref } from 'vue';

import AppChatComposer from './AppChatComposer.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppChatComposer> = {
  title: 'Coriolis/AppChatComposer',
  component: AppChatComposer,
  tags: ['autodocs'],
  argTypes: {
    conversationKind: { control: 'select', options: ['broadcast', 'whisper'] },
    partnerDisplayName: { control: 'text' },
    maxLength: { control: 'number' },
    disabled: { control: 'boolean' },
  },
  parameters: {
    docs: {
      description: {
        component:
          'Chat composer — multi-line textarea with character counter and ⌘/Ctrl+Enter submit. Broadcasts to all or whispers to a named partner. Counter warns at maxLength-64 and errors at maxLength.',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppChatComposer>;

const bg = (): string => `padding:32px 48px;background:var(--surface-void);max-width:520px;`;

// ── BroadcastEmpty ────────────────────────────────────────────────────────────

export const BroadcastEmpty: Story = {
  name: 'BroadcastEmpty — empty broadcast composer',
  render: () => ({
    components: { AppChatComposer },
    setup() {
      const value = ref('');
      return { value };
    },
    template: `
      <div style="${bg()}">
        <AppChatComposer
          v-model="value"
          conversationKind="broadcast"
        />
      </div>
    `,
  }),
};

// ── BroadcastTyping ───────────────────────────────────────────────────────────

export const BroadcastTyping: Story = {
  name: 'BroadcastTyping — in-progress broadcast',
  render: () => ({
    components: { AppChatComposer },
    setup() {
      const value = ref('The Zenith Gate is open — we move in five minutes.');
      return { value };
    },
    template: `
      <div style="${bg()}">
        <AppChatComposer
          v-model="value"
          conversationKind="broadcast"
        />
      </div>
    `,
  }),
};

// ── WhisperToPlayer ───────────────────────────────────────────────────────────

export const WhisperToPlayer: Story = {
  name: 'WhisperToPlayer — whisper with partnerDisplayName',
  render: () => ({
    components: { AppChatComposer },
    setup() {
      const value = ref('');
      return { value };
    },
    template: `
      <div style="${bg()}">
        <AppChatComposer
          v-model="value"
          conversationKind="whisper"
          partnerDisplayName="Junad Vex"
        />
      </div>
    `,
  }),
};

// ── NearLimit ─────────────────────────────────────────────────────────────────

export const NearLimit: Story = {
  name: 'NearLimit — 4032 characters (warn zone)',
  render: () => ({
    components: { AppChatComposer },
    setup() {
      // 4096 - 64 = 4032 — first character in the warn zone
      const value = ref('a'.repeat(4032));
      return { value };
    },
    template: `
      <div style="${bg()}">
        <AppChatComposer
          v-model="value"
          conversationKind="broadcast"
          :maxLength="4096"
        />
      </div>
    `,
  }),
};

// ── AtLimit ───────────────────────────────────────────────────────────────────

export const AtLimit: Story = {
  name: 'AtLimit — 4096 characters (error zone)',
  render: () => ({
    components: { AppChatComposer },
    setup() {
      const value = ref('a'.repeat(4096));
      return { value };
    },
    template: `
      <div style="${bg()}">
        <AppChatComposer
          v-model="value"
          conversationKind="broadcast"
          :maxLength="4096"
        />
      </div>
    `,
  }),
};

// ── Disabled ──────────────────────────────────────────────────────────────────

export const Disabled: Story = {
  name: 'Disabled — composer disabled state',
  render: () => ({
    components: { AppChatComposer },
    setup() {
      const value = ref('Cannot type here');
      return { value };
    },
    template: `
      <div style="${bg()}">
        <AppChatComposer
          v-model="value"
          conversationKind="broadcast"
          :disabled="true"
        />
      </div>
    `,
  }),
};
