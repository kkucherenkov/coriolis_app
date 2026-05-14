<script setup lang="ts">
  import { computed } from 'vue';

  type SwashColor = 'brass' | 'brass-deep' | 'brass-light';

  const props = withDefaults(defineProps<Props>(), {
    width: 80,
    color: 'brass',
  });

  /**
   * Calligraphic underline swash — replaces the section divider beneath display
   * titles. Pairs with every `AppPanelTitle` and any Forum display ≥ 20px.
   *
   * Hand-off reference: `primitives.jsx:L44-L52` + `COMPONENTS.md:L36-L46`.
   *
   * The path is a single open stroke with three quadratic curves and a centre
   * dot — pure ornament, `aria-hidden`.
   */
  const SWASH_PATH = 'M2 5 Q12 2 24 5 Q40 9 60 5 Q80 1 96 5 Q108 8 118 5';

  interface Props {
    /** Stroke width in CSS pixels. Handoff scales to ~2.5× the title width. */
    width?: number;
    /** Stroke colour token. */
    color?: SwashColor;
  }

  const classes = computed(() => ['app-swash', `app-swash--${props.color}`]);
</script>

<template>
  <span :class="classes">
    <svg
      :width="props.width"
      height="10"
      viewBox="0 0 120 10"
      role="presentation"
      aria-hidden="true"
      xmlns="http://www.w3.org/2000/svg"
      class="app-swash__svg"
    >
      <path :d="SWASH_PATH" class="app-swash__path" />
      <circle cx="60" cy="5" r="1.6" class="app-swash__dot" />
    </svg>
  </span>
</template>

<style lang="scss" scoped>
  .app-swash {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;

    // ── SVG layout ────────────────────────────────────────────────────────────

    &__svg {
      display: block;
      overflow: visible;
    }

    // ── Calligraphic stroke ──────────────────────────────────────────────────

    &__path {
      fill: none;
      stroke: currentColor;
      stroke-width: 1.2;
      stroke-linecap: round;
    }

    &__dot {
      fill: currentColor;
      stroke: none;
    }

    // ── Color modifiers ──────────────────────────────────────────────────────

    &--brass {
      color: var(--brand-brass);
    }

    &--brass-deep {
      color: var(--brand-brass-deep);
    }

    &--brass-light {
      color: var(--brand-brass-light);
    }
  }
</style>
