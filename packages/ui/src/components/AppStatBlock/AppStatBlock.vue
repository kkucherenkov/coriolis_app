<script setup lang="ts">
  import { computed } from 'vue';

  import AppDots from '../AppDots/AppDots.vue';

  type Tone = 'brass' | 'mystic';
  type Size = 'sm' | 'md';

  interface Props {
    label: string;
    value: number;
    max?: number;
    hideDots?: boolean;
    tone?: Tone;
    size?: Size;
    disabled?: boolean;
    ariaLabel?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    max: 5,
    hideDots: false,
    tone: 'brass',
    size: 'md',
    disabled: false,
    ariaLabel: undefined,
  });

  const emit = defineEmits<{ select: [] }>();

  const computedAriaLabel = computed(
    () => props.ariaLabel ?? `${props.label} ${String(props.value)} of ${String(props.max)}`,
  );

  const rootClasses = computed(() => [
    'app-stat-block',
    `app-stat-block--${props.tone}`,
    `app-stat-block--${props.size}`,
    { 'app-stat-block--disabled': props.disabled },
  ]);

  function onClick(): void {
    if (!props.disabled) {
      emit('select');
    }
  }
</script>

<template>
  <component
    :is="disabled ? 'div' : 'button'"
    :type="disabled ? undefined : 'button'"
    :class="rootClasses"
    :aria-label="computedAriaLabel"
    :aria-disabled="disabled || undefined"
    @click="onClick"
  >
    <span class="app-stat-block__label">{{ label }}</span>
    <span class="app-stat-block__value">{{ value }}</span>
    <AppDots
      v-if="!hideDots"
      class="app-stat-block__dots"
      :value="value"
      :max="max"
      :tone="tone"
      :size="size === 'sm' ? 'sm' : 'md'"
      :label="computedAriaLabel"
    />
  </component>
</template>

<style lang="scss" scoped>
  // Minimum tap target — 44px per WCAG 2.5.5.
  $tap-min: 44px;

  .app-stat-block {
    display: inline-flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: var(--space-1);
    min-width: $tap-min;
    min-height: $tap-min;
    padding: var(--space-2) var(--space-3);
    background: transparent;
    border: none;
    border-radius: var(--radius-md);
    cursor: pointer;
    user-select: none;
    text-align: center;
    text-decoration: none;
    transition:
      background-color var(--motion-duration-fast) var(--motion-ease-standard),
      box-shadow var(--motion-duration-fast) var(--motion-ease-standard);

    &:focus-visible {
      outline: 2px solid var(--brand-brass);
      outline-offset: 2px;
    }

    // ── Tone: brass (default) ──────────────────────────────────────────────────

    &--brass {
      .app-stat-block__label {
        color: var(--brand-brass-light);
      }

      .app-stat-block__value {
        color: var(--text-primary);
      }

      &:hover:not(.app-stat-block--disabled) {
        background-color: color-mix(in srgb, var(--brand-brass) 8%, transparent);
      }

      &:active:not(.app-stat-block--disabled) {
        background-color: color-mix(in srgb, var(--brand-brass) 14%, transparent);
      }
    }

    // ── Tone: mystic ───────────────────────────────────────────────────────────

    &--mystic {
      .app-stat-block__label {
        color: var(--state-mystic-teal);
      }

      .app-stat-block__value {
        color: var(--text-primary);
      }

      &:hover:not(.app-stat-block--disabled) {
        background-color: color-mix(in srgb, var(--state-mystic-teal) 8%, transparent);
      }

      &:active:not(.app-stat-block--disabled) {
        background-color: color-mix(in srgb, var(--state-mystic-teal) 14%, transparent);
      }
    }

    // ── Size: md (default) ─────────────────────────────────────────────────────

    &--md {
      .app-stat-block__label {
        font-family: var(--type-display-sm-font-family);
        font-size: 11px;
        letter-spacing: 0.1em;
        text-transform: uppercase;
      }

      .app-stat-block__value {
        font-family: var(--type-mono-stat-md-font-family);
        font-size: var(--type-mono-stat-md-font-size);
        font-weight: var(--type-mono-stat-md-font-weight);
        line-height: var(--type-mono-stat-md-line-height);
      }
    }

    // ── Size: sm ───────────────────────────────────────────────────────────────

    &--sm {
      gap: var(--space-1);
      padding: var(--space-1) var(--space-2);

      .app-stat-block__label {
        font-family: var(--type-display-sm-font-family);
        font-size: 10px;
        letter-spacing: 0.08em;
        text-transform: uppercase;
      }

      .app-stat-block__value {
        font-family: var(--type-mono-stat-md-font-family);
        font-size: 18px;
        font-weight: var(--type-mono-stat-md-font-weight);
        line-height: 1;
      }
    }

    // ── Disabled state ─────────────────────────────────────────────────────────

    &--disabled {
      cursor: default;
      opacity: var(--opacity-disabled);
      pointer-events: none;
    }

    // ── Inner elements ─────────────────────────────────────────────────────────

    &__label {
      display: block;
      line-height: 1;
    }

    &__value {
      display: block;
      line-height: 1;
    }

    &__dots {
      // Dots row is centered beneath the value.
    }
  }

  // Respect reduced-motion preference.
  @media (prefers-reduced-motion: reduce) {
    .app-stat-block {
      transition: none;
    }
  }
</style>
