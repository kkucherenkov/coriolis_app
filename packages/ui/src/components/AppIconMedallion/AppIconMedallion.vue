<script setup lang="ts">
  import { computed, useId } from 'vue';

  /**
   * Coriolis Icon medallion — Forum monogram letter inside a radial-gradient
   * brass disc with concentric astrolabe rings and 16 tick marks. Used on
   * the wizard "Pick your Icon" step (step 5 in the canonical 8-step
   * inventory) and anywhere else a player's chosen Icon is celebrated.
   *
   * Handoff reference: `primitives.jsx:L54-L100` + `COMPONENTS.md:L45-L55`.
   *
   * **Distinct from `AppIconCoriolis`** — that component renders the Nine
   * Icons as SVG glyphs from a sprite. This atom renders the same Icons as
   * a monogram letter on a brass medallion, the celebratory presentation
   * used in the wizard. Both atoms ship side-by-side; consumers pick by
   * surface (sprite for inline / dense, medallion for hero / picker).
   *
   * The `glow` prop layers a mystic-teal halo behind the disc to mark a
   * selected Icon in the picker grid (matches the handoff `0 0 24px 4px
   * rgba(43,163,160,0.55)` + a radial-gradient bloom under the disc).
   */

  interface Props {
    /** Single-letter monogram of the Nine Icons (e.g. `"T"` for The Traveler). */
    letter: string;
    /** Medallion diameter in CSS pixels. Handoff defaults: 48 / 56 / 60 / 64. */
    size?: number;
    /** When `true`, layers a mystic-teal halo to mark the selected Icon. */
    glow?: boolean;
    /**
     * Accessible label for assistive tech (e.g. `"The Traveler"`). When
     * omitted, the medallion is treated as decorative (`aria-hidden`).
     */
    label?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    size: 64,
    glow: false,
    label: undefined,
  });

  /** Stable, SSR-safe gradient id per instance — avoids `#mgT` collisions. */
  const gradientId = `app-icon-medallion-grad-${useId()}`;

  /** 16 astrolabe ticks at the outer edge of the disc, in viewBox coords. */
  const tickMarks = computed(() => {
    const cx = 32;
    const cy = 32;
    const rOuter = 28;
    const rInner = 26;
    return Array.from({ length: 16 }, (_, i) => {
      const angle = (i / 16) * Math.PI * 2;
      const cosA = Math.cos(angle);
      const sinA = Math.sin(angle);
      return {
        x1: cx + cosA * rOuter,
        y1: cy + sinA * rOuter,
        x2: cx + cosA * rInner,
        y2: cy + sinA * rInner,
      };
    });
  });

  const letterFontSize = computed(() => props.size * 0.5);

  const rootClasses = computed(() => [
    'app-icon-medallion',
    { 'app-icon-medallion--glow': props.glow },
  ]);

  const cssVars = computed(() => ({
    '--app-icon-medallion-size': `${String(props.size)}px`,
  }));

  const isDecorative = computed(() => !props.label);
</script>

<template>
  <span
    :class="rootClasses"
    :style="cssVars"
    :role="isDecorative ? undefined : 'img'"
    :aria-label="label"
    :aria-hidden="isDecorative ? 'true' : undefined"
    data-testid="app-icon-medallion"
  >
    <span v-if="glow" class="app-icon-medallion__halo" aria-hidden="true" />
    <svg
      class="app-icon-medallion__svg"
      :width="size"
      :height="size"
      viewBox="0 0 64 64"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
    >
      <defs>
        <radialGradient :id="gradientId" cx="50%" cy="40%" r="60%">
          <stop offset="0%" stop-color="var(--brand-brass-light)" />
          <stop offset="60%" stop-color="var(--brand-brass)" />
          <stop offset="100%" stop-color="var(--brand-brass-deep)" />
        </radialGradient>
      </defs>
      <circle cx="32" cy="32" r="30" :fill="`url(#${gradientId})`" />
      <circle
        class="app-icon-medallion__ring app-icon-medallion__ring--outer"
        cx="32"
        cy="32"
        r="28"
        fill="none"
      />
      <circle
        class="app-icon-medallion__ring app-icon-medallion__ring--inner"
        cx="32"
        cy="32"
        r="24"
        fill="none"
      />
      <line
        v-for="(t, i) in tickMarks"
        :key="i"
        class="app-icon-medallion__tick"
        :x1="t.x1"
        :y1="t.y1"
        :x2="t.x2"
        :y2="t.y2"
      />
      <text
        class="app-icon-medallion__letter"
        x="32"
        y="40"
        text-anchor="middle"
        :font-size="letterFontSize"
      >
        {{ letter }}
      </text>
    </svg>
  </span>
</template>

<style lang="scss" scoped>
  // Halo expansion outside the disc — handoff: `inset: -6` for any size.
  $halo-inset: 6px;
  // Ring + tick stroke widths from the handoff (`0.6` outer, `0.4` inner,
  // `0.5` tick). Sub-px values mirror the SVG-coord units, not CSS px.
  $ring-outer-stroke: 0.6px;
  $ring-inner-stroke: 0.4px;
  $tick-stroke: 0.5px;

  .app-icon-medallion {
    position: relative;
    display: inline-flex;
    width: var(--app-icon-medallion-size);
    height: var(--app-icon-medallion-size);
    flex-shrink: 0;

    // ── Selected halo (mystic teal) ───────────────────────────────────────────
    // Matches handoff `boxShadow: '0 0 24px 4px rgba(43,163,160,0.55)'` plus
    // a radial bloom under the disc. Token: `--shadow-icon-glow`.

    &__halo {
      position: absolute;
      inset: #{-$halo-inset};
      border-radius: 50%;
      box-shadow: var(--shadow-icon-glow);
      background: radial-gradient(
        circle,
        color-mix(in srgb, var(--state-mystic-teal) 25%, transparent),
        transparent 70%
      );
      pointer-events: none;
    }

    &--glow {
      // Halo lives in its own pseudo-layer; nothing extra on the disc.
    }

    &__svg {
      position: relative;
      display: block;
    }

    // ── Astrolabe rings ───────────────────────────────────────────────────────
    // Stroked in brass-shadow so they read as engraved on the brass disc.

    &__ring {
      stroke: var(--brand-brass-shadow);

      &--outer {
        stroke-width: $ring-outer-stroke;
      }

      &--inner {
        stroke-width: $ring-inner-stroke;
      }
    }

    &__tick {
      stroke: var(--brand-brass-shadow);
      stroke-width: $tick-stroke;
    }

    // ── Monogram letter ───────────────────────────────────────────────────────

    &__letter {
      font-family: var(--font-display);
      font-weight: var(--fw-regular);
      letter-spacing: 0.04em;
      // Dark navy text reads as cast into the brass disc — handoff uses
      // surface-void (#0B0E2C) for the same effect.
      fill: var(--surface-void);
    }
  }

  // Reduced-motion: the medallion has no motion of its own. The glow halo
  // is static. Declared so any future shimmer/rotate stays guarded.
  @media (prefers-reduced-motion: reduce) {
    .app-icon-medallion__halo {
      transition: none;
      animation: none;
    }
  }
</style>
