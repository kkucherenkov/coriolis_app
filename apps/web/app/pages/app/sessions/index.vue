<script setup lang="ts">
  definePageMeta({ layout: 'app' });

  import { ref, onMounted } from 'vue';
  import { AppCard, AppBadge, AppBanner } from '@app/ui';
  import { useMyMembershipsApi } from '~/composables/useMyMembershipsApi';
  import type { MyMembershipSummary } from '~/composables/useMyMembershipsApi';

  /**
   * Player sessions list (Phase 11 Stream B).
   *
   * Lists all sessions the authenticated user is a member of, sourced from
   * GET /api/v1/me/memberships. GM sessions link to /app/game-sessions/:id;
   * player sessions link to /app/sessions/:id.
   */

  const { t } = useI18n({ useScope: 'local' });
  const membershipsApi = useMyMembershipsApi();

  type LoadState = 'loading' | 'loaded' | 'error';

  const state = ref<LoadState>('loading');
  const memberships = ref<MyMembershipSummary[]>([]);
  const errorMsg = ref('');

  function sessionUrl(m: MyMembershipSummary): string {
    return m.role === 'gm'
      ? `/app/game-sessions/${m.gameSessionId}`
      : `/app/sessions/${m.gameSessionId}`;
  }

  async function load(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      memberships.value = await membershipsApi.list();
      state.value = 'loaded';
    } catch (error) {
      const problem = error as { detail?: string };
      errorMsg.value = problem.detail ?? t('errorLoad');
      state.value = 'error';
    }
  }

  onMounted(() => {
    void load();
  });
</script>

<i18n lang="json">
{
  "en": {
    "heading": "My sessions",
    "loading": "Loading sessions…",
    "errorLoad": "Couldn't load your sessions. Please try again.",
    "empty": "Not playing in any sessions yet.",
    "roleGm": "GM",
    "rolePlayer": "Player",
    "characterLabel": "Character",
    "noCharacter": "No character linked",
    "goToSession": "Open"
  },
  "ru": {
    "heading": "Мои сессии",
    "loading": "Загружаем сессии…",
    "errorLoad": "Не удалось загрузить ваши сессии. Попробуйте ещё раз.",
    "empty": "Вы ещё не участвуете ни в одной сессии.",
    "roleGm": "ГМ",
    "rolePlayer": "Игрок",
    "characterLabel": "Персонаж",
    "noCharacter": "Персонаж не привязан",
    "goToSession": "Открыть"
  }
}
</i18n>

<template>
  <section class="page-sessions-list">
    <h1 class="page-sessions-list__heading">
      {{ t('heading') }}
    </h1>

    <p v-if="state === 'loading'" class="page-sessions-list__placeholder">
      {{ t('loading') }}
    </p>

    <AppBanner v-else-if="state === 'error'" tone="danger" role="alert">
      {{ errorMsg }}
    </AppBanner>

    <p v-else-if="memberships.length === 0" class="page-sessions-list__empty">
      {{ t('empty') }}
    </p>

    <ul v-else class="page-sessions-list__list" role="list">
      <li v-for="m in memberships" :key="m.membershipId" class="page-sessions-list__item">
        <AppCard class="page-sessions-list__card">
          <div class="page-sessions-list__card-header">
            <span class="page-sessions-list__session-name">{{ m.sessionName }}</span>
            <AppBadge :variant="m.role === 'gm' ? 'mystic' : 'brass'" size="sm">
              {{ m.role === 'gm' ? t('roleGm') : t('rolePlayer') }}
            </AppBadge>
          </div>
          <p class="page-sessions-list__character">
            <span class="page-sessions-list__character-label">{{ t('characterLabel') }}:</span>
            {{ m.characterName ?? t('noCharacter') }}
          </p>
          <NuxtLink :to="sessionUrl(m)" class="page-sessions-list__link">
            {{ t('goToSession') }}
          </NuxtLink>
        </AppCard>
      </li>
    </ul>
  </section>
</template>

<style lang="scss" scoped>
  $page-max-width: 900px;

  .page-sessions-list {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    padding: var(--space-6);
    width: 100%;
    max-width: $page-max-width;
    margin: 0 auto;

    &__heading {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-md-font-size);
      letter-spacing: var(--type-display-md-letter-spacing);
      color: var(--brand-brass-light);
    }

    &__placeholder,
    &__empty {
      margin: 0;
      font-family: var(--font-body);
      color: var(--text-tertiary);
      font-style: italic;
    }

    &__list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__item {
      display: contents;
    }

    &__card {
      padding: var(--space-4);
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__card-header {
      display: flex;
      align-items: center;
      gap: var(--space-3);
      flex-wrap: wrap;
    }

    &__session-name {
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--text-primary);
      flex: 1;
      min-width: 0;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    &__character {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      display: flex;
      gap: var(--space-2);
    }

    &__character-label {
      font-weight: var(--fw-medium);
      color: var(--text-tertiary);
      flex-shrink: 0;
    }

    &__link {
      align-self: flex-start;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--brand-accent);
      text-decoration: none;

      &:hover {
        text-decoration: underline;
      }
    }
  }
</style>
