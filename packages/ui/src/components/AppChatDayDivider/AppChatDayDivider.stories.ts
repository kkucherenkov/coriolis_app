import AppChatDayDivider from './AppChatDayDivider.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const meta: Meta<typeof AppChatDayDivider> = {
  title: 'Coriolis/AppChatDayDivider',
  component: AppChatDayDivider,
  tags: ['autodocs'],
  argTypes: {
    label: { control: 'text' },
  },
  args: {
    label: 'TODAY',
  },
  parameters: {
    docs: {
      description: {
        component:
          'Chat day divider — brass hairline on both sides of an uppercase Forum-font label. Used to separate message groups by date in the chat transcript.',
      },
    },
  },
};

export default meta;

type Story = StoryObj<typeof AppChatDayDivider>;

const bg = (): string =>
  `padding:48px;background:var(--surface-void);display:flex;flex-direction:column;gap:24px;min-width:320px;`;

// ── Three labels ──────────────────────────────────────────────────────────────

export const ThreeLabels: Story = {
  name: 'TODAY / YESTERDAY / date',
  render: () => ({
    components: { AppChatDayDivider },
    template: `
      <div style="${bg()}">
        <AppChatDayDivider label="TODAY" />
        <AppChatDayDivider label="YESTERDAY" />
        <AppChatDayDivider label="MAY 16" />
      </div>
    `,
  }),
};
