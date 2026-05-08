<script setup lang="ts">
  import { computed } from 'vue';

  type InputType = 'text' | 'email' | 'password' | 'number' | 'search' | 'tel' | 'url';
  type Size = 'sm' | 'md' | 'lg';

  interface Props {
    modelValue: string | number | null;
    type?: InputType;
    size?: Size;
    disabled?: boolean;
    readonly?: boolean;
    invalid?: boolean;
    placeholder?: string;
    inputId?: string;
    inputmode?: 'none' | 'text' | 'decimal' | 'numeric' | 'tel' | 'search' | 'email' | 'url';
    autocomplete?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    type: 'text',
    size: 'md',
    disabled: false,
    readonly: false,
    invalid: false,
    placeholder: undefined,
    inputId: undefined,
    inputmode: undefined,
    autocomplete: undefined,
  });

  // Emit string for all text-like types; number when type="number"; null when empty.
  // This keeps the v-model contract explicit and predictable for consumers.
  const emit = defineEmits<{
    'update:modelValue': [value: string | number | null];
  }>();

  const classes = computed(() => [
    'app-input',
    `app-input--${props.size}`,
    { 'app-input--invalid': props.invalid },
    { 'app-input--disabled': props.disabled },
  ]);

  function onInput(event: Event): void {
    if (props.disabled) return;
    const target = event.target as HTMLInputElement;
    if (props.type === 'number') {
      emit('update:modelValue', target.value === '' ? null : Number(target.value));
    } else {
      emit('update:modelValue', target.value === '' ? null : target.value);
    }
  }
</script>

<template>
  <input
    :id="inputId"
    :class="classes"
    :type="type"
    :value="modelValue ?? ''"
    :placeholder="placeholder"
    :disabled="disabled"
    :readonly="readonly"
    :inputmode="inputmode"
    :autocomplete="autocomplete"
    :aria-disabled="disabled || undefined"
    :aria-readonly="readonly || undefined"
    :aria-invalid="invalid || undefined"
    @input="onInput"
  />
</template>

<style lang="scss" scoped>
  .app-input {
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
  }
</style>
