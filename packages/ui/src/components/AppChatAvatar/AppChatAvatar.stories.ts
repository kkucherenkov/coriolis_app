import AppChatAvatar from './AppChatAvatar.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const SIZES = ['sm', 'md'] as const;
const PRESENCES = ['online', 'idle', 'offline'] as const;

const meta: Meta<typeof AppChatAvatar> = {
  title: 'Coriolis/AppChatAvatar',
  component: AppChatAvatar,
  tags: ['autodocs'],
  argTypes: {
    size: { control: 'select', options: SIZES },
    presence: { control: 'select', options: PRESENCES },
    initials: { control: 'text' },
    src: { control: 'text' },
  },
  args: {
    initials: 'AS',
    size: 'md',
    presence: 'online',
  },
  parameters: {
    docs: {
      description: {
        component:
          'Chat avatar — AppPortrait with an optional presence pip overlay. Used in chat bubble headers, tab strips, and member lists. Pip colours: online=brand-brass, idle=text-secondary, offline=border-only.',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppChatAvatar>;

const bg = (): string =>
  `padding:48px;background:var(--surface-void);display:inline-flex;align-items:center;gap:24px;flex-wrap:wrap;`;

// ── Matrix: sizes × presences ─────────────────────────────────────────────────

export const Matrix: Story = {
  name: 'Size × Presence matrix',
  render: () => ({
    components: { AppChatAvatar },
    setup() {
      return { sizes: SIZES, presences: PRESENCES };
    },
    template: `
      <div style="${bg()}">
        <table style="border-collapse:separate;border-spacing:24px;">
          <thead>
            <tr>
              <th></th>
              <th v-for="p in presences" :key="p" style="font-family:var(--font-body);font-size:12px;color:var(--text-secondary);text-align:center;">{{ p }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="s in sizes" :key="s">
              <td style="font-family:var(--font-body);font-size:12px;color:var(--text-secondary);padding-right:8px;">{{ s }}</td>
              <td v-for="p in presences" :key="p" style="text-align:center;">
                <AppChatAvatar :size="s" :presence="p" initials="AS" />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    `,
  }),
};

// ── No presence ───────────────────────────────────────────────────────────────

export const NoPresence: Story = {
  name: 'No presence pip',
  args: { presence: undefined, initials: 'NA', size: 'md' },
  render: (args) => ({
    components: { AppChatAvatar },
    setup() {
      return { args };
    },
    template: `
      <div style="${bg()}">
        <AppChatAvatar v-bind="args" />
      </div>
    `,
  }),
};
