import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppWhisperPicker from './AppWhisperPicker.vue';
import type { WhisperPickerMember } from './types';

function member(n: number, extra: Partial<WhisperPickerMember> = {}): WhisperPickerMember {
  return {
    membershipId: `m-${n}`,
    displayName: `Member ${n}`,
    presence: 'online',
    blockedByMe: false,
    ...extra,
  };
}

const THREE_MEMBERS = [member(1), member(2), member(3)];

describe('AppWhisperPicker', () => {
  // ── Spec 1: open=false renders nothing ────────────────────────────────────

  it('renders nothing when open=false', () => {
    const wrapper = mount(AppWhisperPicker, {
      props: { open: false, members: THREE_MEMBERS },
      attachTo: document.body,
    });
    expect(document.body.querySelector('.app-whisper-picker')).toBeNull();
    wrapper.unmount();
  });

  // ── Spec 2: open=true + 0 unblocked → empty state ────────────────────────

  it('shows empty-state copy when open and no unblocked members', () => {
    const wrapper = mount(AppWhisperPicker, {
      props: {
        open: true,
        members: [member(1, { blockedByMe: true }), member(2, { blockedByMe: true })],
      },
      attachTo: document.body,
    });
    const picker = document.body.querySelector('.app-whisper-picker');
    expect(picker).not.toBeNull();
    expect(picker!.querySelector('.app-whisper-picker__empty')?.textContent).toContain(
      'No one available.',
    );
    wrapper.unmount();
  });

  // ── Spec 3: blocked members do not appear in the DOM ──────────────────────

  it('members with blockedByMe=true do not render in the list', () => {
    const wrapper = mount(AppWhisperPicker, {
      props: {
        open: true,
        members: [member(1), member(2, { blockedByMe: true }), member(3)],
      },
      attachTo: document.body,
    });
    const items = document.body.querySelectorAll('.app-whisper-picker__item');
    expect(items).toHaveLength(2);
    const texts = [...items].map((el) => el.textContent ?? '');
    expect(texts.some((t) => t.includes('Member 2'))).toBe(false);
    wrapper.unmount();
  });

  // ── Spec 4: ArrowDown advances focusedIndex ───────────────────────────────

  it('ArrowDown advances focusedIndex and reflects aria-selected', async () => {
    const wrapper = mount(AppWhisperPicker, {
      props: { open: true, members: THREE_MEMBERS },
      attachTo: document.body,
    });
    const list = document.body.querySelector<HTMLElement>('.app-whisper-picker__list');
    expect(list).not.toBeNull();
    list!.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true }));
    await wrapper.vm.$nextTick();
    const items = document.body.querySelectorAll('.app-whisper-picker__item');
    expect(items[1]?.getAttribute('aria-selected')).toBe('true');
    expect(items[0]?.getAttribute('aria-selected')).toBe('false');
    wrapper.unmount();
  });

  // ── Spec 5: ArrowUp wraps when at index 0 ────────────────────────────────

  it('ArrowUp wraps from index 0 to the last item', async () => {
    const wrapper = mount(AppWhisperPicker, {
      props: { open: true, members: THREE_MEMBERS },
      attachTo: document.body,
    });
    const list = document.body.querySelector<HTMLElement>('.app-whisper-picker__list');
    list!.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowUp', bubbles: true }));
    await wrapper.vm.$nextTick();
    const items = document.body.querySelectorAll('.app-whisper-picker__item');
    // Should wrap to last (index 2)
    expect(items[2]?.getAttribute('aria-selected')).toBe('true');
    wrapper.unmount();
  });

  // ── Spec 6: Enter emits pick with focused membershipId ───────────────────

  it('Enter emits pick with the focused member membershipId', async () => {
    const wrapper = mount(AppWhisperPicker, {
      props: { open: true, members: THREE_MEMBERS },
      attachTo: document.body,
    });
    // Default focusedIndex=0 → member m-1
    const list = document.body.querySelector<HTMLElement>('.app-whisper-picker__list');
    list!.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter', bubbles: true }));
    await wrapper.vm.$nextTick();
    expect(wrapper.emitted('pick')?.[0]).toEqual(['m-1']);
    wrapper.unmount();
  });

  // ── Spec 7: Escape emits close ────────────────────────────────────────────

  it('Escape emits close', async () => {
    const wrapper = mount(AppWhisperPicker, {
      props: { open: true, members: THREE_MEMBERS },
      attachTo: document.body,
    });
    const list = document.body.querySelector<HTMLElement>('.app-whisper-picker__list');
    list!.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
    await wrapper.vm.$nextTick();
    expect(wrapper.emitted('close')).toBeDefined();
    wrapper.unmount();
  });

  // ── Spec 8: clicking a row emits pick ─────────────────────────────────────

  it('clicking a row emits pick with the correct membershipId', async () => {
    const wrapper = mount(AppWhisperPicker, {
      props: { open: true, members: THREE_MEMBERS },
      attachTo: document.body,
    });
    const items = document.body.querySelectorAll<HTMLElement>('.app-whisper-picker__item');
    items[1]!.click();
    await wrapper.vm.$nextTick();
    expect(wrapper.emitted('pick')?.[0]).toEqual(['m-2']);
    wrapper.unmount();
  });

  // ── Spec 9: aria-selected flips on focusedIndex change ───────────────────

  it('aria-selected reflects the current focusedIndex after ArrowDown', async () => {
    const wrapper = mount(AppWhisperPicker, {
      props: { open: true, members: THREE_MEMBERS },
      attachTo: document.body,
    });
    const list = document.body.querySelector<HTMLElement>('.app-whisper-picker__list');

    // Move down twice
    list!.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true }));
    await wrapper.vm.$nextTick();
    list!.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true }));
    await wrapper.vm.$nextTick();

    const items = document.body.querySelectorAll('.app-whisper-picker__item');
    expect(items[0]?.getAttribute('aria-selected')).toBe('false');
    expect(items[1]?.getAttribute('aria-selected')).toBe('false');
    expect(items[2]?.getAttribute('aria-selected')).toBe('true');
    wrapper.unmount();
  });
});
