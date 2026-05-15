<script setup lang="ts">
  import { computed } from 'vue';

  import AppSwash from '../AppSwash/AppSwash.vue';

  /**
   * Brand lockup — "CORIOLIS" in Forum display + paired swash + "COMPANION"
   * eyebrow in Inter. Used by landing hero, dashboard hero, and the
   * session-join card.
   *
   * Handoff reference: `primitives.jsx:L263-L290` + `COMPONENTS.md:L75-L80`.
   *
   * Typography:
   * - brand: Forum display, uppercase, brass-light, line-height 1,
   *   tracking 0.1em (mirrors the handoff's `cor-track-10`).
   * - eyebrow: Inter body, uppercase, brass, font-size = `size * 0.18`,
   *   letter-spacing 0.4em — auto-scaled from `size`.
   * - swash: brass underline at `size * 2.4` width — matches the handoff's
   *   2.4× ratio for the brand swash beneath the wordmark.
   *
   * The lockup is presented as a single `role="img"` to assistive tech with a
   * combined accessible name so the brand reads as one unit rather than two
   * disconnected strings.
   */

  interface Props {
    /**
     * Brand font-size in CSS pixels. Eyebrow + swash auto-scale.
     * Handoff defaults: 48 (compact), 88 (landing hero).
     */
    size?: number;
    /** Brand text — defaults to "Coriolis". Override for stress-tests only. */
    brand?: string;
    /** Eyebrow text — defaults to "Companion". Localizable. */
    eyebrow?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    size: 48,
    brand: 'Coriolis',
    eyebrow: 'Companion',
  });
  /** Eyebrow / brand size ratio from the handoff (`size * 0.18`). */
  const EYEBROW_RATIO = 0.18;
  /** Swash / brand width ratio from the handoff (`size * 2.4`). */
  const SWASH_RATIO = 2.4;
  /** Floor for eyebrow font size so small lockups stay legible. */
  const EYEBROW_MIN_PX = 10;

  const eyebrowSize = computed(() => Math.max(props.size * EYEBROW_RATIO, EYEBROW_MIN_PX));

  const swashWidth = computed(() => props.size * SWASH_RATIO);

  const cssVars = computed(() => ({
    '--app-wordmark-brand-size': `${String(props.size)}px`,
    '--app-wordmark-eyebrow-size': `${String(eyebrowSize.value)}px`,
  }));

  const accessibleLabel = computed(() => `${props.brand} ${props.eyebrow}`);
</script>

<template>
  <div
    class="app-wordmark"
    :style="cssVars"
    role="img"
    :aria-label="accessibleLabel"
    data-testid="app-wordmark"
  >
    <span class="app-wordmark__brand" aria-hidden="true">{{ props.brand }}</span>
    <AppSwash :width="swashWidth" color="brass" class="app-wordmark__swash" />
    <span class="app-wordmark__eyebrow" aria-hidden="true">{{ props.eyebrow }}</span>
  </div>
</template>

<style lang="scss" scoped>
  .app-wordmark {
    display: inline-flex;
    flex-direction: column;
    align-items: center;
    gap: var(--space-1);
    margin: 0;

    // ── Brand line ───────────────────────────────────────────────────────────

    &__brand {
      font-family: var(--font-display);
      font-weight: var(--fw-regular);
      font-size: var(--app-wordmark-brand-size);
      line-height: 1;
      letter-spacing: 0.1em;
      text-transform: uppercase;
      color: var(--brand-brass-light);
    }

    // ── Swash flourish ───────────────────────────────────────────────────────

    &__swash {
      // AppSwash already renders the stroke colour; we just align it.
      margin-top: var(--space-1);
    }

    // ── Inter eyebrow ────────────────────────────────────────────────────────

    &__eyebrow {
      font-family: var(--font-body);
      font-weight: var(--fw-regular);
      font-size: var(--app-wordmark-eyebrow-size);
      line-height: 1;
      letter-spacing: 0.4em;
      // The 0.4em tracking pushes the last glyph one cell to the right —
      // offset with text-indent so the eyebrow stays optically centred under
      // the swash.
      text-indent: 0.4em;
      text-transform: uppercase;
      color: var(--brand-brass);
      margin-top: var(--space-1);
    }
  }
</style>
