<script setup lang="ts">
  import { computed, useSlots } from 'vue';

  type Size = 'sm' | 'md';

  interface Props {
    modelValue: boolean;
    disabled?: boolean;
    /** Renders the crimson invalid treatment + sets aria-invalid. */
    invalid?: boolean;
    size?: Size;
    label?: string;
    name?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    disabled: false,
    invalid: false,
    size: 'md',
    label: undefined,
    name: undefined,
  });

  const emit = defineEmits<{
    'update:modelValue': [value: boolean];
  }>();

  const slots = useSlots();

  // Slot wins over label prop when both are provided.
  const hasVisibleLabel = computed(() => !!slots['default'] || !!props.label);

  // Aria-label is set only when there is no visible text label (slot or prop).
  // When a visible label is present, it serves as the accessible name via the
  // <label for=""> association.
  const ariaLabel = computed<string | undefined>(() => {
    if (hasVisibleLabel.value) return;
    return props.label;
  });

  const rootClasses = computed(() => [
    'app-switch',
    `app-switch--${props.size}`,
    {
      'app-switch--checked': props.modelValue,
      'app-switch--disabled': props.disabled,
      'app-switch--invalid': props.invalid,
    },
  ]);

  function toggle(): void {
    if (props.disabled) return;
    emit('update:modelValue', !props.modelValue);
  }

  function onKeydown(event: KeyboardEvent): void {
    // Space is the standard activation key for role="switch".
    // Native <button> already fires click on Enter, so we only intercept Space.
    if (event.key === ' ' || event.code === 'Space') {
      event.preventDefault();
      toggle();
    }
  }
</script>

<template>
  <!-- When there is a visible label (slot or prop), wrap with <label> so clicks
       on the label text activate the switch natively. -->
  <label v-if="hasVisibleLabel" :class="rootClasses">
    <button
      type="button"
      role="switch"
      :aria-checked="modelValue"
      :aria-disabled="disabled || undefined"
      :aria-invalid="invalid || undefined"
      :disabled="disabled"
      :name="name"
      class="app-switch__control"
      @click="toggle"
      @keydown="onKeydown"
    >
      <span class="app-switch__track" aria-hidden="true">
        <span class="app-switch__thumb" />
      </span>
    </button>
    <span class="app-switch__label">
      <!-- Slot wins when both slot and label prop are provided. -->
      <slot>{{ label }}</slot>
    </span>
  </label>

  <!-- No visible label — bare button with aria-label for accessible name. -->
  <button
    v-else
    type="button"
    role="switch"
    :class="rootClasses"
    :aria-checked="modelValue"
    :aria-label="ariaLabel"
    :aria-disabled="disabled || undefined"
    :aria-invalid="invalid || undefined"
    :disabled="disabled"
    :name="name"
    @click="toggle"
    @keydown="onKeydown"
  >
    <span class="app-switch__track" aria-hidden="true">
      <span class="app-switch__thumb" />
    </span>
  </button>
</template>

<style lang="scss" scoped>
  // Track and thumb geometry — SCSS variables for layout-dimension literals
  // (permitted by Stylelint; all color/motion values use design tokens).

  // sm: track 28×16 px, thumb 12 px diameter, translate-x when checked = 12px
  $track-width-sm: 28px;
  $track-height-sm: 16px;
  $thumb-size-sm: 12px;
  $thumb-offset-sm: 2px; // gap between thumb edge and track edge
  $thumb-translate-sm: 12px; // checked position: track-width - thumb - 2*offset

  // md: track 40×22 px, thumb 16 px diameter, translate-x when checked = 18px
  $track-width-md: 40px;
  $track-height-md: 22px;
  $thumb-size-md: 16px;
  $thumb-offset-md: 3px;
  $thumb-translate-md: 18px; // 40 - 16 - 2*3

  .app-switch {
    display: inline-flex;
    align-items: center;
    gap: var(--space-2);
    cursor: pointer;

    &--disabled {
      cursor: not-allowed;
      opacity: var(--opacity-disabled);
    }

    // ── Size modifiers ────────────────────────────────────────────────────────

    &--sm {
      .app-switch__track {
        width: $track-width-sm;
        height: $track-height-sm;
      }

      .app-switch__thumb {
        width: $thumb-size-sm;
        height: $thumb-size-sm;
        top: $thumb-offset-sm;
        left: $thumb-offset-sm;
      }

      &.app-switch--checked .app-switch__thumb,
      &.app-switch--checked > .app-switch__track .app-switch__thumb {
        transform: translateX($thumb-translate-sm);
      }
    }

    &--md {
      .app-switch__track {
        width: $track-width-md;
        height: $track-height-md;
      }

      .app-switch__thumb {
        width: $thumb-size-md;
        height: $thumb-size-md;
        top: $thumb-offset-md;
        left: $thumb-offset-md;
      }

      &.app-switch--checked .app-switch__thumb,
      &.app-switch--checked > .app-switch__track .app-switch__thumb {
        transform: translateX($thumb-translate-md);
      }
    }

    // ── Checked state — track fill ────────────────────────────────────────────

    &--checked .app-switch__track {
      background-color: var(--brand-brass);
      border-color: var(--brand-brass);
    }

    // ── Invalid state — crimson track border (after --checked so it wins) ───────

    &--invalid .app-switch__track {
      border-color: var(--state-crimson);
    }

    &--invalid .app-switch__control:focus-visible,
    &--invalid:not(label):focus-visible {
      outline-color: var(--state-crimson);
    }

    // ── Internal elements ─────────────────────────────────────────────────────

    &__control {
      // Bare button reset — visual control is handled by __track/__thumb.
      display: inline-flex;
      flex-shrink: 0;
      padding: 0;
      background: transparent;
      border: none;
      cursor: inherit;
      appearance: none;

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
        border-radius: var(--radius-pill);
      }

      &:disabled {
        cursor: not-allowed;
      }
    }

    // Focus for the bare-button variant (no wrapper label).
    &:not(label):focus-visible {
      outline: 2px solid var(--brand-brass);
      outline-offset: 2px;
      border-radius: var(--radius-pill);
    }

    &__track {
      position: relative;
      display: inline-block;
      flex-shrink: 0;
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-pill);
      transition:
        background-color var(--motion-duration-fast) var(--motion-ease-standard),
        border-color var(--motion-duration-fast) var(--motion-ease-standard);
    }

    &__thumb {
      position: absolute;
      background-color: var(--brand-brass-light);
      border-radius: var(--radius-pill);
      transition: transform var(--motion-duration-fast) var(--motion-ease-standard);
    }

    &__label {
      color: var(--text-primary);
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      line-height: var(--type-body-md-line-height);
      user-select: none;
    }
  }
</style>
