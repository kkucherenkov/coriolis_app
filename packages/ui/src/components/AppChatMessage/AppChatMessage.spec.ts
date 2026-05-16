import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppChatMessage from './AppChatMessage.vue';

// Minimal required props shared across tests.
const BASE = {
  variant: 'broadcast-other' as const,
  createdAtIso: '2026-05-16T14:30:00.000Z',
  ownByMe: false,
  ownByGm: false,
  canEdit: false,
  canDelete: false,
  canBlock: false,
};

const BASE_AUTHOR = {
  ...BASE,
  variant: 'broadcast-author' as const,
  ownByMe: true,
};

describe('AppChatMessage', () => {
  // ── 1. Variant → BEM modifier (4 specs) ──────────────────────────────────

  it.each([
    ['broadcast-author', 'app-chat-message--variant-broadcast-author'],
    ['broadcast-other', 'app-chat-message--variant-broadcast-other'],
    ['whisper', 'app-chat-message--variant-whisper'],
  ] as const)('variant=%s routes to BEM modifier %s', (variant, expectedClass) => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, variant, ownByMe: variant === 'broadcast-author' },
    });
    expect(wrapper.classes()).toContain(expectedClass);
  });

  it('variant=system routes to BEM modifier app-chat-message--variant-system', () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, variant: 'system', systemLabel: 'Player joined' },
    });
    // system article has both root + variant class applied directly in template
    expect(wrapper.classes()).toContain('app-chat-message--variant-system');
  });

  // ── 2. system variant skips .app-chat-message__bubble ────────────────────

  it('variant=system does not render a .app-chat-message__bubble element', () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, variant: 'system', systemLabel: 'Session started' },
    });
    expect(wrapper.find('.app-chat-message__bubble').exists()).toBe(false);
  });

  // ── 3. system variant renders systemLabel and ignores body ────────────────

  it('variant=system renders systemLabel text', () => {
    const wrapper = mount(AppChatMessage, {
      props: {
        ...BASE,
        variant: 'system',
        systemLabel: 'Aelyn joined the session',
        body: 'ignored',
      },
    });
    expect(wrapper.find('.app-chat-message__system').text()).toBe('Aelyn joined the session');
  });

  it('variant=system does not render body text', () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, variant: 'system', systemLabel: 'Aelyn joined', body: 'should-not-appear' },
    });
    expect(wrapper.html()).not.toContain('should-not-appear');
  });

  // ── 4. ownByMe + broadcast-author → right-aligned ────────────────────────

  it('ownByMe=true with broadcast-author applies --alignment-right', () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE_AUTHOR },
    });
    expect(wrapper.classes()).toContain('app-chat-message--alignment-right');
  });

  it('broadcast-other applies --alignment-left', () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, variant: 'broadcast-other' },
    });
    expect(wrapper.classes()).toContain('app-chat-message--alignment-left');
  });

  // ── 5. editedAtIso truthy → edited mark renders ───────────────────────────

  it('renders the edited mark when editedAtIso is provided', () => {
    const wrapper = mount(AppChatMessage, {
      props: {
        ...BASE,
        body: 'Hello',
        editedAtIso: '2026-05-16T15:00:00.000Z',
      },
    });
    expect(wrapper.find('.app-chat-message__edited').exists()).toBe(true);
  });

  it('does not render the edited mark when editedAtIso is absent', () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, body: 'Hello' },
    });
    expect(wrapper.find('.app-chat-message__edited').exists()).toBe(false);
  });

  // ── 6. deletedAtIso truthy → body replaced, kebab hidden ─────────────────

  it('renders the deleted placeholder when deletedAtIso is set', () => {
    const wrapper = mount(AppChatMessage, {
      props: {
        ...BASE,
        body: 'original text',
        deletedAtIso: '2026-05-16T16:00:00.000Z',
        canDelete: true,
      },
    });
    expect(wrapper.find('.app-chat-message__deleted').exists()).toBe(true);
    expect(wrapper.find('.app-chat-message__deleted').text()).toBe('Message deleted');
  });

  it('hides the kebab button when deletedAtIso is set', () => {
    const wrapper = mount(AppChatMessage, {
      props: {
        ...BASE,
        ownByMe: true,
        canEdit: true,
        canDelete: true,
        deletedAtIso: '2026-05-16T16:00:00.000Z',
      },
    });
    expect(wrapper.find('.app-chat-message__kebab-btn').exists()).toBe(false);
  });

  // ── 7. Kebab menu item visibility (6 sub-cases via it.each) ──────────────

  it.each([
    // [label, props override, menuTestId, expectedExists]
    ['Edit shown when canEdit+ownByMe', { canEdit: true, ownByMe: true }, 'menu-edit', true],
    ['Edit hidden when !canEdit', { canEdit: false, ownByMe: true }, 'menu-edit', false],
    ['Edit hidden when !ownByMe', { canEdit: true, ownByMe: false }, 'menu-edit', false],
    [
      'Delete shown when canDelete+ownByMe',
      { canDelete: true, ownByMe: true },
      'menu-delete',
      true,
    ],
    [
      'Delete shown when canDelete+ownByGm',
      { canDelete: true, ownByMe: false, ownByGm: true },
      'menu-delete',
      true,
    ],
    ['Delete hidden when !canDelete', { canDelete: false, ownByMe: true }, 'menu-delete', false],
    ['Block shown when canBlock+!ownByMe', { canBlock: true, ownByMe: false }, 'menu-block', true],
    ['Block hidden when ownByMe', { canBlock: true, ownByMe: true }, 'menu-block', false],
    ['Block hidden when !canBlock', { canBlock: false, ownByMe: false }, 'menu-block', false],
  ] as const)('%s', async (_label, propsOverride, testId, expectedExists) => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, body: 'hi', ...propsOverride },
    });
    // Open the popover so menu items are mounted
    const kebabBtn = wrapper.find('.app-chat-message__kebab-btn');
    if (!kebabBtn.exists()) {
      // Kebab not rendered means all menu items also absent — check false
      expect(expectedExists).toBe(false);
      return;
    }
    await kebabBtn.trigger('click');
    expect(wrapper.find(`[data-testid="${testId}"]`).exists()).toBe(expectedExists);
  });

  // ── 8. Emits from menu items ──────────────────────────────────────────────

  it('emits "edit" when Edit menu item is clicked', async () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, body: 'hi', canEdit: true, ownByMe: true },
    });
    await wrapper.find('.app-chat-message__kebab-btn').trigger('click');
    await wrapper.find('[data-testid="menu-edit"]').trigger('click');
    expect(wrapper.emitted('edit')).toHaveLength(1);
  });

  it('emits "delete" when Delete menu item is clicked', async () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, body: 'hi', canDelete: true, ownByMe: true },
    });
    await wrapper.find('.app-chat-message__kebab-btn').trigger('click');
    await wrapper.find('[data-testid="menu-delete"]').trigger('click');
    expect(wrapper.emitted('delete')).toHaveLength(1);
  });

  it('emits "block" when Block menu item is clicked', async () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, body: 'hi', canBlock: true, ownByMe: false },
    });
    await wrapper.find('.app-chat-message__kebab-btn').trigger('click');
    await wrapper.find('[data-testid="menu-block"]').trigger('click');
    expect(wrapper.emitted('block')).toHaveLength(1);
  });

  // ── 9. Accessible name ────────────────────────────────────────────────────

  it('accessible name for non-system includes authorDisplayName and time', () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, authorDisplayName: 'Aelyn Skarn', body: 'hello' },
    });
    const label = wrapper.attributes('aria-label') ?? '';
    expect(label).toContain('Aelyn Skarn');
    expect(label).toContain('at');
  });

  it('accessible name for system variant equals systemLabel', () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, variant: 'system', systemLabel: 'Dice roll: 6' },
    });
    expect(wrapper.attributes('aria-label')).toBe('Dice roll: 6');
  });

  // ── 10. Lock icon on whisper variant ─────────────────────────────────────

  it('renders lock SVG on whisper variant', () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, variant: 'whisper', body: 'psst', ownByMe: false },
    });
    expect(wrapper.find('.app-chat-message__lock').exists()).toBe(true);
  });

  it('lock SVG has aria-hidden="true"', () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, variant: 'whisper', body: 'psst', ownByMe: false },
    });
    expect(wrapper.find('.app-chat-message__lock').attributes('aria-hidden')).toBe('true');
  });

  it('does not render lock SVG on broadcast-other variant', () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, variant: 'broadcast-other', body: 'hello' },
    });
    expect(wrapper.find('.app-chat-message__lock').exists()).toBe(false);
  });

  // ── Timestamp ─────────────────────────────────────────────────────────────

  it('renders a <time> element with datetime equal to createdAtIso', () => {
    const wrapper = mount(AppChatMessage, {
      props: { ...BASE, body: 'hello', createdAtIso: '2026-05-16T14:30:00.000Z' },
    });
    const timeEl = wrapper.find('time');
    expect(timeEl.exists()).toBe(true);
    expect(timeEl.attributes('datetime')).toBe('2026-05-16T14:30:00.000Z');
  });
});
