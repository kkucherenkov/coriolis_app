<script setup lang="ts">
  import { computed } from 'vue';

  export type ArabesqueOrientation = 'tl' | 'tr' | 'bl' | 'br';
  type ArabesqueSize = 'sm' | 'md' | 'lg';
  type ArabesqueColor = 'brass' | 'brass-deep';

  const props = withDefaults(defineProps<Props>(), {
    size: 'md',
    color: 'brass',
  });

  /**
   * The canonical arabesque corner ornament — drawn for the TL (top-left)
   * orientation on a 100×100 internal canvas. The geometry mirrors the
   * handoff helper in `specs/design/mockups/primitives.jsx` (the
   * `ArabesqueCorner` factory). It is composed of five glyphs:
   *
   *   1. An L-shaped corner border (`pathCorner`).
   *   2. An outer flowing curve sweeping from left edge down toward the
   *      top edge (`pathSweep`).
   *   3. A central loop suggesting the arabesque flourish (`pathLoop`).
   *   4. A small "X" of crossing ticks where the sweep meets the corner
   *      (`pathTicks`).
   *   5. Two end-cap dots at the visual ends of the sweep (`<circle>` x2).
   *
   * Coordinates are the original 64×64 helper scaled by 100/64 ≈ 1.5625 and
   * rounded to whole units, keeping the design crisp at the three exported
   * sizes (sm = 36, md = 64, lg = 96 CSS px).
   *
   * Rotation per orientation (pivot = 50,50 on the 100×100 canvas):
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

  // L-corner border running up the left edge then right along the top edge.
  const PATH_CORNER = 'M 3 34 L 3 3 L 34 3';
  // Outer sweep curving from the left edge inward toward the top edge.
  const PATH_SWEEP = 'M 3 47 Q 3 22, 22 13 Q 34 6, 47 3';
  // Central arabesque loop (the "leaf").
  const PATH_LOOP = 'M 13 25 Q 22 19, 28 19 Q 34 19, 34 25 Q 34 31, 28 31 Q 22 31, 22 25';
  // Small ticks bridging sweep ↔ corner — two short crossing strokes.
  const PATH_TICKS = 'M 22 6 L 28 13 M 34 13 L 41 6';

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

  const sizePx = computed(() => SIZE_PX[props.size]);

  const rotation = computed(() => ROTATION[props.orientation]);

  /**
   * The inner group transform rotates the canonical TL path about the centre
   * of the 100×100 viewBox (50, 50) to produce the four orientations.
   */
  const groupTransform = computed(() =>
    rotation.value === 0 ? undefined : `rotate(${String(rotation.value)} 50 50)`,
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
        <path :d="PATH_CORNER" class="app-arabesque-corner__path" />
        <path :d="PATH_SWEEP" class="app-arabesque-corner__path" />
        <path :d="PATH_LOOP" class="app-arabesque-corner__path" />
        <path :d="PATH_TICKS" class="app-arabesque-corner__path" />
        <circle cx="50" cy="3" r="2" class="app-arabesque-corner__dot" />
        <circle cx="3" cy="50" r="2" class="app-arabesque-corner__dot" />
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

    &__dot {
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
  }
</style>
