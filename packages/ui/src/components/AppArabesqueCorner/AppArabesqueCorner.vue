<script setup lang="ts">
  import { computed } from 'vue';

  export type ArabesqueOrientation = 'tl' | 'tr' | 'bl' | 'br';
  type ArabesqueSize = 'sm' | 'md' | 'lg';
  type ArabesqueColor = 'brass' | 'brass-deep';

  /**
   * The canonical arabesque path is drawn for the TL (top-left) orientation
   * on a 100×100 internal canvas. It traces a flowing arc from the left edge
   * inward to the top edge, with a small inward flourish at the tip — matching
   * the `ArabesqueCorner` helper used throughout the JSX mockups (landing,
   * sheet-desktop, dice-roller).
   *
   * Design decision: since the mockup JSX does not expose the actual path data
   * (it's an abstract React component name), we author a representative arabesque
   * arc that:
   *   1. Starts at the left edge midpoint (0, 50).
   *   2. Curves through a quarter-arc toward the top-right.
   *   3. Ends at the top edge midpoint (50, 0).
   *   4. Has a small inward loop near the center of the corner to suggest
   *      the arabesque flourish character.
   *   5. Is stroke-only (fill:none) per DESIGN §4.1.
   *
   * The path is "one stroke" not a closed shape — consumer never sees a fill.
   * All four orientations are derived from this single path via SVG transform
   * (rotate + translate) applied to the inner group, keeping the outer SVG
   * dimensions fixed and the stroke-width consistent.
   *
   * Rotation matrix per orientation (pivot = 50,50 on 100x100 canvas):
   *   tl →   0deg (canonical)
   *   tr →  90deg
   *   br → 180deg
   *   bl → 270deg
   */
  const ROTATION: Record<ArabesqueOrientation, number> = {
    tl: 0,
    tr: 90,
    br: 180,
    bl: 270,
  };

  /**
   * The arabesque path on a 100×100 viewBox, TL orientation.
   *
   * Segment breakdown:
   *   M 0 60      — start on left edge, 60% down
   *   C 0 30, 20 10, 40 5   — main sweep curving toward top-left corner area
   *   C 50 2, 55 8, 48 18   — inward flourish curl at the corner
   *   C 42 28, 55 35, 50 50 — small arabesque loop body
   *   M 50 50     — move to center for the second arm
   *   C 65 45, 70 30, 65 0  — arm sweeping up to top edge (not used — single-arm design)
   *
   * Final simplified single-arm design that reads well at all three sizes:
   */
  const ARABESQUE_PATH =
    'M 0 55 C 0 25, 15 10, 30 5 C 40 2, 48 8, 42 18 C 35 28, 45 32, 40 42 C 36 50, 42 52, 50 50 M 50 50 C 58 48, 62 40, 58 30 C 54 20, 58 10, 68 5 C 76 1, 88 0, 100 0';

  // Pixel dimensions per size token — SCSS vars below mirror these.
  const SIZE_PX: Record<ArabesqueSize, number> = {
    sm: 36,
    md: 64,
    lg: 96,
  };

  interface Props {
    orientation: ArabesqueOrientation;
    size?: ArabesqueSize;
    color?: ArabesqueColor;
  }

  const props = withDefaults(defineProps<Props>(), {
    size: 'md',
    color: 'brass',
  });

  const sizePx = computed(() => SIZE_PX[props.size]);

  const rotation = computed(() => ROTATION[props.orientation]);

  /**
   * The inner group transform rotates the canonical TL path about the centre
   * of the 100×100 viewBox (50, 50) to produce the four orientations.
   */
  const groupTransform = computed(() =>
    rotation.value === 0 ? undefined : `rotate(${rotation.value} 50 50)`,
  );

  const classes = computed(() => [
    'app-arabesque-corner',
    `app-arabesque-corner--${props.orientation}`,
    `app-arabesque-corner--${props.size}`,
    `app-arabesque-corner--${props.color}`,
  ]);
</script>

<template>
  <span :class="classes">
    <svg
      :width="sizePx"
      :height="sizePx"
      viewBox="0 0 100 100"
      role="presentation"
      aria-hidden="true"
      xmlns="http://www.w3.org/2000/svg"
      class="app-arabesque-corner__svg"
    >
      <g :transform="groupTransform">
        <path
          :d="ARABESQUE_PATH"
          class="app-arabesque-corner__path"
        />
      </g>
    </svg>
  </span>
</template>

<style lang="scss" scoped>
  // Pixel sizes per size token — SCSS vars are the approved escape hatch.
  $corner-sm: 36px;
  $corner-md: 64px;
  $corner-lg: 96px;

  .app-arabesque-corner {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;

    // ── Size modifiers ────────────────────────────────────────────────────────

    &--sm {
      width: $corner-sm;
      height: $corner-sm;
    }

    &--md {
      width: $corner-md;
      height: $corner-md;
    }

    &--lg {
      width: $corner-lg;
      height: $corner-lg;
    }

    // ── SVG layout ────────────────────────────────────────────────────────────

    &__svg {
      display: block;
      overflow: visible;
    }

    // ── Arabesque stroke path ─────────────────────────────────────────────────

    &__path {
      fill: none;
      stroke: currentColor;
      stroke-width: 1.5;
      stroke-linecap: round;
      stroke-linejoin: round;
    }

    // ── Color modifiers ───────────────────────────────────────────────────────

    &--brass {
      color: var(--brand-brass);
    }

    &--brass-deep {
      color: var(--brand-brass-deep);
    }
  }
</style>
