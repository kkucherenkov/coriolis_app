<script setup lang="ts">
  import { computed } from 'vue';

  type Orientation = 'horizontal' | 'vertical';
  type Tone = 'brass-deep' | 'brass-shadow' | 'brass';
  type Weight = 'hairline' | 'thin' | 'medium';

  interface Props {
    orientation?: Orientation;
    tone?: Tone;
    weight?: Weight;
    inset?: boolean;
  }

  const props = withDefaults(defineProps<Props>(), {
    orientation: 'horizontal',
    tone: 'brass-deep',
    weight: 'hairline',
    inset: false,
  });

  const classes = computed(() => [
    'app-divider',
    `app-divider--${props.orientation}`,
    `app-divider--${props.tone}`,
    `app-divider--${props.weight}`,
    { 'app-divider--inset': props.inset },
  ]);

  const isVertical = computed(() => props.orientation === 'vertical');
</script>

<template>
  <hr v-if="!isVertical" :class="classes" aria-orientation="horizontal" />
  <div v-else :class="classes" role="separator" aria-orientation="vertical" />
</template>

<style lang="scss" scoped>
  // Weight scale — px values named to avoid raw-ms stylelint ban
  $weight-hairline: 1px;
  $weight-thin: 1px;
  $weight-medium: 2px;

  .app-divider {
    // ── Reset browser <hr> defaults ────────────────────────────────────────────
    border: none;
    margin: 0;
    padding: 0;
    flex-shrink: 0;

    // ── Orientation ────────────────────────────────────────────────────────────

    &--horizontal {
      display: block;
      width: 100%;
    }

    &--vertical {
      display: block;
      width: $weight-hairline; // overridden by weight modifiers below
      height: 100%;
      align-self: stretch;
    }

    // ── Tone modifiers — background acts as the line color ─────────────────────

    &--brass-deep {
      background-color: var(--brand-brass-deep);
    }

    &--brass-shadow {
      background-color: var(--brand-brass-shadow);
    }

    &--brass {
      background-color: var(--brand-brass);
    }

    // ── Weight modifiers ───────────────────────────────────────────────────────

    &--hairline {
      &.app-divider--horizontal {
        height: $weight-hairline;
      }

      &.app-divider--vertical {
        width: $weight-hairline;
      }
    }

    &--thin {
      &.app-divider--horizontal {
        height: $weight-thin;
      }

      &.app-divider--vertical {
        width: $weight-thin;
      }
    }

    &--medium {
      &.app-divider--horizontal {
        height: $weight-medium;
      }

      &.app-divider--vertical {
        width: $weight-medium;
      }
    }

    // ── Inset modifier — var(--space-4) = 16px margin on both ends ─────────────

    &--inset {
      &.app-divider--horizontal {
        margin-inline: var(--space-4);
        width: calc(100% - 2 * var(--space-4));
      }

      &.app-divider--vertical {
        margin-block: var(--space-4);
        height: calc(100% - 2 * var(--space-4));
      }
    }
  }
</style>
