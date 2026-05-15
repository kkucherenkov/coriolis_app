<script setup lang="ts">
  import { computed } from 'vue';

  type StarSize = 'sm' | 'md' | 'lg';
  type StarColor = 'brass' | 'brass-deep' | 'brass-light';
  type StarVariant = 'filled' | 'outlined';

  /**
   * Eight-pointed star (rub el hizb / Coriolis decorative motif).
   *
   * Geometry per the handoff (`/screens/primitives.jsx` `StarOrnament` /
   * `StarFilled`): two squares — one normal, one rotated 45° around the
   * centre — with an optional centre dot. The two squares overlap to form
   * the eight-pointed silhouette without resorting to a polygon path.
   *
   * Two `variant` modes:
   *
   * - `filled` (default) — rects fill with currentColor at 18 % opacity +
   *   the same stroke; centre dot at r=2. Used for hero ornaments, panel
   *   accents, dashboard card glyphs.
   * - `outlined` — rects are stroke-only (`fill: none`); centre dot at
   *   r=2.2. Used for empty-state ornaments, share-viewer watermarks,
   *   chat empty-state icons.
   *
   * Closes T-AUDIT-2026-05-15-STAR-VARIANT and resolves the
   * "drift-documented" row in `HANDOFF_NAME_MAP.md` §Atom-layer.
   */

  interface Props {
    size?: StarSize;
    color?: StarColor;
    opacity?: number;
    variant?: StarVariant;
  }

  const props = withDefaults(defineProps<Props>(), {
    size: 'md',
    color: 'brass',
    opacity: 1,
    variant: 'filled',
  });

  // Pixel dimensions per size token. Mirrors the three sizes in the brief:
  // sm=16px, md=24px, lg=56px.
  const SIZE_PX: Record<StarSize, number> = {
    sm: 16,
    md: 24,
    lg: 56,
  };

  const sizePx = computed(() => SIZE_PX[props.size]);
  const centreRadius = computed(() => (props.variant === 'outlined' ? 2.2 : 2));

  const classes = computed(() => [
    'app-star-ornament',
    `app-star-ornament--${props.size}`,
    `app-star-ornament--${props.color}`,
    `app-star-ornament--${props.variant}`,
  ]);
</script>

<template>
  <span :class="classes" :style="opacity !== 1 ? { opacity } : undefined">
    <svg
      :width="sizePx"
      :height="sizePx"
      viewBox="0 0 32 32"
      role="presentation"
      aria-hidden="true"
      xmlns="http://www.w3.org/2000/svg"
      class="app-star-ornament__svg"
    >
      <!-- Two overlapping squares — variant decides fill vs stroke-only. -->
      <g class="app-star-ornament__rects">
        <rect x="6" y="6" width="20" height="20" />
        <rect x="6" y="6" width="20" height="20" transform="rotate(45 16 16)" />
      </g>
      <!-- Centre dot — always filled with currentColor. -->
      <circle cx="16" cy="16" :r="centreRadius" class="app-star-ornament__dot" />
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

    // ── Shape — currentColor drives both stroke and fill ─────────────────────

    &__rects {
      // Both rects share the same paint rules per the active variant.
      fill: currentColor;
      stroke: currentColor;
    }

    &__dot {
      fill: currentColor;
      stroke: none;
    }

    // ── Variant: filled (handoff `StarFilled`) ───────────────────────────────

    &--filled .app-star-ornament__rects {
      fill-opacity: 0.18;
      stroke-width: 1;
    }

    // ── Variant: outlined (handoff `StarOrnament`) ───────────────────────────

    &--outlined .app-star-ornament__rects {
      fill: none;
      stroke-width: 1.2;
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
