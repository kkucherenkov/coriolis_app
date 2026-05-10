<script setup lang="ts">
  import { AppCard, AppButton } from '@app/ui';
  import { ref, onMounted } from 'vue';
  import { useCharactersApi } from '~/composables/useCharactersApi';
  import type { Character } from '~/composables/useCharactersApi';

  const { t } = useI18n({ useScope: 'local' });
  const api = useCharactersApi();

  type LoadState = 'loading' | 'loaded' | 'error';

  const state = ref<LoadState>('loading');
  const characters = ref<Character[]>([]);
  const errorMsg = ref('');

  async function load(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      const data = await api.list({ limit: 20 });
      characters.value = data.items;
      state.value = 'loaded';
    } catch {
      errorMsg.value = t('errorLoad');
      state.value = 'error';
    }
  }

  onMounted(() => {
    void load();
  });

  function formatDate(iso: string): string {
    if (!iso) return '';
    try {
      return new Intl.DateTimeFormat(undefined, {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
      }).format(new Date(iso));
    } catch {
      return '';
    }
  }

  function initials(name: string): string {
    return name
      .trim()
      .split(/\s+/)
      .slice(0, 2)
      .map((w) => w[0]?.toUpperCase() ?? '')
      .join('');
  }
</script>

<i18n lang="json">
{
  "en": {
    "pageTitle": "Characters",
    "newCharacter": "New character",
    "emptyHeading": "No characters yet",
    "emptyBody": "Create your first character to start your journey in the Third Horizon.",
    "errorLoad": "Failed to load characters. Please try again.",
    "retry": "Try again",
    "iconLabel": "Icon",
    "skeletonAria": "Loading characters…",
    "navShips": "Ships"
  },
  "ru": {
    "pageTitle": "Персонажи",
    "newCharacter": "Новый персонаж",
    "emptyHeading": "Ещё нет персонажей",
    "emptyBody": "Создайте первого персонажа, чтобы начать своё путешествие по Третьему Горизонту.",
    "errorLoad": "Не удалось загрузить персонажей. Попробуйте ещё раз.",
    "retry": "Попробовать снова",
    "iconLabel": "Икона",
    "skeletonAria": "Загрузка персонажей…",
    "navShips": "Корабли"
  },
  "uk": {
    "pageTitle": "[uk-todo] Characters",
    "newCharacter": "[uk-todo] New character",
    "emptyHeading": "[uk-todo] No characters yet",
    "emptyBody": "[uk-todo] Create your first character",
    "errorLoad": "[uk-todo] Failed to load characters",
    "retry": "[uk-todo] Try again",
    "iconLabel": "[uk-todo] Icon",
    "skeletonAria": "[uk-todo] Loading characters",
    "navShips": "[uk-todo] Ships"
  },
  "el": {
    "pageTitle": "[el-todo] Characters",
    "newCharacter": "[el-todo] New character",
    "emptyHeading": "[el-todo] No characters yet",
    "emptyBody": "[el-todo] Create your first character",
    "errorLoad": "[el-todo] Failed to load characters",
    "retry": "[el-todo] Try again",
    "iconLabel": "[el-todo] Icon",
    "skeletonAria": "[el-todo] Loading characters",
    "navShips": "[el-todo] Ships"
  }
}
</i18n>

