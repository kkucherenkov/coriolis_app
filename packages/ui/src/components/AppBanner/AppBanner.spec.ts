import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppBanner from './AppBanner.vue';

const TONES = ['info', 'success', 'warning', 'danger', 'parchment'] as const;

// Default icon expected per tone per DEFAULT_ICONS map in AppBanner.vue
const TONE_DEFAULT_ICONS: Record<(typeof TONES)[number], string> = {
  info: 'info',
  success: 'check-circle',
  warning: 'triangle-alert',
  danger: 'octagon-alert',
  parchment: 'eye',
};

describe('AppBanner', () => {
  // ── Root element ──────────────────────────────────────────────────────────

  it('renders a <div> root element', () => {
    const wrapper = mount(AppBanner);
    expect(wrapper.element.tagName).toBe('DIV');
  });

  it('applies the app-banner base class', () => {
    const wrapper = mount(AppBanner);
    expect(wrapper.classes()).toContain('app-banner');
  });

  // ── BEM tone modifiers ────────────────────────────────────────────────────

  it.each(TONES)('applies app-banner--%s modifier for tone=%s', (tone) => {
    const wrapper = mount(AppBanner, { props: { tone } });
    expect(wrapper.classes()).toContain(`app-banner--${tone}`);
  });

  it('defaults to tone=info', () => {
    const wrapper = mount(AppBanner);
    expect(wrapper.classes()).toContain('app-banner--info');
  });

  it('applies exactly one tone class', () => {
    const wrapper = mount(AppBanner, { props: { tone: 'danger' } });
    const toneClasses = wrapper
      .classes()
      .filter((c) => TONES.some((t) => c === `app-banner--${t}`));
    expect(toneClasses).toHaveLength(1);
    expect(toneClasses[0]).toBe('app-banner--danger');
  });

  // ── Role attribute ────────────────────────────────────────────────────────

  it('sets role="alert" for tone=danger', () => {
    const wrapper = mount(AppBanner, { props: { tone: 'danger' } });
    expect(wrapper.attributes('role')).toBe('alert');
  });

  it.each(['info', 'success', 'warning', 'parchment'] as const)(
    'sets role="status" for tone=%s',
    (tone) => {
      const wrapper = mount(AppBanner, { props: { tone } });
      expect(wrapper.attributes('role')).toBe('status');
    },
  );

  // ── Title ─────────────────────────────────────────────────────────────────

  it('renders the title when provided', () => {
    const wrapper = mount(AppBanner, { props: { title: 'Read-only view' } });
    const title = wrapper.find('.app-banner__title');
    expect(title.exists()).toBe(true);
    expect(title.text()).toBe('Read-only view');
  });

  it('does not render .app-banner__title when title is absent', () => {
    const wrapper = mount(AppBanner);
    expect(wrapper.find('.app-banner__title').exists()).toBe(false);
  });

  // ── Default slot ──────────────────────────────────────────────────────────

  it('renders default slot content in .app-banner__content', () => {
    const wrapper = mount(AppBanner, {
      slots: { default: '<p>Sign in to create your own character sheet.</p>' },
    });
    expect(wrapper.find('.app-banner__content').exists()).toBe(true);
    expect(wrapper.find('.app-banner__content').text()).toContain(
      'Sign in to create your own character sheet.',
    );
  });

  it('does not render .app-banner__content when default slot is absent', () => {
    const wrapper = mount(AppBanner, { props: { title: 'Title only' } });
    expect(wrapper.find('.app-banner__content').exists()).toBe(false);
  });

  // ── Actions slot ──────────────────────────────────────────────────────────

  it('renders .app-banner__actions when actions slot is provided', () => {
    const wrapper = mount(AppBanner, {
      slots: { actions: '<button>Learn more</button>' },
    });
    expect(wrapper.find('.app-banner__actions').exists()).toBe(true);
    expect(wrapper.find('.app-banner__actions').text()).toContain('Learn more');
  });

  it('does not render .app-banner__actions when actions slot is absent', () => {
    const wrapper = mount(AppBanner);
    expect(wrapper.find('.app-banner__actions').exists()).toBe(false);
  });

  // ── Dismiss button ────────────────────────────────────────────────────────

  it('renders .app-banner__dismiss when dismissible=true', () => {
    const wrapper = mount(AppBanner, { props: { dismissible: true } });
    expect(wrapper.find('.app-banner__dismiss').exists()).toBe(true);
  });

  it('does not render .app-banner__dismiss when dismissible is false (default)', () => {
    const wrapper = mount(AppBanner);
    expect(wrapper.find('.app-banner__dismiss').exists()).toBe(false);
  });

  it('applies app-banner--dismissible modifier when dismissible=true', () => {
    const wrapper = mount(AppBanner, { props: { dismissible: true } });
    expect(wrapper.classes()).toContain('app-banner--dismissible');
  });

  it('emits "dismiss" when the × button is clicked', async () => {
    const wrapper = mount(AppBanner, { props: { dismissible: true } });
    await wrapper.find('.app-banner__dismiss').trigger('click');
    expect(wrapper.emitted('dismiss')).toHaveLength(1);
  });

  it('does not emit "dismiss" when not dismissible and no button exists', () => {
    const wrapper = mount(AppBanner);
    expect(wrapper.find('.app-banner__dismiss').exists()).toBe(false);
    expect(wrapper.emitted('dismiss')).toBeUndefined();
  });

  it('defaults the dismiss button aria-label to "Dismiss"', () => {
    const wrapper = mount(AppBanner, { props: { dismissible: true } });
    expect(wrapper.find('.app-banner__dismiss').attributes('aria-label')).toBe('Dismiss');
  });

  it('uses the dismissLabel prop for the dismiss button aria-label', () => {
    const wrapper = mount(AppBanner, { props: { dismissible: true, dismissLabel: 'Закрыть' } });
    expect(wrapper.find('.app-banner__dismiss').attributes('aria-label')).toBe('Закрыть');
  });

  // ── Default icon per tone ─────────────────────────────────────────────────

  it.each(TONES)('uses default icon "%s" for tone=%s when no icon prop given', (tone) => {
    const wrapper = mount(AppBanner, { props: { tone } });
    const iconEl = wrapper.find('.app-banner__icon');
    expect(iconEl.exists()).toBe(true);
    // The AppIcon component receives the name as a prop; verify it rendered inside the icon wrapper.
    // We confirm the span is present — icon name forwarding is tested via AppIcon's own spec.
    expect(iconEl.find('[class*="app-icon"]').exists()).toBe(true);
    // Verify correct icon name is forwarded by checking the AppIcon component prop
    const iconComponent = wrapper.findComponent({ name: 'AppIcon' });
    expect(iconComponent.props('name')).toBe(TONE_DEFAULT_ICONS[tone]);
  });

  it('uses the custom icon prop when provided, overriding tone default', () => {
    const wrapper = mount(AppBanner, { props: { tone: 'info', icon: 'share-2' } });
    const iconComponent = wrapper.findComponent({ name: 'AppIcon' });
    // The first AppIcon is the leading icon
    expect(iconComponent.props('name')).toBe('share-2');
  });

  // ── Icon wrapper always present ───────────────────────────────────────────

  it('always renders .app-banner__icon element', () => {
    const wrapper = mount(AppBanner);
    expect(wrapper.find('.app-banner__icon').exists()).toBe(true);
  });
});
