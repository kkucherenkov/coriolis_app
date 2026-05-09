<script setup lang="ts">
  import { AppCard, AppBanner, AppBadge } from '@app/ui';
  import { ref, onMounted, computed } from 'vue';
  import { useGameSessionsApi } from '~/composables/useGameSessionsApi';
  import type { GameSession } from '~/composables/useGameSessionsApi';
  import type { Problem } from '@app/api-client-ts';

  /**
   * Session detail page — placeholder skeleton for Block 3 of
   * T-2026-05-10-002. Block 4 fills in the DP counter, audit log,
   * GM-only adjustment controls, and character assignment UX. Block 5
   * adds the Centrifugo subscription so the DP counter and roll-pushed
   * notifications update without a reload.
   *
   * For now we just resolve the session, render the basic card, and
   * link back to the index. Letting the navigation from
   * `/app/sessions` actually land somewhere prevents the create-flow
   * redirect from 404-ing.
   */

  const { t } = useI18n({ useScope: 'local' });
  const route = useRoute();
  const sessionsApi = useGameSessionsApi();

  const sessionId = computed<string>(() => route.params.id as string);

  type LoadState = 'loading' | 'loaded' | 'error' | 'notfound';

  const state = ref<LoadState>('loading');
  const session = ref<GameSession | null>(null);
  const errorMsg = ref('');

  onMounted(async () => {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      const s = await sessionsApi.getSession(sessionId.value);
      session.value = s;
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
  });
</script>

<i18n lang="json">
{
  "en": {
    "backToList": "← Back to sessions",
    "loading": "Loading session…",
    "errorLoad": "Couldn't load that session.",
    "notFoundHeading": "Session not found",
    "notFoundBody": "It may have been deleted, or you don't have permission to view it.",
    "comingSoon": "DP counter, audit log, character assignment, and live updates land in the next blocks (T-2026-05-10-002 Block 4 + 5).",
    "dpLabel": "Darkness Points",
    "charactersLabel": "Characters"
  },
  "ru": {
    "backToList": "← К списку сессий",
    "loading": "Загружаем сессию…",
    "errorLoad": "Не удалось загрузить сессию.",
    "notFoundHeading": "Сессия не найдена",
    "notFoundBody": "Возможно, она была удалена или у вас нет к ней доступа.",
    "comingSoon": "Счётчик пунктов тьмы, журнал событий, назначение персонажей и live-обновления появятся в следующих блоках (T-2026-05-10-002 Block 4 + 5).",
    "dpLabel": "Пункты тьмы",
    "charactersLabel": "Персонажи"
  },
  "uk": {
    "backToList": "[uk-todo] Back",
    "loading": "[uk-todo] Loading session",
    "errorLoad": "[uk-todo] Couldn't load",
    "notFoundHeading": "[uk-todo] Session not found",
    "notFoundBody": "[uk-todo] May have been deleted",
    "comingSoon": "[uk-todo] Coming soon",
    "dpLabel": "[uk-todo] Darkness Points",
    "charactersLabel": "[uk-todo] Characters"
  },
  "el": {
    "backToList": "[el-todo] Back",
    "loading": "[el-todo] Loading session",
    "errorLoad": "[el-todo] Couldn't load",
    "notFoundHeading": "[el-todo] Session not found",
    "notFoundBody": "[el-todo] May have been deleted",
    "comingSoon": "[el-todo] Coming soon",
    "dpLabel": "[el-todo] Darkness Points",
    "charactersLabel": "[el-todo] Characters"
  }
}
</i18n>

<template>
  <section
    class="page-session-detail"
    data-testid="page-session-detail"
  >
    <NuxtLink
      to="/app/sessions"
      class="page-session-detail__back"
    >
      {{ t('backToList') }}
    </NuxtLink>

    <p
      v-if="state === 'loading'"
      class="page-session-detail__placeholder"
    >
      {{ t('loading') }}
    </p>

    <AppBanner
      v-else-if="state === 'error'"
      tone="danger"
      role="alert"
    >
      {{ errorMsg }}
    </AppBanner>

    <div
      v-else-if="state === 'notfound'"
      class="page-session-detail__empty"
    >
      <h2 class="page-session-detail__empty-heading">
        {{ t('notFoundHeading') }}
      </h2>
      <p class="page-session-detail__empty-body">
        {{ t('notFoundBody') }}
      </p>
    </div>

    <template v-else-if="session">
      <header class="page-session-detail__header">
        <h1 class="page-session-detail__title">
          {{ session.name }}
        </h1>
        <p
          v-if="session.description"
          class="page-session-detail__description"
        >
          {{ session.description }}
        </p>
      </header>

      <div class="page-session-detail__stats">
        <AppCard class="page-session-detail__stat">
          <span class="page-session-detail__stat-label">
            {{ t('dpLabel') }}
          </span>
          <span class="page-session-detail__stat-value">
            {{ session.dpCount }}
          </span>
        </AppCard>
        <AppCard class="page-session-detail__stat">
          <span class="page-session-detail__stat-label">
            {{ t('charactersLabel') }}
          </span>
          <span class="page-session-detail__stat-value">
            {{ session.characterIds.length }}
          </span>
        </AppCard>
        <AppCard class="page-session-detail__stat">
          <span class="page-session-detail__stat-label">Status</span>
          <span class="page-session-detail__stat-value">
            <AppBadge
              :variant="session.status === 'active' ? 'success' : 'brass'"
              size="md"
            >
              {{ session.status }}
            </AppBadge>
          </span>
        </AppCard>
      </div>

      <AppCard class="page-session-detail__placeholder-card">
        {{ t('comingSoon') }}
      </AppCard>
    </template>
  </section>
</template>

<style lang="scss" scoped>
  .page-session-detail {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    padding: var(--space-6);
    max-width: 1200px;
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

    &__stats {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: var(--space-3);
    }

    &__stat {
      padding: var(--space-4);
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__stat-label {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 0.06em;
    }

    &__stat-value {
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      color: var(--brand-brass-light);
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

    &__placeholder-card {
      padding: var(--space-4);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-tertiary);
      font-style: italic;
      text-align: center;
    }
  }
</style>
