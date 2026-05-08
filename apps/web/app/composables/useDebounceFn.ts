/**
 * useDebounceFn — minimal debounce composable for apps/web.
 *
 * Returns a debounced version of `fn` and a `cancel` function that clears
 * any pending invocation. Works outside Vue's reactivity system — safe to
 * call inside script setup or plain composables.
 *
 * Intentionally thin; @vueuse/core's useDebounceFn is the upgrade path if
 * that package is ever added.
 */
export function useDebounceFn<T extends unknown[]>(
  fn: (...args: T) => void,
  delay: number,
): { debouncedFn: (...args: T) => void; cancel: () => void } {
  let timer: ReturnType<typeof setTimeout> | null = null;

  function debouncedFn(...args: T): void {
    if (timer !== null) clearTimeout(timer);
    timer = setTimeout(() => {
      timer = null;
      fn(...args);
    }, delay);
  }

  function cancel(): void {
    if (timer !== null) {
      clearTimeout(timer);
      timer = null;
    }
  }

  return { debouncedFn, cancel };
}
