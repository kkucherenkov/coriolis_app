<script setup lang="ts">
  import { computed } from 'vue';

  type Variant = 'brass' | 'mystic' | 'crimson' | 'success' | 'darkness';
  type Size = 'sm' | 'md';

  interface Props {
    modelValue?: boolean;
    variant?: Variant;
    size?: Size;
    disabled?: boolean;
    removable?: boolean;
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    variant: 'brass',
    size: 'md',
    disabled: false,
    removable: false,
  });

  const emit = defineEmits<{
    'update:modelValue': [value: boolean];
    remove: [];
  }>();

  const classes = computed(() => [
    'app-chip',
    `app-chip--${props.variant}`,
    `app-chip--${props.size}`,
    {
      'app-chip--active': props.modelValue,
      'app-chip--disabled': props.disabled,
      'app-chip--removable': props.removable,
    },
  ]);

  function handleToggle(): void {
    if (props.disabled) return;
    emit('update:modelValue', !props.modelValue);
  }

  function handleRemove(event: MouseEvent | KeyboardEvent): void {
    if (props.disabled) return;
    event.stopPropagation();
    emit('remove');
  }
</script>

<template>
  <button
    type="button"
    :class="classes"
    :disabled="disabled"
    :aria-pressed="modelValue ? 'true' : 'false'"
    :aria-disabled="disabled ? 'true' : undefined"
    @click="handleToggle"
  >
    <span class="app-chip__label">
      <slot />
    </span>
    <span
      v-if="removable"
      class="app-chip__remove"
      role="button"
      tabindex="0"
      aria-label="Remove"
      @click.stop="handleRemove"
      @keydown.enter.prevent="handleRemove"
      @keydown.space.prevent="handleRemove"
      >×</span
    >
  </button>
</template>

<style lang="scss" scoped>
  // Badge-aligned font sizes — sub body-sm by design.
  // SCSS variables are the approved escape hatch for layout-dimension literals.
  $chip-font-sm: 10px;
  $chip-font-md: 12px;
  $chip-pad-v-md: 3px;
  $chip-remove-size: 16px;
  $chip-remove-font: 14px;

  .app-chip {
    display: inline-flex;
    align-items: center;
    gap: var(--space-1);
    border: 1px solid;
    border-radius: var(--radius-pill);
    background: transparent;
    font-family: var(--type-body-sm-font-family);
    font-weight: 500;
    white-space: nowrap;
    line-height: 1;
    cursor: pointer;
    transition:
      background-color var(--motion-duration-fast) var(--motion-ease-standard),
      border-color var(--motion-duration-fast) var(--motion-ease-standard),
      color var(--motion-duration-fast) var(--motion-ease-standard);

    // ── Focus ───────────────────────────────────────────────────────────────

    &:focus-visible {
      outline: 2px solid var(--brand-brass);
      outline-offset: 2px;
    }

    // ── Size modifiers ───────────────────────────────────────────────────────

    &--sm {
      font-size: $chip-font-sm;
      padding: 2px var(--space-2);
    }

    &--md {
      font-size: $chip-font-md;
      padding: $chip-pad-v-md var(--space-3);
    }

    // ── Variant: brass ───────────────────────────────────────────────────────

    &--brass {
      border-color: var(--brand-brass);
      color: var(--brand-brass-light);
      background-color: transparent;

      &:hover:not(:disabled) {
        background-color: color-mix(in srgb, var(--brand-brass) 12%, transparent);
      }

      &:active:not(:disabled) {
        background-color: color-mix(in srgb, var(--brand-brass) 20%, transparent);
      }

      &.app-chip--active {
        background-color: var(--brand-brass);
        color: var(--text-on-brass);

        &:hover:not(:disabled) {
          background-color: var(--brand-brass-deep);
        }
      }
    }

    // ── Variant: mystic ──────────────────────────────────────────────────────

    &--mystic {
      border-color: var(--state-mystic-teal);
      color: var(--state-mystic-teal);
      background-color: transparent;

      &:hover:not(:disabled) {
        background-color: color-mix(in srgb, var(--state-mystic-teal) 12%, transparent);
      }

      &:active:not(:disabled) {
        background-color: color-mix(in srgb, var(--state-mystic-teal) 20%, transparent);
      }

      &.app-chip--active {
        background-color: var(--state-mystic-teal);
        color: var(--text-primary);

        &:hover:not(:disabled) {
          background-color: color-mix(in srgb, var(--state-mystic-teal) 85%, transparent);
        }
      }
    }

    // ── Variant: crimson ─────────────────────────────────────────────────────

    &--crimson {
      border-color: var(--state-crimson);
      color: var(--state-crimson-bright);
      background-color: transparent;

      &:hover:not(:disabled) {
        background-color: color-mix(in srgb, var(--state-crimson) 12%, transparent);
      }

      &:active:not(:disabled) {
        background-color: color-mix(in srgb, var(--state-crimson) 20%, transparent);
      }

      &.app-chip--active {
        background-color: var(--state-crimson);
        color: var(--text-primary);

        &:hover:not(:disabled) {
          background-color: color-mix(in srgb, var(--state-crimson) 85%, transparent);
        }
      }
    }

    // ── Variant: success ─────────────────────────────────────────────────────

    &--success {
      border-color: var(--state-success);
      color: var(--state-success);
      background-color: transparent;

      &:hover:not(:disabled) {
        background-color: color-mix(in srgb, var(--state-success) 12%, transparent);
      }

      &:active:not(:disabled) {
        background-color: color-mix(in srgb, var(--state-success) 20%, transparent);
      }

      &.app-chip--active {
        background-color: var(--state-success);
        color: var(--text-primary);

        &:hover:not(:disabled) {
          background-color: color-mix(in srgb, var(--state-success) 85%, transparent);
        }
      }
    }

    // ── Variant: darkness ────────────────────────────────────────────────────

    &--darkness {
      border-color: var(--state-darkness);
      color: var(--text-primary);
      background-color: transparent;

      &:hover:not(:disabled) {
        background-color: color-mix(in srgb, var(--state-darkness) 20%, transparent);
      }

      &:active:not(:disabled) {
        background-color: color-mix(in srgb, var(--state-darkness) 35%, transparent);
      }

      &.app-chip--active {
        background-color: var(--state-darkness);
        color: var(--text-primary);

        &:hover:not(:disabled) {
          background-color: color-mix(in srgb, var(--state-darkness) 85%, transparent);
        }
      }
    }

    // ── State: disabled ──────────────────────────────────────────────────────

    &--disabled,
    &:disabled {
      cursor: not-allowed;
      opacity: var(--opacity-disabled);
      pointer-events: none;
    }

    // ── Internal elements ────────────────────────────────────────────────────

    &__label {
      display: inline-flex;
      align-items: center;
    }

    &__remove {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      width: $chip-remove-size;
      height: $chip-remove-size;
      font-size: $chip-remove-font;
      line-height: 1;
      border-radius: var(--radius-pill);
      cursor: pointer;
      margin-inline-start: var(--space-1);

      &:hover {
        background-color: color-mix(in srgb, currentcolor 20%, transparent);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 1px;
      }
    }
  }
</style>
