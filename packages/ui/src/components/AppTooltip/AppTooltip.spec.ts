import { mount } from '@vue/test-utils';
import { describe, expect, it, vi } from 'vitest';

import AppTooltip from './AppTooltip.vue';

// Helper: mount with a focusable trigger child.
function mountWithTrigger(props: Record<string, unknown> = {}) {
  return mount(AppTooltip, {
    props: { content: 'Tip text', ...props },
    slots: {
      default: `<button type="button">Trigger</button>`,
    },
    attachTo: document.body,
  });
}

describe('AppTooltip', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a <span> root element', () => {
    const wrapper = mountWithTrigger();
    expect(wrapper.element.tagName).toBe('SPAN');
    wrapper.unmount();
  });

  it('applies the app-tooltip base class', () => {
    const wrapper = mountWithTrigger();
    expect(wrapper.classes()).toContain('app-tooltip');
    wrapper.unmount();
  });

  it('applies the placement modifier class (default top)', () => {
    const wrapper = mountWithTrigger();
    expect(wrapper.classes()).toContain('app-tooltip--top');
    wrapper.unmount();
  });

  it('applies the correct placement modifier for each placement', async () => {
    for (const placement of ['top', 'right', 'bottom', 'left'] as const) {
      const wrapper = mountWithTrigger({ placement });
      expect(wrapper.classes()).toContain(`app-tooltip--${placement}`);
      wrapper.unmount();
    }
  });

  // ── Panel element ─────────────────────────────────────────────────────────

  it('renders a panel with role="tooltip"', () => {
    const wrapper = mountWithTrigger();
    const panel = wrapper.find('.app-tooltip__panel');
    expect(panel.exists()).toBe(true);
    expect(panel.attributes('role')).toBe('tooltip');
    wrapper.unmount();
  });

  it('panel has aria-hidden="true" when not visible', () => {
    const wrapper = mountWithTrigger();
    const panel = wrapper.find('.app-tooltip__panel');
    expect(panel.attributes('aria-hidden')).toBe('true');
    wrapper.unmount();
  });

  it('panel text content matches the content prop', () => {
    const wrapper = mountWithTrigger({ content: 'My tooltip' });
    const panel = wrapper.find('.app-tooltip__panel');
    expect(panel.text()).toBe('My tooltip');
    wrapper.unmount();
  });

  // ── Hover: show after delay ────────────────────────────────────────────────

  it('shows the panel after the delay on mouseenter', async () => {
    vi.useFakeTimers();
    const wrapper = mountWithTrigger({ delay: 300 });

    await wrapper.trigger('mouseenter');
    // Not yet visible — delay has not elapsed.
    expect(wrapper.classes()).not.toContain('app-tooltip--visible');

    vi.advanceTimersByTime(300);
    await wrapper.vm.$nextTick();

    expect(wrapper.classes()).toContain('app-tooltip--visible');
    expect(wrapper.find('.app-tooltip__panel').attributes('aria-hidden')).toBe('false');
    wrapper.unmount();
    vi.useRealTimers();
  });

  it('does not show before the delay elapses', async () => {
    vi.useFakeTimers();
    const wrapper = mountWithTrigger({ delay: 300 });

    await wrapper.trigger('mouseenter');
    vi.advanceTimersByTime(150);
    await wrapper.vm.$nextTick();

    expect(wrapper.classes()).not.toContain('app-tooltip--visible');
    wrapper.unmount();
    vi.useRealTimers();
  });

  // ── Hover: hide on mouseleave ─────────────────────────────────────────────

  it('hides the panel on mouseleave', async () => {
    vi.useFakeTimers();
    const wrapper = mountWithTrigger({ delay: 0 });

    await wrapper.trigger('mouseenter');
    vi.advanceTimersByTime(0);
    await wrapper.vm.$nextTick();

    expect(wrapper.classes()).toContain('app-tooltip--visible');

    await wrapper.trigger('mouseleave');
    await wrapper.vm.$nextTick();

    expect(wrapper.classes()).not.toContain('app-tooltip--visible');
    wrapper.unmount();
    vi.useRealTimers();
  });

  it('cancels the show timer if mouseleave happens before delay', async () => {
    vi.useFakeTimers();
    const wrapper = mountWithTrigger({ delay: 300 });

    await wrapper.trigger('mouseenter');
    vi.advanceTimersByTime(150);
    await wrapper.trigger('mouseleave');
    vi.advanceTimersByTime(200);
    await wrapper.vm.$nextTick();

    expect(wrapper.classes()).not.toContain('app-tooltip--visible');
    wrapper.unmount();
    vi.useRealTimers();
  });

  // ── Focus: show immediately ───────────────────────────────────────────────

  it('shows the panel immediately on focusin (no delay)', async () => {
    const wrapper = mountWithTrigger({ delay: 1000 });

    await wrapper.trigger('focusin');
    await wrapper.vm.$nextTick();

    expect(wrapper.classes()).toContain('app-tooltip--visible');
    wrapper.unmount();
  });

  // ── Focus: hide on blur ───────────────────────────────────────────────────

  it('hides the panel on focusout', async () => {
    const wrapper = mountWithTrigger();

    await wrapper.trigger('focusin');
    await wrapper.vm.$nextTick();
    expect(wrapper.classes()).toContain('app-tooltip--visible');

    await wrapper.trigger('focusout');
    await wrapper.vm.$nextTick();
    expect(wrapper.classes()).not.toContain('app-tooltip--visible');
    wrapper.unmount();
  });

  // ── ESC dismiss ──────────────────────────────────────────────────────────

  it('hides the panel on Escape keydown', async () => {
    const wrapper = mountWithTrigger();

    await wrapper.trigger('focusin');
    await wrapper.vm.$nextTick();
    expect(wrapper.classes()).toContain('app-tooltip--visible');

    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
    await wrapper.vm.$nextTick();

    expect(wrapper.classes()).not.toContain('app-tooltip--visible');
    wrapper.unmount();
  });

  it('does not hide on non-Escape keys', async () => {
    const wrapper = mountWithTrigger();

    await wrapper.trigger('focusin');
    await wrapper.vm.$nextTick();
    expect(wrapper.classes()).toContain('app-tooltip--visible');

    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter', bubbles: true }));
    await wrapper.vm.$nextTick();

    expect(wrapper.classes()).toContain('app-tooltip--visible');
    wrapper.unmount();
  });

  // ── Disabled ─────────────────────────────────────────────────────────────

  it('does not show on hover when disabled', async () => {
    vi.useFakeTimers();
    const wrapper = mountWithTrigger({ disabled: true, delay: 0 });

    await wrapper.trigger('mouseenter');
    vi.advanceTimersByTime(0);
    await wrapper.vm.$nextTick();

    expect(wrapper.classes()).not.toContain('app-tooltip--visible');
    wrapper.unmount();
    vi.useRealTimers();
  });

  it('does not show on focus when disabled', async () => {
    const wrapper = mountWithTrigger({ disabled: true });

    await wrapper.trigger('focusin');
    await wrapper.vm.$nextTick();

    expect(wrapper.classes()).not.toContain('app-tooltip--visible');
    wrapper.unmount();
  });

  it('applies app-tooltip--disabled class when disabled', () => {
    const wrapper = mountWithTrigger({ disabled: true });
    expect(wrapper.classes()).toContain('app-tooltip--disabled');
    wrapper.unmount();
  });

  // ── aria-describedby via scoped slot ──────────────────────────────────────

  it('exposes the panel id via the scoped slot so the trigger can bind aria-describedby', () => {
    // Mount via a component wrapper that consumes the scoped slot.
    const Wrapper = {
      components: { AppTooltip },
      template: `
        <AppTooltip content="Tip">
          <template #default="{ ariaDescribedby }">
            <button :aria-describedby="ariaDescribedby">T</button>
          </template>
        </AppTooltip>
      `,
    };
    const wrapper = mount(Wrapper, { attachTo: document.body });
    const panelId = wrapper.find('.app-tooltip__panel').attributes('id');
    const triggerDescribedBy = wrapper.find('button').attributes('aria-describedby');
    expect(panelId).toBeTruthy();
    expect(triggerDescribedBy).toBe(panelId);
    wrapper.unmount();
  });
});
