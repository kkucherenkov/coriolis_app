<script setup lang="ts">
  import { ref, computed } from 'vue';
  import { AppButton, AppInput, AppField, AppDiePool, AppBanner } from '@app/ui';
  import { useRollsApi } from '~/composables/useRollsApi';
  import type { Roll } from '~/composables/useRollsApi';
  import type { Problem } from '@app/api-client-ts';

  /**
   * Coriolis ST3001 dice roller (player view, Phase 4 Feature 7.1).
   *
   * Server holds the RNG — this widget describes a roll (label + pool size)
   * and renders whatever the server sends back. The push mechanic also
   * round-trips through the server: PATCH `/rolls/{id}/push` rerolls the
   * non-six dice and returns the same Roll shape with updated `dice` and
   * `pushed: true`.
   *
   * The push button is gated on:
   *   - a roll exists and hasn't already been pushed; and
   *   - the character isn't currently `exhausted` (RulesEngine.canPush will
   *     return `{ ok: false, reason: 'exhausted' }`, but disabling client-
   *     side avoids the round-trip and surfaces the rule visually).
   */

  type DieValue = 1 | 2 | 3 | 4 | 5 | 6;

  interface Props {
    characterId: string;
    /** True when the character has the `exhausted` condition flag set. */
    exhausted: boolean;
  }

  const props = defineProps<Props>();
  const emit = defineEmits<{
    rollCreated: [roll: Roll];
    rollPushed: [roll: Roll];
  }>();

  const { t } = useI18n({ useScope: 'local' });
  const rollsApi = useRollsApi();

  const POOL_MIN = 1;
  const POOL_MAX = 10;

  const label = ref('');
  const pool = ref(5);
  const lastRoll = ref<Roll | null>(null);
  const creating = ref(false);
  const pushing = ref(false);
  const errorMsg = ref('');
  // SURFACES.md §9 — push can fail (no new 6s). `pushDelta` tracks the
  // in-session outcome: count of hits gained by this push. Null until a
  // push fires in this session. A reloaded already-pushed roll keeps the
  // pushed badge but does NOT replay the outcome line — ritual feedback
  // is session-scoped, not a persistent label.
  const pushDelta = ref<number | null>(null);

  const labelTrimmed = computed(() => label.value.trim());
  const labelValid = computed(() => labelTrimmed.value.length > 0);
  const canRoll = computed(
    () => labelValid.value && pool.value >= POOL_MIN && pool.value <= POOL_MAX && !creating.value,
  );

  // The push button mirrors the server-side `RulesEngine.canPush` invariants
  // so the player sees the disabled state without paying for a round-trip.
  // The server still validates on PATCH and will reject with 422
  // ROLL_NOT_PUSHABLE if the client lies — `errorMsg` carries the detail.
  const canPush = computed(() => {
    if (!lastRoll.value) return false;
    if (lastRoll.value.pushed) return false;
    if (props.exhausted) return false;
    if (pushing.value) return false;
    return true;
  });

  function clampPool(next: number): void {
    if (next < POOL_MIN) pool.value = POOL_MIN;
    else if (next > POOL_MAX) pool.value = POOL_MAX;
    else pool.value = next;
  }

  function decPool(): void {
    clampPool(pool.value - 1);
  }

  function incPool(): void {
    clampPool(pool.value + 1);
  }

  // The Roll API returns `dice: number[]` per the openapi schema; the
  // server-side roll engine never produces values outside 1..6, but a defensive
  // cast keeps `AppDiePool` happy without conditional rendering.
  function asDieValues(dice: readonly number[]): DieValue[] {
    return dice.map((n) => n as DieValue);
  }

  // Indices that were rerolled on push — by convention the kept 6s sit at the
  // start of the dice array on the pushed result (server-side roll-engine
  // contract, see `apps/backend/src/modules/rules-engine`). Any value !== 6 is
  // a die that failed to convert; for the visual we mark the non-6 indices as
  // `pushed` so they read as "rerolled and didn't help".
  const pushedIndices = computed<number[]>(() => {
    const r = lastRoll.value;
    if (!r?.pushed) return [];
    const out: number[] = [];
    for (const [index, value] of r.dice.entries()) {
      if (value !== 6) out.push(index);
    }
    return out;
  });

  async function onRoll(): Promise<void> {
    errorMsg.value = '';
    pushDelta.value = null;
    if (!canRoll.value) return;
    creating.value = true;
    try {
      const roll = await rollsApi.createRoll(props.characterId, {
        label: labelTrimmed.value,
        pool: pool.value,
        gameSessionId: null,
      });
      lastRoll.value = roll;
      emit('rollCreated', roll);
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorRoll');
    } finally {
      creating.value = false;
    }
  }

  async function onPush(): Promise<void> {
    errorMsg.value = '';
    if (!canPush.value || !lastRoll.value) return;
    // Snapshot pre-push hits so we can compute the new-successes delta.
    // The server returns the same roll shape with updated `dice` and
    // `hits`; the difference is "new 6s gained by the push" (≥ 0).
    const preHits = lastRoll.value.hits;
    pushing.value = true;
    try {
      const roll = await rollsApi.pushRoll(lastRoll.value.id);
      lastRoll.value = roll;
      pushDelta.value = roll.hits - preHits;
      emit('rollPushed', roll);
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorPush');
    } finally {
      pushing.value = false;
    }
  }
