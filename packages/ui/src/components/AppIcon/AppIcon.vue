<script setup lang="ts">
  import * as lucideIcons from 'lucide-vue-next';
  import { computed, type Component } from 'vue';

  type Size = 'xs' | 'sm' | 'md' | 'lg' | 'xl';
  type Color = 'brass' | 'mystic' | 'crimson' | 'success' | 'darkness' | 'inherit';

  // Pixel dimensions per size variant (xs=12, sm=16, md=20, lg=24, xl=32).
  // These are SVG attribute values forwarded to the Lucide component, not CSS.
  const SIZE_PX: Record<Size, number> = {
    xs: 12,
    sm: 16,
    md: 20,
    lg: 24,
    xl: 32,
  };

  interface Props {
    name: string;
    size?: Size;
    color?: Color;
    strokeWidth?: number;
    ariaLabel?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    size: 'md',
    color: 'inherit',
    strokeWidth: 1.5,
    ariaLabel: undefined,
  });

  // kebab-case → PascalCase: "dice-3" → "Dice3", "arrow-up-right" → "ArrowUpRight"
  function toPascalCase(kebab: string): string {
    return kebab
      .split('-')
      .map((seg) => seg.charAt(0).toUpperCase() + seg.slice(1))
      .join('');
  }

  const iconComponent = computed<Component | null>(() => {
    const pascal = toPascalCase(props.name);
    // lucide-vue-next exports both bare (Sword) and aliased (SwordIcon) names;
    // prefer the bare name for deterministic lookup.
    const candidate = (lucideIcons as unknown as Record<string, Component>)[pascal];
    if (!candidate) {
      console.warn(
        `[AppIcon] Unknown Lucide icon: "${props.name}" (looked up "${pascal}"). Rendering empty fallback.`,
      );
      return null;
    }
    return candidate;
  });

  const decorative = computed(() => !props.ariaLabel);

  const classes = computed(() => [
    'app-icon',
    `app-icon--${props.size}`,
    props.color !== 'inherit' ? `app-icon--${props.color}` : null,
  ]);
</script>

<template>
  <span
    :class="classes"
    :aria-hidden="decorative ? 'true' : undefined"
    :aria-label="decorative ? undefined : ariaLabel"
    role="img"
  >
    <component
      :is="iconComponent"
      v-if="iconComponent"
      :width="SIZE_PX[size]"
      :height="SIZE_PX[size]"
      :stroke-width="strokeWidth"
      aria-hidden="true"
      focusable="false"
    />
  </span>
</template>

<style lang="scss" scoped>
  // All icon box dimensions are below the Stylelint raw-px threshold for
  // width/height (≥10 px is banned; must use named SCSS vars or tokens).
  // SCSS variables are the approved escape hatch per AppBadge convention.
  $icon-xs: 12px;
  $icon-sm: 16px;
  $icon-md: 20px;
  $icon-lg: 24px;
  $icon-xl: 32px;

  .app-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    // Default: inherit the parent's color so the Lucide SVG picks it up via
    // currentColor (DESIGN §4.3 default).
    color: currentcolor;

    // ── Size modifiers ──────────────────────────────────────────────────────

    &--xs {
      width: $icon-xs;
      height: $icon-xs;
    }

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

    &--xl {
      width: $icon-xl;
      height: $icon-xl;
    }

    // ── Color modifiers ─────────────────────────────────────────────────────
    // Each sets `color` so the Lucide SVG's stroke="currentColor" resolves
    // to the token value.  'inherit' has no modifier class — color cascades
    // from the parent untouched.

    &--brass {
      color: var(--brand-brass);
    }

    &--mystic {
      color: var(--state-mystic-teal);
    }

    &--crimson {
      color: var(--state-crimson-bright);
    }

    &--success {
      color: var(--state-success);
    }

    &--darkness {
      color: var(--state-darkness);
    }
  }
</style>
