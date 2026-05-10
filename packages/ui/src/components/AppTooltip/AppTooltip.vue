<script setup lang="ts">
  import { computed, onMounted, onUnmounted, ref, useId } from 'vue';

  type Placement = 'top' | 'right' | 'bottom' | 'left';

  interface Props {
    content: string;
    placement?: Placement;
    delay?: number;
    disabled?: boolean;
  }

  const props = withDefaults(defineProps<Props>(), {
    placement: 'top',
    delay: 300,
    disabled: false,
  });

  // useId() is Vue 3.5+ — generates a stable SSR-safe id per instance.
  // We use it to connect the trigger to the panel via aria-describedby.
  const panelId = useId();

  const visible = ref(false);
  let showTimer: ReturnType<typeof setTimeout> | null = null;

  function clearTimer(): void {
    if (showTimer !== null) {
      clearTimeout(showTimer);
      showTimer = null;
    }
  }

  function show(): void {
    if (props.disabled) return;
    clearTimer();
    showTimer = setTimeout(() => {
      visible.value = true;
    }, props.delay);
  }

  function hide(): void {
    clearTimer();
    visible.value = false;
  }

  function onFocusin(): void {
    if (props.disabled) return;
    // Focus shows immediately — no delay; keyboard users shouldn't wait.
    visible.value = true;
  }

  function onFocusout(): void {
    hide();
  }

  function onEscape(event: KeyboardEvent): void {
    if (event.key === 'Escape' && visible.value) {
      hide();
    }
  }

  onMounted(() => {
    document.addEventListener('keydown', onEscape);
  });

  onUnmounted(() => {
    document.removeEventListener('keydown', onEscape);
    clearTimer();
  });

  const rootClasses = computed(() => [
    'app-tooltip',
    `app-tooltip--${props.placement}`,
    { 'app-tooltip--visible': visible.value },
    { 'app-tooltip--disabled': props.disabled },
  ]);
</script>

<template>
  <span
    :class="rootClasses"
    @mouseenter="show"
    @mouseleave="hide"
    @focusin="onFocusin"
    @focusout="onFocusout"
  >
    <!--
      Positional tooltip — v1 limitations:
      - No smart-flip on edge collision. Place the trigger away from viewport edges,
        or swap `placement` yourself.
      - `aria-describedby` is forwarded as a scoped-slot prop for the consumer to
        bind manually on the trigger element (simplest approach; avoids traversing
        default-slot vnodes at runtime).
    -->
    <slot :aria-describedby="panelId" />
    <div :id="panelId" class="app-tooltip__panel" role="tooltip" :aria-hidden="!visible">
      {{ content }}
    </div>
  </span>
</template>

<style lang="scss" scoped>
  // Arrow size — sub-token dimension, SCSS variable approved.
  $arrow-size: 5px;
  // Tooltip max-width — sub-token layout dimension, SCSS variable approved.
  $tooltip-max-width: 240px;

  .app-tooltip {
    position: relative;
    display: inline-flex;
    align-items: center;

    // ── Panel ──────────────────────────────────────────────────────────────────

    &__panel {
      position: absolute;
      z-index: var(--z-tooltip);
      max-width: $tooltip-max-width;
      padding: var(--space-1) var(--space-2);
      background: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-sm);
      box-shadow: var(--shadow-panel-rise);
      color: var(--text-primary);
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      line-height: var(--type-body-sm-line-height);
      font-weight: var(--type-body-sm-font-weight);
      white-space: nowrap;
      pointer-events: none;

      // Hidden by default — toggled via visible class on parent.
      opacity: 0;
      visibility: hidden;
      transition:
        opacity var(--motion-duration-fast) var(--motion-ease-standard),
        visibility var(--motion-duration-fast) var(--motion-ease-standard);

      // Arrow pseudo-element — brass-deep triangle.
      &::after {
        content: '';
        position: absolute;
        border: $arrow-size solid transparent;
      }
    }

    // ── Visible state ──────────────────────────────────────────────────────────

    &--visible .app-tooltip__panel {
      opacity: 1;
      visibility: visible;
    }

    // ── Placement: top (default) ───────────────────────────────────────────────

    &--top .app-tooltip__panel {
      bottom: calc(100% + var(--space-2));
      left: 50%;
      transform: translateX(-50%);

      &::after {
        top: 100%;
        left: 50%;
        transform: translateX(-50%);
        border-top-color: var(--brand-brass-shadow);
      }
    }

    // ── Placement: bottom ──────────────────────────────────────────────────────

    &--bottom .app-tooltip__panel {
      top: calc(100% + var(--space-2));
      left: 50%;
      transform: translateX(-50%);

      &::after {
        bottom: 100%;
        left: 50%;
        transform: translateX(-50%);
        border-bottom-color: var(--brand-brass-shadow);
      }
    }

    // ── Placement: right ───────────────────────────────────────────────────────

    &--right .app-tooltip__panel {
      left: calc(100% + var(--space-2));
      top: 50%;
      transform: translateY(-50%);

      &::after {
        right: 100%;
        top: 50%;
        transform: translateY(-50%);
        border-right-color: var(--brand-brass-shadow);
      }
    }

    // ── Placement: left ────────────────────────────────────────────────────────

    &--left .app-tooltip__panel {
      right: calc(100% + var(--space-2));
      top: 50%;
      transform: translateY(-50%);

      &::after {
        left: 100%;
        top: 50%;
        transform: translateY(-50%);
        border-left-color: var(--brand-brass-shadow);
      }
    }

    // ── Disabled: panel never shows ────────────────────────────────────────────

    &--disabled .app-tooltip__panel {
      display: none;
    }
  }

  // Respect reduced-motion preference — no fade transition.
  @media (prefers-reduced-motion: reduce) {
    .app-tooltip__panel {
      transition: none;
    }
  }
</style>
