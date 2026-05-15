import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import { AppSessionHeader } from './index';

const baseLabels = {
  statusOnline: 'Online',
  statusOffline: 'Offline',
  dpLabel: 'DP',
  leaveLabel: 'Leave session',
  backLabel: 'Back to sessions',
};

describe('AppSessionHeader', () => {
  it('renders session name', () => {
    const wrapper = mount(AppSessionHeader, {
      props: {
        sessionName: 'The Mercy of Kua',
        mode: 'gm',
        status: 'online',
        dpCount: 3,
        labels: baseLabels,
      },
    });
    expect(wrapper.text()).toContain('The Mercy of Kua');
  });

  it('shows DP count', () => {
    const wrapper = mount(AppSessionHeader, {
      props: { sessionName: 'Test', mode: 'gm', status: 'online', dpCount: 5, labels: baseLabels },
    });
    expect(wrapper.text()).toContain('5');
  });

  it('shows "Online" badge when status is online', () => {
    const wrapper = mount(AppSessionHeader, {
      props: { sessionName: 'Test', mode: 'gm', status: 'online', dpCount: 0, labels: baseLabels },
    });
    expect(wrapper.text()).toContain('Online');
  });

  it('shows "Offline" badge when status is offline', () => {
    const wrapper = mount(AppSessionHeader, {
      props: {
        sessionName: 'Test',
        mode: 'gm',
        status: 'offline',
        dpCount: 0,
        labels: baseLabels,
      },
    });
    expect(wrapper.text()).toContain('Offline');
  });

  it('emits "leave" when Leave button clicked in player mode', async () => {
    const wrapper = mount(AppSessionHeader, {
      props: {
        sessionName: 'Test',
        mode: 'player',
        status: 'online',
        dpCount: 0,
        labels: baseLabels,
      },
    });
    const leaveBtn = wrapper.findAll('button').find((b) => b.text() === 'Leave session');
    expect(leaveBtn).toBeDefined();
    await leaveBtn!.trigger('click');
    expect(wrapper.emitted('leave')).toBeTruthy();
  });

  it('does not render Leave button in GM mode', () => {
    const wrapper = mount(AppSessionHeader, {
      props: { sessionName: 'Test', mode: 'gm', status: 'online', dpCount: 0, labels: baseLabels },
    });
    const leaveBtn = wrapper.findAll('button').find((b) => b.text() === 'Leave session');
    expect(leaveBtn).toBeUndefined();
  });

  it('renders a semantic header element', () => {
    const wrapper = mount(AppSessionHeader, {
      props: { sessionName: 'Test', mode: 'gm', status: 'online', dpCount: 0, labels: baseLabels },
    });
    expect(wrapper.find('header, [role="banner"], h1, h2').exists()).toBe(true);
  });
});
