<script setup lang="ts">
  import { computed, useId } from 'vue';

  type Size = 'sm' | 'md';

  interface Props {
    label: string;
    for?: string;
    required?: boolean;
    helpText?: string;
    error?: string;
    size?: Size;
  }

  const props = withDefaults(defineProps<Props>(), {
    for: undefined,
    required: false,
    helpText: undefined,
    error: undefined,
    size: 'md',
  });

  // useId() is Vue 3.5+; generates a stable, SSR-safe id per component instance.
  // When the consumer supplies an explicit `for` id we use that instead so the
  // label and input share a predetermined stable id (e.g. for E2E selectors).
  const generatedId = useId();
  const fieldId = computed<string>(() => props.for ?? generatedId);

  // We show either the error span or the help span — never both.
  // aria-describedby points at whichever is currently rendered.
  const activeDescId = computed<string | undefined>(() =>
    props.error ? `${fieldId.value}-error` : props.helpText ? `${fieldId.value}-help` : undefined,
  );

  // Attrs spread onto the slotted control so the consumer wires a11y for free.
  const slotAttrs = computed(() => ({
    id: fieldId.value,
    'aria-describedby': activeDescId.value,
    'aria-invalid': props.error ? (true as const) : undefined,
    'aria-required': props.required ? (true as const) : undefined,
  }));

  const rootClasses = computed(() => [
    'app-field',
    `app-field--${props.size}`,
    { 'app-field--required': props.required },
    { 'app-field--invalid': !!props.error },
  ]);
</script>

<template>
  <div :class="rootClasses">
    <!-- Label rendered inline — no AppLabel dep so this branch ships independently -->
    <label :for="fieldId" class="app-field__label">
      <span class="app-field__label-text">{{ label }}</span>
      <span v-if="required" class="app-field__required" aria-hidden="true">*</span>
    </label>

    <div class="app-field__control">
      <slot v-bind="slotAttrs" />
    </div>

    <!-- error wins over helpText when both are set -->
    <span v-if="error" :id="`${fieldId}-error`" class="app-field__error" role="alert">{{
      error
    }}</span>
    <span v-else-if="helpText" :id="`${fieldId}-help`" class="app-field__help">{{ helpText }}</span>
  </div>
</template>

<style lang="scss" scoped>
  .app-field {
    display: flex;
    flex-direction: column;
    gap: var(--space-2);

    // ── Size modifiers ───────────────────────────────────────────────────────

    &--sm {
      gap: var(--space-1);
    }

    &--md {
      gap: var(--space-2);
    }

    // ── Label ────────────────────────────────────────────────────────────────

    &__label {
      display: inline-flex;
      align-items: baseline;
      gap: var(--space-1);
      color: var(--text-secondary);
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      font-weight: var(--type-body-sm-font-weight);
      line-height: var(--type-body-sm-line-height);
      cursor: default;
      user-select: none;

      .app-field--sm & {
        font-size: var(--type-body-sm-font-size);
        line-height: var(--type-body-sm-line-height);
      }
    }

    &__label-text {
      display: inline-block;
    }

    &__required {
      color: var(--state-crimson-bright);
      font-weight: 600;
    }

    // ── Control wrapper ──────────────────────────────────────────────────────

    &__control {
      display: flex;
      flex-direction: column;
    }

    // ── Help and Error ───────────────────────────────────────────────────────

    &__help,
    &__error {
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      line-height: var(--type-body-sm-line-height);
    }

    &__help {
      color: var(--text-secondary);
    }

    &__error {
      color: var(--state-crimson-bright);
      font-weight: 600;
    }

    // ── State: invalid ───────────────────────────────────────────────────────

    &--invalid &__label {
      color: var(--state-crimson-bright);
    }
  }
</style>
