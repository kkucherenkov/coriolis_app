<script setup lang="ts">
  import { nextTick, onUnmounted, watch } from 'vue';

  export interface DrawerLabels {
    /** Accessible label for the drawer dialog. */
    ariaLabel: string;
    /** Accessible label for the close button. */
    closeAriaLabel: string;
  }

  export interface Props {
    /** Whether the drawer is open. Use v-model:open. */
    open: boolean;
    /** Translated labels — no useI18n() in @app/ui components. */
    labels: DrawerLabels;
    /** Side the panel slides in from. */
    side?: 'left' | 'right';
    /**
     * Optional id applied to the inner panel element. Lets the parent set
     * aria-controls on the trigger button that points to this panel.
     */
    panelId?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    side: 'left',
    panelId: undefined,
  });

  const emit = defineEmits<{ 'update:open': [value: boolean] }>();

  defineSlots<{ default?(): unknown }>();

  // ── Refs ───────────────────────────────────────────────────────────────────

  let panelEl: HTMLElement | null = null;

  function setPanelRef(el: HTMLElement | null): void {
    panelEl = el;
  }

  // ── Close helpers ──────────────────────────────────────────────────────────

  function close(): void {
    emit('update:open', false);
  }

  function onOverlayClick(event: MouseEvent): void {
    // Only close when the click is directly on the overlay, not inside the panel.
    if (event.target === event.currentTarget) {
      close();
    }
  }

  // ── ESC handler ────────────────────────────────────────────────────────────

  function onKeydown(event: KeyboardEvent): void {
    if (event.key === 'Escape') {
      event.stopPropagation();
      close();
    }
  }

  // ── Focus trap ─────────────────────────────────────────────────────────────

  function getFocusable(): HTMLElement[] {
    if (!panelEl) return [];
    return [
      ...panelEl.querySelectorAll<HTMLElement>(
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

  // ── Body scroll-lock ───────────────────────────────────────────────────────

  let previousOverflow = '';

  function lockScroll(): void {
    previousOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
  }

  function unlockScroll(): void {
    document.body.style.overflow = previousOverflow;
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  watch(
    () => props.open,
    async (isOpen) => {
      if (isOpen) {
        lockScroll();
        document.addEventListener('keydown', onKeydown);
        await nextTick();
        // Move focus to the close button (first focusable inside panel).
        const focusable = getFocusable();
        if (focusable.length > 0) focusable[0]?.focus();
        panelEl?.addEventListener('keydown', trapFocus);
      } else {
        unlockScroll();
        document.removeEventListener('keydown', onKeydown);
        panelEl?.removeEventListener('keydown', trapFocus);
      }
    },
    { immediate: true },
  );

  onUnmounted(() => {
    unlockScroll();
    document.removeEventListener('keydown', onKeydown);
    panelEl?.removeEventListener('keydown', trapFocus);
  });
</script>

<template>
  <Teleport to="body">
    <Transition name="app-mobile-drawer">
      <div
        v-if="open"
        class="app-mobile-drawer"
        :class="`app-mobile-drawer--${side}`"
        @click="onOverlayClick"
      >
        <div
          :id="panelId"
          :ref="(el) => setPanelRef(el as HTMLElement | null)"
          class="app-mobile-drawer__panel"
          role="dialog"
          aria-modal="true"
          :aria-label="labels.ariaLabel"
        >
          <!-- Close button — always the first focusable element -->
          <button
            class="app-mobile-drawer__close"
            type="button"
            :aria-label="labels.closeAriaLabel"
            @click="close"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="20"
              height="20"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              aria-hidden="true"
            >
              <line x1="18" y1="6" x2="6" y2="18" />
              <line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>

          <!-- Consumer fills this with nav links, user menu, etc. -->
          <div class="app-mobile-drawer__content">
            <slot />
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style lang="scss" scoped>
  // Panel width: fits a phone, never fills the whole screen.
  $panel-width: clamp(280px, 80vw, 360px);

  // Close button — 36px is the icon-button hit target (between space-7=32 and space-8=40).
  $close-button-size: 36px;

  // Animation duration token — components use the standard motion duration.
  $anim-duration: 200ms;

  // ── Overlay ────────────────────────────────────────────────────────────────

  .app-mobile-drawer {
    position: fixed;
    inset: 0;
    z-index: var(--z-modal, 1000);
    background: color-mix(in srgb, var(--surface-void) 75%, transparent);

    // ── Panel ──────────────────────────────────────────────────────────────

    &__panel {
      position: absolute;
      top: 0;
      bottom: 0;
      width: $panel-width;
      display: flex;
      flex-direction: column;
      background: var(--surface-night);
      border-color: var(--brand-brass-deep);
      border-style: solid;
      box-shadow: var(--shadow-brass-bevel), var(--shadow-panel-rise);
      color: var(--text-primary);
      overflow-y: auto;
      padding: var(--space-4);
    }

    // ── Side variants ──────────────────────────────────────────────────────

    &--left .app-mobile-drawer__panel {
      left: 0;
      right: auto;
      border-width: 0 1px 0 0;
      border-radius: 0 var(--radius-lg) var(--radius-lg) 0;
    }

    &--right .app-mobile-drawer__panel {
      right: 0;
      left: auto;
      border-width: 0 0 0 1px;
      border-radius: var(--radius-lg) 0 0 var(--radius-lg);
    }

    // ── Close button ───────────────────────────────────────────────────────

    &__close {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      align-self: flex-end;
      width: $close-button-size;
      height: $close-button-size;
      padding: var(--space-1);
      flex-shrink: 0;
      background: transparent;
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
      color: var(--text-secondary);
      cursor: pointer;
      transition:
        color var(--motion-duration-fast) var(--motion-ease-standard),
        background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        color: var(--brand-brass-light);
        background-color: color-mix(in srgb, var(--brand-brass) 8%, transparent);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    // ── Content area ───────────────────────────────────────────────────────

    &__content {
      flex: 1;
      padding-top: var(--space-4);
    }
  }

  // ── Transition: left slide ─────────────────────────────────────────────────

  .app-mobile-drawer--left {
    &.app-mobile-drawer-enter-from,
    &.app-mobile-drawer-leave-to {
      background: transparent;

      .app-mobile-drawer__panel {
        transform: translateX(-100%);
      }
    }
  }

  // ── Transition: right slide ────────────────────────────────────────────────

  .app-mobile-drawer--right {
    &.app-mobile-drawer-enter-from,
    &.app-mobile-drawer-leave-to {
      background: transparent;

      .app-mobile-drawer__panel {
        transform: translateX(100%);
      }
    }
  }

  // Enter-active / leave-active: both overlay and panel animate.
  .app-mobile-drawer-enter-active {
    transition: background-color $anim-duration ease-out;

    .app-mobile-drawer__panel {
      transition: transform $anim-duration ease-out;
    }
  }

  .app-mobile-drawer-leave-active {
    transition: background-color $anim-duration ease-out;

    .app-mobile-drawer__panel {
      transition: transform $anim-duration ease-out;
    }
  }

  // ── Reduced motion ─────────────────────────────────────────────────────────

  @media (prefers-reduced-motion: reduce) {
    .app-mobile-drawer-enter-active,
    .app-mobile-drawer-leave-active {
      transition: none;

      .app-mobile-drawer__panel {
        transition: none;
      }
    }
  }
</style>
