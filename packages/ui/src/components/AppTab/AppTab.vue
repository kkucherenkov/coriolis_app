<script setup lang="ts">
  import { computed } from 'vue';

  type Size = 'sm' | 'md';
  type Tone = 'brass' | 'mystic';

  interface Props {
    active?: boolean;
    disabled?: boolean;
    size?: Size;
    tone?: Tone;
  }

  const props = withDefaults(defineProps<Props>(), {
    active: false,
    disabled: false,
    size: 'md',
    tone: 'brass',
  });

  const emit = defineEmits<{ click: [event: MouseEvent] }>();

  const classes = computed(() => [
    'app-tab',
    `app-tab--${props.size}`,
    `app-tab--${props.tone}`,
    {
      'app-tab--active': props.active,
      'app-tab--disabled': props.disabled,
    },
  ]);

  function onClick(event: MouseEvent): void {
    if (props.disabled) {
      event.preventDefault();
      event.stopPropagation();
      return;
    }
    emit('click', event);
  }
</script>

<template>
  <button
    type="button"
    role="tab"
    :class="classes"
    :disabled="disabled"
    :aria-selected="active ? 'true' : 'false'"
    :aria-disabled="disabled ? 'true' : undefined"
    :tabindex="active ? 0 : -1"
    @click="onClick"
  >
    <span
      v-if="$slots['icon-leading']"
      class="app-tab__icon"
      aria-hidden="true"
    >
      <slot name="icon-leading" />
    </span>
    <span class="app-tab__label">
      <slot />
    </span>
  </button>
</template>

<style lang="scss" scoped>
  // Underline thickness — not a spacing token, intentionally sub-1 space unit.
  // SCSS variable is the approved escape hatch (see AppIcon convention).
  $tab-underline-h: 2px;
  $tab-underline-gap: 3px;

  .app-tab {
    position: relative;
    display: inline-flex;
    align-items: center;
    gap: var(--space-2);
    background: transparent;
    border: none;
    border-radius: 0;
    padding-bottom: calc(var(--space-1) + $tab-underline-gap + $tab-underline-h);
    cursor: pointer;
    white-space: nowrap;
    font-family: var(--type-body-md-font-family);
    font-weight: var(--type-body-md-font-weight);
    line-height: var(--type-body-md-line-height);
    color: var(--text-secondary);
    user-select: none;
    transition: color var(--motion-duration-fast) var(--motion-ease-standard);

    // Underline pseudo-element — positioned at the very bottom of the button,
    // separated by a small gap. Rendered as ::after so no extra DOM node is
    // needed and scoped SCSS can target it cleanly.
    &::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      height: $tab-underline-h;
      border-radius: $tab-underline-h;
      background: transparent;
      transition:
        background-color var(--motion-duration-fast) var(--motion-ease-standard),
        opacity var(--motion-duration-fast) var(--motion-ease-standard);
    }

    // ── Focus ────────────────────────────────────────────────────────────────

    &:focus-visible {
      outline: 2px solid var(--brand-brass);
      outline-offset: 2px;
    }

    // ── Size modifiers ────────────────────────────────────────────────────────

    &--sm {
      font-size: var(--type-body-sm-font-size);
      line-height: var(--type-body-sm-line-height);
      padding-top: var(--space-1);
      padding-inline: var(--space-2);
      padding-bottom: calc(var(--space-1) + $tab-underline-gap + $tab-underline-h);
    }

    &--md {
      font-size: var(--type-body-md-font-size);
      line-height: var(--type-body-md-line-height);
      padding-top: var(--space-2);
      padding-inline: var(--space-3);
      padding-bottom: calc(var(--space-2) + $tab-underline-gap + $tab-underline-h);
    }

    // ── Tone: brass ──────────────────────────────────────────────────────────

    &--brass {
      &:hover:not(.app-tab--disabled):not(.app-tab--active) {
        color: var(--text-primary);

        &::after {
          background: color-mix(in srgb, var(--brand-brass) 30%, transparent);
        }
      }

      &.app-tab--active {
        color: var(--brand-brass-light);

        &::after {
          background: var(--brand-brass);
        }
      }
    }

    // ── Tone: mystic ─────────────────────────────────────────────────────────

    &--mystic {
      &:hover:not(.app-tab--disabled):not(.app-tab--active) {
        color: var(--text-primary);

        &::after {
          background: color-mix(in srgb, var(--state-mystic-teal) 30%, transparent);
        }
      }

      &.app-tab--active {
        color: var(--state-mystic-teal);

        &::after {
          background: var(--state-mystic-teal);
        }
      }
    }

    // ── State: disabled ──────────────────────────────────────────────────────

    &--disabled {
      cursor: not-allowed;
      opacity: var(--opacity-disabled);
      pointer-events: none;
    }

    // ── Internal elements ─────────────────────────────────────────────────────

    &__icon {
      display: inline-flex;
      align-items: center;
      flex-shrink: 0;
    }

    &__label {
      display: inline-flex;
      align-items: center;
    }
  }
</style>
