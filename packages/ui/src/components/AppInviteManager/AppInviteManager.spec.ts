import { describe, expect, it } from 'vitest';
import { mount } from '@vue/test-utils';

import { AppInviteManager } from './index';

const labels = {
  title: 'Player invite',
  blurbNone: 'Generate a link',
  ctaGenerate: 'Generate invite link',
  labelActiveSince: 'Active since',
  noteActive: 'Note',
  ctaCopy: 'Copy',
  ctaRotate: 'Rotate',
  ctaRevoke: 'Revoke',
  revealTitleNew: 'Your new invite link',
  revealTitleRotated: 'Link rotated',
  revealClose: 'Close',
  revealWarning: 'Once only',
  revealCopy: 'Copy',
  revealCopied: 'Copied',
};

describe('AppInviteManager', () => {
  it('renders the empty state and emits "generate"', async () => {
    const wrapper = mount(AppInviteManager, { props: { state: 'none', labels } });
    expect(wrapper.text()).toContain('Generate a link');
    await wrapper.find('button').trigger('click');
    expect(wrapper.emitted('generate')).toBeTruthy();
  });

  it('renders the active state with rotatedAt and emits copy/rotate/revoke', async () => {
    const wrapper = mount(AppInviteManager, {
      props: { state: 'active', rotatedAt: '2026-05-15T10:00:00Z', labels },
    });
    expect(wrapper.text()).toContain('Active since');
    const buttons = wrapper.findAll('button');
    await buttons[0]!.trigger('click');
    await buttons[1]!.trigger('click');
    await buttons[2]!.trigger('click');
    expect(wrapper.emitted('copy')).toBeTruthy();
    expect(wrapper.emitted('rotate')).toBeTruthy();
    expect(wrapper.emitted('revoke')).toBeTruthy();
  });

  it('renders the reveal modal with role="alertdialog" on just-generated', () => {
    const wrapper = mount(AppInviteManager, {
      props: { state: 'just-generated', revealUrl: 'https://x/join/abc', labels },
    });
    expect(wrapper.find('[role="alertdialog"]').exists()).toBe(true);
    expect(wrapper.text()).toContain('Your new invite link');
  });

  it('uses the rotated-title copy on just-rotated', () => {
    const wrapper = mount(AppInviteManager, {
      props: { state: 'just-rotated', revealUrl: 'https://x/join/abc', labels },
    });
    expect(wrapper.text()).toContain('Link rotated');
  });

  it('emits closeReveal when the close button is clicked', async () => {
    const wrapper = mount(AppInviteManager, {
      props: { state: 'just-generated', revealUrl: 'https://x/join/abc', labels },
    });
    const closeBtn = wrapper.findAll('button').find((b) => b.text() === 'Close');
    await closeBtn!.trigger('click');
    expect(wrapper.emitted('closeReveal')).toBeTruthy();
  });
});
