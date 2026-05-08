<script setup lang="ts">
  import { computed, nextTick, onUnmounted, ref, watch } from 'vue';

  type Placement = 'top' | 'bottom' | 'left' | 'right';

  interface Props {
    open?: boolean;
    placement?: Placement;
    ariaLabel?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    open: false,
    placement: 'bottom',
    ariaLabel: undefined,
  });

  const emit = defineEmits<{ 'update:open': [value: boolean] }>();

  defineSlots<{
    default(): unknown;
    trigger?(): unknown;
  }>();

  const triggerRef = ref<HTMLElement | null>(null);
  const panelRef = ref<HTMLElement | null>(null);

  // Focus management: save element that opened the popover.
  let priorFocus: HTMLElement | null = null;

  function close(): void {
    emit('update:open', false);
  }

  function onTriggerClick(): void {
    emit('update:open', !props.open);
  }

  function onKeydown(event: KeyboardEvent): void {
    if (event.key === 'Escape' && props.open) {
      event.stopPropagation();
      close();
    }
  }

  function onDocumentClick(event: MouseEvent): void {
    if (!props.open) return;
    const target = event.target as Node;
    const insideTrigger = triggerRef.value?.contains(target) ?? false;
    const insidePanel = panelRef.value?.contains(target) ?? false;
    if (!insideTrigger && !insidePanel) {
      close();
    }
  }

  // Trap focus inside the panel while open.
  function getFocusable(): HTMLElement[] {
    if (!panelRef.value) return [];
    return [
      ...panelRef.value.querySelectorAll<HTMLElement>(
        'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])',
      ),
    ];
  }

  function trapFocus(event: KeyboardEvent): void {
    if (event.key !== 'Tab') return;
    const focusable = getFocusable();
    if (focusable.length === 0) return;
    const first = focusable[0];
    if (!first) return;
    const last = focusable.at(-1) ?? first;
    if (event.shiftKey) {
      if (document.activeElement === first) {
        event.preventDefault();
        last.focus();
      }
    } else {
      if (document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    }
  }

  watch(
    () => props.open,
    async (isOpen) => {
      if (isOpen) {
        priorFocus = document.activeElement as HTMLElement | null;
        document.addEventListener('click', onDocumentClick, { capture: true });
        document.addEventListener('keydown', onKeydown);
        // Move focus into panel on next tick so DOM is visible.
        await nextTick();
        const focusable = getFocusable();
        if (focusable.length > 0) focusable[0]?.focus();
        panelRef.value?.addEventListener('keydown', trapFocus);
      } else {
        document.removeEventListener('click', onDocumentClick, { capture: true });
        document.removeEventListener('keydown', onKeydown);
        panelRef.value?.removeEventListener('keydown', trapFocus);
        // Return focus to the element that opened the popover.
        priorFocus?.focus();
        priorFocus = null;
      }
    },
    { immediate: true },
  );

  onUnmounted(() => {
    document.removeEventListener('click', onDocumentClick, { capture: true });
    document.removeEventListener('keydown', onKeydown);
    panelRef.value?.removeEventListener('keydown', trapFocus);
  });

  const rootClasses = computed(() => [
    'app-popover',
    `app-popover--${props.placement}`,
    { 'app-popover--open': props.open },
  ]);
</script>

<template>
  <div :class="rootClasses">
    <!-- Trigger wrapper — click toggles the panel. -->
    <div ref="triggerRef" class="app-popover__trigger" @click="onTriggerClick">
      <slot name="trigger" />
    </div>

    <!-- Popover surface — brass-bevel styled panel. -->
    <div
      v-if="open"
      ref="panelRef"
      class="app-popover__panel"
      role="dialog"
      :aria-label="props.ariaLabel || undefined"
      :aria-modal="true"
    >
      <slot />
    </div>
  </div>
</template>

<style lang="scss" scoped>
  // Minimum panel width — layout constant; not a spacing-scale value.
  $panel-min-width: 180px;

  .app-popover {
    position: relative;
    display: inline-flex;
    align-items: flex-start;

    // ── Trigger wrapper ────────────────────────────────────────────────────────

    &__trigger {
      display: contents;
    }

    // ── Panel surface ──────────────────────────────────────────────────────────

    &__panel {
      position: absolute;
      z-index: var(--z-dropdown);
      min-width: $panel-min-width;
      padding: var(--space-3);
      background: var(--surface-night);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
      box-shadow: var(--shadow-brass-bevel), var(--shadow-panel-rise);
      color: var(--text-primary);

      // Entrance animation — scale + fade from the panel origin.
      animation: app-popover-enter var(--motion-duration) var(--motion-ease-standard) both;
    }

    // ── Placement: bottom (default) ────────────────────────────────────────────

    &--bottom .app-popover__panel {
      top: calc(100% + var(--space-2));
      left: 50%;
      transform: translateX(-50%);
    }

    // ── Placement: top ─────────────────────────────────────────────────────────

    &--top .app-popover__panel {
      bottom: calc(100% + var(--space-2));
      left: 50%;
      transform: translateX(-50%);
    }

    // ── Placement: right ───────────────────────────────────────────────────────

    &--right .app-popover__panel {
      left: calc(100% + var(--space-2));
      top: 50%;
      transform: translateY(-50%);
    }

    // ── Placement: left ────────────────────────────────────────────────────────

    &--left .app-popover__panel {
      right: calc(100% + var(--space-2));
      top: 50%;
      transform: translateY(-50%);
    }
  }

  // ── Entrance keyframes ─────────────────────────────────────────────────────

  @keyframes app-popover-enter {
    from {
      opacity: 0;
      scale: 0.96;
    }

    to {
      opacity: 1;
      scale: 1;
    }
  }

  // Respect reduced-motion preference — skip scale/translate animation.
  @media (prefers-reduced-motion: reduce) {
    .app-popover__panel {
      animation: none;
    }
  }
</style>
