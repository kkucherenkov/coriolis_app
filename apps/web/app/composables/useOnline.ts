import { onBeforeUnmount, onMounted, readonly, ref } from 'vue';

/**
 * Reactive `navigator.onLine`.
 *
 * SSR-safe: returns `true` until the component mounts (SSR has no
 * `navigator`, and we'd rather not flash an offline banner during hydration
 * on the rare case `ssr: false` is ever toggled back on for a route).
 *
 * Browser-only signal: `navigator.onLine` is best-effort — it tells you the
 * OS thinks there's a network, not that the API is reachable. Pair with
 * actual fetch errors when deciding whether to disable mutations.
 */
export function useOnline() {
  const online = ref(true);

  function update(): void {
    online.value = typeof navigator === 'undefined' ? true : navigator.onLine;
  }

  function onOnline(): void {
    online.value = true;
  }

  function onOffline(): void {
    online.value = false;
  }

  onMounted(() => {
    update();
    globalThis.addEventListener('online', onOnline);
    globalThis.addEventListener('offline', onOffline);
  });

  onBeforeUnmount(() => {
    globalThis.removeEventListener('online', onOnline);
    globalThis.removeEventListener('offline', onOffline);
  });

  return { online: readonly(online) };
}
