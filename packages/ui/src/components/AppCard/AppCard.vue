<script setup lang="ts">
  import { computed } from 'vue';

  type Variant = 'default' | 'featured';

  interface Props {
    variant?: Variant;
    as?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    variant: 'default',
    as: 'div',
  });

  const classes = computed(() => [
    'app-card',
    { 'app-card--featured': props.variant === 'featured' },
  ]);
</script>

<template>
  <component :is="as" :class="classes">
    <div v-if="$slots['header']" class="app-card__header">
      <slot name="header" />
    </div>
    <div class="app-card__body">
      <slot />
    </div>
    <div v-if="$slots['footer']" class="app-card__footer">
      <slot name="footer" />
    </div>
  </component>
</template>

<style lang="scss" scoped>
  .app-card {
    background-color: var(--surface-night);
    border: 1px solid var(--brand-brass-shadow);
    border-radius: var(--radius-md);
    overflow: hidden;
    transition: box-shadow var(--motion-duration-fast) var(--motion-ease-standard);

    // ── Variant: featured ────────────────────────────────────────────────────
    // Beveled brass plate effect (DESIGN §5.4): border emphasis + inset bevel.

    &--featured {
      border-color: var(--brand-brass-deep);
      box-shadow: var(--shadow-brass-bevel);

      &:hover {
        box-shadow: var(--shadow-brass-bevel), var(--shadow-card-featured);
      }
    }

    // ── Sections ─────────────────────────────────────────────────────────────

    &__header {
      padding: var(--space-4) var(--space-6);
      border-bottom: 1px solid var(--brand-brass-deep);
      color: var(--brand-brass-light);
    }

    &__body {
      padding: var(--space-6);
    }

    &__footer {
      padding: var(--space-4) var(--space-6);
      border-top: 1px solid var(--brand-brass-shadow);
    }
  }
</style>
