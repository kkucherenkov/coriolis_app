<script setup lang="ts">
  definePageMeta({ layout: 'app' });

  import { AppCard, AppButton, AppInput, AppField, AppBanner, AppBadge } from '@app/ui';
  import EncounterPanel from '~/components/EncounterPanel.vue';
  import { ref, onMounted, onBeforeUnmount, computed, watch } from 'vue';
  import { useGameSessionsApi } from '~/composables/useGameSessionsApi';
  import { useDpApi } from '~/composables/useDpApi';
  import { useMeApi } from '~/composables/useMeApi';
  import { useCharactersApi } from '~/composables/useCharactersApi';
  import {
    useSessionRealtime,
    type DpChangedPayload,
    type RollPushedPayload,
    type CombatUpdatedPayload,
  } from '~/composables/useSessionRealtime';
  import type { GameSession } from '~/composables/useGameSessionsApi';
  import type { DpEvent, DpSource } from '~/composables/useDpApi';
  import type { Me } from '~/composables/useMeApi';
  import type { Character, Problem } from '@app/api-client-ts';

  /**
   * Session detail (Phase 4 Feature 7.2 + 7.3). The page resolves the
   * session, the authenticated user, and the user's characters in
   * parallel on mount, then branches the UI on whether the user is the
   * GM owner. Players see a read-only DP counter + assigned-character
   * list. GMs additionally see DP +/- controls, the audit log tail,
   * and a character-assignment widget.
   *
   * The DP write path is a single POST that returns the updated
   * GameSession — we patch `session.value` from the response without
   * needing a follow-up GET. Optimistic update is deliberately avoided
   * because the server may reject the delta (DP_BELOW_ZERO, etc) and
   * we'd then have to roll back the visible counter, which feels worse
   * than a 100-ms blink.
   *
   * Live updates via Centrifugo land in Block 5 — for now the page
   * refetches DP events after every adjust to keep the audit tail in
   * sync.
   */

  const { t, locale } = useI18n({ useScope: 'local' });
  const route = useRoute();
  const sessionsApi = useGameSessionsApi();
  const dpApi = useDpApi();
  const meApi = useMeApi();
  const charactersApi = useCharactersApi();

  const sessionId = computed<string>(() => route.params.id as string);

  type LoadState = 'loading' | 'loaded' | 'error' | 'notfound';

  const state = ref<LoadState>('loading');
  const session = ref<GameSession | null>(null);
  const me = ref<Me | null>(null);
  const myCharacters = ref<Character[]>([]);
  const dpEvents = ref<DpEvent[]>([]);
  const errorMsg = ref('');

  const isGm = computed(() => Boolean(me.value && me.value.id === session.value?.ownerId));

  const assignedCharacters = computed<readonly Character[]>(() => {
    const ids = new Set(session.value?.characterIds);
    return myCharacters.value.filter((c) => ids.has(c.id));
  });

  const assignableCharacters = computed<readonly Character[]>(() => {
    const ids = new Set(session.value?.characterIds);
    // Drafts can be assigned in principle, but it usually means the GM
    // grabbed the wrong character; let the player publish first.
    return myCharacters.value.filter((c) => !ids.has(c.id) && c.status === 'active');
  });

  // ── DP adjustment form ────────────────────────────────────────────────────
  const dpDelta = ref(1);
  const dpReason = ref('');
  const dpSubmitting = ref(false);
  const dpError = ref('');
  const dpDeltaValid = computed(() => dpDelta.value !== 0);

  // ── Character assignment ─────────────────────────────────────────────────
  const assignSelected = ref<string>('');
  const assignBusy = ref(false);
  const assignError = ref('');

  // ── Realtime (Phase 4 Feature 7.4) ────────────────────────────────────────
  // Single subscription per session — torn down on unmount. The handle's
  // refs drive a small "live" indicator on the DP card; we also watch them
  // to push DP / roll-pushed events into the visible state.
  const realtime = useSessionRealtime(sessionId.value);
  const recentRollPushed = ref<RollPushedPayload | null>(null);
  // Last combat.updated snapshot forwarded to EncounterPanel → CombatTracker.
  const lastCombatSnapshot = ref<CombatUpdatedPayload | null>(null);

  watch(
    () => realtime.lastDpChanged.value,
    (payload: DpChangedPayload | null) => {
      if (!payload || !session.value) return;
      // Patch the visible counter even if we just sent the adjust ourselves —
      // the round-trip already returned the new value, so this is mostly a
      // no-op for the GM's own clicks but the right thing for everyone else
      // sharing the session.
      session.value = { ...session.value, dpCount: payload.dpCount };
      if (isGm.value) {
        // Prepend a synthetic audit row so the trail updates without a
        // refetch. The next page reload (or any subsequent adjust) will
        // pull the canonical row from the server, including its real id.
        const synthetic: DpEvent = {
          id: `live-${String(Date.now())}`,
          gameSessionId: payload.gameSessionId,
          delta: payload.delta,
          source: payload.source as DpSource,
          reason: null,
          rollId: null,
          createdAt: payload.at ?? new Date().toISOString(),
        };
        // Skip if our own adjust just ran — the post-adjust refetch will
        // bring the real row in within ~100 ms.
        const top = dpEvents.value[0];
        if (
          top?.delta !== synthetic.delta ||
          Math.abs(new Date(top.createdAt).getTime() - new Date(synthetic.createdAt).getTime()) >
            5000
        ) {
          dpEvents.value = [synthetic, ...dpEvents.value].slice(0, 20);
        }
      }
    },
  );

  watch(
    () => realtime.lastRollPushed.value,
    (payload: RollPushedPayload | null) => {
      if (!payload) return;
      // Surface the most recent push for ~5 s. A toast component would be
      // nicer; deferring to a later UX pass.
      recentRollPushed.value = payload;
      globalThis.setTimeout(() => {
        if (recentRollPushed.value === payload) recentRollPushed.value = null;
      }, 5000);
    },
  );

  watch(
    () => realtime.lastCombatUpdated.value,
    (payload: CombatUpdatedPayload | null) => {
      if (!payload) return;
      // Replace local snapshot reference — EncounterPanel and CombatTracker
      // consume this via the combatSnapshot prop.
      lastCombatSnapshot.value = payload;
    },
  );

  async function loadSession(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      const [s, profile, chars] = await Promise.all([
        sessionsApi.getSession(sessionId.value),
        meApi.get(),
        // The list endpoint defaults to active-only, which is what we want
        // here — drafts are wizard-in-progress and shouldn't be assigned.
        charactersApi.list({ limit: 100 }),
      ]);
      session.value = s;
      me.value = profile;
      myCharacters.value = [...chars.items];
      state.value = 'loaded';
    } catch (error) {
      const problem = error as Problem;
      if (problem.status === 404) {
        state.value = 'notfound';
        return;
      }
      errorMsg.value = problem.detail ?? t('errorLoad');
      state.value = 'error';
    }
  }

  async function loadDpEvents(): Promise<void> {
    if (!session.value || !isGm.value) return;
    try {
      const data = await dpApi.listEvents(sessionId.value, { limit: 20 });
      dpEvents.value = [...data.items];
    } catch (error) {
      const problem = error as Problem;
      // Audit log failure shouldn't sink the rest of the page.
      dpError.value = problem.detail ?? t('errorAuditLoad');
    }
  }

  onMounted(async () => {
    await loadSession();
    // Open the websocket only after the session resolved — on error /
    // notfound the channel doesn't exist server-side and the subscription
    // would be rejected on subscribe().
    if (state.value === 'loaded') {
      void realtime.start();
    }
  });

  onBeforeUnmount(() => {
    void realtime.stop();
  });

  // Once the session resolves and we know whether the user is the GM,
  // pull in the audit log.
  watch(isGm, (now, before) => {
    if (now && !before) void loadDpEvents();
  });

  async function applyDelta(magnitude: number): Promise<void> {
    dpError.value = '';
    if (magnitude === 0) return;
    dpSubmitting.value = true;
    try {
      const updated = await dpApi.adjust(sessionId.value, {
        delta: magnitude,
        reason: dpReason.value.trim() || undefined,
      });
      session.value = updated;
      dpReason.value = '';
      await loadDpEvents();
    } catch (error) {
      const problem = error as Problem;
      dpError.value = problem.detail ?? t('errorDpAdjust');
    } finally {
      dpSubmitting.value = false;
    }
  }

  async function onApplyForm(): Promise<void> {
    if (!dpDeltaValid.value) {
      dpError.value = t('errorDpDeltaInvalid');
      return;
    }
    await applyDelta(dpDelta.value);
  }

  async function onAssign(): Promise<void> {
    if (!assignSelected.value) return;
    assignError.value = '';
    assignBusy.value = true;
    try {
      await sessionsApi.assignCharacter(sessionId.value, assignSelected.value);
      session.value = await sessionsApi.getSession(sessionId.value);
      assignSelected.value = '';
    } catch (error) {
      const problem = error as Problem;
      assignError.value = problem.detail ?? t('errorAssign');
    } finally {
      assignBusy.value = false;
    }
  }

  async function onUnassign(characterId: string): Promise<void> {
    assignError.value = '';
    try {
      await sessionsApi.unassignCharacter(sessionId.value, characterId);
      session.value = await sessionsApi.getSession(sessionId.value);
    } catch (error) {
      const problem = error as Problem;
      assignError.value = problem.detail ?? t('errorUnassign');
    }
  }

  function formatEventTime(iso: string): string {
    return new Date(iso).toLocaleString(locale.value, {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  }

  function sourceLabel(source: DpEvent['source']): string {
    switch (source) {
      case 'gm-manual': {
        return t('source.gmManual');
      }
      case 'roll-push': {
        return t('source.rollPush');
      }
      case 'system': {
        return t('source.system');
      }
      default: {
        return source;
      }
    }
  }
</script>

<i18n lang="json">
{
  "en": {
    "backToList": "← Back to sessions",
    "loading": "Loading session…",
    "errorLoad": "Couldn't load that session.",
    "errorDpAdjust": "Couldn't adjust DP.",
    "errorDpDeltaInvalid": "Delta must be non-zero.",
    "errorAuditLoad": "Couldn't load DP audit log.",
    "errorAssign": "Couldn't assign that character.",
    "errorUnassign": "Couldn't remove that character.",
    "notFoundHeading": "Session not found",
    "notFoundBody": "It may have been deleted, or you don't have permission to view it.",
    "dpLabel": "Darkness Points",
    "dpAdjustHeading": "Adjust DP",
    "dpAdjustHint": "Positive adds, negative removes. Reason is optional but useful in the audit log.",
    "dpDeltaLabel": "Delta",
    "dpReasonLabel": "Reason",
    "dpReasonPlaceholder": "e.g. Faceless Whisper invoked",
    "dpQuickPlus": "+1",
    "dpQuickMinus": "−1",
    "dpApplyButton": "Apply",
    "auditHeading": "Audit log",
    "auditEmpty": "No DP events yet — adjust above to start the trail.",
    "charactersHeading": "Characters",
    "charactersEmpty": "No characters assigned yet.",
    "assignHeading": "Assign character",
    "assignNoneLeft": "All your active characters are already assigned.",
    "assignButton": "Assign",
    "assignSelectPlaceholder": "Pick a character",
    "removeButton": "Remove",
    "gmBadge": "GM owner",
    "playerBadge": "Player view",
    "liveBadge": "Live",
    "liveDisconnected": "Reconnecting…",
    "rollPushedToast": "Roll pushed: character {character} got {hits} hits.",
    "source": {
      "gmManual": "GM",
      "rollPush": "Roll push",
      "system": "System"
    }
  },
  "ru": {
    "backToList": "← К списку сессий",
    "loading": "Загружаем сессию…",
    "errorLoad": "Не удалось загрузить сессию.",
    "errorDpAdjust": "Не удалось изменить ПТ.",
    "errorDpDeltaInvalid": "Дельта должна быть ненулевой.",
    "errorAuditLoad": "Не удалось загрузить журнал ПТ.",
    "errorAssign": "Не удалось назначить персонажа.",
    "errorUnassign": "Не удалось снять персонажа.",
    "notFoundHeading": "Сессия не найдена",
    "notFoundBody": "Возможно, она была удалена или у вас нет к ней доступа.",
    "dpLabel": "Пункты тьмы",
    "dpAdjustHeading": "Изменить ПТ",
    "dpAdjustHint": "Положительные добавляют, отрицательные снимают. Причина необязательна, но помогает в журнале.",
    "dpDeltaLabel": "Дельта",
    "dpReasonLabel": "Причина",
    "dpReasonPlaceholder": "напр. «Шёпот Безликого»",
    "dpQuickPlus": "+1",
    "dpQuickMinus": "−1",
    "dpApplyButton": "Применить",
    "auditHeading": "Журнал событий",
    "auditEmpty": "Событий ПТ ещё нет — измените значение выше, чтобы начать журнал.",
    "charactersHeading": "Персонажи",
    "charactersEmpty": "Ни одного персонажа ещё не назначено.",
    "assignHeading": "Назначить персонажа",
    "assignNoneLeft": "Все ваши активные персонажи уже в сессии.",
    "assignButton": "Назначить",
    "assignSelectPlaceholder": "Выберите персонажа",
    "removeButton": "Снять",
    "gmBadge": "ГМ-владелец",
    "playerBadge": "Вид игрока",
    "liveBadge": "Live",
    "liveDisconnected": "Переподключение…",
    "rollPushedToast": "Бросок дожат: персонаж {character} получил {hits} успехов.",
    "source": {
      "gmManual": "ГМ",
      "rollPush": "Дожим броска",
      "system": "Система"
    }
  },
  "uk": {
    "backToList": "[uk-todo] Back",
    "loading": "[uk-todo] Loading session",
    "errorLoad": "[uk-todo] Couldn't load",
    "errorDpAdjust": "[uk-todo] Couldn't adjust DP",
    "errorDpDeltaInvalid": "[uk-todo] Delta must be non-zero",
    "errorAuditLoad": "[uk-todo] Couldn't load audit",
    "errorAssign": "[uk-todo] Couldn't assign",
    "errorUnassign": "[uk-todo] Couldn't unassign",
    "notFoundHeading": "[uk-todo] Session not found",
    "notFoundBody": "[uk-todo] May have been deleted",
    "dpLabel": "[uk-todo] Darkness Points",
    "dpAdjustHeading": "[uk-todo] Adjust DP",
    "dpAdjustHint": "[uk-todo] Positive adds, negative removes",
    "dpDeltaLabel": "[uk-todo] Delta",
    "dpReasonLabel": "[uk-todo] Reason",
    "dpReasonPlaceholder": "[uk-todo] e.g. invocation",
    "dpQuickPlus": "[uk-todo] +1",
    "dpQuickMinus": "[uk-todo] -1",
    "dpApplyButton": "[uk-todo] Apply",
    "auditHeading": "[uk-todo] Audit log",
    "auditEmpty": "[uk-todo] No events yet",
    "charactersHeading": "[uk-todo] Characters",
    "charactersEmpty": "[uk-todo] None assigned yet",
    "assignHeading": "[uk-todo] Assign character",
    "assignNoneLeft": "[uk-todo] All assigned",
    "assignButton": "[uk-todo] Assign",
    "assignSelectPlaceholder": "[uk-todo] Pick a character",
    "removeButton": "[uk-todo] Remove",
    "gmBadge": "[uk-todo] GM owner",
    "playerBadge": "[uk-todo] Player view",
    "liveBadge": "[uk-todo] Live",
    "liveDisconnected": "[uk-todo] Reconnecting",
    "rollPushedToast": "[uk-todo] Roll pushed: {character} got {hits} hits.",
    "source": {
      "gmManual": "[uk-todo] GM",
      "rollPush": "[uk-todo] Roll push",
      "system": "[uk-todo] System"
    }
  },
  "el": {
    "backToList": "[el-todo] Back",
    "loading": "[el-todo] Loading session",
    "errorLoad": "[el-todo] Couldn't load",
    "errorDpAdjust": "[el-todo] Couldn't adjust DP",
    "errorDpDeltaInvalid": "[el-todo] Delta must be non-zero",
    "errorAuditLoad": "[el-todo] Couldn't load audit",
    "errorAssign": "[el-todo] Couldn't assign",
    "errorUnassign": "[el-todo] Couldn't unassign",
    "notFoundHeading": "[el-todo] Session not found",
    "notFoundBody": "[el-todo] May have been deleted",
    "dpLabel": "[el-todo] Darkness Points",
    "dpAdjustHeading": "[el-todo] Adjust DP",
    "dpAdjustHint": "[el-todo] Positive adds, negative removes",
    "dpDeltaLabel": "[el-todo] Delta",
    "dpReasonLabel": "[el-todo] Reason",
    "dpReasonPlaceholder": "[el-todo] e.g. invocation",
    "dpQuickPlus": "[el-todo] +1",
    "dpQuickMinus": "[el-todo] -1",
    "dpApplyButton": "[el-todo] Apply",
    "auditHeading": "[el-todo] Audit log",
    "auditEmpty": "[el-todo] No events yet",
    "charactersHeading": "[el-todo] Characters",
    "charactersEmpty": "[el-todo] None assigned yet",
    "assignHeading": "[el-todo] Assign character",
    "assignNoneLeft": "[el-todo] All assigned",
    "assignButton": "[el-todo] Assign",
    "assignSelectPlaceholder": "[el-todo] Pick a character",
    "removeButton": "[el-todo] Remove",
    "gmBadge": "[el-todo] GM owner",
    "playerBadge": "[el-todo] Player view",
    "liveBadge": "[el-todo] Live",
    "liveDisconnected": "[el-todo] Reconnecting",
    "rollPushedToast": "[el-todo] Roll pushed: {character} got {hits} hits.",
    "source": {
      "gmManual": "[el-todo] GM",
      "rollPush": "[el-todo] Roll push",
      "system": "[el-todo] System"
    }
  }
}
</i18n>

<template>
  <section class="page-session-detail" data-testid="page-session-detail">
    <NuxtLink to="/app/sessions" class="page-session-detail__back">
      {{ t('backToList') }}
    </NuxtLink>

    <p v-if="state === 'loading'" class="page-session-detail__placeholder">
      {{ t('loading') }}
    </p>

    <AppBanner v-else-if="state === 'error'" tone="danger" role="alert">
      {{ errorMsg }}
    </AppBanner>

    <div v-else-if="state === 'notfound'" class="page-session-detail__empty">
      <h2 class="page-session-detail__empty-heading">
        {{ t('notFoundHeading') }}
      </h2>
      <p class="page-session-detail__empty-body">
        {{ t('notFoundBody') }}
      </p>
    </div>

    <template v-else-if="session">
      <header class="page-session-detail__header">
        <div class="page-session-detail__title-row">
          <h1 class="page-session-detail__title">
            {{ session.name }}
          </h1>
          <AppBadge :variant="isGm ? 'mystic' : 'brass'" size="sm">
            {{ isGm ? t('gmBadge') : t('playerBadge') }}
          </AppBadge>
        </div>
        <p v-if="session.description" class="page-session-detail__description">
          {{ session.description }}
        </p>
      </header>

      <Transition name="fade">
        <AppBanner
          v-if="recentRollPushed"
          tone="success"
          role="status"
          class="page-session-detail__toast"
        >
          {{
            t('rollPushedToast', {
              character:
                assignedCharacters.find((c) => c.id === recentRollPushed?.characterId)?.name ?? '#',
              hits: recentRollPushed.hits,
            })
          }}
        </AppBanner>
      </Transition>

      <div class="page-session-detail__top">
        <AppCard class="page-session-detail__dp">
          <span class="page-session-detail__dp-label">
            {{ t('dpLabel') }}
          </span>
          <span class="page-session-detail__dp-value">
            {{ session.dpCount }}
          </span>
          <AppBadge
            :variant="realtime.connected.value ? 'success' : 'brass'"
            size="sm"
            class="page-session-detail__live-badge"
          >
            {{ realtime.connected.value ? t('liveBadge') : t('liveDisconnected') }}
          </AppBadge>
        </AppCard>

        <AppCard v-if="isGm" class="page-session-detail__dp-controls">
          <h3 class="page-session-detail__panel-title">
            {{ t('dpAdjustHeading') }}
          </h3>
          <p class="page-session-detail__panel-hint">
            {{ t('dpAdjustHint') }}
          </p>
          <AppBanner v-if="dpError" tone="danger" role="alert">
            {{ dpError }}
          </AppBanner>
          <div class="page-session-detail__dp-quick">
            <AppButton variant="ghost" size="sm" :disabled="dpSubmitting" @click="applyDelta(-1)">
              {{ t('dpQuickMinus') }}
            </AppButton>
            <AppButton variant="primary" size="sm" :disabled="dpSubmitting" @click="applyDelta(1)">
              {{ t('dpQuickPlus') }}
            </AppButton>
          </div>
          <form class="page-session-detail__dp-form" novalidate @submit.prevent="onApplyForm">
            <AppField :label="t('dpDeltaLabel')" required>
              <template #default="slotAttrs">
                <AppInput
                  v-bind="slotAttrs"
                  v-model.number="dpDelta"
                  type="number"
                  min="-99"
                  max="99"
                />
              </template>
            </AppField>
            <AppField :label="t('dpReasonLabel')">
              <template #default="slotAttrs">
                <AppInput
                  v-bind="slotAttrs"
                  v-model="dpReason"
                  type="text"
                  maxlength="200"
                  :placeholder="t('dpReasonPlaceholder')"
                />
              </template>
            </AppField>
            <AppButton
              type="submit"
              variant="primary"
              size="sm"
              :loading="dpSubmitting"
              :disabled="!dpDeltaValid || dpSubmitting"
            >
              {{ t('dpApplyButton') }}
            </AppButton>
          </form>
        </AppCard>
      </div>

      <AppCard class="page-session-detail__panel">
        <h3 class="page-session-detail__panel-title">
          {{ t('charactersHeading') }}
        </h3>
        <AppBanner v-if="assignError" tone="danger" role="alert">
          {{ assignError }}
        </AppBanner>
        <p v-if="(session.characterIds.length ?? 0) === 0" class="page-session-detail__panel-hint">
          {{ t('charactersEmpty') }}
        </p>
        <ul v-else class="page-session-detail__char-list" role="list">
          <li
            v-for="characterId in session.characterIds"
            :key="characterId"
            class="page-session-detail__char-row"
          >
            <span class="page-session-detail__char-name">
              {{ assignedCharacters.find((c) => c.id === characterId)?.name ?? `#${characterId}` }}
            </span>
            <AppButton v-if="isGm" variant="ghost" size="sm" @click="onUnassign(characterId)">
              {{ t('removeButton') }}
            </AppButton>
          </li>
        </ul>

        <div v-if="isGm" class="page-session-detail__assign">
          <h4 class="page-session-detail__panel-subtitle">
            {{ t('assignHeading') }}
          </h4>
          <p v-if="assignableCharacters.length === 0" class="page-session-detail__panel-hint">
            {{ t('assignNoneLeft') }}
          </p>
          <form
            v-else
            class="page-session-detail__assign-form"
            novalidate
            @submit.prevent="onAssign"
          >
            <select
              v-model="assignSelected"
              class="page-session-detail__assign-select"
              :disabled="assignBusy"
              :aria-label="t('assignHeading')"
            >
              <option value="" disabled>
                {{ t('assignSelectPlaceholder') }}
              </option>
              <option v-for="c in assignableCharacters" :key="c.id" :value="c.id">
                {{ c.name }}
              </option>
            </select>
            <AppButton
              type="submit"
              variant="primary"
              size="sm"
              :loading="assignBusy"
              :disabled="!assignSelected || assignBusy"
            >
              {{ t('assignButton') }}
            </AppButton>
          </form>
        </div>
      </AppCard>

      <AppCard v-if="isGm" class="page-session-detail__panel">
        <h3 class="page-session-detail__panel-title">
          {{ t('auditHeading') }}
        </h3>
        <p v-if="dpEvents.length === 0" class="page-session-detail__panel-hint">
          {{ t('auditEmpty') }}
        </p>
        <ul v-else class="page-session-detail__audit-list" role="list">
          <li v-for="event in dpEvents" :key="event.id" class="page-session-detail__audit-row">
            <span
              class="page-session-detail__audit-delta"
              :class="{
                'page-session-detail__audit-delta--neg': event.delta < 0,
              }"
            >
              {{ event.delta > 0 ? '+' : '' }}{{ event.delta }}
            </span>
            <span class="page-session-detail__audit-source">
              {{ sourceLabel(event.source) }}
            </span>
            <span v-if="event.reason" class="page-session-detail__audit-reason">
              {{ event.reason }}
            </span>
            <span class="page-session-detail__audit-time">
              {{ formatEventTime(event.createdAt) }}
            </span>
          </li>
        </ul>
      </AppCard>

      <!-- Encounters (Block 5) — GM only; players see the combat state
           read-only once a player-view encounter display is designed. -->
      <EncounterPanel
        v-if="isGm"
        :session-id="sessionId"
        :session-character-ids="session?.characterIds ?? []"
        :is-gm="isGm"
        :combat-snapshot="lastCombatSnapshot"
        data-testid="encounter-panel-section"
      />
    </template>
  </section>
</template>

<style lang="scss" scoped>
  $page-max-width: 1200px;

  .page-session-detail {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    padding: var(--space-6);
    max-width: $page-max-width;
    margin: 0 auto;

    &__back {
      align-self: flex-start;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--brand-accent);
      text-decoration: none;

      &:hover {
        text-decoration: underline;
      }
    }

    &__header {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__title-row {
      display: flex;
      align-items: center;
      gap: var(--space-3);
      flex-wrap: wrap;
    }

    &__title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-md-font-size);
      letter-spacing: var(--type-display-md-letter-spacing);
      color: var(--brand-brass-light);
    }

    &__description {
      margin: 0;
      font-family: var(--font-body);
      color: var(--text-secondary);
    }

    &__top {
      display: grid;
      grid-template-columns: minmax(180px, 280px) 1fr;
      gap: var(--space-4);

      @media (max-width: 720px) {
        grid-template-columns: 1fr;
      }
    }

    &__dp {
      padding: var(--space-5);
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
      align-items: center;
      justify-content: center;
    }

    &__dp-label {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 0.06em;
    }

    &__dp-value {
      font-family: var(--font-display);
      font-size: var(--type-display-xl-font-size);
      color: var(--brand-brass-light);
    }

    &__live-badge {
      align-self: center;
    }

    &__toast {
      // Toast-style banner pinned above the DP card. Animated by the
      // <Transition name="fade"> wrapper.
      margin-bottom: 0;
    }

    &__dp-controls {
      padding: var(--space-4);
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__panel-title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }

    &__panel-subtitle {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-sm-font-size);
      color: var(--brand-brass-light);
    }

    &__panel-hint {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__dp-quick {
      display: flex;
      gap: var(--space-2);
    }

    &__dp-form {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__panel {
      padding: var(--space-4);
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__char-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__char-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: var(--space-3);
      padding: var(--space-2) var(--space-3);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-sm);
    }

    &__char-name {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
    }

    &__assign {
      margin-top: var(--space-3);
      padding-top: var(--space-3);
      border-top: 1px dashed var(--brand-brass-shadow);
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__assign-form {
      display: flex;
      gap: var(--space-2);
      align-items: center;
    }

    &__assign-select {
      flex: 1;
      padding: var(--space-2) var(--space-3);
      background: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-sm);
      color: var(--text-primary);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    &__audit-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
      max-height: 24rem;
      overflow-y: auto;
    }

    &__audit-row {
      display: grid;
      grid-template-columns: 3rem 5rem 1fr auto;
      gap: var(--space-2);
      align-items: center;
      padding: var(--space-2) var(--space-3);
      border-radius: var(--radius-sm);
      font-size: var(--type-body-sm-font-size);

      &:nth-child(odd) {
        background: color-mix(in srgb, var(--brand-brass-shadow) 15%, transparent);
      }
    }

    &__audit-delta {
      font-family: var(--font-mono);
      font-weight: var(--fw-bold);
      color: var(--state-success);

      &--neg {
        color: var(--status-danger);
      }
    }

    &__audit-source {
      font-family: var(--font-body);
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 0.06em;
      font-size: var(--type-body-xs-font-size);
    }

    &__audit-reason {
      font-family: var(--font-body);
      color: var(--text-primary);
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    &__audit-time {
      font-family: var(--font-mono);
      font-size: var(--type-body-xs-font-size);
      color: var(--text-tertiary);
    }

    &__placeholder {
      margin: 0;
      font-family: var(--font-body);
      color: var(--text-tertiary);
      font-style: italic;
    }

    &__empty {
      padding: var(--space-8) var(--space-4);
      text-align: center;
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-md);
    }

    &__empty-heading {
      margin: 0 0 var(--space-2);
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);
    }

    &__empty-body {
      margin: 0;
      font-family: var(--font-body);
      color: var(--text-secondary);
    }
  }
</style>
