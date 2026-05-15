<script setup lang="ts">
  import { computed } from 'vue';

  import AppSwash from '../AppSwash/AppSwash.vue';

  type PanelTitleSize = 'sm' | 'md' | 'lg';
  type HeadingLevel = 'h2' | 'h3' | 'h4';

  const props = withDefaults(defineProps<Props>(), {
    size: 'md',
    level: 'h3',
  });

  /**
   * Forum heading + paired calligraphic swash — the single source of truth for
   * panel headers across sheets, ship sheet, wizard, dashboard, GM session.
   *
   * Handoff reference: `primitives.jsx:L230-L241` + `COMPONENTS.md:L82-L89`.
   *
   * Typography: Forum (display) at 16 / 22 / 28 px (sm / md / lg) with the
   * project's display tracking of 0.04em. The 16 / 22 / 28 scale is mandated
   * by the handoff and does not align 1-for-1 with our `--type-display-*` role
   * tokens (20 / 28 / 36) — so the family, weight, color, and line-height come
   * from tokens while font-size lives as a documented per-component SCSS var
   * applied via BEM size modifier in the style block below.
   */

  /** Swash widths from handoff: lg=110, sm/md=70. */
  const SWASH_WIDTH: Record<PanelTitleSize, number> = {
    sm: 70,
    md: 70,
    lg: 110,
  };

  interface Props {
    /** Visual size — controls font-size and swash width. */
    size?: PanelTitleSize;
    /** Semantic heading level; defaults to h3 to slot under page h1/h2. */
    level?: HeadingLevel;
  }

  const swashWidth = computed(() => SWASH_WIDTH[props.size]);

  const rootClasses = computed(() => ['app-panel-title', `app-panel-title--${props.size}`]);

  const headingClass = 'app-panel-title__heading';
</script>

<template>
  <div :class="rootClasses">
    <component :is="props.level" :class="headingClass">
      <slot />
    </component>
    <AppSwash :width="swashWidth" color="brass" />
  </div>
</template>

<style lang="scss" scoped>
  // Handoff-mandated panel-title sizes. Documented in the script block — they
  // intentionally diverge from --type-display-* role sizes (20/28/36).
  $title-sm: 16px;
  $title-md: 22px;
  $title-lg: 28px;

  .app-panel-title {
    display: inline-flex;
    flex-direction: column;
    align-items: flex-start;
    gap: var(--space-1);
    margin: 0;

    // ── Heading text ──────────────────────────────────────────────────────────

    &__heading {
      margin: 0;
      font-family: var(--font-display);
      font-weight: var(--fw-regular);
      line-height: 1.2;
      letter-spacing: 0.04em;
      color: var(--brand-brass-light);
    }

    // ── Size modifiers ────────────────────────────────────────────────────────

    &--sm .app-panel-title__heading {
      font-size: $title-sm;
    }

    &--md .app-panel-title__heading {
      font-size: $title-md;
    }

    &--lg .app-panel-title__heading {
      font-size: $title-lg;
    }
  }
</style>
