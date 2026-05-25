import { nextTick, onUnmounted, watch, type Ref } from 'vue';

const FOCUSABLE_SELECTOR =
  'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])';

/**
 * Trap keyboard focus inside `panelRef` while `isActive()` is true.
 *
 * On activation: remembers the previously-focused element, moves focus to the
 * first focusable inside the panel (next tick, after the DOM paints), and wraps
 * Tab / Shift+Tab within the panel. On deactivation: returns focus to the
 * element that held it before. Esc / backdrop behaviour is intentionally NOT
 * handled here, it varies per surface (a modal closes on Esc; the invite reveal
 * deliberately does not), so callers own that.
 *
 * Shared by AppModal and AppInviteManager so the two modal-shaped surfaces use
 * one focus implementation rather than diverging copies.
 */
export function useFocusTrap(panelRef: Ref<HTMLElement | null>, isActive: () => boolean): void {
  let priorFocus: HTMLElement | null = null;

  function getFocusable(): HTMLElement[] {
    if (!panelRef.value) return [];
    return [...panelRef.value.querySelectorAll<HTMLElement>(FOCUSABLE_SELECTOR)];
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
    } else if (document.activeElement === last) {
      event.preventDefault();
      first.focus();
    }
  }

  watch(
    isActive,
    async (active) => {
      if (active) {
        priorFocus = document.activeElement as HTMLElement | null;
        await nextTick();
        const focusable = getFocusable();
        if (focusable.length > 0) focusable[0]?.focus();
        panelRef.value?.addEventListener('keydown', trapFocus);
      } else {
        panelRef.value?.removeEventListener('keydown', trapFocus);
        priorFocus?.focus();
        priorFocus = null;
      }
    },
    { immediate: true },
  );

  onUnmounted(() => {
    panelRef.value?.removeEventListener('keydown', trapFocus);
  });
}
