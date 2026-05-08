<script setup lang="ts">
  import { computed } from 'vue';

  type Size = 'sm' | 'md' | 'lg';
  type Tone = 'brass' | 'mystic' | 'crimson' | 'darkness';

  interface Props {
    value: number;
    max?: number;
    size?: Size;
    tone?: Tone;
    label?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    max: 5,
    size: 'md',
    tone: 'brass',
    label: undefined,
  });

  const clampedValue = computed(() => Math.max(0, Math.min(props.max, props.value)));

  const rootClasses = computed(() => [
    'app-dots',
    `app-dots--${props.size}`,
    `app-dots--${props.tone}`,
  ]);
</script>

<template>
  <div
    :class="rootClasses"
    role="meter"
    :aria-valuenow="clampedValue"
    aria-valuemin="0"
    :aria-valuemax="max"
    :aria-label="label || undefined"
  >
    <span
      v-for="i in max"
      :key="i"
      :class="['app-dots__dot', { 'app-dots__dot--filled': i - 1 < clampedValue }]"
    />
  </div>
</template>

<style lang="scss" scoped>
  // Dot diameter scale — page-scoped layout dimensions, not design-token values.
  // Named SCSS variables are permitted by Stylelint for layout px values.
  $dot-size-sm: 6px;
  $dot-size-md: 8px;
  $dot-size-lg: 12px;

  .app-dots {
    display: inline-flex;
    align-items: center;
    gap: var(--space-1);

    // ── Size modifiers ────────────────────────────────────────────────────────

    &--sm .app-dots__dot {
      width: $dot-size-sm;
      height: $dot-size-sm;
    }

    &--md .app-dots__dot {
      width: $dot-size-md;
      height: $dot-size-md;
    }

    &--lg .app-dots__dot {
      width: $dot-size-lg;
      height: $dot-size-lg;
    }

    // ── Tone modifiers (filled-dot color) ─────────────────────────────────────

    &--brass .app-dots__dot--filled {
      background-color: var(--brand-brass);
      border-color: var(--brand-brass);
    }

    &--mystic .app-dots__dot--filled {
      background-color: var(--state-mystic-teal);
      border-color: var(--state-mystic-teal);
    }

    &--crimson .app-dots__dot--filled {
      background-color: var(--state-crimson);
      border-color: var(--state-crimson);
    }

    &--darkness .app-dots__dot--filled {
      background-color: var(--state-darkness);
      border-color: var(--state-darkness);
    }

    // ── Dot element ───────────────────────────────────────────────────────────

    &__dot {
      display: inline-block;
      flex-shrink: 0;
      border-radius: var(--radius-pill);
      border: 1px solid var(--brand-brass-shadow);
      background-color: transparent;
      transition: background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &--filled {
        // Color overridden per tone modifier above.
      }
    }
  }
</style>
