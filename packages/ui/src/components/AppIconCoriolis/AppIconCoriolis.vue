<script setup lang="ts">
  import { computed } from 'vue';

  export type IconCoriolisName =
    | 'lady-of-tears'
    | 'traveler'
    | 'messenger'
    | 'merchant'
    | 'dancer'
    | 'gambler'
    | 'judge'
    | 'faceless-one'
    | 'deckhand';

  type IconSize = 'sm' | 'md' | 'lg';
  type IconColor = 'brass' | 'mystic';

  const props = withDefaults(defineProps<Props>(), {
    size: 'md',
    color: 'brass',
  });

  /**
   * Inline SVG path data for each of the Nine Icons.
   * Each entry is the `<path>` / `<circle>` / `<line>` / `<rect>` content
   * rendered inside a 24×24 viewBox with stroke="currentColor" stroke-width="1.5".
   * Keeping the data here avoids bundler SVG-raw-import configuration and
   * ensures the 9 fixed glyphs are auditable in one place.
   */
  const ICON_PATHS: Record<IconCoriolisName, string> = {
    'lady-of-tears': `
      <circle cx="12" cy="12" r="10"/>
      <path d="M12 4 C9 7, 7 9.5, 7 12 a5 5 0 0 0 10 0 C17 9.5, 15 7, 12 4Z"/>
      <circle cx="12" cy="9" r="1" fill="currentColor" stroke="none"/>
    `,
    traveler: `
      <circle cx="12" cy="12" r="9"/>
      <line x1="12" y1="3" x2="12" y2="6"/>
      <line x1="12" y1="18" x2="12" y2="21"/>
      <line x1="3" y1="12" x2="6" y2="12"/>
      <line x1="18" y1="12" x2="21" y2="12"/>
      <path d="M12 12 L16 8"/>
      <polyline points="13 8 16 8 16 11"/>
    `,
    messenger: `
      <ellipse cx="12" cy="13" rx="3" ry="4"/>
      <circle cx="12" cy="7" r="2"/>
      <path d="M9 12 C6 9, 3 10, 2 13 C4 12, 7 13, 9 14"/>
      <path d="M15 12 C18 9, 21 10, 22 13 C20 12, 17 13, 15 14"/>
    `,
    merchant: `
      <line x1="12" y1="4" x2="12" y2="20"/>
      <line x1="6" y1="8" x2="18" y2="8"/>
      <path d="M4 8 C4 11, 6 13, 8 13 C10 13, 12 11, 12 8"/>
      <path d="M12 8 C12 11, 14 13, 16 13 C18 13, 20 11, 20 8"/>
      <circle cx="12" cy="20" r="1.5" fill="currentColor" stroke="none"/>
    `,
    dancer: `
      <path d="M7 20 C8 15, 12 14, 11 8 C10 5, 8 4, 9 2"/>
      <path d="M12 20 C13 15, 17 14, 16 8 C15 5, 13 4, 14 2"/>
      <path d="M9.5 20 C10.5 15, 14.5 14, 13.5 8 C12.5 5, 10.5 4, 11.5 2"/>
    `,
    gambler: `
      <rect x="3" y="3" width="18" height="18" rx="3" ry="3"/>
      <circle cx="12" cy="12" r="2" fill="currentColor" stroke="none"/>
    `,
    judge: `
      <line x1="4" y1="7" x2="20" y2="7"/>
      <line x1="12" y1="3" x2="12" y2="7"/>
      <line x1="7" y1="7" x2="7" y2="11"/>
      <ellipse cx="7" cy="13" rx="3" ry="2"/>
      <line x1="17" y1="7" x2="17" y2="13"/>
      <ellipse cx="17" cy="15" rx="3" ry="2"/>
      <line x1="12" y1="7" x2="12" y2="21"/>
      <line x1="9" y1="21" x2="15" y2="21"/>
    `,
    'faceless-one': `
      <circle cx="12" cy="12" r="10"/>
      <circle cx="12" cy="12" r="6"/>
      <line x1="12" y1="2" x2="12" y2="6"/>
      <line x1="12" y1="18" x2="12" y2="22"/>
      <line x1="2" y1="12" x2="6" y2="12"/>
      <line x1="18" y1="12" x2="22" y2="12"/>
    `,
    deckhand: `
      <circle cx="12" cy="6" r="2"/>
      <line x1="12" y1="8" x2="12" y2="18"/>
      <line x1="7" y1="11" x2="17" y2="11"/>
      <path d="M12 18 C9 18, 7 16, 7 14"/>
      <path d="M12 18 C15 18, 17 16, 17 14"/>
      <path d="M4 21 C6 19, 8 22, 10 20 C12 18, 14 21, 16 20 C18 19, 20 21, 22 20"/>
    `,
  };

  const VALID_NAMES: IconCoriolisName[] = [
    'lady-of-tears',
    'traveler',
    'messenger',
    'merchant',
    'dancer',
    'gambler',
    'judge',
    'faceless-one',
    'deckhand',
  ];

  // Pixel dimensions per size — SCSS vars below mirror these for the wrapper.
  const SIZE_PX: Record<IconSize, number> = {
    sm: 24,
    md: 32,
    lg: 64,
  };

  interface Props {
    name: IconCoriolisName;
    size?: IconSize;
    color?: IconColor;
    ariaLabel: string;
  }

  if (!VALID_NAMES.includes(props.name)) {
    console.warn(
      `[AppIconCoriolis] Unknown icon name "${props.name}". Valid names: ${VALID_NAMES.join(', ')}.`,
    );
  }

  // Guard the (typed-complete) map against runtime-unknown names from JS
  // callers; an unknown name renders empty rather than `undefined`.
  const svgContent = computed(() =>
    VALID_NAMES.includes(props.name) ? ICON_PATHS[props.name] : '',
  );

  const sizePx = computed(() => SIZE_PX[props.size]);

  const classes = computed(() => [
    'app-icon-coriolis',
    `app-icon-coriolis--${props.name}`,
    `app-icon-coriolis--${props.size}`,
    `app-icon-coriolis--${props.color}`,
  ]);
