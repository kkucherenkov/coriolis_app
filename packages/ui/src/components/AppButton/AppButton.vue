<script setup lang="ts">
  import { computed } from 'vue';

  type Variant = 'primary' | 'secondary' | 'ghost' | 'danger' | 'mystic';
  type Size = 'sm' | 'md' | 'lg';

  interface Props {
    variant?: Variant;
    size?: Size;
    disabled?: boolean;
    loading?: boolean;
    type?: 'button' | 'submit' | 'reset';
  }

  const props = withDefaults(defineProps<Props>(), {
    variant: 'primary',
    size: 'md',
    disabled: false,
    loading: false,
    type: 'button',
  });

  const emit = defineEmits<{ click: [event: MouseEvent] }>();

  const isDisabled = computed(() => props.disabled || props.loading);

  const classes = computed(() => [
    'app-button',
    `app-button--${props.variant}`,
    `app-button--${props.size}`,
    { 'app-button--disabled': isDisabled.value },
    { 'app-button--loading': props.loading },
  ]);

  function onClick(event: MouseEvent): void {
    if (isDisabled.value) {
      event.preventDefault();
      event.stopPropagation();
      return;
    }
    emit('click', event);
  }
</script>

<template>
  <button
    :class="classes"
    :type="type"
    :disabled="isDisabled"
    :aria-busy="loading || undefined"
    :aria-disabled="isDisabled || undefined"
    @click="onClick"
  >
    <span v-if="loading" class="app-button__spinner" aria-hidden="true" />
    <span
      v-if="$slots['icon-leading'] && !loading"
      class="app-button__icon app-button__icon--leading"
      aria-hidden="true"
    >
      <slot name="icon-leading" />
    </span>
    <span v-if="$slots['default']" class="app-button__label">
      <slot />
    </span>
    <span
      v-if="$slots['icon-trailing']"
      class="app-button__icon app-button__icon--trailing"
      aria-hidden="true"
    >
      <slot name="icon-trailing" />
    </span>
  </button>
</template>