</script>

<i18n lang="json">
{
  "en": {
    "labelLabel": "Label",
    "labelHint": "What you're rolling for, e.g. \"Pilot · Evade\"",
    "poolLabel": "Pool",
    "poolDecrement": "Decrease pool",
    "poolIncrement": "Increase pool",
    "rollButton": "Roll",
    "pushButton": "Push",
    "pushedBadge": "Pushed",
    "pushFailLine": "The prayer goes unanswered — no new successes.",
    "pushSuccessLine": "+{count} new successes",
    "exhaustedHint": "Exhausted — push not available.",
    "noRollYet": "No roll yet — describe one above.",
    "errorRoll": "Couldn't roll. Try again.",
    "errorPush": "Couldn't push that roll.",
    "hits": "{n} hit | {n} hits"
  },
  "ru": {
    "labelLabel": "Название",
    "labelHint": "Что бросаешь, напр. «Пилот · Уклонение»",
    "poolLabel": "Пул",
    "poolDecrement": "Уменьшить пул",
    "poolIncrement": "Увеличить пул",
    "rollButton": "Бросить",
    "pushButton": "Дожать",
    "pushedBadge": "Дожато",
    "pushFailLine": "Молитва не услышана — новых успехов нет.",
    "pushSuccessLine": "Новых успехов: +{count}",
    "exhaustedHint": "Истощение — дожать нельзя.",
    "noRollYet": "Бросков ещё нет — опиши бросок выше.",
    "errorRoll": "Не удалось бросить. Попробуй ещё раз.",
    "errorPush": "Не удалось дожать.",
    "hits": "{n} успех | {n} успеха | {n} успехов"
  }
}
</i18n>

