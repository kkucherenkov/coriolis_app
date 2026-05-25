<script setup lang="ts">
  import { computed } from 'vue';

  import AppButton from '../AppButton/AppButton.vue';

  /**
   * Chat composer — multi-line textarea with character counter and
   * ⌘/Ctrl+Enter submit shortcut. Two kinds: broadcast (to all) and
   * whisper (to one named partner).
   *
   * Plain Enter inserts a newline. ⌘+Enter / Ctrl+Enter submits if the
   * trimmed value is non-empty.
   *
   * Inline edit mode — when `editingLabel` is set the composer renders a
   * banner above the textarea with that label, the original body
   * preview, and a Cancel button. The Send button is recoloured to flag
   * the in-flight edit; submission semantics stay the same (parent
   * routes the submit to the edit / send branch based on its own
   * editing-state flag).
   */

  type Kind = 'broadcast' | 'whisper';

  interface Props {
    modelValue: string;
    conversationKind: Kind;
    partnerDisplayName?: string;
    maxLength?: number;
    disabled?: boolean;
    /**
     * Banner heading when the composer is in edit mode (e.g. "Editing message").
     * The presence of this prop toggles the banner on; passing an empty
     * string leaves it off so the prop is safe to bind unconditionally.
     */
    editingLabel?: string;
    /**
     * Optional one-line preview of the original message body shown next
     * to the editing label. Long bodies are CSS-truncated.
     */
    editingPreview?: string;
    /** Label for the Cancel button inside the edit banner. */
    cancelEditLabel?: string;
    /** Override the textarea placeholder. Defaults to a kind-aware English string. */
    placeholder?: string;
    /** Label for the send button. Localize per consumer locale. */
    sendLabel?: string;
    /** Label for the save button shown in edit mode. Localize per consumer locale. */
    saveLabel?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    partnerDisplayName: undefined,
    maxLength: 4096,
    disabled: false,
    editingLabel: '',
    editingPreview: '',
    cancelEditLabel: 'Cancel',
    placeholder: undefined,
    sendLabel: 'Send',
    saveLabel: 'Save',
  });

  const emit = defineEmits<{
    (e: 'update:modelValue', v: string): void;
    (e: 'submit' | 'cancel-edit'): void;
  }>();

  const isEditing = computed(() => Boolean(props.editingLabel));

  const rootClasses = computed(() => [
    'app-chat-composer',
    `app-chat-composer--kind-${props.conversationKind}`,
    { 'app-chat-composer--disabled': props.disabled },
    { 'app-chat-composer--editing': isEditing.value },
  ]);

  function onCancelEdit(): void {
    emit('cancel-edit');
  }

  const placeholder = computed(() => {
    if (props.placeholder) return props.placeholder;
    if (props.conversationKind === 'whisper') {
      return `Whisper to ${props.partnerDisplayName ?? '…'}…`;
    }
    return 'Message everyone in the session…';
  });

  const isOverLimit = computed(() => props.modelValue.length >= props.maxLength);
  const isNearLimit = computed(
    () => props.modelValue.length >= props.maxLength - 64 && !isOverLimit.value,
  );

  const counterClasses = computed(() => [
    'app-chat-composer__counter',
    { 'app-chat-composer__counter--warn': isNearLimit.value },
    { 'app-chat-composer__counter--error': isOverLimit.value },
  ]);

  const submitDisabled = computed(
    () => props.disabled || props.modelValue.trim().length === 0 || isOverLimit.value,
  );

  function onInput(event: Event): void {
    const target = event.target as HTMLTextAreaElement;
    emit('update:modelValue', target.value);
  }

  function onKeydown(event: KeyboardEvent): void {
    if (event.key !== 'Enter') return;
    if (event.metaKey || event.ctrlKey) {
      event.preventDefault();
      if (props.modelValue.trim().length > 0 && !isOverLimit.value && !props.disabled) {
        emit('submit');
      }
    }
    // Plain Enter and Shift+Enter: fall through — browser inserts newline naturally.
  }

  function onSubmitClick(): void {
    if (!submitDisabled.value) {
      emit('submit');
    }
  }
</script>

