import AppSessionHeader from './AppSessionHeader.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const labels = {
  statusOnline: 'Online',
  statusOffline: 'Offline',
  dpLabel: 'DP',
  leaveLabel: 'Leave session',
  backLabel: 'Back to sessions',
};

const meta: Meta<typeof AppSessionHeader> = {
  title: 'Components/AppSessionHeader',
  component: AppSessionHeader,
  tags: ['autodocs'],
  argTypes: {
    mode: { control: 'select', options: ['gm', 'player'] },
    status: { control: 'select', options: ['online', 'offline'] },
    dpCount: { control: 'number' },
  },
  args: {
    sessionName: 'The Mercy of Kua',
    mode: 'gm',
    status: 'online',
    dpCount: 3,
    labels,
  },
};

export default meta;

type Story = StoryObj<typeof AppSessionHeader>;

export const GmOnline: Story = {
  name: 'GM / Online',
  args: { sessionName: 'The Mercy of Kua', mode: 'gm', status: 'online', dpCount: 3, labels },
};

export const GmOffline: Story = {
  name: 'GM / Offline',
  args: { sessionName: 'The Mercy of Kua', mode: 'gm', status: 'offline', dpCount: 3, labels },
};

export const PlayerOnline: Story = {
  name: 'Player / Online',
  args: { sessionName: 'The Mercy of Kua', mode: 'player', status: 'online', dpCount: 3, labels },
};

export const PlayerOffline: Story = {
  name: 'Player / Offline',
  args: {
    sessionName: 'The Mercy of Kua',
    mode: 'player',
    status: 'offline',
    dpCount: 3,
    labels,
  },
};
