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
   */

  type Kind = 'broadcast' | 'whisper';

  interface Props {
    modelValue: string;
    conversationKind: Kind;
    partnerDisplayName?: string;
    maxLength?: number;
    disabled?: boolean;
  }

  const props = withDefaults(defineProps<Props>(), {
    partnerDisplayName: undefined,
    maxLength: 4096,
    disabled: false,
  });

  const emit = defineEmits<{
    (e: 'update:modelValue', v: string): void;
    (e: 'submit'): void;
  }>();

  const rootClasses = computed(() => [
    'app-chat-composer',
    `app-chat-composer--kind-${props.conversationKind}`,
    { 'app-chat-composer--disabled': props.disabled },
  ]);

  const placeholder = computed(() => {
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
  <div
    :class="rootClasses"
    data-testid="app-chat-composer"
  >
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
      <span
        :class="counterClasses"
        aria-live="polite"
        data-testid="counter"
      >
        {{ modelValue.length }} / {{ maxLength }}
      </span>

      <AppButton
        variant="primary"
        size="sm"
        :disabled="submitDisabled"
        data-testid="submit-btn"
        @click="onSubmitClick"
      >
        Send
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

    &:focus-within {
      border-color: var(--brand-brass);
    }

    // ── Kind modifiers ─────────────────────────────────────────────────────────

    &--kind-whisper {
      border-color: var(--chat-whisper-accent);

      &:focus-within {
        border-color: var(--chat-whisper-accent);
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
      font-size: var(--type-body-xs-font-size, 0.75rem);
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