</script>

<template>
  <span :class="classes">
    <!-- eslint-disable vue/no-v-html -- svgContent comes from ICON_PATHS, a
         closed static map keyed by a typed icon name, never user input, so it
         cannot carry injected script. v-html is the only way to inline the raw
         <path> set. Block form (not next-line) because the directive is
         reported on the multi-line element's attribute, not its opening tag. -->
    <svg
      :width="sizePx"
      :height="sizePx"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.5"
      stroke-linecap="round"
      stroke-linejoin="round"
      role="img"
      :aria-label="ariaLabel"
      xmlns="http://www.w3.org/2000/svg"
      class="app-icon-coriolis__svg"
      v-html="svgContent"
    />
    <!-- eslint-enable vue/no-v-html -->
  </span>
</template>

<style lang="scss" scoped>
  // Pixel dimensions per size — SCSS vars are the approved escape hatch.
  $icon-sm: 24px;
  $icon-md: 32px;
  $icon-lg: 64px;

  .app-icon-coriolis {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;

    // ── Size modifiers ────────────────────────────────────────────────────────

    &--sm {
      width: $icon-sm;
      height: $icon-sm;
    }

    &--md {
      width: $icon-md;
      height: $icon-md;
    }

    &--lg {
      width: $icon-lg;
      height: $icon-lg;
    }

    // ── Color modifiers ───────────────────────────────────────────────────────

    &--brass {
      color: var(--brand-brass);
    }

    &--mystic {
      color: var(--state-mystic-teal);
    }

    // ── SVG layout ────────────────────────────────────────────────────────────

    &__svg {
      display: block;
      overflow: visible;
    }
  }
</style>
