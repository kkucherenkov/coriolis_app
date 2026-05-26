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

  const canDecrement = computed(() => clampedValue.value > props.min);
  const canIncrement = computed(() => clampedValue.value < props.max);

  const rootClasses = computed(() => [
    'app-dot-input',
    `app-dot-input--${props.size}`,
    `app-dot-input--${props.tone}`,
    { 'app-dot-input--disabled': props.disabled },
  ]);

  // Announce the ceiling too ("Force: 3 of 5"), matching AppDots/AppStatBlock.
  const ariaValueText = computed(() => {
    const range = `${String(clampedValue.value)} of ${String(props.max)}`;
    return props.label ? `${props.label}: ${range}` : range;
  });

  function commit(next: number): void {
    if (props.disabled) return;
    const clamped = Math.max(props.min, Math.min(props.max, next));
    if (clamped !== clampedValue.value) emit('update:modelValue', clamped);
  }

  // Clicking a dot sets the value to exactly that dot (up or down) — no hidden
  // "click the active dot to decrement" gesture. The explicit − / + controls
  // are the discoverable step path and the only way to reach 0 (skills), where
  // the lowest dot is value 1.
  function onDotClick(dot: number): void {
    commit(dot);
  }

  function stepDown(): void {
    commit(clampedValue.value - 1);
  }

  function stepUp(): void {
    commit(clampedValue.value + 1);
  }

  function onKeydown(event: KeyboardEvent): void {
    if (props.disabled) return;
    let handled = true;
    switch (event.key) {
      case 'ArrowRight':
      case 'ArrowUp': {
        stepUp();
        break;
      }
      case 'ArrowLeft':
      case 'ArrowDown': {
        stepDown();
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
    <!-- −/+ and dots are pointer affordances only; the slider container carries
         the accessible name, value, and keyboard control, so they're
         aria-hidden. The steppers are always present (and reserve their width)
         so the control reads as editable at rest and never shifts layout. -->
    <span
      class="app-dot-input__step app-dot-input__step--dec"
      :class="{ 'app-dot-input__step--off': !canDecrement }"
      aria-hidden="true"
      @click="stepDown"
      @mousedown.prevent
      >&#8722;</span
    >
    <span class="app-dot-input__dots">
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
    </span>
    <span
      class="app-dot-input__step app-dot-input__step--inc"
      :class="{ 'app-dot-input__step--off': !canIncrement }"
      aria-hidden="true"
      @click="stepUp"
      @mousedown.prevent
      >+</span
    >
  </div>
</template>

<style lang="scss" scoped>
  // Dot diameter scale — mirrors AppDots; layout px values, not design tokens.
  $dot-size-sm: 6px;
  $dot-size-md: 8px;
  $dot-size-lg: 12px;
  // Minimum tap target on coarse pointers — WCAG 2.5.5.
  $tap-min: 32px;
  // Stepper glyph box at rest (fine pointers).
  $step-size-sm: 14px;
  $step-size-md: 18px;

  .app-dot-input {
    display: inline-flex;
    align-items: center;
    gap: var(--space-1);
    border-radius: var(--radius-sm);

    &:focus-visible {
      outline: 2px solid var(--brand-brass);
      outline-offset: 2px;
    }

    // ── Stepper (− / +) ─────────────────────────────────────────────────────────
    // Always visible so the control advertises that it is editable. Subdued at
    // rest, brightens when the control is hovered or focused.

    &__step {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: $step-size-md;
      height: $step-size-md;
      flex-shrink: 0;
      cursor: pointer;
      user-select: none;
      line-height: 1;
      color: var(--brand-brass-deep);
      border: 1px solid transparent;
      border-radius: var(--radius-sm);
      transition:
        color var(--motion-duration-fast) var(--motion-ease-standard),
        border-color var(--motion-duration-fast) var(--motion-ease-standard);

      @media (pointer: coarse) {
        min-width: $tap-min;
        min-height: $tap-min;
      }

      &--off {
        opacity: var(--opacity-disabled);
        pointer-events: none;
      }
    }

    &--sm .app-dot-input__step {
      width: $step-size-sm;
      height: $step-size-sm;
    }

    @media (hover: hover) {
      &:hover .app-dot-input__step:not(.app-dot-input__step--off),
      &:focus-within .app-dot-input__step:not(.app-dot-input__step--off) {
        color: var(--brand-brass-light);
        border-color: var(--brand-brass-deep);
      }
    }

    // ── Hit target (pointer affordance around each dot) ───────────────────────

    &__dots {
      display: inline-flex;
      align-items: center;
      gap: 0;
    }

    &__hit {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      padding: var(--space-1);
      cursor: pointer;

      @media (pointer: coarse) {
        min-width: $tap-min;
        min-height: $tap-min;
      }
    }

    // ── Dot ───────────────────────────────────────────────────────────────────
    // Unfilled dots use a brass-deep ring (higher contrast than the read-only
    // AppDots meter's brass-shadow) so empty slots read as fillable.

    &__dot {
      display: inline-block;
      flex-shrink: 0;
      border-radius: var(--radius-pill);
      border: 1px solid var(--brand-brass-deep);
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

    // ── Hover affordance on the dots (fine pointers) ──────────────────────────

    @media (hover: hover) {
      &:not(.app-dot-input--disabled) .app-dot-input__hit:hover .app-dot-input__dot {
        border-color: var(--brand-brass);
      }
    }

    // ── Disabled ──────────────────────────────────────────────────────────────

    &--disabled {
      pointer-events: none;

      .app-dot-input__step {
        opacity: var(--opacity-disabled);
      }
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .app-dot-input__dot,
    .app-dot-input__step {
      transition: none;
    }
  }
</style>
