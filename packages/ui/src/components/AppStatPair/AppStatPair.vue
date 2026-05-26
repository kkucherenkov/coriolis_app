<script setup lang="ts">
  /**
   * AppStatPair — mono-stat current/max counter.
   *
   * Renders a brass-on-indigo paired counter in JetBrains Mono:
   *   "14 / 8"  (current / max)
   * with −/+ steppers that clamp current to [0, max].
   *
   * Props:
   *   label        — accessible name (e.g. "Hull", "Energy")
   *   current      — current value (v-model via update:current)
   *   max          — max value (read-only; the caller owns it separately)
   *   tone         — 'brass' | 'mystic' (default 'brass')
   *   disabled     — disables steppers + direct input
   *
   * Emits:
   *   update:current — new current value after a step or direct edit
   *   blur           — forwarded from the direct-entry input (triggers auto-save)
   */

  import { computed, ref } from 'vue';

  type Tone = 'brass' | 'mystic';

  interface Props {
    label: string;
    current: number;
    max: number;
    tone?: Tone;
    disabled?: boolean;
  }

  const props = withDefaults(defineProps<Props>(), {
    tone: 'brass',
    disabled: false,
  });

  const emit = defineEmits<{
    'update:current': [value: number];
    blur: [];
  }>();

  // Direct-entry input: the user can type a number; we clamp on blur.
  const inputRef = ref<HTMLInputElement | null>(null);

  const clamp = (v: number): number => Math.min(props.max, Math.max(0, v));

  function decrement(): void {
    if (props.disabled) return;
    emit('update:current', clamp(props.current - 1));
  }

  function increment(): void {
    if (props.disabled) return;
    emit('update:current', clamp(props.current + 1));
  }

  function onInputChange(e: Event): void {
    const raw = (e.target as HTMLInputElement).value;
    const n = Number.parseInt(raw, 10);
    if (!Number.isNaN(n)) {
      emit('update:current', clamp(n));
    }
    // Restore clamped value in the DOM (input is uncontrolled for typing UX)
    if (inputRef.value) {
      inputRef.value.value = String(clamp(Number.isNaN(n) ? props.current : n));
    }
    emit('blur');
  }

  const ariaValuetext = computed(
    () => `${props.label}: ${String(props.current)} of ${String(props.max)}`,
  );

  const rootClasses = computed(() => [
    'app-stat-pair',
    `app-stat-pair--${props.tone}`,
    { 'app-stat-pair--disabled': props.disabled },
  ]);

  const decrementId = computed(() => `sp-dec-${props.label.toLowerCase().replaceAll(/\s+/g, '-')}`);
  const incrementId = computed(() => `sp-inc-${props.label.toLowerCase().replaceAll(/\s+/g, '-')}`);
  const inputId = computed(() => `sp-input-${props.label.toLowerCase().replaceAll(/\s+/g, '-')}`);
</script>

