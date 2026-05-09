<script setup lang="ts">
  import { computed } from 'vue';

  type DieValue = 1 | 2 | 3 | 4 | 5 | 6;
  type DieState = 'normal' | 'hit' | 'pushed' | 'failed';
  type DieSize = 'sm' | 'md' | 'lg';

  const props = withDefaults(defineProps<Props>(), {
    state: 'normal',
    size: 'md',
    ariaLabel: undefined,
  });

  // SVG canvas dimensions per size.
  // SCSS variables below mirror these for px-only layout; kept here for SVG attrs.
  const SIZE_PX: Record<DieSize, number> = {
    sm: 24,
    md: 32,
    lg: 48,
  };

  /**
   * Pip positions expressed as fractions of the face dimension.
   * The SVG viewBox is always 100×100; actual rendered size is controlled by
   * the width/height attrs. Radius is scaled proportionally.
   *
   * Layout convention (d6 canonical):
   *   1: centre
   *   2: top-right + bottom-left diagonal
   *   3: diagonal 2 + centre
   *   4: four corners
   *   5: four corners + centre
   *   6: two columns of 3 (top/mid/bot left, top/mid/bot right)
   */
  interface Point {
    cx: number;
    cy: number;
  }

  const TL: Point = { cx: 28, cy: 28 };
  const TR: Point = { cx: 72, cy: 28 };
  const ML: Point = { cx: 28, cy: 50 };
  const MR: Point = { cx: 72, cy: 50 };
  const BL: Point = { cx: 28, cy: 72 };
  const BR: Point = { cx: 72, cy: 72 };
  const C: Point = { cx: 50, cy: 50 };

  const PIP_MAP: Record<DieValue, Point[]> = {
    1: [C],
    2: [TR, BL],
    3: [TR, C, BL],
    4: [TL, TR, BL, BR],
    5: [TL, TR, C, BL, BR],
    6: [TL, TR, ML, MR, BL, BR],
  };

  const VALID_VALUES: DieValue[] = [1, 2, 3, 4, 5, 6];

  interface Props {
    value: DieValue;
    state?: DieState;
    size?: DieSize;
    ariaLabel?: string;
  }

  if (!VALID_VALUES.includes(props.value)) {
    console.warn(`[AppDie] Invalid value "${props.value}". Must be 1–6.`);
  }

  const pips = computed<Point[]>(() => PIP_MAP[props.value] ?? []);

  const sizePx = computed(() => SIZE_PX[props.size]);

  const computedAriaLabel = computed(() => {
    if (props.ariaLabel) return props.ariaLabel;
    const stateLabel =
      props.state === 'normal'
        ? ''
        : ` — ${props.state.charAt(0).toUpperCase() + props.state.slice(1)}`;
    return `Die showing ${props.value}${stateLabel}`;
  });

  const classes = computed(() => [
    'app-die',
    `app-die--${props.size}`,
    `app-die--state-${props.state}`,
  ]);

  // Filter ids must be unique per instance when multiple dice render on page.
  // Using a stable derivation from props keeps SSR-safe (no crypto.randomUUID).
  const filterId = computed(() => `app-die-glow-${props.state}-${props.value}-${props.size}`);
  const glowId = computed(() => `app-die-halo-${props.state}-${props.value}-${props.size}`);
</script>

<template>
  <span :class="classes">
    <svg
      :width="sizePx"
      :height="sizePx"
      viewBox="0 0 100 100"
      role="img"
      :aria-label="computedAriaLabel"
      xmlns="http://www.w3.org/2000/svg"
      class="app-die__svg"
    >
      <defs>
        <!-- Hit: mystic-teal glow filter -->
        <filter v-if="state === 'hit'" :id="filterId" x="-30%" y="-30%" width="160%" height="160%">
          <feGaussianBlur stdDeviation="3" result="blur" />
          <feFlood flood-color="var(--state-mystic-teal)" flood-opacity="0.6" result="color" />
          <feComposite in="color" in2="blur" operator="in" result="teal-glow" />
          <feMerge>
            <feMergeNode in="teal-glow" />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>

        <!-- Pushed: crimson danger-pulse halo filter -->
        <filter
          v-if="state === 'pushed'"
          :id="filterId"
          x="-30%"
          y="-30%"
          width="160%"
          height="160%"
        >
          <feGaussianBlur stdDeviation="4" result="blur" />
          <feFlood flood-color="var(--state-crimson)" flood-opacity="0.5" result="color" />
          <feComposite in="color" in2="blur" operator="in" result="crimson-glow" />
          <feMerge>
            <feMergeNode in="crimson-glow" />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>
      </defs>

      <!-- Die face body -->
      <rect
        x="6"
        y="6"
        width="88"
        height="88"
        rx="14"
        ry="14"
        class="app-die__face"
        :filter="state === 'hit' || state === 'pushed' ? `url(#${filterId})` : undefined"
      />

      <!-- Pips -->
      <circle
        v-for="(pip, i) in pips"
        :key="i"
        :cx="pip.cx"
        :cy="pip.cy"
        r="7"
        class="app-die__pip"
      />

      <!-- Halo glow overlay for hit state (border ring) -->
      <rect
        v-if="state === 'hit'"
        :id="glowId"
        x="6"
        y="6"
        width="88"
        height="88"
        rx="14"
        ry="14"
        class="app-die__halo"
      />
    </svg>
  </span>
</template>

<style lang="scss" scoped>
  // SVG canvas dimensions per size — SCSS vars are the approved escape hatch
  // for raw-px layout values in component CSS.
  $die-sm: 24px;
  $die-md: 32px;
  $die-lg: 48px;

  .app-die {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;

    // ── Size modifiers ────────────────────────────────────────────────────────

    &--sm {
      width: $die-sm;
      height: $die-sm;
    }

    &--md {
      width: $die-md;
      height: $die-md;
    }

    &--lg {
      width: $die-lg;
      height: $die-lg;
    }

    // ── SVG layout ────────────────────────────────────────────────────────────

    &__svg {
      display: block;
      overflow: visible; // allow glow filter to bleed outside viewBox
    }

    // ── Die face ──────────────────────────────────────────────────────────────

    &__face {
      fill: var(--surface-night);
      stroke: var(--brand-brass);
      stroke-width: 2;
    }

    // ── Pips ──────────────────────────────────────────────────────────────────

    &__pip {
      fill: var(--brand-brass-light);
    }

    // ── Halo ring (hit state) ─────────────────────────────────────────────────

    &__halo {
      fill: none;
      stroke: var(--state-mystic-teal);
      stroke-width: 2.5;
      opacity: 0.8;
    }

    // ── State: normal ─────────────────────────────────────────────────────────

    &--state-normal {
      .app-die__face {
        stroke: var(--brand-brass);
      }

      .app-die__pip {
        fill: var(--brand-brass-light);
      }
    }

    // ── State: hit ────────────────────────────────────────────────────────────

    &--state-hit {
      .app-die__face {
        stroke: var(--brand-brass-light);
      }

      .app-die__pip {
        fill: var(--state-mystic-teal);
      }
    }

    // ── State: pushed ─────────────────────────────────────────────────────────

    &--state-pushed {
      .app-die__face {
        stroke: var(--state-crimson);
      }

      .app-die__pip {
        fill: var(--brand-brass-light);
      }
    }

    // ── State: failed ─────────────────────────────────────────────────────────

    &--state-failed {
      .app-die__face {
        stroke: var(--state-crimson);
      }

      .app-die__pip {
        fill: var(--state-crimson-bright);
      }
    }
  }
</style>
