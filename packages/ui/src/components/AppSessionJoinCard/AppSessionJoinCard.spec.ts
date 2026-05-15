import { describe, expect, it } from 'vitest';
import { mount } from '@vue/test-utils';

import { AppSessionJoinCard } from './index';

const baseLabels = {
  titleValid: 'Join session',
  titleRevoked: 'Invite revoked',
  titleAlreadyMember: 'Already a member',
  titleNotSignedIn: 'Sign in to join',
  sessionLabel: 'Session',
  gmLabel: 'GM',
  ctaJoin: 'Join',
  ctaSignIn: 'Sign in',
  ctaGoToSession: 'Go to session',
  revokedMessage: 'This invite link is no longer active.',
  alreadyMemberMessage: 'You are already a member of this session.',
};

const preview = { sessionName: 'The Mercy of Kua', gmDisplayName: 'Kirill GM' };

describe('AppSessionJoinCard', () => {
  it('valid state: shows session + GM name and Join button', () => {
    const wrapper = mount(AppSessionJoinCard, {
      props: { state: 'valid', preview, labels: baseLabels },
    });
    expect(wrapper.text()).toContain('The Mercy of Kua');
    expect(wrapper.text()).toContain('Kirill GM');
    const joinBtn = wrapper.findAll('button').find((b) => b.text() === 'Join');
    expect(joinBtn).toBeDefined();
  });

  it('valid state: emits "join" on Join button click', async () => {
    const wrapper = mount(AppSessionJoinCard, {
      props: { state: 'valid', preview, labels: baseLabels },
    });
    const joinBtn = wrapper.findAll('button').find((b) => b.text() === 'Join');
    await joinBtn!.trigger('click');
    expect(wrapper.emitted('join')).toBeTruthy();
  });

  it('revoked state: shows revoke message, no Join button', () => {
    const wrapper = mount(AppSessionJoinCard, {
      props: { state: 'revoked', preview: null, labels: baseLabels },
    });
    expect(wrapper.text()).toContain('This invite link is no longer active.');
    expect(wrapper.findAll('button').find((b) => b.text() === 'Join')).toBeUndefined();
  });

  it('already-member state: shows "Go to session" button and emits "goToSession"', async () => {
    const wrapper = mount(AppSessionJoinCard, {
      props: { state: 'already-member', preview, labels: baseLabels },
    });
    const btn = wrapper.findAll('button').find((b) => b.text() === 'Go to session');
    expect(btn).toBeDefined();
    await btn!.trigger('click');
    expect(wrapper.emitted('goToSession')).toBeTruthy();
  });

  it('not-signed-in state: shows Sign in button and emits "signIn"', async () => {
    const wrapper = mount(AppSessionJoinCard, {
      props: { state: 'not-signed-in', preview, labels: baseLabels },
    });
    const btn = wrapper.findAll('button').find((b) => b.text() === 'Sign in');
    expect(btn).toBeDefined();
    await btn!.trigger('click');
    expect(wrapper.emitted('signIn')).toBeTruthy();
  });
});