<template>
  <div :class="rootClasses" data-testid="app-chat-composer">
    <div
      v-if="isEditing"
      class="app-chat-composer__edit-banner"
      role="status"
      aria-live="polite"
      data-testid="edit-banner"
    >
      <div class="app-chat-composer__edit-banner-text">
        <span class="app-chat-composer__edit-banner-label">{{ editingLabel }}</span>
        <span
          v-if="editingPreview"
          class="app-chat-composer__edit-banner-preview"
          :title="editingPreview"
        >
          {{ editingPreview }}
        </span>
      </div>
      <AppButton variant="ghost" size="sm" data-testid="cancel-edit-btn" @click="onCancelEdit">
        {{ cancelEditLabel }}
      </AppButton>
    </div>

    <textarea
      class="app-chat-composer__textarea"
      :value="modelValue"
      :placeholder="placeholder"
      :disabled="disabled"
      :aria-disabled="disabled || undefined"
      rows="3"
      @input="onInput"
      @keydown="onKeydown"
    />

    <div class="app-chat-composer__footer">
      <span :class="counterClasses" aria-live="polite" data-testid="counter">
        {{ modelValue.length }} / {{ maxLength }}
      </span>

      <AppButton
        variant="primary"
        size="sm"
        :disabled="submitDisabled"
        data-testid="submit-btn"
        @click="onSubmitClick"
      >
        {{ isEditing ? saveLabel : sendLabel }}
      </AppButton>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  .app-chat-composer {
    display: flex;
    flex-direction: column;
    gap: var(--space-2);
    padding: var(--space-2);
    background: var(--surface-night);
    border: 1px solid var(--brand-brass-shadow);
    border-radius: var(--radius-md);
    transition: border-color var(--motion-duration-fast) var(--motion-ease-standard);

    // Focus ring lives on the whole compound control: the inner textarea
    // sets outline:none, so the composer shows the system 2px brass ring on
    // :focus-within, matching AppInput / AppTextarea / AppSelect.
    &:focus-within {
      border-color: var(--brand-brass);
      outline: 2px solid var(--brand-brass);
      outline-offset: 2px;
    }

    // ── Kind modifiers ─────────────────────────────────────────────────────────

    &--kind-whisper {
      border-color: var(--chat-whisper-accent);

      &:focus-within {
        border-color: var(--chat-whisper-accent);
      }
    }

    // ── Edit-banner ────────────────────────────────────────────────────────────

    &__edit-banner {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: var(--space-2);
      padding: var(--space-1) var(--space-2);
      background: color-mix(in srgb, var(--brand-brass) 12%, transparent);
      border-radius: var(--radius-sm);
      border: 1px solid var(--brand-brass-deep);
      color: var(--text-primary);
      font-size: var(--type-body-sm-font-size);
    }

    &__edit-banner-text {
      display: flex;
      flex-direction: column;
      min-width: 0;
      gap: var(--space-1);
    }

    &__edit-banner-label {
      font-weight: var(--fw-medium);
      color: var(--brand-brass);
      letter-spacing: 0.02em;
    }

    &__edit-banner-preview {
      color: var(--text-secondary);
      font-style: italic;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    // ── State: editing ─────────────────────────────────────────────────────────
    // Stronger border so users register the mode change at a glance.

    &--editing {
      border-color: var(--brand-brass);

      &:focus-within {
        border-color: var(--brand-brass);
      }
    }

    // ── State: disabled ────────────────────────────────────────────────────────

    &--disabled {
      opacity: var(--opacity-disabled);
      pointer-events: none;
    }

    // ── Textarea ───────────────────────────────────────────────────────────────

    &__textarea {
      display: block;
      width: 100%;
      min-width: 0;
      background: transparent;
      border: none;
      // Focus is shown on the composer container (:focus-within ring above),
      // so the inner textarea intentionally has no ring of its own.
      outline: none;
      resize: none;
      color: var(--text-primary);
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      line-height: var(--type-body-md-line-height);

      &::placeholder {
        color: var(--text-secondary);
      }

      &:disabled {
        cursor: not-allowed;
      }
    }

    // ── Footer row ─────────────────────────────────────────────────────────────

    &__footer {
      display: flex;
      align-items: center;
      justify-content: flex-end;
      gap: var(--space-2);
    }

    // ── Counter ────────────────────────────────────────────────────────────────

    &__counter {
      font-size: var(--type-body-xs-font-size);
      color: var(--text-secondary);
      font-variant-numeric: tabular-nums;

      &--warn {
        color: var(--brand-brass);
      }

      &--error {
        color: var(--state-crimson);
      }
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .app-chat-composer {
      transition: none;
    }
  }
</style>
