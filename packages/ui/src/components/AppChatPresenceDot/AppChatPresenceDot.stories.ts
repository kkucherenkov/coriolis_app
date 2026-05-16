import AppChatPresenceDot from './AppChatPresenceDot.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const PRESENCES = ['online', 'idle', 'offline'] as const;

const meta: Meta<typeof AppChatPresenceDot> = {
  title: 'Coriolis/AppChatPresenceDot',
  component: AppChatPresenceDot,
  tags: ['autodocs'],
  argTypes: {
    presence: { control: 'select', options: PRESENCES },
  },
  args: {
    presence: 'online',
  },
  parameters: {
    docs: {
      description: {
        component:
          'Presence dot — standalone presence indicator extracted from AppChatAvatar. Use in tab strips where a full portrait is not needed. Colours: online=brand-brass, idle=text-secondary, offline=border-only.',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppChatPresenceDot>;

const bg = (): string =>
  `padding:48px;background:var(--surface-void);display:inline-flex;align-items:center;gap:32px;`;

// ── All presences ─────────────────────────────────────────────────────────────

export const AllPresences: Story = {
  name: 'All presences',
  render: () => ({
    components: { AppChatPresenceDot },
    setup() {
      return { presences: PRESENCES };
    },
    template: `
      <div style="${bg()}">
        <div v-for="p in presences" :key="p" style="display:flex;flex-direction:column;align-items:center;gap:8px;">
          <AppChatPresenceDot :presence="p" />
          <span style="font-family:var(--font-body);font-size:11px;color:var(--text-secondary);">{{ p }}</span>
        </div>
      </div>
    `,
  }),
};
