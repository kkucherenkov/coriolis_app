<script setup lang="ts">
  import { computed } from 'vue';

  type Size = 'sm' | 'md' | 'lg';

  interface Props {
    modelValue: string | null;
    size?: Size;
    disabled?: boolean;
    readonly?: boolean;
    invalid?: boolean;
    placeholder?: string;
    inputId?: string;
    rows?: number;
    /** Grows the textarea to fit its content via CSS `field-sizing: content`.
     *  The `rows` value acts as the minimum height. Progressive enhancement:
     *  browsers without `field-sizing` keep the fixed `rows` height. Manual
     *  resize is suppressed so height tracks content. */
    autosize?: boolean;
    maxlength?: number;
  }

  const props = withDefaults(defineProps<Props>(), {
    size: 'md',
    disabled: false,
    readonly: false,
    invalid: false,
    placeholder: undefined,
    inputId: undefined,
    rows: 4,
    autosize: false,
    maxlength: undefined,
  });

  const emit = defineEmits<{
    'update:modelValue': [value: string | null];
  }>();

  const classes = computed(() => [
    'app-textarea',
    `app-textarea--${props.size}`,
    { 'app-textarea--invalid': props.invalid },
    { 'app-textarea--disabled': props.disabled },
    { 'app-textarea--autosize': props.autosize },
  ]);

  function onInput(event: Event): void {
    if (props.disabled) return;
    const target = event.target as HTMLTextAreaElement;
    emit('update:modelValue', target.value === '' ? null : target.value);
  }
</script>

<template>
  <textarea
    :id="inputId"
    :class="classes"
    :value="modelValue ?? ''"
    :placeholder="placeholder"
    :rows="rows"
    :disabled="disabled"
    :readonly="readonly"
    :maxlength="maxlength"
    :aria-disabled="disabled || undefined"
    :aria-readonly="readonly || undefined"
    :aria-invalid="invalid || undefined"
    @input="onInput"
  />
</template>

<style lang="scss" scoped>
  .app-textarea {
    display: block;
    width: 100%;
    min-width: 0;
    background-color: var(--surface-night);
    border: 1px solid var(--brand-brass-shadow);
    border-radius: var(--radius-md);
    color: var(--brand-brass-light);
    font-family: var(--type-body-md-font-family);
    font-size: var(--type-body-md-font-size);
    line-height: var(--type-body-md-line-height);
    resize: vertical;
    transition: border-color var(--motion-duration-fast) var(--motion-ease-standard);

    &::placeholder {
      color: var(--text-secondary);
    }

    &:hover:not(:disabled):not([readonly]) {
      border-color: var(--brand-brass-deep);
    }

    &:focus-visible {
      outline: 2px solid var(--brand-brass);
      outline-offset: 2px;
      border-color: var(--brand-brass);
    }

    // ── Size modifiers ───────────────────────────────────────────────────────

    &--sm {
      padding: var(--space-1) var(--space-3);
      font-size: var(--type-body-sm-font-size);
      line-height: var(--type-body-sm-line-height);
    }

    &--md {
      padding: var(--space-2) var(--space-4);
      font-size: var(--type-body-md-font-size);
      line-height: var(--type-body-md-line-height);
    }

    &--lg {
      padding: var(--space-3) var(--space-5);
      font-size: var(--type-body-lg-font-size);
      line-height: var(--type-body-lg-line-height);
    }

    // ── State: invalid ───────────────────────────────────────────────────────

    &--invalid {
      border-color: var(--state-crimson);

      &:hover:not(:disabled) {
        border-color: var(--state-crimson-bright);
      }

      &:focus-visible {
        outline-color: var(--state-crimson-bright);
        border-color: var(--state-crimson);
      }
    }

    // ── State: disabled ──────────────────────────────────────────────────────

    &--disabled,
    &:disabled {
      opacity: var(--opacity-disabled);
      pointer-events: none;
      cursor: not-allowed;
    }

    // ── Autosize — grow-to-content via CSS field-sizing ─────────────────────
    // `field-sizing: content` sizes the control to its text; the `rows` attr
    // stays the minimum height. Manual resize is suppressed so height tracks
    // content. Browsers without field-sizing keep the fixed rows height.

    &--autosize {
      field-sizing: content;
      resize: none;
    }
  }
</style>
