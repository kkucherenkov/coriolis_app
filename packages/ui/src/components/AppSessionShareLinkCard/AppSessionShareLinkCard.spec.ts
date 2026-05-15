import { describe, expect, it, vi } from 'vitest';
import { mount } from '@vue/test-utils';

import { AppSessionShareLinkCard } from './index';

const baseProps = {
  url: 'https://app.example.com/app/sessions/join/abc',
  warning: "Won't be shown again.",
  copyLabel: 'Copy',
  copiedLabel: 'Copied',
};

describe('AppSessionShareLinkCard', () => {
  it('renders the URL in a <code>', () => {
    const wrapper = mount(AppSessionShareLinkCard, { props: baseProps });
    expect(wrapper.find('code').text()).toBe(baseProps.url);
  });

  it('renders the warning sentence', () => {
    const wrapper = mount(AppSessionShareLinkCard, { props: baseProps });
    expect(wrapper.text()).toContain("Won't be shown again.");
  });

  it('copies to clipboard on button click and flips to "Copied"', async () => {
    const writeText = vi.fn().mockResolvedValue(undefined);
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText },
      configurable: true,
    });
    const wrapper = mount(AppSessionShareLinkCard, { props: baseProps });
    await wrapper.find('button').trigger('click');
    await wrapper.vm.$nextTick();
    expect(writeText).toHaveBeenCalledWith(baseProps.url);
    expect(wrapper.find('button').text()).toBe('Copied');
  });

  it('keeps button label as "Copy" if clipboard write fails', async () => {
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText: vi.fn().mockRejectedValue(new Error('denied')) },
      configurable: true,
    });
    const wrapper = mount(AppSessionShareLinkCard, { props: baseProps });
    await wrapper.find('button').trigger('click');
    await wrapper.vm.$nextTick();
    expect(wrapper.find('button').text()).toBe('Copy');
  });
});
