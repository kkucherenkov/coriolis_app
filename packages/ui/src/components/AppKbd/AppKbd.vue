<script setup lang="ts">
  import { computed } from 'vue';

  type Size = 'sm' | 'md';

  interface Props {
    keys: string | string[];
    size?: Size;
  }

  const props = withDefaults(defineProps<Props>(), {
    size: 'md',
  });

  // Normalise to an array so the template is uniform.
  const keyList = computed<string[]>(() => (Array.isArray(props.keys) ? props.keys : [props.keys]));

  const rootClasses = computed(() => ['app-kbd', `app-kbd--${props.size}`]);
</script>

<template>
  <kbd :class="rootClasses">
    <!--
      Semantic <kbd> wrapping one or more key labels.
      Multi-key combos render each key in its own inner <kbd> separated by
      a hairspace + "+" + hairspace (U+200A U+002B U+200A). The hairspace
      avoids collision with letter "I" / "l" which looks cramped next to "+".
    -->
    <template v-if="keyList.length === 1">{{ keyList[0] }}</template>
    <template v-else>
      <template
        v-for="(key, idx) in keyList"
        :key="idx"
      >
        <kbd class="app-kbd__key">{{ key }}</kbd>
        <span
          v-if="idx < keyList.length - 1"
          class="app-kbd__sep"
          aria-hidden="true"
        >+</span>
      </template>
    </template>
  </kbd>
</template>

<style lang="scss" scoped>
  // Sub-token sizing for the kbd element; SCSS variables are the approved
  // escape hatch for pixel dimensions that don't map to spacing tokens.
  $kbd-font-sm: 11px;
  $kbd-font-md: 13px;
  $kbd-line-height: 1;

  .app-kbd {
    display: inline-flex;
    align-items: center;
    gap: var(--space-1);
    background: var(--surface-night);
    border: 1px solid var(--brand-brass-deep);
    border-radius: var(--radius-sm);
    color: var(--brand-brass-light);
    font-family: var(--type-mono-stat-md-font-family);
    font-weight: var(--type-mono-stat-md-font-weight);
    line-height: $kbd-line-height;
    white-space: nowrap;
    user-select: none;

    // ── Size: sm ──────────────────────────────────────────────────────────────

    &--sm {
      font-size: $kbd-font-sm;
      padding: var(--space-1) var(--space-1);
    }

    // ── Size: md ──────────────────────────────────────────────────────────────

    &--md {
      font-size: $kbd-font-md;
      padding: var(--space-1) var(--space-2);
    }

    // ── Inner key (multi-key combo) ───────────────────────────────────────────

    &__key {
      display: inline-flex;
      align-items: center;
      background: transparent;
      border: none;
      padding: 0;
      color: inherit;
      font-family: inherit;
      font-size: inherit;
      font-weight: inherit;
      line-height: inherit;
    }

    // ── Separator ─────────────────────────────────────────────────────────────

    &__sep {
      display: inline-flex;
      align-items: center;
      color: var(--text-secondary);
      font-size: inherit;
      line-height: inherit;
      margin-inline: 1px;
    }
  }
</style>