<template>
  <section class="page-characters">
    <div class="page-characters__header">
      <h1 class="page-characters__title">
        {{ t('pageTitle') }}
      </h1>
      <div class="page-characters__header-actions">
        <AppButton variant="ghost" size="md" @click="navigateTo('/app/ships')">
          {{ t('navShips') }}
        </AppButton>
        <AppButton variant="primary" size="md" @click="navigateTo('/app/characters/new')">
          {{ t('newCharacter') }}
        </AppButton>
      </div>
    </div>

    <!-- Loading skeleton -->
    <div
      v-if="state === 'loading'"
      class="page-characters__grid"
      :aria-label="t('skeletonAria')"
      aria-busy="true"
    >
      <div v-for="n in 4" :key="n" class="page-characters__skeleton" aria-hidden="true" />
    </div>

    <!-- Error -->
    <div v-else-if="state === 'error'" class="page-characters__error" role="alert">
      <p class="page-characters__error-text">
        {{ errorMsg }}
      </p>
      <AppButton variant="ghost" size="sm" @click="load">
        {{ t('retry') }}
      </AppButton>
    </div>

    <!-- Empty state -->
    <div v-else-if="characters.length === 0" class="page-characters__empty">
      <AppCard class="page-characters__empty-card">
        <div class="page-characters__empty-body">
          <p class="page-characters__empty-heading">
            {{ t('emptyHeading') }}
          </p>
          <p class="page-characters__empty-sub">
            {{ t('emptyBody') }}
          </p>
          <AppButton variant="primary" size="md" @click="navigateTo('/app/characters/new')">
            {{ t('newCharacter') }}
          </AppButton>
        </div>
      </AppCard>
    </div>

    <!-- Character grid -->
    <div v-else class="page-characters__grid">
      <button
        v-for="char in characters"
        :key="char.id"
        type="button"
        class="page-characters__card"
        @click="navigateTo(`/app/characters/${char.id}`)"
      >
        <div class="page-characters__avatar" aria-hidden="true">
          {{ initials(char.name) }}
        </div>
        <div class="page-characters__card-info">
          <span class="page-characters__card-name">{{ char.name }}</span>
          <span v-if="char.concept" class="page-characters__card-concept">{{ char.concept }}</span>
          <span v-if="char.iconId" class="page-characters__card-meta">
            {{ t('iconLabel') }}: {{ char.iconId }}
          </span>
        </div>
        <span class="page-characters__card-date">
          {{ formatDate(char.updatedAt) }}
        </span>
      </button>
    </div>
  </section>
</template>

<style lang="scss" scoped>
  // Layout constants — not part of the spacing scale.
  $card-min-width: 280px;
  $skeleton-min-height: 120px;
  $avatar-size: 44px;
  $card-empty-max-width: 480px;

  .page-characters {
    display: flex;
    flex-direction: column;
    gap: var(--space-7);

    &__header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: var(--space-4);
    }

    &__header-actions {
      display: inline-flex;
      align-items: center;
      gap: var(--space-2);
    }

    &__title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-md-font-size);
      line-height: var(--type-display-md-line-height);
      font-weight: var(--type-display-md-font-weight);
      letter-spacing: var(--type-display-md-letter-spacing);
      color: var(--brand-brass-light);
    }

    // ── Skeleton ─────────────────────────────────────────────────────────────

    &__skeleton {
      min-height: $skeleton-min-height;
      border-radius: var(--radius-md);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      opacity: var(--opacity-disabled);
      animation: characters-pulse var(--motion-duration-ceremony) ease-in-out infinite alternate;
    }

    // ── Error ─────────────────────────────────────────────────────────────────

    &__error {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--space-4);
      padding: var(--space-8) 0;
    }

    &__error-text {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--state-crimson-bright);
    }

    // ── Empty state ──────────────────────────────────────────────────────────

    &__empty {
      display: flex;
      justify-content: center;
    }

    &__empty-card {
      max-width: $card-empty-max-width;
      width: 100%;
    }

    &__empty-body {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--space-4);
      padding: var(--space-6) 0;
      text-align: center;
    }

    &__empty-heading {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      line-height: var(--type-display-sm-line-height);
      color: var(--brand-brass-light);
    }

    &__empty-sub {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    // ── Grid ─────────────────────────────────────────────────────────────────

    &__grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax($card-min-width, 1fr));
      gap: var(--space-5);
    }

    // ── Card ─────────────────────────────────────────────────────────────────

    &__card {
      display: flex;
      align-items: center;
      gap: var(--space-4);
      padding: var(--space-5);
      text-align: left;
      cursor: pointer;
      width: 100%;
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      color: var(--text-primary);
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      transition: border-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      &:hover {
        border-color: var(--brand-brass-deep);
      }
    }

    &__avatar {
      flex-shrink: 0;
      width: $avatar-size;
      height: $avatar-size;
      border-radius: var(--radius-pill);
      background-color: var(--brand-brass-deep);
      color: var(--text-on-brass);
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      font-weight: 600;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    &__card-info {
      flex: 1;
      min-width: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__card-name {
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      line-height: var(--type-display-sm-line-height);
      color: var(--brand-brass-light);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    &__card-concept {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    &__card-meta {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--brand-brass);
      letter-spacing: 0.08em;
      text-transform: uppercase;
    }

    &__card-date {
      flex-shrink: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }
  }

  @keyframes characters-pulse {
    from {
      opacity: var(--opacity-disabled);
    }

    to {
      opacity: 0.18;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .page-characters__skeleton {
      animation: none;
    }
  }
</style>
