<script setup lang="ts">
  import { computed } from 'vue';

  import AppIcon from '../AppIcon/AppIcon.vue';

  type Condition = 'exhausted' | 'sleepless' | 'thirsty' | 'hungry';
  type PillSize = 'sm' | 'md';

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    disabled: false,
    size: 'md',
  });

  const emit = defineEmits<{
    'update:modelValue': [value: boolean];
  }>();

  const CONDITION_ICONS: Record<Condition, string> = {
    exhausted: 'battery-low',
    sleepless: 'moon',
    thirsty: 'droplet',
    hungry: 'apple',
  };

  const VALID_CONDITIONS: Condition[] = ['exhausted', 'sleepless', 'thirsty', 'hungry'];

  interface Props {
    condition: Condition;
    modelValue?: boolean;
    disabled?: boolean;
    size?: PillSize;
  }

  const iconName = computed(() => CONDITION_ICONS[props.condition]);

  // Fallback label: capitalise first letter of condition name.
  const defaultLabel = computed(
    () => props.condition.charAt(0).toUpperCase() + props.condition.slice(1),
  );

  const classes = computed(() => [
    'app-condition-pill',
    `app-condition-pill--${props.condition}`,
    `app-condition-pill--${props.size}`,
    {
      'app-condition-pill--active': props.modelValue,
      'app-condition-pill--disabled': props.disabled,
    },
  ]);

  const iconSize = computed(() => (props.size === 'sm' ? 'xs' : 'sm'));

  function handleClick(): void {
    if (props.disabled) return;
    emit('update:modelValue', !props.modelValue);
  }
</script>

<template>
  <button
    type="button"
    :class="classes"
    :disabled="disabled"
    :aria-pressed="modelValue ? 'true' : 'false'"
    :aria-disabled="disabled ? 'true' : undefined"
    @click="handleClick"
  >
    <span class="app-condition-pill__icon" aria-hidden="true">
      <AppIcon :name="iconName" :size="iconSize" color="inherit" />
    </span>
    <span class="app-condition-pill__label">
      <slot>{{ defaultLabel }}</slot>
    </span>
  </button>
</template>

<style lang="scss" scoped>
  // Font size values below the Stylelint raw-px floor — SCSS vars approved.
  $pill-font-sm: 10px;
  $pill-font-md: 12px;

  .app-condition-pill {
    display: inline-flex;
    align-items: center;
    gap: var(--space-1);
    border: 1px solid var(--state-mystic-teal);
    border-radius: var(--radius-pill);
    background: transparent;
    color: var(--text-secondary);
    font-family: var(--type-body-sm-font-family);
    font-weight: 500;
    white-space: nowrap;
    line-height: 1;
    cursor: pointer;
    transition:
      background-color var(--motion-duration-fast) var(--motion-ease-standard),
      border-color var(--motion-duration-fast) var(--motion-ease-standard),
      box-shadow var(--motion-duration-fast) var(--motion-ease-standard);

    // ── Focus ───────────────────────────────────────────────────────────────

    &:focus-visible {
      outline: 2px solid var(--brand-brass);
      outline-offset: 2px;
    }

    // ── Size modifiers ───────────────────────────────────────────────────────

    &--sm {
      font-size: $pill-font-sm;
      padding: 2px var(--space-2);
    }

    &--md {
      font-size: $pill-font-md;
      padding: var(--space-1) var(--space-3);
    }

    // ── Icon (inherits button color by default) ───────────────────────────────

    &__icon {
      display: inline-flex;
      align-items: center;
      flex-shrink: 0;
      color: var(--state-mystic-teal);
    }

    &__label {
      display: inline-flex;
      align-items: center;
    }

    // ── Active state ──────────────────────────────────────────────────────────

    &--active {
      background-color: var(--state-mystic-teal);
      color: var(--text-primary);
      box-shadow: var(--shadow-icon-glow);

      .app-condition-pill__icon {
        color: var(--text-on-brass);
      }
    }

    // ── Hover ─────────────────────────────────────────────────────────────────

    &:hover:not(:disabled):not(.app-condition-pill--active) {
      background-color: color-mix(in srgb, var(--state-mystic-teal) 12%, transparent);
    }

    &--active:hover:not(:disabled) {
      background-color: color-mix(in srgb, var(--state-mystic-teal) 85%, transparent);
    }

    // ── Disabled state ────────────────────────────────────────────────────────

    &--disabled,
    &:disabled {
      opacity: var(--opacity-disabled);
      cursor: not-allowed;
      pointer-events: none;
    }
  }
</style>
