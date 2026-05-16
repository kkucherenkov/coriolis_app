import AppChatConnectionPip from './AppChatConnectionPip.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const STATUSES = ['connecting', 'subscribed', 'unrecoverable', 'disconnected'] as const;

const meta: Meta<typeof AppChatConnectionPip> = {
  title: 'Coriolis/AppChatConnectionPip',
  component: AppChatConnectionPip,
  tags: ['autodocs'],
  argTypes: {
    status: { control: 'select', options: STATUSES },
  },
  args: {
    status: 'subscribed',
  },
  parameters: {
    docs: {
      description: {
        component:
          'Connection status pip — 6px circle reflecting Centrifugo subscription state. role="status" + aria-live="polite" for screen-reader announcements. Tooltip uses English placeholders until Block 8 adds i18n keys.',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppChatConnectionPip>;

const bg = (): string =>
  `padding:48px;background:var(--surface-void);display:inline-flex;align-items:center;gap:24px;flex-wrap:wrap;`;

// ── All statuses ──────────────────────────────────────────────────────────────

export const AllStatuses: Story = {
  name: 'All statuses',
  render: () => ({
    components: { AppChatConnectionPip },
    setup() {
      return { statuses: STATUSES };
    },
    template: `
      <div style="${bg()}">
        <div v-for="s in statuses" :key="s" style="display:flex;flex-direction:column;align-items:center;gap:8px;">
          <AppChatConnectionPip :status="s" />
          <span style="font-family:var(--font-body);font-size:11px;color:var(--text-secondary);">{{ s }}</span>
        </div>
      </div>
    `,
  }),
};
