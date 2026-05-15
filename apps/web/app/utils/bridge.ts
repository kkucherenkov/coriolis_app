/**
 * Pure helpers for the Bridge dashboard
 * (`apps/web/app/pages/app/dashboard.vue`).
 *
 * Kept side-effect-free so the formatters are unit-testable without
 * mounting Nuxt / i18n. The dashboard component injects `locale` and
 * `now` at the call site.
 */

/**
 * Curated Coriolis aphorisms — one shows in the Bridge footer per day.
 * Localised copy lives in the dashboard's `<i18n>` block under
 * `aphorism.<key>`. Keep the array in declaration order so new entries
 * can be appended without reshuffling existing day → key mappings.
 */
export const APHORISM_KEYS = ['aphorism.wheel', 'aphorism.icons', 'aphorism.dark'] as const;

export type AphorismKey = (typeof APHORISM_KEYS)[number];

/**
 * Pick today's aphorism deterministically from `now`.
 *
 * Uses the day-of-epoch (ms / 86 400 000, floored) modulo the array
 * length so the same key shows for every page render in the same UTC
 * day, then advances to the next key at midnight UTC. The `((day % N)
 * + N) % N` form keeps the index non-negative for `now` values before
 * the epoch (defensive — should never happen in production).
 */
export function pickAphorism(now: Date, keys: readonly AphorismKey[] = APHORISM_KEYS): AphorismKey {
  if (keys.length === 0) {
    throw new Error('pickAphorism: keys must contain at least one entry');
  }
  const day = Math.floor(now.getTime() / 86_400_000);
  const ix = ((day % keys.length) + keys.length) % keys.length;
  // `ix` is bounded to [0, keys.length); the modulo + length>0 guard above
  // make the lookup total. We still default-coerce to the first entry as a
  // belt-and-braces fallback that keeps TS strict-mode happy without a
  // forbidden non-null assertion (`keys[ix]!`).
  return keys[ix] ?? keys[0] ?? APHORISM_KEYS[0];
}

/** 24-hour clock for the Cycle card (`HH:MM`). */
export function formatCycleClock(now: Date, locale: string): string {
  return new Intl.DateTimeFormat(locale, {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  }).format(now);
}

/** Long-form date for the Cycle card caption (`Friday, 14 May`). */
export function formatCycleDate(now: Date, locale: string): string {
  return new Intl.DateTimeFormat(locale, {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
  }).format(now);
}

/**
 * Format the Sync card caption.
 *
 * Inputs:
 *   - `online` — `navigator.onLine` snapshot at render time.
 *   - `now` — current tick (drives the relative-time delta).
 *   - `lastSyncAt` — timestamp of the last successful backend hit, or
 *     `null` if no fetch has completed yet.
 *   - `locale` — i18n locale for `Intl.RelativeTimeFormat`.
 *   - `t(key)` — i18n message lookup; the dashboard passes
 *     `useI18n().t` directly.
 *
 * Returns one of:
 *   - `t('sync.offline')` if `online` is false
 *   - `t('sync.pending')` if no `lastSyncAt`
 *   - localised relative time (`5 seconds ago`, `2 minutes ago`, …)
 */
export function formatSyncLabel(args: {
  online: boolean;
  now: Date;
  lastSyncAt: Date | null;
  locale: string;
  t: (key: string) => string;
}): string {
  const { online, now, lastSyncAt, locale, t } = args;
  if (!online) return t('sync.offline');
  if (!lastSyncAt) return t('sync.pending');
  const fmt = new Intl.RelativeTimeFormat(locale, { numeric: 'auto' });
  const seconds = Math.round((lastSyncAt.getTime() - now.getTime()) / 1000);
  if (Math.abs(seconds) < 60) return fmt.format(seconds, 'second');
  const minutes = Math.round(seconds / 60);
  if (Math.abs(minutes) < 60) return fmt.format(minutes, 'minute');
  return fmt.format(Math.round(minutes / 60), 'hour');
}
