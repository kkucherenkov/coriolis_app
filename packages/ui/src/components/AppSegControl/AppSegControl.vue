<script setup lang="ts">
  import { computed } from 'vue';

  type Size = 'sm' | 'md' | 'lg';

  interface Option {
    value: string | number;
    label: string;
    disabled?: boolean;
  }

  interface Props {
    modelValue: string | number | null;
    options: Option[];
    size?: Size;
    disabled?: boolean;
  }

  const props = withDefaults(defineProps<Props>(), {
    size: 'md',
    disabled: false,
  });

  const emit = defineEmits<{
    'update:modelValue': [value: string | number];
  }>();

  // ── Roving focus ─────────────────────────────────────────────────────────────
  // The checked option (or first non-disabled option if none checked) holds
  // tabindex="0"; all others are "-1". Arrow keys move selection, which also
  // moves focus. This is the canonical accessible radiogroup pattern (ARIA 1.1
  // §3.15.21 — roving tabindex).

  const checkedIndex = computed<number>(() => {
    const idx = props.options.findIndex((o) => o.value === props.modelValue);
    // Fall back to the first non-disabled option if nothing is selected.
    if (idx === -1) {
      return props.options.findIndex((o) => !o.disabled);
    }
    return idx;
  });

  function tabindexFor(idx: number): 0 | -1 {
    return idx === checkedIndex.value ? 0 : -1;
  }

  function optionClasses(option: Option): (string | Record<string, boolean>)[] {
    const isActive = option.value === props.modelValue;
    const isDisabled = props.disabled || !!option.disabled;
    return [
      'app-seg-control__option',
      `app-seg-control__option--${props.size}`,
      { 'app-seg-control__option--active': isActive },
      { 'app-seg-control__option--disabled': isDisabled },
    ];
  }

  function select(option: Option): void {
    if (props.disabled || option.disabled) return;
    emit('update:modelValue', option.value);
  }

  function onKeydown(event: KeyboardEvent, currentIdx: number): void {
    if (props.disabled) return;

    let targetIdx: number | null = null;

    switch (event.key) {
      case 'ArrowRight':
      case 'ArrowDown': {
        event.preventDefault();
        targetIdx = nextEnabledIndex(currentIdx, 1);

        break;
      }
      case 'ArrowLeft':
      case 'ArrowUp': {
        event.preventDefault();
        targetIdx = nextEnabledIndex(currentIdx, -1);

        break;
      }
      case 'Home': {
        event.preventDefault();
        targetIdx = firstEnabledIndex();

        break;
      }
      case 'End': {
        event.preventDefault();
        targetIdx = lastEnabledIndex();

        break;
      }
      // No default
    }

    if (targetIdx !== null) {
      const option = props.options[targetIdx];
      if (!option) return;
      select(option);
      // Move DOM focus to the target button so the keyboard user can continue
      // navigating. We query by logical index among all option buttons (including
      // disabled ones, which are skipped by nextEnabledIndex anyway).
      const allButtons = (event.currentTarget as HTMLElement)
        .closest('[role="radiogroup"]')
        ?.querySelectorAll<HTMLButtonElement>('.app-seg-control__option');
      const targetButton = allButtons?.[targetIdx];
      if (targetButton) {
        targetButton.focus();
      }
    }
  }

  function nextEnabledIndex(from: number, direction: 1 | -1): number {
    const count = props.options.length;
    let idx = (from + direction + count) % count;
    let attempts = 0;
    while (props.options[idx]?.disabled && attempts < count) {
      idx = (idx + direction + count) % count;
      attempts++;
    }
    return props.options[idx]?.disabled ? from : idx;
  }

  function firstEnabledIndex(): number {
    return props.options.findIndex((o) => !o.disabled);
  }

  function lastEnabledIndex(): number {
    for (let i = props.options.length - 1; i >= 0; i--) {
      if (!props.options[i]?.disabled) return i;
    }
    return 0;
  }

  const rootClasses = computed(() => [
    'app-seg-control',
    `app-seg-control--${props.size}`,
    { 'app-seg-control--disabled': props.disabled },
  ]);
</script>

<template>
  <div :class="rootClasses" role="radiogroup" :aria-disabled="disabled ? 'true' : undefined">
    <!--
      Roving focus pattern:
      - Only the checked option has tabindex="0"; all others have tabindex="-1".
      - Arrow Left/Right (and Up/Down) move selection AND focus.
      - Home / End jump to first / last enabled option.
      Disabled individual options are skipped in arrow navigation.
    -->
    <button
      v-for="(option, idx) in options"
      :key="String(option.value)"
      type="button"
      role="radio"
      :class="optionClasses(option)"
      :aria-checked="option.value === modelValue ? 'true' : 'false'"
      :disabled="disabled || !!option.disabled"
      :tabindex="tabindexFor(idx)"
      @click="select(option)"
      @keydown="onKeydown($event, idx)"
    >
      {{ option.label }}
    </button>
  </div>
</template>

<style lang="scss" scoped>
  // Sub-token font-sizes for sm/md/lg inline controls.
  $seg-font-sm: 12px;
  $seg-font-md: 14px;
  $seg-font-lg: 16px;

  .app-seg-control {
    display: inline-flex;
    align-items: stretch;
    border: 1px solid var(--brand-brass-deep);
    border-radius: var(--radius-md);
    overflow: hidden;

    // ── Disabled: whole group ──────────────────────────────────────────────────

    &--disabled {
      opacity: var(--opacity-disabled);
      pointer-events: none;
      cursor: not-allowed;
    }

    // ── Option button ──────────────────────────────────────────────────────────

    &__option {
      position: relative;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      border: none;
      // Left divider between segments — rendered via border-left on siblings.
      border-left: 1px solid var(--brand-brass-deep);
      border-radius: 0;
      background: var(--surface-night);
      color: var(--text-secondary);
      font-family: var(--type-body-md-font-family);
      cursor: pointer;
      white-space: nowrap;
      user-select: none;
      transition:
        background-color var(--motion-duration-fast) var(--motion-ease-standard),
        color var(--motion-duration-fast) var(--motion-ease-standard);

      // Remove the divider from the first segment.
      &:first-child {
        border-left: none;
      }

      // ── Hover ────────────────────────────────────────────────────────────────

      &:hover:not(.app-seg-control__option--active):not(.app-seg-control__option--disabled) {
        background-color: color-mix(in srgb, var(--brand-brass) 8%, transparent);
        color: var(--text-primary);
      }

      // ── Focus ────────────────────────────────────────────────────────────────

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: -2px;
        z-index: var(--z-raised);
      }

      // ── Active (checked) ─────────────────────────────────────────────────────

      &--active {
        background: var(--brand-brass);
        color: var(--text-on-brass);
        box-shadow: var(--shadow-card-featured);

        &:hover {
          background: var(--brand-brass-light);
        }
      }

      // ── Disabled (individual option) ──────────────────────────────────────────

      &--disabled {
        cursor: not-allowed;
        opacity: var(--opacity-disabled);
        pointer-events: none;
      }

      // ── Sizes ─────────────────────────────────────────────────────────────────

      &--sm {
        font-size: $seg-font-sm;
        padding: var(--space-1) var(--space-2);
      }

      &--md {
        font-size: $seg-font-md;
        padding: var(--space-2) var(--space-3);
      }

      &--lg {
        font-size: $seg-font-lg;
        padding: var(--space-2) var(--space-4);
      }
    }
  }

  // Respect reduced-motion preference — skip background transition.
  @media (prefers-reduced-motion: reduce) {
    .app-seg-control__option {
      transition: none;
    }
  }
</style>