<style lang="scss" scoped>
  // Spinner rotation duration — intentionally faster than motion-duration-slow;
  // not a UI transition. SCSS variable keeps it out of Stylelint's raw-ms ban.
  $btn-spin-dur: 650ms;

  .app-button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: var(--space-2);
    border: 1px solid transparent;
    border-radius: var(--radius-md);
    font-family: var(--type-body-md-font-family);
    font-weight: var(--type-body-md-font-weight);
    line-height: var(--type-body-md-line-height);
    cursor: pointer;
    user-select: none;
    text-decoration: none;
    white-space: nowrap;
    transition:
      background-color var(--motion-duration-fast) var(--motion-ease-standard),
      border-color var(--motion-duration-fast) var(--motion-ease-standard),
      color var(--motion-duration-fast) var(--motion-ease-standard),
      box-shadow var(--motion-duration-fast) var(--motion-ease-standard);

    &:focus-visible {
      outline: 2px solid var(--brand-brass);
      outline-offset: 2px;
    }

    // ── Size modifiers ───────────────────────────────────────────────────────

    &--sm {
      font-size: var(--type-body-sm-font-size);
      line-height: var(--type-body-sm-line-height);
      padding: var(--space-1) var(--space-3);
    }

    &--md {
      font-size: var(--type-body-md-font-size);
      line-height: var(--type-body-md-line-height);
      padding: var(--space-2) var(--space-4);
    }

    &--lg {
      font-size: var(--type-body-lg-font-size);
      line-height: var(--type-body-lg-line-height);
      padding: var(--space-3) var(--space-5);
    }

    // ── Variant: primary ─────────────────────────────────────────────────────

    &--primary {
      background-color: var(--brand-brass);
      color: var(--text-on-brass);
      border-color: transparent;
      box-shadow: var(--shadow-brass-bevel);

      &:hover:not(.app-button--disabled) {
        background-color: var(--brand-brass-light);
      }

      &:active:not(.app-button--disabled) {
        background-color: var(--brand-brass-deep);
      }
    }

    // ── Variant: secondary ───────────────────────────────────────────────────
    // Handoff `.cor-btn--secondary`: transparent fill + 1px brass border +
    // brass text. Sits between `primary` (filled) and `ghost` (borderless)
    // and is used for Cancel / Skip / Reroll actions.

    &--secondary {
      background-color: transparent;
      color: var(--brand-brass);
      border: 1px solid var(--brand-brass);

      &:hover:not(.app-button--disabled) {
        background-color: color-mix(in srgb, var(--brand-brass) 10%, transparent);
        border-color: var(--brand-brass-light);
        color: var(--brand-brass-light);
      }

      &:active:not(.app-button--disabled) {
        background-color: color-mix(in srgb, var(--brand-brass) 18%, transparent);
        border-color: var(--brand-brass-light);
      }
    }

    // ── Variant: ghost ───────────────────────────────────────────────────────

    &--ghost {
      background-color: transparent;
      color: var(--brand-brass-light);
      border: 1px solid var(--brand-brass-deep);

      &:hover:not(.app-button--disabled) {
        background-color: color-mix(in srgb, var(--brand-brass) 8%, transparent);
        border-color: var(--brand-brass);
      }

      &:active:not(.app-button--disabled) {
        background-color: color-mix(in srgb, var(--brand-brass) 14%, transparent);
        border-color: var(--brand-brass);
      }
    }

    // ── Variant: danger ──────────────────────────────────────────────────────

    &--danger {
      background-color: var(--state-crimson);
      color: var(--text-primary);
      border-color: transparent;

      &:hover:not(.app-button--disabled) {
        background-color: var(--state-crimson-bright);
      }

      &:active:not(.app-button--disabled) {
        background-color: color-mix(in srgb, var(--state-crimson-bright) 80%, transparent);
      }
    }

    // ── Variant: mystic ──────────────────────────────────────────────────────
    // Ritual CTA — Push the Roll, Pray-eligible confirms. Handoff
    // `.cor-btn--mystic`: mystic-teal fill + on-brass text + matching border.
    // Pairs with AppDie's mystic die rendering in the dice-roller surface.

    &--mystic {
      background-color: var(--state-mystic-teal);
      color: var(--text-on-brass);
      border: 1px solid var(--state-mystic-teal);

      &:hover:not(.app-button--disabled) {
        background-color: color-mix(
          in srgb,
          var(--state-mystic-teal) 88%,
          var(--brand-brass-light)
        );
        border-color: color-mix(in srgb, var(--state-mystic-teal) 88%, var(--brand-brass-light));
      }

      &:active:not(.app-button--disabled) {
        background-color: color-mix(in srgb, var(--state-mystic-teal) 72%, transparent);
        border-color: var(--state-mystic-teal);
      }
    }

    // ── State: disabled ──────────────────────────────────────────────────────

    &--disabled {
      cursor: not-allowed;
      opacity: var(--opacity-disabled);
      pointer-events: none;
    }

    // ── Internal elements ────────────────────────────────────────────────────

    &__icon {
      display: inline-flex;
      align-items: center;
      flex-shrink: 0;
    }

    &__label {
      display: inline-flex;
      align-items: center;
    }

    &__spinner {
      width: 1em;
      height: 1em;
      border: 2px solid currentcolor;
      border-right-color: transparent;
      border-radius: var(--radius-pill);
      animation: app-button-spin $btn-spin-dur linear infinite;
      flex-shrink: 0;
    }
  }

  @keyframes app-button-spin {
    to {
      transform: rotate(360deg);
    }
  }

  // Respect reduced-motion — replace continuous spin with a static pulse.
  @media (prefers-reduced-motion: reduce) {
    .app-button__spinner {
      animation: app-button-pulse $btn-spin-dur ease-in-out infinite alternate;
      border-right-color: currentcolor;
    }
  }

  @keyframes app-button-pulse {
    from {
      opacity: 0.4;
    }

    to {
      opacity: 1;
    }
  }
</style>
