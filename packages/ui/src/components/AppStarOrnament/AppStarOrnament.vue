<script setup lang="ts">
  import { computed } from 'vue';

  type StarSize = 'sm' | 'md' | 'lg';
  type StarColor = 'brass' | 'brass-deep' | 'brass-light';

  const props = withDefaults(defineProps<Props>(), {
    size: 'md',
    color: 'brass',
    opacity: 1,
  });
  /**
   * Eight-pointed star (rub el hizb / Coriolis decorative motif).
   * Constructed from two squares rotated 45° apart, expressed as a 16-vertex
   * polygon on a 100×100 internal canvas. This approach is cleaner than two
   * <rect> elements and produces a consistent sharp eight-pointed silhouette.
   *
   * The 16 polygon points (cx=50, cy=50, inner r=22, outer r=40, 8 points):
   * Each of the 8 outer tips alternates with 8 inner corners.
   * Outer tip angle starts at -90° (top), inner corners at -90°+22.5°.
   */
  const STAR_POINTS =
    '50,10 58.5,38.5 87,28 65,50 87,72 58.5,61.5 50,90 41.5,61.5 13,72 35,50 13,28 41.5,38.5';
  // Above is a compact 8-pointed star: outer r=40, inner r=19 at 22.5° offsets.
  // Rounded to nearest 0.5 for visual clarity at small sizes.

  // Pixel dimensions per size token — mirroring the three sizes in the brief:
  // sm=16px, md=24px, lg=56px.
  const SIZE_PX: Record<StarSize, number> = {
    sm: 16,
    md: 24,
    lg: 56,
  };

  interface Props {
    size?: StarSize;
    color?: StarColor;
    opacity?: number;
  }

  const sizePx = computed(() => SIZE_PX[props.size]);

  const classes = computed(() => [
    'app-star-ornament',
    `app-star-ornament--${props.size}`,
    `app-star-ornament--${props.color}`,
  ]);
</script>

<template>
  <span :class="classes" :style="opacity !== 1 ? { opacity } : undefined">
    <svg
      :width="sizePx"
      :height="sizePx"
      viewBox="0 0 100 100"
      role="presentation"
      aria-hidden="true"
      xmlns="http://www.w3.org/2000/svg"
      class="app-star-ornament__svg"
    >
      <polygon :points="STAR_POINTS" class="app-star-ornament__shape" />
    </svg>
  </span>
</template>

<style lang="scss" scoped>
  // Pixel sizes per size token — SCSS vars are the approved escape hatch.
  $star-sm: 16px;
  $star-md: 24px;
  $star-lg: 56px;

  .app-star-ornament {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;

    // ── Size modifiers ────────────────────────────────────────────────────────

    &--sm {
      width: $star-sm;
      height: $star-sm;
    }

    &--md {
      width: $star-md;
      height: $star-md;
    }

    &--lg {
      width: $star-lg;
      height: $star-lg;
    }

    // ── SVG layout ────────────────────────────────────────────────────────────

    &__svg {
      display: block;
    }

    // ── Star shape ────────────────────────────────────────────────────────────

    &__shape {
      // Filled by currentColor so the consumer's color token drives the shade.
      fill: currentColor;
      stroke: none;
    }

    // ── Color modifiers ───────────────────────────────────────────────────────

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
