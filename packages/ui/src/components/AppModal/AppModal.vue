<script setup lang="ts">
  import { computed, nextTick, onUnmounted, ref, watch } from 'vue';

  type Size = 'sm' | 'md' | 'lg';

  interface Props {
    /** Controlled open state; v-model:open binding. */
    open?: boolean;
    /** Optional accessible label for the dialog. Required for screen readers when no labelledby. */
    ariaLabel?: string;
    /** Optional aria-labelledby — pass an id of a heading element inside the modal. */
    ariaLabelledby?: string;
    /** Closes on click on the backdrop (default: true). */
    closeOnBackdrop?: boolean;
    /** Closes on Escape (default: true). */
    closeOnEsc?: boolean;
    /** Width preset. */
    size?: Size;
  }

  const props = withDefaults(defineProps<Props>(), {
    open: false,
    ariaLabel: undefined,
    ariaLabelledby: undefined,
    closeOnBackdrop: true,
    closeOnEsc: true,
    size: 'md',
  });

  const emit = defineEmits<{ 'update:open': [value: boolean] }>();

  defineSlots<{
    default(): unknown;
    trigger?(): unknown;
    footer?(): unknown;
  }>();

  const panelRef = ref<HTMLElement | null>(null);
  const triggerRef = ref<HTMLElement | null>(null);

  // Track the element that triggered the modal open so focus can be returned.
  let priorFocus: HTMLElement | null = null;

  function close(): void {
    emit('update:open', false);
  }

  function onTriggerClick(): void {
    emit('update:open', !props.open);
  }

  function onBackdropClick(event: MouseEvent): void {
    if (!props.closeOnBackdrop) return;
    // Only close if the click landed directly on the backdrop, not inside the panel.
    if (event.target === event.currentTarget) {
      close();
    }
  }

  function onKeydown(event: KeyboardEvent): void {
    if (event.key === 'Escape' && props.open && props.closeOnEsc) {
      event.stopPropagation();
      close();
    }
  }

  // ── Focus trap ─────────────────────────────────────────────────────────────

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
        document.addEventListener('keydown', onKeydown);
        // Move focus into the panel on next tick so the DOM is visible.
        await nextTick();
        const focusable = getFocusable();
        if (focusable.length > 0) focusable[0]?.focus();
        panelRef.value?.addEventListener('keydown', trapFocus);
      } else {
        document.removeEventListener('keydown', onKeydown);
        panelRef.value?.removeEventListener('keydown', trapFocus);
        // Return focus to the element that opened the modal.
        priorFocus?.focus();
        priorFocus = null;
      }
    },
    { immediate: true },
  );

  onUnmounted(() => {
    document.removeEventListener('keydown', onKeydown);
    panelRef.value?.removeEventListener('keydown', trapFocus);
  });

  // ── Computed ────────────────────────────────────────────────────────────────

  const panelClasses = computed(() => ['app-modal__panel', `app-modal__panel--${props.size}`]);
</script>

<template>
  <!-- Optional trigger slot — wrapped so we can track the ref. -->
  <div v-if="$slots['trigger']" ref="triggerRef" class="app-modal__trigger" @click="onTriggerClick">
    <slot name="trigger" />
  </div>

  <!-- Teleport to body so the modal is always on top of everything. -->
  <Teleport to="body">
    <Transition name="app-modal">
      <div
        v-if="open"
        class="app-modal__backdrop"
        role="dialog"
        aria-modal="true"
        :aria-label="ariaLabel || undefined"
        :aria-labelledby="ariaLabelledby || undefined"
        @click="onBackdropClick"
      >
        <div ref="panelRef" :class="panelClasses">
          <div class="app-modal__body">
            <slot />
          </div>

          <div v-if="$slots['footer']" class="app-modal__footer">
            <slot name="footer" />
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style lang="scss" scoped>
  // Panel width presets — layout constants below the spacing scale.
  $panel-sm: 360px;
  $panel-md: 520px;
  $panel-lg: 720px;

  // ── Backdrop ────────────────────────────────────────────────────────────────

  .app-modal {
    &__trigger {
      display: contents;
    }

    &__backdrop {
      position: fixed;
      inset: 0;
      z-index: var(--z-modal);
      display: flex;
      align-items: center;
      justify-content: center;
      padding: var(--space-4);
      background: color-mix(in srgb, var(--surface-void) 75%, transparent);
    }

    // ── Panel surface ──────────────────────────────────────────────────────

    &__panel {
      position: relative;
      display: flex;
      flex-direction: column;
      max-height: calc(100vh - var(--space-8));
      width: 100%;
      background: var(--surface-night);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-lg);
      box-shadow: var(--shadow-brass-bevel), var(--shadow-panel-rise);
      color: var(--text-primary);
      overflow: hidden;

      &--sm {
        max-width: $panel-sm;
      }

      &--md {
        max-width: $panel-md;
      }

      &--lg {
        max-width: $panel-lg;
      }
    }

    // ── Body / footer sections ─────────────────────────────────────────────

    &__body {
      flex: 1;
      overflow-y: auto;
      padding: var(--space-6);
    }

    &__footer {
      flex-shrink: 0;
      padding: var(--space-4) var(--space-6);
      border-top: 1px solid var(--brand-brass-deep);
      display: flex;
      align-items: center;
      justify-content: flex-end;
      gap: var(--space-3);
    }
  }

  // ── Entrance / exit animation ───────────────────────────────────────────────

  .app-modal-enter-active {
    transition:
      opacity var(--motion-duration) var(--motion-ease-standard),
      scale var(--motion-duration) var(--motion-ease-standard);
  }

  .app-modal-leave-active {
    transition:
      opacity var(--motion-duration-fast) var(--motion-ease-standard),
      scale var(--motion-duration-fast) var(--motion-ease-standard);
  }

  .app-modal-enter-from,
  .app-modal-leave-to {
    opacity: 0;

    .app-modal__panel {
      scale: 0.96;
    }
  }

  // Respect reduced-motion — fade only, no scale.
  @media (prefers-reduced-motion: reduce) {
    .app-modal-enter-active,
    .app-modal-leave-active {
      transition: opacity var(--motion-duration) var(--motion-ease-standard);
    }

    .app-modal-enter-from,
    .app-modal-leave-to {
      .app-modal__panel {
        scale: 1;
      }
    }
  }
</style>
