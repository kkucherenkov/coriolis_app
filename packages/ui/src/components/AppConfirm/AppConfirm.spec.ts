import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppConfirm from './AppConfirm.vue';

function mountConfirm(props: Record<string, unknown> = {}) {
  return mount(AppConfirm, {
    props: {
      open: true,
      title: 'Discard draft?',
      body: 'You will lose any unsaved changes.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep editing',
      ...props,
    },
    attachTo: document.body,
  });
}

describe('AppConfirm', () => {
  it('renders title and body inside the modal panel', () => {
    const wrapper = mountConfirm();
    const panel = document.body.querySelector('.app-modal__panel');
    expect(panel?.textContent).toContain('Discard draft?');
    expect(panel?.textContent).toContain('You will lose any unsaved changes.');
    wrapper.unmount();
  });

  it('does not render the body block when omitted', () => {
    const wrapper = mountConfirm({ body: '' });
    expect(document.body.querySelector('.app-confirm__body')).toBeNull();
    wrapper.unmount();
  });

  it('renders the confirm CTA with the danger variant when tone="danger"', () => {
    const wrapper = mountConfirm({ tone: 'danger' });
    const confirmBtn = document.body.querySelectorAll('.app-modal__footer .app-button')[1];
    expect(confirmBtn?.classList.contains('app-button--danger')).toBe(true);
    wrapper.unmount();
  });

  it('renders the confirm CTA with the primary variant by default', () => {
    const wrapper = mountConfirm();
    const confirmBtn = document.body.querySelectorAll('.app-modal__footer .app-button')[1];
    expect(confirmBtn?.classList.contains('app-button--primary')).toBe(true);
    wrapper.unmount();
  });

  it('emits "confirm" when the confirm CTA is clicked', async () => {
    const wrapper = mountConfirm();
    const buttons = document.body.querySelectorAll('.app-modal__footer .app-button');
    (buttons[1] as HTMLButtonElement).click();
    await wrapper.vm.$nextTick();
    expect(wrapper.emitted('confirm')).toBeTruthy();
    // Confirm does NOT auto-close — caller decides when to flip `open` so
    // async work can finish + spinner can render.
    expect(wrapper.emitted('update:open')).toBeUndefined();
    wrapper.unmount();
  });

  it('emits "cancel" + "update:open=false" when the cancel button is clicked', async () => {
    const wrapper = mountConfirm();
    const buttons = document.body.querySelectorAll('.app-modal__footer .app-button');
    (buttons[0] as HTMLButtonElement).click();
    await wrapper.vm.$nextTick();
    expect(wrapper.emitted('cancel')).toBeTruthy();
    expect(wrapper.emitted('update:open')).toEqual([[false]]);
    wrapper.unmount();
  });

  it('disables both buttons + spins the confirm CTA when loading=true', () => {
    const wrapper = mountConfirm({ loading: true });
    const buttons = document.body.querySelectorAll(
      '.app-modal__footer .app-button',
    ) as NodeListOf<HTMLButtonElement>;
    expect(buttons[0]?.disabled).toBe(true);
    expect(buttons[1]?.disabled).toBe(true);
    expect(buttons[1]?.classList.contains('app-button--loading')).toBe(true);
    wrapper.unmount();
  });

  it('ignores click on confirm/cancel while loading', async () => {
    const wrapper = mountConfirm({ loading: true });
    const buttons = document.body.querySelectorAll('.app-modal__footer .app-button');
    (buttons[1] as HTMLButtonElement).click();
    (buttons[0] as HTMLButtonElement).click();
    await wrapper.vm.$nextTick();
    expect(wrapper.emitted('confirm')).toBeUndefined();
    expect(wrapper.emitted('cancel')).toBeUndefined();
    wrapper.unmount();
  });

  it('emits "cancel" when AppModal closes via Esc (proxied through update:open=false)', async () => {
    const wrapper = mountConfirm();
    // Simulate Esc key
    const event = new KeyboardEvent('keydown', { key: 'Escape' });
    document.dispatchEvent(event);
    await wrapper.vm.$nextTick();
    expect(wrapper.emitted('cancel')).toBeTruthy();
    expect(wrapper.emitted('update:open')).toEqual([[false]]);
    wrapper.unmount();
  });

  it('does not close on backdrop click (defense-in-depth for destructive confirms)', async () => {
    const wrapper = mountConfirm({ tone: 'danger' });
    const backdrop = document.body.querySelector('.app-modal__backdrop') as HTMLElement;
    backdrop.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await wrapper.vm.$nextTick();
    // Neither cancel nor update:open should fire from a backdrop click.
    expect(wrapper.emitted('cancel')).toBeUndefined();
    expect(wrapper.emitted('update:open')).toBeUndefined();
    wrapper.unmount();
  });
});
