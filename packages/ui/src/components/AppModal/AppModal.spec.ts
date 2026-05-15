import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppModal from './AppModal.vue';

// ── Helper ───────────────────────────────────────────────────────────────────

function mountModal(props: Record<string, unknown> = {}, slots: Record<string, string> = {}) {
  return mount(AppModal, {
    props: { open: false, ...props },
    slots: {
      default: '<div data-content>Modal body content</div>',
      ...slots,
    },
    attachTo: document.body,
  });
}

describe('AppModal', () => {
  // ── Mounting into body via Teleport ───────────────────────────────────────

  it('mounts content into document.body via Teleport when open=true', () => {
    const wrapper = mountModal({ open: true });
    // The backdrop should be rendered into the document body.
    expect(document.body.querySelector('.app-modal__backdrop')).not.toBeNull();
    wrapper.unmount();
  });

  it('does not render the backdrop when open=false', () => {
    const wrapper = mountModal({ open: false });
    expect(document.body.querySelector('.app-modal__backdrop')).toBeNull();
    wrapper.unmount();
  });

  // ── Opens and closes ──────────────────────────────────────────────────────

  it('shows the panel when open=true', () => {
    const wrapper = mountModal({ open: true });
    expect(document.body.querySelector('.app-modal__panel')).not.toBeNull();
    wrapper.unmount();
  });

  it('hides the panel when open switches to false', async () => {
    const wrapper = mountModal({ open: true });
    await wrapper.setProps({ open: false });
    expect(document.body.querySelector('.app-modal__panel')).toBeNull();
    wrapper.unmount();
  });

  // ── Escape closes the modal ───────────────────────────────────────────────

  it('emits update:open=false when Escape is pressed (closeOnEsc=true)', async () => {
    const wrapper = mountModal({ open: true, closeOnEsc: true });
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
    await wrapper.vm.$nextTick();
    const emitted = wrapper.emitted('update:open') as boolean[][];
    expect(emitted).toBeDefined();
    expect(emitted[0]).toEqual([false]);
    wrapper.unmount();
  });

  it('does NOT emit on Escape when closeOnEsc=false', async () => {
    const wrapper = mountModal({ open: true, closeOnEsc: false });
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
    await wrapper.vm.$nextTick();
    expect(wrapper.emitted('update:open')).toBeUndefined();
    wrapper.unmount();
  });

  // ── Backdrop click closes the modal ───────────────────────────────────────

  it('emits update:open=false on backdrop click (closeOnBackdrop=true)', async () => {
    const wrapper = mountModal({ open: true, closeOnBackdrop: true });
    const backdrop = document.body.querySelector<HTMLElement>('.app-modal__backdrop');
    expect(backdrop).not.toBeNull();
    backdrop!.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await wrapper.vm.$nextTick();
    const emitted = wrapper.emitted('update:open') as boolean[][];
    expect(emitted).toBeDefined();
    expect(emitted[0]).toEqual([false]);
    wrapper.unmount();
  });

  it('does NOT emit on backdrop click when closeOnBackdrop=false', async () => {
    const wrapper = mountModal({ open: true, closeOnBackdrop: false });
    const backdrop = document.body.querySelector<HTMLElement>('.app-modal__backdrop');
    backdrop!.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await wrapper.vm.$nextTick();
    expect(wrapper.emitted('update:open')).toBeUndefined();
    wrapper.unmount();
  });

  // PATTERNS.md §5 — backdrop click is NOT a close trigger by default.
  // Pins the post-2026-05-15 contract (T-AUDIT-2026-05-15-MODAL-BACKDROP-DEFAULT).
  it('does NOT emit on backdrop click by default (closeOnBackdrop unset)', async () => {
    const wrapper = mountModal({ open: true });
    const backdrop = document.body.querySelector<HTMLElement>('.app-modal__backdrop');
    backdrop!.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await wrapper.vm.$nextTick();
    expect(wrapper.emitted('update:open')).toBeUndefined();
    wrapper.unmount();
  });

  // ── aria-label flows through ──────────────────────────────────────────────

  it('forwards aria-label to the backdrop element', () => {
    const wrapper = mountModal({ open: true, ariaLabel: 'Add item' });
    const backdrop = document.body.querySelector('.app-modal__backdrop');
    expect(backdrop?.getAttribute('aria-label')).toBe('Add item');
    wrapper.unmount();
  });

  it('sets aria-modal="true" on the backdrop', () => {
    const wrapper = mountModal({ open: true });
    const backdrop = document.body.querySelector('.app-modal__backdrop');
    expect(backdrop?.getAttribute('aria-modal')).toBe('true');
    wrapper.unmount();
  });

  // ── Focus management ──────────────────────────────────────────────────────

  it('moves focus to first focusable element inside the modal on open', async () => {
    const wrapper = mount(AppModal, {
      props: { open: true },
      slots: {
        default: '<button data-first-btn type="button">First</button>',
      },
      attachTo: document.body,
    });

    await wrapper.vm.$nextTick();
    // Focus should have moved to the first button inside the modal.
    const firstBtn = document.body.querySelector<HTMLElement>('[data-first-btn]');
    expect(document.activeElement).toBe(firstBtn);
    wrapper.unmount();
  });

  // ── Footer slot ───────────────────────────────────────────────────────────

  it('renders footer slot when provided', () => {
    const wrapper = mountModal({ open: true }, { footer: '<div data-footer>Footer content</div>' });
    expect(document.body.querySelector('[data-footer]')).not.toBeNull();
    wrapper.unmount();
  });

  it('does not render footer when slot is not provided', () => {
    const wrapper = mountModal({ open: true });
    // No footer element — the wrapper div with .app-modal__footer should be absent.
    expect(document.body.querySelector('.app-modal__footer')).toBeNull();
    wrapper.unmount();
  });

  // ── Size modifier classes ─────────────────────────────────────────────────

  it('applies --sm modifier class when size=sm', () => {
    const wrapper = mountModal({ open: true, size: 'sm' });
    const panel = document.body.querySelector('.app-modal__panel');
    expect(panel?.classList).toContain('app-modal__panel--sm');
    wrapper.unmount();
  });

  it('applies --lg modifier class when size=lg', () => {
    const wrapper = mountModal({ open: true, size: 'lg' });
    const panel = document.body.querySelector('.app-modal__panel');
    expect(panel?.classList).toContain('app-modal__panel--lg');
    wrapper.unmount();
  });

  // ── Trigger slot ──────────────────────────────────────────────────────────

  it('emits update:open=true when trigger slot is clicked (currently closed)', async () => {
    const wrapper = mount(AppModal, {
      props: { open: false },
      slots: {
        trigger: '<button data-trigger type="button">Open modal</button>',
        default: '<p>Content</p>',
      },
      attachTo: document.body,
    });

    await wrapper.find('[data-trigger]').trigger('click');
    const emitted = wrapper.emitted('update:open') as boolean[][];
    expect(emitted).toBeDefined();
    expect(emitted[0]).toEqual([true]);
    wrapper.unmount();
  });

  // ── Default content rendered ──────────────────────────────────────────────

  it('renders default slot content inside the panel body', () => {
    const wrapper = mountModal({ open: true });
    expect(document.body.querySelector('[data-content]')).not.toBeNull();
    wrapper.unmount();
  });

  // ── role="dialog" ─────────────────────────────────────────────────────────

  it('sets role="dialog" on the backdrop element', () => {
    const wrapper = mountModal({ open: true });
    const backdrop = document.body.querySelector('.app-modal__backdrop');
    expect(backdrop?.getAttribute('role')).toBe('dialog');
    wrapper.unmount();
  });
});