<template>
  <div class="dice-roller" data-testid="sheet-dice-roller">
    <AppBanner v-if="errorMsg" tone="danger" role="alert" class="dice-roller__error">
      {{ errorMsg }}
    </AppBanner>

    <form class="dice-roller__form" novalidate @submit.prevent="onRoll">
      <AppField :label="t('labelLabel')" :help="t('labelHint')" required>
        <template #default="slotAttrs">
          <AppInput
            v-bind="slotAttrs"
            v-model="label"
            type="text"
            maxlength="80"
            placeholder="Pilot · Evade"
          />
        </template>
      </AppField>

      <div class="dice-roller__pool-row">
        <span id="dice-roller-pool-label" class="dice-roller__pool-label">
          {{ t('poolLabel') }}
        </span>
        <div
          class="dice-roller__pool-stepper"
          role="group"
          aria-labelledby="dice-roller-pool-label"
        >
          <AppButton
            type="button"
            variant="ghost"
            size="sm"
            :disabled="pool <= POOL_MIN || creating"
            :aria-label="t('poolDecrement')"
            @click="decPool"
          >
            −
          </AppButton>
          <span class="dice-roller__pool-value" aria-live="polite">
            {{ pool }}
          </span>
          <AppButton
            type="button"
            variant="ghost"
            size="sm"
            :disabled="pool >= POOL_MAX || creating"
            :aria-label="t('poolIncrement')"
            @click="incPool"
          >
            +
          </AppButton>
        </div>
        <AppButton
          type="submit"
          variant="primary"
          size="sm"
          :loading="creating"
          :disabled="!canRoll"
        >
          {{ t('rollButton') }}
        </AppButton>
      </div>
    </form>

    <div v-if="lastRoll" class="dice-roller__result" data-testid="sheet-dice-roller-last">
      <div class="dice-roller__result-head">
        <span class="dice-roller__result-label">{{ lastRoll.label }}</span>
        <span v-if="lastRoll.pushed" class="dice-roller__pushed-badge">
          {{ t('pushedBadge') }}
        </span>
      </div>
      <AppDiePool
        :values="asDieValues(lastRoll.dice)"
        :pushed-indices="pushedIndices"
        size="md"
        :count-label="t('hits', { n: lastRoll.hits })"
      />
      <!--
        SURFACES.md §9 — pushed outcome line. Renders only after an
        in-session push (pushDelta !== null). Failure variant
        (delta === 0) uses the darker brass-shadow divider per spec;
        success variant uses mystic-teal.
      -->
      <p
        v-if="pushDelta === 0"
        class="dice-roller__push-outcome dice-roller__push-outcome--fail"
        data-testid="sheet-dice-roller-push-fail"
        role="status"
      >
        {{ t('pushFailLine') }}
      </p>
      <p
        v-else-if="pushDelta !== null && pushDelta > 0"
        class="dice-roller__push-outcome dice-roller__push-outcome--success"
        data-testid="sheet-dice-roller-push-success"
        role="status"
      >
        {{ t('pushSuccessLine', { count: pushDelta }) }}
      </p>
      <div class="dice-roller__push-row">
        <AppButton
          type="button"
          variant="ghost"
          size="sm"
          :loading="pushing"
          :disabled="!canPush"
          @click="onPush"
        >
          {{ t('pushButton') }}
        </AppButton>
        <span v-if="exhausted && !lastRoll.pushed" class="dice-roller__push-hint">
          {{ t('exhaustedHint') }}
        </span>
      </div>
    </div>
    <p v-else class="dice-roller__placeholder">
      {{ t('noRollYet') }}
    </p>
  </div>
</template>

<style lang="scss" scoped>
  .dice-roller {
    display: flex;
    flex-direction: column;
    gap: var(--space-3);

    &__error {
      // Banner already styles itself; trim default trailing margin.
      margin-bottom: 0;
    }

    &__form {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__pool-row {
      display: flex;
      align-items: center;
      gap: var(--space-3);
      flex-wrap: wrap;
    }

    &__pool-label {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    &__pool-stepper {
      display: inline-flex;
      align-items: center;
      gap: var(--space-2);
    }

    &__pool-value {
      min-width: 2ch;
      text-align: center;
      font-family: var(--font-mono);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }

    &__result {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
      padding: var(--space-3);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      background-color: color-mix(in srgb, var(--brand-brass-shadow) 25%, transparent);
    }

    &__result-head {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: var(--space-2);
    }

    &__result-label {
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
      // Long labels (up to 80 chars) ellipsis instead of pushing the pushed
      // badge out of the row or overflowing the narrow right column.
      min-width: 0;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    &__pushed-badge {
      flex-shrink: 0;
      padding: var(--space-1) var(--space-2);
      background-color: color-mix(in srgb, var(--state-mystic-teal) 15%, transparent);
      border: 1px solid var(--state-mystic-teal);
      border-radius: var(--radius-sm);
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--state-mystic-teal);
      text-transform: uppercase;
      letter-spacing: 0.1em;
    }

    &__push-outcome {
      // SURFACES.md §9 — pushed-state outcome line. The top border IS the
      // divider; the fail variant darkens it to brass-shadow per spec.
      margin: var(--space-2) 0 0;
      padding-top: var(--space-3);
      border-top: 1px solid var(--brand-brass-deep);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      text-align: center;

      &--fail {
        border-top-color: var(--brand-brass-shadow);
        color: var(--brand-brass-deep);
        font-style: italic;
      }

      &--success {
        color: var(--state-mystic-teal);
      }
    }

    &__push-row {
      display: flex;
      align-items: center;
      gap: var(--space-3);
      flex-wrap: wrap;
    }

    &__push-hint {
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__placeholder {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }
  }
</style>
