<script setup lang="ts">
  import { computed } from 'vue';

  type Variant = 'linear' | 'circular';
  type Tone = 'brass' | 'mystic' | 'crimson' | 'success' | 'darkness';
  type Size = 'sm' | 'md' | 'lg';

  interface Props {
    value: number;
    max?: number;
    min?: number;
    variant?: Variant;
    tone?: Tone;
    size?: Size;
    label?: string;
    showLabel?: boolean;
  }

  const props = withDefaults(defineProps<Props>(), {
    max: 100,
    min: 0,
    variant: 'linear',
    tone: 'brass',
    size: 'md',
    label: undefined,
    showLabel: false,
  });

  const clampedValue = computed(() =>
    Math.max(props.min, Math.min(props.max, props.value)),
  );

  const range = computed(() => props.max - props.min);

  const percentage = computed(() =>
    range.value === 0 ? 0 : ((clampedValue.value - props.min) / range.value) * 100,
  );

  const fillStyle = computed(() => ({ width: `${percentage.value}%` }));

  const rootClasses = computed(() => [
    'app-progress',
    `app-progress--${props.variant}`,
    `app-progress--${props.tone}`,
    `app-progress--${props.size}`,
  ]);

  const labelText = computed(() =>
    `${clampedValue.value} / ${props.max}`,
  );
</script>

<template>
  <div
    :class="rootClasses"
    role="progressbar"
    :aria-valuenow="clampedValue"
    :aria-valuemin="min"
    :aria-valuemax="max"
    :aria-label="label || undefined"
  >
    <div class="app-progress__track">
      <div class="app-progress__fill" :style="fillStyle" />
    </div>
    <span v-if="showLabel" class="app-progress__label">{{ labelText }}</span>
  </div>
</template>

<style lang="scss" scoped>
  // Bar height scale — named SCSS variables, permitted for layout-dimension literals.
  $bar-height-sm: 4px;
  $bar-height-md: 8px;
  $bar-height-lg: 12px;

  .app-progress {
    display: inline-flex;
    flex-direction: column;
    gap: var(--space-1);
    width: 100%;

    // ── Size modifiers ────────────────────────────────────────────────────────

    &--sm .app-progress__track {
      height: $bar-height-sm;
    }

    &--md .app-progress__track {
      height: $bar-height-md;
    }

    &--lg .app-progress__track {
      height: $bar-height-lg;
    }

    // ── Tone modifiers (fill colour) ──────────────────────────────────────────

    &--brass .app-progress__fill {
      background-color: var(--brand-brass);
    }

    &--mystic .app-progress__fill {
      background-color: var(--state-mystic-teal);
    }

    &--crimson .app-progress__fill {
      background-color: var(--state-crimson);
    }

    &--success .app-progress__fill {
      background-color: var(--state-success);
    }

    &--darkness .app-progress__fill {
      background-color: var(--state-darkness);
    }

    // ── Track element ─────────────────────────────────────────────────────────

    &__track {
      position: relative;
      width: 100%;
      border-radius: var(--radius-sm);
      background-color: var(--surface-dawn);
      overflow: hidden;
    }

    // ── Fill element ──────────────────────────────────────────────────────────

    &__fill {
      position: absolute;
      inset-block-start: 0;
      inset-block-end: 0;
      inset-inline-start: 0;
      border-radius: var(--radius-sm);
      transition:
        width var(--motion-duration) var(--motion-ease-standard),
        background-color var(--motion-duration-fast) var(--motion-ease-standard);

      @media (prefers-reduced-motion: reduce) {
        transition: none;
      }
    }

    // ── Label element ─────────────────────────────────────────────────────────

    &__label {
      font-family: var(--type-mono-stat-md-font-family);
      font-size: var(--type-body-sm-font-size);
      font-weight: var(--type-mono-stat-md-font-weight);
      color: var(--text-secondary);
      line-height: 1;
    }
  }
</style>
