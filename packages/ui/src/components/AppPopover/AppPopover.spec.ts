import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppPopover from './AppPopover.vue';

// Helper: mount with a trigger slot and default slot content.
function mountPopover(props: Record<string, unknown> = {}, slots: Record<string, string> = {}) {
  return mount(AppPopover, {
    props: { open: false, placement: 'bottom', ...props },
    slots: {
      trigger: '<button type="button" data-trigger>Open</button>',
      default: '<div data-content>Popover body</div>',
      ...slots,
    },
    attachTo: document.body,
  });
}

describe('AppPopover', () => {
  // ── Trigger slot ──────────────────────────────────────────────────────────

  it('renders the trigger slot', () => {
    const wrapper = mountPopover();
    expect(wrapper.find('[data-trigger]').exists()).toBe(true);
    wrapper.unmount();
  });

  it('does not render the panel when open=false', () => {
    const wrapper = mountPopover({ open: false });
    expect(wrapper.find('.app-popover__panel').exists()).toBe(false);
    wrapper.unmount();
  });

  it('renders the panel when open=true', () => {
    const wrapper = mountPopover({ open: true });
    expect(wrapper.find('.app-popover__panel').exists()).toBe(true);
    wrapper.unmount();
  });

  // ── Trigger click emits update:open ───────────────────────────────────────

  it('emits update:open=true on trigger click when closed', async () => {
    const wrapper = mountPopover({ open: false });
    await wrapper.find('.app-popover__trigger').trigger('click');
    const emitted = wrapper.emitted('update:open') as boolean[][];
    expect(emitted).toBeDefined();
    expect(emitted[0]).toEqual([true]);
    wrapper.unmount();
  });

  it('emits update:open=false on trigger click when open', async () => {
    const wrapper = mountPopover({ open: true });
    await wrapper.find('.app-popover__trigger').trigger('click');
    const emitted = wrapper.emitted('update:open') as boolean[][];
    expect(emitted).toBeDefined();
    expect(emitted[0]).toEqual([false]);
    wrapper.unmount();
  });

  // ── Escape closes the popover ─────────────────────────────────────────────

  it('emits update:open=false on Escape keydown when open', async () => {
    const wrapper = mountPopover({ open: true });
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
    await wrapper.vm.$nextTick();
    const emitted = wrapper.emitted('update:open') as boolean[][];
    expect(emitted).toBeDefined();
    expect(emitted[0]).toEqual([false]);
    wrapper.unmount();
  });

  it('does NOT emit update:open on Escape when already closed', async () => {
    const wrapper = mountPopover({ open: false });
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
    await wrapper.vm.$nextTick();
    expect(wrapper.emitted('update:open')).toBeUndefined();
    wrapper.unmount();
  });

  // ── Click outside closes the popover ─────────────────────────────────────

  it('emits update:open=false on click outside when open', async () => {
    const wrapper = mountPopover({ open: true });
    // Simulate a click outside the component.
    document.body.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await wrapper.vm.$nextTick();
    const emitted = wrapper.emitted('update:open') as boolean[][];
    expect(emitted).toBeDefined();
    expect(emitted[0]).toEqual([false]);
    wrapper.unmount();
  });

  // ── aria-label forwarded to panel ─────────────────────────────────────────

  it('forwards aria-label to the popover surface', () => {
    const wrapper = mountPopover({ open: true, ariaLabel: 'Edit Strength' });
    const panel = wrapper.find('.app-popover__panel');
    expect(panel.attributes('aria-label')).toBe('Edit Strength');
    wrapper.unmount();
  });

  it('panel has role="dialog"', () => {
    const wrapper = mountPopover({ open: true });
    expect(wrapper.find('.app-popover__panel').attributes('role')).toBe('dialog');
    wrapper.unmount();
  });

  // ── BEM modifiers ─────────────────────────────────────────────────────────

  it('applies placement modifier class', () => {
    const wrapper = mountPopover({ placement: 'top' });
    expect(wrapper.classes()).toContain('app-popover--top');
    wrapper.unmount();
  });

  it('applies --open modifier when open=true', () => {
    const wrapper = mountPopover({ open: true });
    expect(wrapper.classes()).toContain('app-popover--open');
    wrapper.unmount();
  });

  it('does not apply --open modifier when open=false', () => {
    const wrapper = mountPopover({ open: false });
    expect(wrapper.classes()).not.toContain('app-popover--open');
    wrapper.unmount();
  });

  // ── Default slot content ──────────────────────────────────────────────────

  it('renders default slot content inside the panel', () => {
    const wrapper = mountPopover({ open: true });
    expect(wrapper.find('[data-content]').exists()).toBe(true);
    wrapper.unmount();
  });
});
