<script setup lang="ts">
  import { computed, ref } from 'vue';

  type Size = 'sm' | 'md' | 'lg';
  type Tone = 'brass' | 'mystic' | 'crimson' | 'darkness';

  interface Props {
    /** Current committed value (v-model). */
    modelValue: number;
    /** Lowest selectable value. Attributes use 1, skills use 0. */
    min?: number;
    max?: number;
    size?: Size;
    tone?: Tone;
    disabled?: boolean;
    /** Accessible name (e.g. the stat label). */
    label?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    min: 0,
    max: 5,
    size: 'md',
    tone: 'brass',
    disabled: false,
    label: undefined,
  });

  const emit = defineEmits<{ 'update:modelValue': [value: number] }>();

  const clampedValue = computed(() => Math.max(props.min, Math.min(props.max, props.modelValue)));

  // Hover preview (fine pointers); null while not hovering. Takes precedence
  // over the committed value so the prospective fill is visible before click.
  const hoverValue = ref<number | null>(null);
  const displayValue = computed(() => hoverValue.value ?? clampedValue.value);

  const rootClasses = computed(() => [
    'app-dot-input',
    `app-dot-input--${props.size}`,
    `app-dot-input--${props.tone}`,
    { 'app-dot-input--disabled': props.disabled },
  ]);

  const ariaValueText = computed(() =>
    props.label ? `${props.label}: ${String(clampedValue.value)}` : String(clampedValue.value),
  );

  function commit(next: number): void {
    if (props.disabled) return;
    const clamped = Math.max(props.min, Math.min(props.max, next));
    if (clamped !== clampedValue.value) emit('update:modelValue', clamped);
  }

  // Click dot N sets the value to N. Clicking the current top-filled dot steps
  // down by one (star-rating idiom) so the value can be lowered to min without
  // a separate stepper control.
  function onDotClick(dot: number): void {
    if (props.disabled) return;
    commit(dot === clampedValue.value ? dot - 1 : dot);
  }

  function onKeydown(event: KeyboardEvent): void {
    if (props.disabled) return;
    let handled = true;
    switch (event.key) {
      case 'ArrowRight':
      case 'ArrowUp': {
        commit(clampedValue.value + 1);
        break;
      }
      case 'ArrowLeft':
      case 'ArrowDown': {
        commit(clampedValue.value - 1);
        break;
      }
      case 'Home': {
        commit(props.min);
        break;
      }
      case 'End': {
        commit(props.max);
        break;
      }
      default: {
        handled = false;
      }
    }
    if (handled) event.preventDefault();
  }

  function onDotEnter(dot: number): void {
    if (props.disabled) return;
    hoverValue.value = dot;
  }

  function clearHover(): void {
    hoverValue.value = null;
  }
</script>

<template>
  <div
    :class="rootClasses"
    role="slider"
    :tabindex="disabled ? -1 : 0"
    aria-orientation="horizontal"
    :aria-valuemin="min"
    :aria-valuemax="max"
    :aria-valuenow="clampedValue"
    :aria-valuetext="ariaValueText"
    :aria-label="label || undefined"
    :aria-disabled="disabled || undefined"
    @keydown="onKeydown"
    @mouseleave="clearHover"
  >
    <!-- Dots are pointer affordances only; the slider container carries the
         accessible name, value, and keyboard control, so each dot is
         aria-hidden. -->
    <span
      v-for="dot in max"
      :key="dot"
      class="app-dot-input__hit"
      aria-hidden="true"
      @click="onDotClick(dot)"
      @mouseenter="onDotEnter(dot)"
    >
      <span
        class="app-dot-input__dot"
        :class="{ 'app-dot-input__dot--filled': dot <= displayValue }"
      />
    </span>
  </div>
</template>

<style lang="scss" scoped>
  // Dot diameter scale — mirrors AppDots; layout px values, not design tokens.
  $dot-size-sm: 6px;
  $dot-size-md: 8px;
  $dot-size-lg: 12px;
  // Minimum tap target on coarse pointers — WCAG 2.5.5.
  $tap-min: 32px;

  .app-dot-input {
    display: inline-flex;
    align-items: center;
    gap: 0;
    border-radius: var(--radius-sm);
    cursor: pointer;

    &:focus-visible {
      outline: 2px solid var(--brand-brass);
      outline-offset: 2px;
    }

    // ── Hit target (pointer affordance around each dot) ───────────────────────

    &__hit {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      padding: var(--space-1);

      // Generous tap target on touch devices; visual dot stays small.
      @media (pointer: coarse) {
        min-width: $tap-min;
        min-height: $tap-min;
      }
    }

    // ── Dot ───────────────────────────────────────────────────────────────────

    &__dot {
      display: inline-block;
      flex-shrink: 0;
      border-radius: var(--radius-pill);
      border: 1px solid var(--brand-brass-shadow);
      background-color: transparent;
      transition:
        background-color var(--motion-duration-fast) var(--motion-ease-standard),
        border-color var(--motion-duration-fast) var(--motion-ease-standard);
    }

    // ── Size modifiers ────────────────────────────────────────────────────────

    &--sm .app-dot-input__dot {
      width: $dot-size-sm;
      height: $dot-size-sm;
    }

    &--md .app-dot-input__dot {
      width: $dot-size-md;
      height: $dot-size-md;
    }

    &--lg .app-dot-input__dot {
      width: $dot-size-lg;
      height: $dot-size-lg;
    }

    // ── Tone modifiers (filled-dot color) ─────────────────────────────────────

    &--brass .app-dot-input__dot--filled {
      background-color: var(--brand-brass);
      border-color: var(--brand-brass);
    }

    &--mystic .app-dot-input__dot--filled {
      background-color: var(--state-mystic-teal);
      border-color: var(--state-mystic-teal);
    }

    &--crimson .app-dot-input__dot--filled {
      background-color: var(--state-crimson);
      border-color: var(--state-crimson);
    }

    &--darkness .app-dot-input__dot--filled {
      background-color: var(--state-darkness);
      border-color: var(--state-darkness);
    }

    // ── Hover affordance (fine pointers) ──────────────────────────────────────

    @media (hover: hover) {
      &:not(.app-dot-input--disabled) .app-dot-input__hit:hover .app-dot-input__dot {
        border-color: var(--brand-brass);
      }
    }

    // ── Disabled ──────────────────────────────────────────────────────────────

    &--disabled {
      cursor: default;
      opacity: var(--opacity-disabled);
      pointer-events: none;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .app-dot-input__dot {
      transition: none;
    }
  }
</style>
