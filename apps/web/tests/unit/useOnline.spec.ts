/**
 * useOnline.spec.ts
 *
 * Reactive `navigator.onLine` mirror. Locks three things:
 *   1. Default value is true (not false) — protects against an offline
 *      banner flash during hydration.
 *   2. `online`/`offline` window events flip the ref.
 *   3. The composable cleans up its listeners on unmount.
 */

import { mount } from '@vue/test-utils';
import { defineComponent, h } from 'vue';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { useOnline } from '../../app/composables/useOnline';

function mountWithComposable() {
  let captured: ReturnType<typeof useOnline> | undefined;
  const Comp = defineComponent({
    setup() {
      captured = useOnline();
      return () => h('div');
    },
  });
  const wrapper = mount(Comp);
  if (!captured) throw new Error('useOnline did not run');
  return { wrapper, online: captured.online };
}

describe('useOnline', () => {
  let onlineSpy: ReturnType<typeof vi.spyOn> | undefined;

  beforeEach(() => {
    onlineSpy = vi.spyOn(navigator, 'onLine', 'get').mockReturnValue(true);
  });

  afterEach(() => {
    onlineSpy?.mockRestore();
    onlineSpy = undefined;
  });

  it('starts true when navigator.onLine is true', () => {
    const { wrapper, online } = mountWithComposable();
    expect(online.value).toBe(true);
    wrapper.unmount();
  });

  it('reflects navigator.onLine on mount when initially false', () => {
    onlineSpy?.mockReturnValue(false);
    const { wrapper, online } = mountWithComposable();
    expect(online.value).toBe(false);
    wrapper.unmount();
  });

  it('flips to false on a window "offline" event', async () => {
    const { wrapper, online } = mountWithComposable();
    expect(online.value).toBe(true);

    window.dispatchEvent(new Event('offline'));
    await wrapper.vm.$nextTick();
    expect(online.value).toBe(false);

    wrapper.unmount();
  });

  it('flips back to true on a window "online" event', async () => {
    onlineSpy?.mockReturnValue(false);
    const { wrapper, online } = mountWithComposable();
    expect(online.value).toBe(false);

    window.dispatchEvent(new Event('online'));
    await wrapper.vm.$nextTick();
    expect(online.value).toBe(true);

    wrapper.unmount();
  });

  it('removes its event listeners on unmount', () => {
    const removeSpy = vi.spyOn(window, 'removeEventListener');
    const { wrapper } = mountWithComposable();
    wrapper.unmount();

    const offlineRemoved = removeSpy.mock.calls.some(([type]) => type === 'offline');
    const onlineRemoved = removeSpy.mock.calls.some(([type]) => type === 'online');
    expect(offlineRemoved).toBe(true);
    expect(onlineRemoved).toBe(true);

    removeSpy.mockRestore();
  });
});
