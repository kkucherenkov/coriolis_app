<script setup lang="ts">
  definePageMeta({
    layout: 'app',
    middleware: ['require-session-membership'],
  });

  import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue';
  import { AppSessionHeader, AppBanner } from '@app/ui';
  import type { AppSessionHeaderLabels } from '@app/ui';
  import { useGameSessionsApi } from '~/composables/useGameSessionsApi';
  import { useMyMembershipsApi } from '~/composables/useMyMembershipsApi';
  import { useSessionRealtime, type DpChangedPayload } from '~/composables/useSessionRealtime';
  import type { GameSession, Problem } from '@app/api-client-ts';

  /**
   * Player session shell (Phase 11 Stream B).
   *
   * Serves as the player-facing view for an active game session. Renders:
   *   - AppSessionHeader (player mode) with live realtime status.
   *   - Chat placeholder (Stream D).
   *   - Encounter placeholder (read-only view TBD).
   *
   * Leave flow: resolves the membership id from /me/memberships, then calls
   * DELETE /api/v1/game-sessions/{id}/members/{membershipId}. On success
   * navigates back to /app/sessions.
   *
   * The require-session-membership middleware guards this route; a user
   * without an active membership is redirected to /app/sessions.
   */

  const { t } = useI18n({ useScope: 'local' });
  const route = useRoute();
  const sessionsApi = useGameSessionsApi();
  const membershipsApi = useMyMembershipsApi();

  const sessionId = computed<string>(() => route.params.id as string);

  type LoadState = 'loading' | 'loaded' | 'error' | 'notfound';

  const state = ref<LoadState>('loading');
  const session = ref<GameSession | null>(null);
  const membershipId = ref<string | null>(null);
  const errorMsg = ref('');
  const leaving = ref(false);
  const leaveError = ref('');

  // Realtime — mirrors the GM page pattern but read-only.
  const realtime = useSessionRealtime(sessionId.value);

  // Patch DP counter on live push.
  watch(
    () => realtime.lastDpChanged.value,
    (payload: DpChangedPayload | null) => {
      if (!payload || !session.value) return;
      session.value = { ...session.value, dpCount: payload.dpCount };
    },
  );

  const headerStatus = computed<'online' | 'offline'>(() =>
    realtime.connected.value ? 'online' : 'offline',
  );

  const headerLabels = computed<AppSessionHeaderLabels>(() => ({
    statusOnline: t('statusOnline'),
    statusOffline: t('statusOffline'),
    dpLabel: t('dpLabel'),
    leaveLabel: t('leaveLabel'),
    backLabel: t('backLabel'),
  }));

  async function load(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      const [s, memberships] = await Promise.all([
        sessionsApi.getSession(sessionId.value),
        membershipsApi.list(),
      ]);
      session.value = s;
      const m = memberships.find((x) => x.gameSessionId === sessionId.value);
      membershipId.value = m?.membershipId ?? null;
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

  async function onLeave(): Promise<void> {
    if (!membershipId.value) return;
    leaveError.value = '';
    leaving.value = true;
    try {
      await membershipsApi.leave(sessionId.value, membershipId.value);
      await navigateTo('/app/sessions');
    } catch (error) {
      const problem = error as Problem;
      leaveError.value = problem.detail ?? t('errorLeave');
    } finally {
      leaving.value = false;
    }
  }

  onMounted(async () => {
    await load();
    if (state.value === 'loaded') {
      void realtime.start();
    }
  });

  onBeforeUnmount(() => {
    void realtime.stop();
  });
</script>

<i18n lang="json">
{
  "en": {
    "loading": "Loading session…",
    "errorLoad": "Couldn't load that session.",
    "errorLeave": "Couldn't leave the session. Please try again.",
    "notFoundHeading": "Session not found",
    "notFoundBody": "It may have been deleted, or you don't have permission to view it.",
    "statusOnline": "Online",
    "statusOffline": "Offline",
    "dpLabel": "Darkness Points",
    "leaveLabel": "Leave session",
    "backLabel": "← Back",
    "chatPlaceholder": "Chat (coming soon)",
    "encounterPlaceholder": "Encounter view coming soon"
  },
  "ru": {
    "loading": "Загружаем сессию…",
    "errorLoad": "Не удалось загрузить сессию.",
    "errorLeave": "Не удалось покинуть сессию. Попробуйте ещё раз.",
    "notFoundHeading": "Сессия не найдена",
    "notFoundBody": "Возможно, она была удалена или у вас нет к ней доступа.",
    "statusOnline": "Онлайн",
    "statusOffline": "Офлайн",
    "dpLabel": "Пункты тьмы",
    "leaveLabel": "Покинуть сессию",
    "backLabel": "← Назад",
    "chatPlaceholder": "Чат (скоро)",
    "encounterPlaceholder": "Отображение столкновения — скоро"
  },
  "uk": {
    "loading": "[uk-todo] Loading session…",
    "errorLoad": "[uk-todo] Couldn't load that session.",
    "errorLeave": "[uk-todo] Couldn't leave the session.",
    "notFoundHeading": "[uk-todo] Session not found",
    "notFoundBody": "[uk-todo] May have been deleted.",
    "statusOnline": "[uk-todo] Online",
    "statusOffline": "[uk-todo] Offline",
    "dpLabel": "[uk-todo] Darkness Points",
    "leaveLabel": "[uk-todo] Leave session",
    "backLabel": "[uk-todo] ← Back",
    "chatPlaceholder": "[uk-todo] Chat (coming soon)",
    "encounterPlaceholder": "[uk-todo] Encounter view coming soon"
  },
  "el": {
    "loading": "[el-todo] Loading session…",
    "errorLoad": "[el-todo] Couldn't load that session.",
    "errorLeave": "[el-todo] Couldn't leave the session.",
    "notFoundHeading": "[el-todo] Session not found",
    "notFoundBody": "[el-todo] May have been deleted.",
    "statusOnline": "[el-todo] Online",
    "statusOffline": "[el-todo] Offline",
    "dpLabel": "[el-todo] Darkness Points",
    "leaveLabel": "[el-todo] Leave session",
    "backLabel": "[el-todo] ← Back",
    "chatPlaceholder": "[el-todo] Chat (coming soon)",
    "encounterPlaceholder": "[el-todo] Encounter view coming soon"
  }
}
</i18n>

<template>
  <div class="session-player">
    <p v-if="state === 'loading'" class="session-player__placeholder">
      {{ t('loading') }}
    </p>

    <AppBanner v-else-if="state === 'error'" tone="danger" role="alert">
      {{ errorMsg }}
    </AppBanner>

    <div v-else-if="state === 'notfound'" class="session-player__empty">
      <h2 class="session-player__empty-heading">
        {{ t('notFoundHeading') }}
      </h2>
      <p class="session-player__empty-body">
        {{ t('notFoundBody') }}
      </p>
    </div>

    <template v-else-if="session">
      <AppSessionHeader
        mode="player"
        :session-name="session.name"
        :status="headerStatus"
        :dp-count="session.dpCount"
        :labels="headerLabels"
        @leave="onLeave"
      />

      <AppBanner v-if="leaveError" tone="danger" role="alert" class="session-player__leave-error">
        {{ leaveError }}
      </AppBanner>

      <div class="session-player__body">
        <div
          class="session-player__chat-placeholder"
          :aria-label="t('chatPlaceholder')"
          role="region"
        />
        <div class="session-player__encounter-placeholder">
          {{ t('encounterPlaceholder') }}
        </div>
      </div>
    </template>
  </div>
</template>

<style lang="scss" scoped>
  // Minimum height for placeholder panels (chat / encounter) — sub-token literal.
  $placeholder-min-height: 200px;

  .session-player {
    display: flex;
    flex-direction: column;
    height: 100%;
    min-height: 0;

    &__placeholder {
      margin: var(--space-6);
      font-family: var(--font-body);
      color: var(--text-tertiary);
      font-style: italic;
    }

    &__empty {
      padding: var(--space-8) var(--space-4);
      text-align: center;
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      margin: var(--space-6);
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

    &__leave-error {
      margin: var(--space-3) var(--space-4);
    }

    &__body {
      flex: 1;
      display: grid;
      grid-template-columns: 1fr;
      gap: var(--space-4);
      padding: var(--space-4);
      min-height: 0;
    }

    &__chat-placeholder {
      background: var(--surface-night);
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      min-height: $placeholder-min-height;
    }

    &__encounter-placeholder {
      display: flex;
      align-items: center;
      justify-content: center;
      padding: var(--space-6);
      background: var(--surface-night);
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-tertiary);
      font-style: italic;
    }
  }
</style>