<template>
  <div :class="rootClasses" role="group" :aria-label="label">
    <!-- Label -->
    <span :id="`${inputId}-label`" class="app-stat-pair__label" aria-hidden="true">
      {{ label }}
    </span>

    <!-- Counter display: current / max -->
    <div class="app-stat-pair__display" :aria-valuetext="ariaValuetext" aria-live="polite">
      <!-- Direct-entry for current -->
      <input
        :id="inputId"
        ref="inputRef"
        class="app-stat-pair__input"
        type="number"
        inputmode="numeric"
        :value="current"
        :min="0"
        :max="max"
        :disabled="disabled"
        :aria-label="label"
        :aria-valuemin="0"
        :aria-valuemax="max"
        :aria-valuenow="current"
        :aria-valuetext="ariaValuetext"
        @change="onInputChange"
        @blur="onInputChange"
      />
      <span class="app-stat-pair__separator" aria-hidden="true"> / </span>
      <span class="app-stat-pair__max" :aria-label="`${label} max`">{{ max }}</span>
    </div>

    <!-- Steppers -->
    <div class="app-stat-pair__controls">
      <button
        :id="decrementId"
        class="app-stat-pair__btn app-stat-pair__btn--dec"
        type="button"
        :aria-label="`Decrease ${label}`"
        :disabled="disabled || current <= 0"
        @click="decrement"
      >
        −
      </button>
      <button
        :id="incrementId"
        class="app-stat-pair__btn app-stat-pair__btn--inc"
        type="button"
        :aria-label="`Increase ${label}`"
        :disabled="disabled || current >= max"
        @click="increment"
      >
        +
      </button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  $stepper-size: 28px;
  $label-font-size: 11px;
  $stat-pair-min-width: 72px;

  .app-stat-pair {
    display: inline-flex;
    flex-direction: column;
    align-items: center;
    gap: var(--space-1);
    min-width: $stat-pair-min-width;

    // ── Label ──────────────────────────────────────────────────────────────────

    &__label {
      font-family: var(--type-display-sm-font-family);
      font-size: $label-font-size;
      letter-spacing: 0.12em;
      text-transform: uppercase;
      color: var(--brand-brass-light);
      line-height: 1;

      .app-stat-pair--mystic & {
        color: var(--state-mystic-teal);
      }
    }

    // ── Display row: current / max ─────────────────────────────────────────────

    &__display {
      display: flex;
      align-items: baseline;
      gap: 0;
      line-height: 1;
    }

    &__input {
      // Unadorned numeric field — resets all browser chrome
      appearance: none;
      background: transparent;
      border: none;
      outline: none;
      padding: 0;
      margin: 0;
      width: 2.4ch;
      text-align: right;
      font-family: var(--type-mono-stat-md-font-family);
      font-size: var(--type-mono-stat-md-font-size);
      font-weight: 700;
      color: var(--text-primary);
      line-height: 1;

      // Hide browser spinners
      &::-webkit-inner-spin-button,
      &::-webkit-outer-spin-button {
        appearance: none;
        margin: 0;
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
        border-radius: var(--radius-sm);
      }

      &:disabled {
        opacity: var(--opacity-disabled);
        cursor: default;
      }

      .app-stat-pair--mystic & {
        color: var(--state-mystic-teal);
      }

      .app-stat-pair--disabled & {
        cursor: default;
      }
    }

    &__separator {
      font-family: var(--type-mono-stat-md-font-family);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
      font-weight: 400;
      line-height: 1;
      padding: 0 1px;
    }

    &__max {
      font-family: var(--type-mono-stat-md-font-family);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
      font-weight: 400;
      line-height: 1;
    }

    // ── Steppers ───────────────────────────────────────────────────────────────

    &__controls {
      display: flex;
      gap: var(--space-2);
    }

    &__btn {
      width: $stepper-size;
      height: $stepper-size;
      border: 1px solid var(--brand-brass-deep);
      background: transparent;
      color: var(--brand-brass);
      border-radius: var(--radius-sm);
      cursor: pointer;
      font-size: var(--type-body-md-font-size);
      line-height: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover:not([disabled]) {
        background-color: color-mix(in srgb, var(--brand-brass) 10%, transparent);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      &[disabled] {
        opacity: var(--opacity-disabled);
        cursor: default;
      }

      .app-stat-pair--mystic & {
        border-color: var(--state-mystic-teal);
        color: var(--state-mystic-teal);

        &:hover:not([disabled]) {
          background-color: color-mix(in srgb, var(--state-mystic-teal) 10%, transparent);
        }

        &:focus-visible {
          outline-color: var(--state-mystic-teal);
        }
      }
    }

    // ── Disabled state ─────────────────────────────────────────────────────────

    &--disabled {
      opacity: var(--opacity-disabled);
    }
  }

  // Respect reduced-motion preference.
  @media (prefers-reduced-motion: reduce) {
    .app-stat-pair {
      &__btn {
        transition: none;
      }
    }
  }
</style>
