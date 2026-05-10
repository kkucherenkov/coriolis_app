<script setup lang="ts">
  import { computed } from 'vue';

  type Variant = 'brass' | 'mystic' | 'crimson' | 'success' | 'darkness';
  type Size = 'sm' | 'md';

  interface Props {
    variant?: Variant;
    size?: Size;
  }

  const props = withDefaults(defineProps<Props>(), {
    variant: 'brass',
    size: 'md',
  });

  const classes = computed(() => [
    'app-badge',
    `app-badge--${props.variant}`,
    `app-badge--${props.size}`,
  ]);
</script>

<template>
  <span
    :class="classes"
    tabindex="-1"
  >
    <span
      v-if="$slots['icon']"
      class="app-badge__icon"
      aria-hidden="true"
    >
      <slot name="icon" />
    </span>
    <slot />
  </span>
</template>

<style lang="scss" scoped>
  // Badge-specific font sizes — below the body-sm token (14px) by design.
  // SCSS variables are the approved escape hatch for layout-dimension literals
  // per the Stylelint config (0/1px/2px are additionally exempt).
  $badge-font-sm: 10px;
  $badge-font-md: 12px;
  $badge-pad-v-md: 3px;

  .app-badge {
    display: inline-flex;
    align-items: center;
    gap: var(--space-1);
    border-radius: var(--radius-pill);
    border: 1px solid;
    font-family: var(--type-body-sm-font-family);
    font-weight: 500;
    white-space: nowrap;
    line-height: 1;

    // ── Size modifiers ──────────────────────────────────────────────────────

    &--sm {
      font-size: $badge-font-sm;
      padding: 2px var(--space-2);
    }

    &--md {
      font-size: $badge-font-md;
      padding: $badge-pad-v-md var(--space-3);
    }

    // ── Variant: brass (default) ────────────────────────────────────────────

    &--brass {
      border-color: var(--brand-brass);
      color: var(--brand-brass-light);
      background-color: color-mix(in srgb, var(--brand-brass) 12%, transparent);
    }

    // ── Variant: mystic ─────────────────────────────────────────────────────

    &--mystic {
      border-color: var(--state-mystic-teal);
      color: var(--state-mystic-teal);
      background-color: color-mix(in srgb, var(--state-mystic-teal) 12%, transparent);
    }

    // ── Variant: crimson ────────────────────────────────────────────────────

    &--crimson {
      border-color: var(--state-crimson);
      color: var(--state-crimson-bright);
      background-color: color-mix(in srgb, var(--state-crimson) 12%, transparent);
    }

    // ── Variant: success ────────────────────────────────────────────────────

    &--success {
      border-color: var(--state-success);
      color: var(--state-success);
      background-color: color-mix(in srgb, var(--state-success) 12%, transparent);
    }

    // ── Variant: darkness ───────────────────────────────────────────────────

    &--darkness {
      border-color: var(--state-darkness);
      color: var(--text-primary);
      background-color: color-mix(in srgb, var(--state-darkness) 30%, transparent);
    }

    // ── Internal elements ───────────────────────────────────────────────────

    &__icon {
      display: inline-flex;
      align-items: center;
      flex-shrink: 0;
    }
  }
</style>
