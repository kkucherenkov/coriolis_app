import type { Meta, StoryObj } from '@storybook/vue3';

import { AppInviteManager } from './index';

const baseLabels = {
  title: 'Player invite',
  blurbNone: 'Generate a link your players can use to join this session and link their characters.',
  ctaGenerate: 'Generate invite link',
  labelActiveSince: 'Active since',
  noteActive: 'Current link is valid. Rotating invalidates the old link immediately.',
  ctaCopy: 'Copy link',
  ctaRotate: 'Rotate',
  ctaRevoke: 'Revoke',
  revealTitleNew: 'Your new invite link',
  revealTitleRotated: 'Link rotated',
  revealClose: "I've copied it — close",
  revealWarning: 'This URL appears once. If you lose it, rotate the invite to generate a new one.',
  revealCopy: 'Copy',
  revealCopied: 'Copied',
} as const;

const meta: Meta<typeof AppInviteManager> = {
  title: 'Phase 8/AppInviteManager',
  component: AppInviteManager,
};
export default meta;

type Story = StoryObj<typeof AppInviteManager>;

export const None: Story = { args: { state: 'none', labels: baseLabels } };
export const Active: Story = {
  args: { state: 'active', rotatedAt: '2026-05-15T10:00:00Z', labels: baseLabels },
};
export const JustGenerated: Story = {
  args: {
    state: 'just-generated',
    revealUrl: 'https://app.coriolis.example.com/app/sessions/join/Sl9X3kQpZr8mVtNuY7Hb2C',
    labels: baseLabels,
  },
};
export const JustRotated: Story = {
  ...JustGenerated,
  args: { ...JustGenerated.args!, state: 'just-rotated' },
};
