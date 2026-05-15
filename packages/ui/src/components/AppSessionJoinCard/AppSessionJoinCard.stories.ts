import AppSessionJoinCard from './AppSessionJoinCard.vue';

import type { Meta, StoryObj } from '@storybook/vue3';

const labels = {
  titleValid: 'Join session',
  titleRevoked: 'Invite revoked',
  titleAlreadyMember: 'Already a member',
  titleNotSignedIn: 'Sign in to join',
  sessionLabel: 'Session',
  gmLabel: 'GM',
  ctaJoin: 'Join',
  ctaSignIn: 'Sign in',
  ctaGoToSession: 'Go to session',
  revokedMessage: 'This invite link is no longer active. Ask the GM for a new one.',
  alreadyMemberMessage: 'You are already a member of this session.',
};

const preview = { sessionName: 'The Mercy of Kua', gmDisplayName: 'Kirill GM' };

const meta: Meta<typeof AppSessionJoinCard> = {
  title: 'Components/AppSessionJoinCard',
  component: AppSessionJoinCard,
  tags: ['autodocs'],
  argTypes: {
    state: {
      control: 'select',
      options: ['valid', 'revoked', 'already-member', 'not-signed-in'],
    },
  },
  args: {
    state: 'valid',
    preview,
    labels,
  },
};

export default meta;

type Story = StoryObj<typeof AppSessionJoinCard>;

export const Valid: Story = {
  name: 'Valid — invite active',
  args: { state: 'valid', preview, labels },
};

export const Revoked: Story = {
  name: 'Revoked — 404/410',
  args: { state: 'revoked', preview: null, labels },
};

export const AlreadyMember: Story = {
  name: 'Already a member',
  args: { state: 'already-member', preview, labels },
};

export const NotSignedIn: Story = {
  name: 'Not signed in',
  args: { state: 'not-signed-in', preview, labels },
};
