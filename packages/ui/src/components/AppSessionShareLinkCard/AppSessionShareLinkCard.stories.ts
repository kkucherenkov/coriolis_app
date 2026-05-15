import type { Meta, StoryObj } from '@storybook/vue3';

import { AppSessionShareLinkCard } from './index';

const meta: Meta<typeof AppSessionShareLinkCard> = {
  title: 'Phase 8/AppSessionShareLinkCard',
  component: AppSessionShareLinkCard,
};
export default meta;

type Story = StoryObj<typeof AppSessionShareLinkCard>;

export const Default: Story = {
  args: {
    url: 'https://app.coriolis.example.com/app/sessions/join/Sl9X3kQpZr8mVtNuY7Hb2C',
    warning: 'This URL appears once. If you lose it, rotate the invite to generate a new one.',
    copyLabel: 'Copy',
    copiedLabel: 'Copied',
  },
};

export const LongUrlWraps: Story = {
  args: {
    ...Default.args,
    url: 'https://very-long-host-name.example.com/app/sessions/join/' + 'X'.repeat(80),
  },
};

export const Russian: Story = {
  args: {
    ...Default.args,
    warning: 'Эта ссылка показывается один раз. Если потеряете — придётся сменить инвайт.',
    copyLabel: 'Скопировать',
    copiedLabel: 'Скопировано',
  },
};
