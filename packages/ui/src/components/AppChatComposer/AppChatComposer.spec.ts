import { mount } from '@vue/test-utils';
import { describe, expect, it } from 'vitest';

import AppChatComposer from './AppChatComposer.vue';

const BASE = {
  modelValue: '',
  conversationKind: 'broadcast' as const,
};

describe('AppChatComposer', () => {
  // ── 1. ⌘+Enter emits submit ───────────────────────────────────────────────

  it('⌘+Enter emits submit when value is non-empty', async () => {
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, modelValue: 'hello' },
    });
    const textarea = wrapper.find('textarea');
    await textarea.trigger('keydown', { key: 'Enter', metaKey: true });
    expect(wrapper.emitted('submit')).toHaveLength(1);
  });

  // ── 2. Ctrl+Enter emits submit ────────────────────────────────────────────

  it('Ctrl+Enter emits submit when value is non-empty', async () => {
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, modelValue: 'hello' },
    });
    const textarea = wrapper.find('textarea');
    await textarea.trigger('keydown', { key: 'Enter', ctrlKey: true });
    expect(wrapper.emitted('submit')).toHaveLength(1);
  });

  // ── 3. Plain Enter does NOT emit submit ───────────────────────────────────

  it('plain Enter does NOT emit submit', async () => {
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, modelValue: 'hello' },
    });
    const textarea = wrapper.find('textarea');
    await textarea.trigger('keydown', { key: 'Enter' });
    expect(wrapper.emitted('submit')).toBeUndefined();
  });

  // ── 4. Shift+Enter does NOT emit submit ───────────────────────────────────

  it('Shift+Enter does NOT emit submit', async () => {
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, modelValue: 'hello' },
    });
    const textarea = wrapper.find('textarea');
    await textarea.trigger('keydown', { key: 'Enter', shiftKey: true });
    expect(wrapper.emitted('submit')).toBeUndefined();
  });

  // ── 5. Counter aria-live is "polite" ─────────────────────────────────────

  it('counter has aria-live="polite"', () => {
    const wrapper = mount(AppChatComposer, { props: BASE });
    const counter = wrapper.find('[data-testid="counter"]');
    expect(counter.attributes('aria-live')).toBe('polite');
  });

  // ── 6. Counter class flips at maxLength-64 and maxLength ─────────────────

  it('counter has --warn class when length >= maxLength - 64', () => {
    const maxLength = 100;
    const value = 'a'.repeat(36); // 100 - 64 = 36
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, modelValue: value, maxLength },
    });
    const counter = wrapper.find('[data-testid="counter"]');
    expect(counter.classes()).toContain('app-chat-composer__counter--warn');
    expect(counter.classes()).not.toContain('app-chat-composer__counter--error');
  });

  it('counter has --error class when length >= maxLength', () => {
    const maxLength = 100;
    const value = 'a'.repeat(100);
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, modelValue: value, maxLength },
    });
    const counter = wrapper.find('[data-testid="counter"]');
    expect(counter.classes()).toContain('app-chat-composer__counter--error');
    expect(counter.classes()).not.toContain('app-chat-composer__counter--warn');
  });

  it('counter has no special class below maxLength - 64', () => {
    const maxLength = 100;
    const value = 'a'.repeat(35); // one short of warn threshold
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, modelValue: value, maxLength },
    });
    const counter = wrapper.find('[data-testid="counter"]');
    expect(counter.classes()).not.toContain('app-chat-composer__counter--warn');
    expect(counter.classes()).not.toContain('app-chat-composer__counter--error');
  });

  // ── 7. Submit disabled when value is whitespace-only ─────────────────────

  it('submit button is disabled when value is whitespace-only', () => {
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, modelValue: '   \n  ' },
    });
    const btn = wrapper.find('[data-testid="submit-btn"]');
    expect(btn.attributes('disabled')).toBeDefined();
  });

  // ── 8. Submit disabled when disabled prop is true ────────────────────────

  it('submit button is disabled when disabled prop is true', () => {
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, modelValue: 'hello', disabled: true },
    });
    const btn = wrapper.find('[data-testid="submit-btn"]');
    expect(btn.attributes('disabled')).toBeDefined();
  });

  // ── 9. Whitespace-only submit does NOT fire ───────────────────────────────

  it('⌘+Enter with whitespace-only value does NOT emit submit', async () => {
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, modelValue: '   ' },
    });
    await wrapper.find('textarea').trigger('keydown', { key: 'Enter', metaKey: true });
    expect(wrapper.emitted('submit')).toBeUndefined();
  });

  // ── 10. Placeholder routes through kind + partnerDisplayName ─────────────

  it('broadcast placeholder is "Message everyone in the session…"', () => {
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, conversationKind: 'broadcast' },
    });
    expect(wrapper.find('textarea').attributes('placeholder')).toBe(
      'Message everyone in the session…',
    );
  });

  it('whisper placeholder includes partnerDisplayName', () => {
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, conversationKind: 'whisper', partnerDisplayName: 'Junad Vex' },
    });
    expect(wrapper.find('textarea').attributes('placeholder')).toBe('Whisper to Junad Vex…');
  });

  it('whisper placeholder falls back to "…" when partnerDisplayName is absent', () => {
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, conversationKind: 'whisper' },
    });
    expect(wrapper.find('textarea').attributes('placeholder')).toBe('Whisper to ……');
  });

  // ── BEM root class ────────────────────────────────────────────────────────

  it('applies app-chat-composer root BEM class', () => {
    const wrapper = mount(AppChatComposer, { props: BASE });
    expect(wrapper.classes()).toContain('app-chat-composer');
  });

  it('applies --kind-broadcast modifier for conversationKind=broadcast', () => {
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, conversationKind: 'broadcast' },
    });
    expect(wrapper.classes()).toContain('app-chat-composer--kind-broadcast');
  });

  it('applies --kind-whisper modifier for conversationKind=whisper', () => {
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, conversationKind: 'whisper' },
    });
    expect(wrapper.classes()).toContain('app-chat-composer--kind-whisper');
  });

  it('applies --disabled modifier when disabled=true', () => {
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, disabled: true },
    });
    expect(wrapper.classes()).toContain('app-chat-composer--disabled');
  });

  // ── emit update:modelValue ────────────────────────────────────────────────

  it('emits update:modelValue on textarea input', async () => {
    const wrapper = mount(AppChatComposer, { props: BASE });
    const el = wrapper.find('textarea').element as HTMLTextAreaElement;
    el.value = 'typed text';
    await wrapper.find('textarea').trigger('input');
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['typed text']);
  });

  // ── Submit button click ───────────────────────────────────────────────────

  it('emits submit when submit button clicked with valid value', async () => {
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, modelValue: 'hello' },
    });
    await wrapper.find('[data-testid="submit-btn"]').trigger('click');
    expect(wrapper.emitted('submit')).toHaveLength(1);
  });

  // ── Over limit: submit disabled ───────────────────────────────────────────

  it('submit button is disabled when value exceeds maxLength', () => {
    const maxLength = 10;
    const wrapper = mount(AppChatComposer, {
      props: { ...BASE, modelValue: 'a'.repeat(11), maxLength },
    });
    expect(wrapper.find('[data-testid="submit-btn"]').attributes('disabled')).toBeDefined();
  });

  // ── Inline edit affordance ────────────────────────────────────────────────

  it('renders no edit banner by default', () => {
    const wrapper = mount(AppChatComposer, { props: BASE });
    expect(wrapper.find('[data-testid="edit-banner"]').exists()).toBe(false);
    expect(wrapper.classes()).not.toContain('app-chat-composer--editing');
    expect(wrapper.find('[data-testid="submit-btn"]').text()).toBe('Send');
  });

  it('renders the edit banner + Save label when editingLabel is set', () => {
    const wrapper = mount(AppChatComposer, {
      props: {
        ...BASE,
        modelValue: 'updated body',
        editingLabel: 'Editing message',
        editingPreview: 'original body',
      },
    });
    const banner = wrapper.find('[data-testid="edit-banner"]');
    expect(banner.exists()).toBe(true);
    expect(banner.text()).toContain('Editing message');
    expect(banner.text()).toContain('original body');
    expect(wrapper.classes()).toContain('app-chat-composer--editing');
    expect(wrapper.find('[data-testid="submit-btn"]').text()).toBe('Save');
  });

  it('emits "cancel-edit" when the banner Cancel button is clicked', async () => {
    const wrapper = mount(AppChatComposer, {
      props: {
        ...BASE,
        modelValue: 'updated body',
        editingLabel: 'Editing message',
      },
    });
    await wrapper.find('[data-testid="cancel-edit-btn"]').trigger('click');
    expect(wrapper.emitted('cancel-edit')).toHaveLength(1);
  });

  it('does not render the preview span when editingPreview is empty', () => {
    const wrapper = mount(AppChatComposer, {
      props: {
        ...BASE,
        editingLabel: 'Editing message',
      },
    });
    expect(wrapper.find('.app-chat-composer__edit-banner-preview').exists()).toBe(false);
  });

  it('still emits "submit" via ⌘+Enter while in edit mode (parent routes the verb)', async () => {
    const wrapper = mount(AppChatComposer, {
      props: {
        ...BASE,
        modelValue: 'updated body',
        editingLabel: 'Editing message',
      },
    });
    await wrapper.find('textarea').trigger('keydown', { key: 'Enter', metaKey: true });
    expect(wrapper.emitted('submit')).toHaveLength(1);
  });
});
