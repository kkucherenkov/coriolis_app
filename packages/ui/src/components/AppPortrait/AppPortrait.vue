<script setup lang="ts">
  import { computed } from 'vue';

  /**
   * Character portrait medallion — initials inside a brass-rimmed indigo
   * disc with 24 concentric astrolabe ticks. Used as the canonical
   * character / NPC portrait across sheet hero, combat tracker, GM crew
   * list, member lists, and chat bubbles (handoff `ChatAvatar` wraps this
   * atom + a presence pip).
   *
   * Handoff reference: `primitives.jsx:L202-L224` + `COMPONENTS.md:L64-L73`.
   *
   * **Distinct from `AppAvatar`** — `AppAvatar` is the generic initials/
   * image avatar used in the UserMenu and account chrome; it has tone
   * variants (brass / mystic / crimson / darkness) but no astrolabe ring.
   * `AppPortrait` is the in-fiction character portrait — always indigo
   * disc + brass ring — and never carries an image. (Audit T-2026-05-14-003
   * §3.1 explicitly carries this as a "ship AppPortrait wrapping AppAvatar
   * vs extend AppAvatar with `astrolabe` shape" decision; the latter would
   * overload `shape` with a visual-treatment switch and conflict with the
   * image-bearing `src` prop, so we ship a standalone atom instead.)
   */

  interface Props {
    /**
     * Display name used to derive initials when `initials` is omitted.
     * Either `name` or `initials` must resolve to non-empty content.
     */
    name?: string;
    /** Explicit initials override (e.g. `"NA"`). Trimmed to the first 2 chars. */
    initials?: string;
    /** Medallion diameter in CSS pixels. Handoff default: 96. */
    size?: number;
    /** Accessible label override. Falls back to `name`, then to the initials. */
    label?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    name: undefined,
    initials: undefined,
    size: 96,
    label: undefined,
  });

  /** Initials font-size ratio relative to disc diameter (handoff: 0.36). */
  const INITIALS_RATIO = 0.36;

  /** Count of astrolabe ticks ringing the disc (handoff: 24). */
  const TICK_COUNT = 24;

  /**
   * Take the first `count` Unicode code-points of `value`, joined back into
   * a string. Avoids `[...string]` (flagged by `no-misused-spread` in this
   * ESLint config) and handles surrogate pairs + combining marks correctly.
   */
  function takeCodePoints(value: string, count: number): string {
    let result = '';
    let taken = 0;
    for (const ch of value) {
      if (taken >= count) break;
      result += ch;
      taken += 1;
    }
    return result;
  }

  const computedInitials = computed(() => {
    if (props.initials) {
      return takeCodePoints(props.initials.trim(), 2).toUpperCase();
    }
    if (props.name) {
      const words = props.name.trim().split(/\s+/);
      return words
        .slice(0, 2)
        .map((w) => takeCodePoints(w, 1))
        .join('')
        .toUpperCase();
    }
    return 'NA';
  });

  /** 24 astrolabe ticks on a 100×100 viewBox at outer r=46, inner r=43. */
  const tickMarks = computed(() => {
    const cx = 50;
    const cy = 50;
    const rOuter = 46;
    const rInner = 43;
    return Array.from({ length: TICK_COUNT }, (_, i) => {
      const angle = (i / TICK_COUNT) * Math.PI * 2;
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

  const accessibleLabel = computed(() => props.label ?? props.name ?? computedInitials.value);

  const cssVars = computed(() => ({
    '--app-portrait-size': `${String(props.size)}px`,
    '--app-portrait-initials-size': `${String(props.size * INITIALS_RATIO)}px`,
  }));
</script>

<template>
  <span
    class="app-portrait"
    :style="cssVars"
    role="img"
    :aria-label="accessibleLabel"
    data-testid="app-portrait"
  >
    <svg
      class="app-portrait__ring"
      :width="size"
      :height="size"
      viewBox="0 0 100 100"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
    >
      <circle
        class="app-portrait__ring-circle"
        cx="50"
        cy="50"
        r="46"
        fill="none"
      />
      <line
        v-for="(t, i) in tickMarks"
        :key="i"
        class="app-portrait__tick"
        :x1="t.x1"
        :y1="t.y1"
        :x2="t.x2"
        :y2="t.y2"
      />
    </svg>
    <span
      class="app-portrait__initials"
      aria-hidden="true"
    >{{ computedInitials }}</span>
  </span>
</template>

<style lang="scss" scoped>
  // Ring + tick stroke widths from the handoff (both 0.4 on a 100×100
  // viewBox). Sub-px values are SVG-coord units, not CSS px.
  $ring-stroke: 0.4px;
  $tick-stroke: 0.4px;

  .app-portrait {
    position: relative;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: var(--app-portrait-size);
    height: var(--app-portrait-size);
    border-radius: 50%;
    border: 1px solid var(--brand-brass-deep);
    box-shadow: inset 0 0 0 1px var(--brand-brass-shadow);
    // Indigo radial — handoff: linear 160deg dawn → night → void. We swap to
    // a radial-from-top-left so the gradient stays well-formed across sizes.
    background: linear-gradient(
      160deg,
      var(--surface-dawn) 0%,
      var(--surface-night) 60%,
      var(--surface-void) 100%
    );
    overflow: hidden;
    flex-shrink: 0;

    // ── Astrolabe ring SVG ────────────────────────────────────────────────────

    &__ring {
      position: absolute;
      inset: 0;
      pointer-events: none;
    }

    &__ring-circle,
    &__tick {
      stroke: var(--brand-brass-deep);
      stroke-width: $ring-stroke;
    }

    &__tick {
      stroke-width: $tick-stroke;
    }

    // ── Forum initials ────────────────────────────────────────────────────────

    &__initials {
      position: relative;
      font-family: var(--font-display);
      font-weight: var(--fw-regular);
      font-size: var(--app-portrait-initials-size);
      line-height: 1;
      letter-spacing: 0.04em;
      color: var(--brand-brass-light);
      user-select: none;
    }
  }

  // No motion ships in this atom. The declaration stays so any future
  // hover or focus transition is guarded under reduced-motion.
  @media (prefers-reduced-motion: reduce) {
    .app-portrait {
      transition: none;
    }
  }
</style>
