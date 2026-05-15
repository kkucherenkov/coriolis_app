<script setup lang="ts">
  import { ref, onMounted, computed } from 'vue';
  import { AppModal, AppDiePool, AppBadge } from '@app/ui';
  import { useRollsApi } from '~/composables/useRollsApi';
  import type { Roll } from '~/composables/useRollsApi';
  import type { Problem } from '@app/api-client-ts';

  /**
   * Reverse-chronological roll history for the character sheet (Phase 4
   * Feature 7.1). Fetches the last 50 rolls on mount; the parent injects
   * fresh rolls via `prependRoll` (after `SheetDiceRoller` creates one)
   * and updates an existing row via `updateRoll` (after a push). We
   * deliberately don't refetch on every roll change — the API is paged
   * to 50 and a fresh GET would race against the server's still-being-
   * persisted insert.
   *
   * Row click opens an `AppModal` with the full dice strip + label +
   * pushed flag. The Coriolis push convention surfaces by passing the
   * indices of non-six dice as `pushedIndices` so the modal die-pool
   * dims them — same visual contract as the live roller above.
   */

  type DieValue = 1 | 2 | 3 | 4 | 5 | 6;

  interface Props {
    characterId: string;
  }

  const props = defineProps<Props>();

  const { t, locale } = useI18n({ useScope: 'local' });
  const rollsApi = useRollsApi();

  const rolls = ref<Roll[]>([]);
  const loading = ref(true);
  const errorMsg = ref('');
  const modalRoll = ref<Roll | null>(null);

  onMounted(async () => {
    loading.value = true;
    errorMsg.value = '';
    try {
      const list = await rollsApi.listRolls(props.characterId, 50);
      rolls.value = [...list];
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorLoad');
    } finally {
      loading.value = false;
    }
  });

  function prependRoll(roll: Roll): void {
    // De-dupe: a server-side retry could legitimately surface the same
    // id twice. Drop the older copy on collision so the strip stays
    // monotonic.
    rolls.value = [roll, ...rolls.value.filter((r) => r.id !== roll.id)].slice(0, 50);
  }

  function updateRoll(roll: Roll): void {
    rolls.value = rolls.value.map((r) => (r.id === roll.id ? roll : r));
  }

  // Parent component reaches into these from SheetDiceRoller's
  // rollCreated / rollPushed events — see [id].vue.
  defineExpose({ prependRoll, updateRoll });

  function asDieValues(dice: readonly number[]): DieValue[] {
    return dice.map((n) => n as DieValue);
  }

  function pushedIndicesFor(roll: Roll): number[] {
    if (!roll.pushed) return [];
    const out: number[] = [];
    for (const [index, value] of roll.dice.entries()) {
      if (value !== 6) out.push(index);
    }
    return out;
  }

  // Compact relative timestamp ("just now", "3m", "2h", "yesterday",
  // "May 09"). The history list is dense so we trade absolute precision
  // for visual rhythm; the modal shows the full ISO datetime.
  function relativeTime(iso: string): string {
    const then = new Date(iso).getTime();
    const now = Date.now();
    const seconds = Math.max(0, Math.floor((now - then) / 1000));
    if (seconds < 45) return t('relative.justNow');
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return t('relative.minutes', { n: minutes });
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return t('relative.hours', { n: hours });
    const days = Math.floor(hours / 24);
    if (days < 2) return t('relative.yesterday');
    if (days < 7) return t('relative.days', { n: days });
    return new Date(iso).toLocaleDateString(locale.value, {
      month: 'short',
      day: 'numeric',
    });
  }

  function absoluteTime(iso: string): string {
    return new Date(iso).toLocaleString(locale.value, {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  }

  function openModal(roll: Roll): void {
    modalRoll.value = roll;
  }

  function closeModal(): void {
    modalRoll.value = null;
  }

  const hasRolls = computed(() => rolls.value.length > 0);
</script>

<i18n lang="json">
{
  "en": {
    "header": "History",
    "loading": "Loading rolls…",
    "empty": "No rolls yet.",
    "errorLoad": "Couldn't load roll history.",
    "hits": "{n} hit | {n} hits",
    "pushed": "Pushed",
    "modalTitle": "Roll detail",
    "modalLabel": "Label",
    "modalPool": "Pool",
    "modalHits": "Hits",
    "modalRolledAt": "Rolled at",
    "modalClose": "Close",
    "relative": {
      "justNow": "just now",
      "minutes": "{n}m ago",
      "hours": "{n}h ago",
      "yesterday": "yesterday",
      "days": "{n}d ago"
    }
  },
  "ru": {
    "header": "История",
    "loading": "Загружаем броски…",
    "empty": "Бросков пока нет.",
    "errorLoad": "Не удалось загрузить историю бросков.",
    "hits": "{n} успех | {n} успеха | {n} успехов",
    "pushed": "Дожато",
    "modalTitle": "Детали броска",
    "modalLabel": "Название",
    "modalPool": "Пул",
    "modalHits": "Успехи",
    "modalRolledAt": "Время",
    "modalClose": "Закрыть",
    "relative": {
      "justNow": "только что",
      "minutes": "{n} мин назад",
      "hours": "{n} ч назад",
      "yesterday": "вчера",
      "days": "{n} дн назад"
    }
  },
  "uk": {
    "header": "[uk-todo] History",
    "loading": "[uk-todo] Loading rolls",
    "empty": "[uk-todo] No rolls yet",
    "errorLoad": "[uk-todo] Couldn't load history",
    "hits": "[uk-todo] {n} hits",
    "pushed": "[uk-todo] Pushed",
    "modalTitle": "[uk-todo] Roll detail",
    "modalLabel": "[uk-todo] Label",
    "modalPool": "[uk-todo] Pool",
    "modalHits": "[uk-todo] Hits",
    "modalRolledAt": "[uk-todo] Rolled at",
    "modalClose": "[uk-todo] Close",
    "relative": {
      "justNow": "[uk-todo] just now",
      "minutes": "[uk-todo] {n}m ago",
      "hours": "[uk-todo] {n}h ago",
      "yesterday": "[uk-todo] yesterday",
      "days": "[uk-todo] {n}d ago"
    }
  },
  "el": {
    "header": "[el-todo] History",
    "loading": "[el-todo] Loading rolls",
    "empty": "[el-todo] No rolls yet",
    "errorLoad": "[el-todo] Couldn't load history",
    "hits": "[el-todo] {n} hits",
    "pushed": "[el-todo] Pushed",
    "modalTitle": "[el-todo] Roll detail",
    "modalLabel": "[el-todo] Label",
    "modalPool": "[el-todo] Pool",
    "modalHits": "[el-todo] Hits",
    "modalRolledAt": "[el-todo] Rolled at",
    "modalClose": "[el-todo] Close",
    "relative": {
      "justNow": "[el-todo] just now",
      "minutes": "[el-todo] {n}m ago",
      "hours": "[el-todo] {n}h ago",
      "yesterday": "[el-todo] yesterday",
      "days": "[el-todo] {n}d ago"
    }
  }
}
</i18n>

<template>
  <div class="roll-history" data-testid="sheet-roll-history">
    <h4 class="roll-history__header">
      {{ t('header') }}
    </h4>

    <p v-if="loading" class="roll-history__placeholder">
      {{ t('loading') }}
    </p>

    <p v-else-if="errorMsg" class="roll-history__error" role="alert">
      {{ errorMsg }}
    </p>

    <p v-else-if="!hasRolls" class="roll-history__placeholder">
      {{ t('empty') }}
    </p>

    <ul v-else class="roll-history__list" role="list">
      <li v-for="roll in rolls" :key="roll.id" class="roll-history__row">
        <button type="button" class="roll-history__row-btn" @click="openModal(roll)">
          <span class="roll-history__row-label">{{ roll.label }}</span>
          <span class="roll-history__row-meta">
            <AppBadge variant="brass" size="sm">
              {{ t('hits', { n: roll.hits }) }}
            </AppBadge>
            <AppBadge v-if="roll.pushed" variant="mystic" size="sm">
              {{ t('pushed') }}
            </AppBadge>
            <span class="roll-history__row-time">
              {{ relativeTime(roll.createdAt) }}
            </span>
          </span>
        </button>
      </li>
    </ul>

    <AppModal
      :open="modalRoll !== null"
      :aria-label="t('modalTitle')"
      size="md"
      data-testid="sheet-roll-history-modal"
      close-on-backdrop
      @update:open="(v: boolean) => !v && closeModal()"
    >
      <div v-if="modalRoll" class="roll-history__modal">
        <h2 class="roll-history__modal-title">
          {{ t('modalTitle') }}
        </h2>
        <dl class="roll-history__detail">
          <div class="roll-history__detail-row">
            <dt>{{ t('modalLabel') }}</dt>
            <dd>{{ modalRoll.label }}</dd>
          </div>
          <div class="roll-history__detail-row">
            <dt>{{ t('modalPool') }}</dt>
            <dd>{{ modalRoll.pool }}</dd>
          </div>
          <div class="roll-history__detail-row">
            <dt>{{ t('modalHits') }}</dt>
            <dd>{{ modalRoll.hits }}</dd>
          </div>
          <div class="roll-history__detail-row">
            <dt>{{ t('modalRolledAt') }}</dt>
            <dd>{{ absoluteTime(modalRoll.createdAt) }}</dd>
          </div>
        </dl>

        <div class="roll-history__detail-dice">
          <AppDiePool
            :values="asDieValues(modalRoll.dice)"
            :pushed-indices="pushedIndicesFor(modalRoll)"
            size="md"
            tone="brass"
          />
        </div>
      </div>
    </AppModal>
  </div>
</template>

<style lang="scss" scoped>
  .roll-history {
    display: flex;
    flex-direction: column;
    gap: var(--space-2);
    margin-top: var(--space-4);
    padding-top: var(--space-3);
    border-top: 1px solid var(--brand-brass-shadow);

    &__header {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
      letter-spacing: 0.06em;
      text-transform: uppercase;
    }

    &__placeholder {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__error {
      margin: 0;
      padding: var(--space-2) var(--space-3);
      border-radius: var(--radius-sm);
      background: var(--status-danger-soft);
      color: var(--status-danger);
      font-size: var(--type-body-sm-font-size);
    }

    &__list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
      max-height: 18rem;
      overflow-y: auto;
    }

    &__row {
      margin: 0;
    }

    &__row-btn {
      width: 100%;
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: var(--space-3);
      padding: var(--space-2) var(--space-3);
      background: transparent;
      border: 1px solid transparent;
      border-radius: var(--radius-sm);
      cursor: pointer;
      text-align: left;
      font: inherit;
      color: inherit;
      transition:
        background-color var(--motion-duration-fast) var(--motion-ease-standard),
        border-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        background: color-mix(in srgb, var(--brand-brass-shadow) 25%, transparent);
        border-color: var(--brand-brass-shadow);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    &__row-label {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
      flex: 1;
      min-width: 0;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    &__row-meta {
      display: inline-flex;
      align-items: center;
      gap: var(--space-2);
      flex-shrink: 0;
    }

    &__row-time {
      font-family: var(--font-mono);
      font-size: var(--type-body-xs-font-size);
      color: var(--text-tertiary);
    }

    &__detail {
      margin: 0;
      display: grid;
      grid-template-columns: max-content 1fr;
      gap: var(--space-2) var(--space-4);
    }

    &__detail-row {
      display: contents;

      dt {
        font-family: var(--font-body);
        font-size: var(--type-body-sm-font-size);
        color: var(--text-secondary);
      }

      dd {
        margin: 0;
        font-family: var(--font-body);
        font-size: var(--type-body-sm-font-size);
        color: var(--text-primary);
      }
    }

    &__detail-dice {
      margin-top: var(--space-4);
      display: flex;
      justify-content: center;
    }

    &__modal {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
    }

    &__modal-title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }
  }
</style>
