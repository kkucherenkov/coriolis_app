<script setup lang="ts">
  import { AppBanner, AppButton } from '@app/ui';
  import { usePublicSharingApi } from '~/composables/usePublicSharingApi';
  import type { Character } from '~/composables/usePublicSharingApi';
  import type { Problem } from '~/composables/useCharactersApi';
  import AppShareViewer from '~/components/AppShareViewer.vue';

  const { t } = useI18n({ useScope: 'local' });
  const route = useRoute();
  const slug = computed(() => route.params.slug as string);
  const api = usePublicSharingApi();

  type PageState = 'loading' | 'loaded' | 'not-found' | 'revoked' | 'error';

  const state = ref<PageState>('loading');
  const character = ref<Character | null>(null);
  const errorMsg = ref('');

  // useAsyncData is not reliable in ssr:false SPA mode for pages that need
  // reactive refresh, so we use onMounted + reactive state instead.
  async function load(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      character.value = await api.getCharacter(slug.value);
      state.value = 'loaded';
    } catch (error) {
      const problem = error as Problem;
      if (problem.status === 404) {
        state.value = 'not-found';
      } else if (problem.status === 410) {
        state.value = 'revoked';
      } else {
        errorMsg.value = problem.detail ?? t('errorLoad');
        state.value = 'error';
      }
    }
  }

  onMounted(() => {
    void load();
  });

  // ── OG meta tags ──────────────────────────────────────────────────────────────

  useHead({
    title: () =>
      character.value ? `${character.value.name} — Coriolis Companion` : t('metaTitleLoading'),
    meta: () => [
      { property: 'og:title', content: character.value?.name ?? '' },
      {
        property: 'og:description',
        content: character.value?.concept ?? t('metaDescriptionDefault'),
      },
      { property: 'og:image', content: `/api/v1/public/og/character/${slug.value}.png` },
      { property: 'og:type', content: 'profile' },
      { name: 'twitter:card', content: 'summary_large_image' },
    ],
  });
</script>

<i18n lang="json">
{
  "en": {
    "metaTitleLoading": "Loading… — Coriolis Companion",
    "metaDescriptionDefault": "A shared Coriolis character.",
    "errorLoad": "Failed to load character.",
    "notFoundHeading": "Character not found",
    "notFoundBody": "This share link does not exist or has been removed.",
    "notFoundBack": "Go to home",
    "revokedHeading": "Share link revoked",
    "revokedBody": "The owner has revoked this share link. It is no longer accessible.",
    "revokedBack": "Go to home",
    "errorHeading": "Something went wrong",
    "loadingLabel": "Loading shared character…"
  },
  "ru": {
    "metaTitleLoading": "Загрузка… — Coriolis Companion",
    "metaDescriptionDefault": "Общий персонаж Coriolis.",
    "errorLoad": "Не удалось загрузить персонажа.",
    "notFoundHeading": "Персонаж не найден",
    "notFoundBody": "Эта ссылка не существует или была удалена.",
    "notFoundBack": "На главную",
    "revokedHeading": "Ссылка отозвана",
    "revokedBody": "Владелец отозвал эту ссылку. Она больше недоступна.",
    "revokedBack": "На главную",
    "errorHeading": "Что-то пошло не так",
    "loadingLabel": "Загрузка персонажа…"
  },
  "uk": {
    "metaTitleLoading": "[uk-todo] Loading…",
    "metaDescriptionDefault": "[uk-todo] A shared Coriolis character.",
    "errorLoad": "[uk-todo] Failed to load character.",
    "notFoundHeading": "[uk-todo] Character not found",
    "notFoundBody": "[uk-todo] This share link does not exist.",
    "notFoundBack": "[uk-todo] Go to home",
    "revokedHeading": "[uk-todo] Share link revoked",
    "revokedBody": "[uk-todo] The owner has revoked this share link.",
    "revokedBack": "[uk-todo] Go to home",
    "errorHeading": "[uk-todo] Something went wrong",
    "loadingLabel": "[uk-todo] Loading…"
  },
  "el": {
    "metaTitleLoading": "[el-todo] Loading…",
    "metaDescriptionDefault": "[el-todo] A shared Coriolis character.",
    "errorLoad": "[el-todo] Failed to load character.",
    "notFoundHeading": "[el-todo] Character not found",
    "notFoundBody": "[el-todo] This share link does not exist.",
    "notFoundBack": "[el-todo] Go to home",
    "revokedHeading": "[el-todo] Share link revoked",
    "revokedBody": "[el-todo] The owner has revoked this share link.",
    "revokedBack": "[el-todo] Go to home",
    "errorHeading": "[el-todo] Something went wrong",
    "loadingLabel": "[el-todo] Loading…"
  }
}
</i18n>

<template>
  <main class="shared-character-page">
    <!-- ── Loading ───────────────────────────────────────────────────────────── -->
    <div
      v-if="state === 'loading'"
      class="shared-character-page__loading"
      aria-busy="true"
      :aria-label="t('loadingLabel')"
    >
      <div class="shared-character-page__skeleton-hero" aria-hidden="true" />
      <div class="shared-character-page__skeleton-body" aria-hidden="true" />
    </div>

    <!-- ── Not found ─────────────────────────────────────────────────────────── -->
    <div v-else-if="state === 'not-found'" class="shared-character-page__state-wrap">
      <AppBanner tone="warning" :title="t('notFoundHeading')">
        {{ t('notFoundBody') }}
        <template #actions>
          <AppButton variant="ghost" size="sm" @click="navigateTo('/')">
            {{ t('notFoundBack') }}
          </AppButton>
        </template>
      </AppBanner>
    </div>

    <!-- ── Revoked (410) ──────────────────────────────────────────────────────── -->
    <div v-else-if="state === 'revoked'" class="shared-character-page__state-wrap">
      <AppBanner tone="danger" :title="t('revokedHeading')">
        {{ t('revokedBody') }}
        <template #actions>
          <AppButton variant="ghost" size="sm" @click="navigateTo('/')">
            {{ t('revokedBack') }}
          </AppButton>
        </template>
      </AppBanner>
    </div>

    <!-- ── Error ─────────────────────────────────────────────────────────────── -->
    <div v-else-if="state === 'error'" class="shared-character-page__state-wrap" role="alert">
      <AppBanner tone="danger" :title="t('errorHeading')">
        {{ errorMsg }}
      </AppBanner>
    </div>

    <!-- ── Loaded ─────────────────────────────────────────────────────────────── -->
    <AppShareViewer v-else-if="state === 'loaded' && character" :character="character" />
  </main>
</template>

<style lang="scss" scoped>
  $skeleton-hero-height: 140px;
  $skeleton-body-height: 400px;
  // Duration values must live in SCSS vars (stylelint forbids inline ms in animation)
  $skeleton-dur: var(--motion-duration-deliberate, 1.5s);
  $skeleton-stagger: var(--motion-duration-fast, 0.2s);
  $skeleton-base: var(--surface-night);
  $skeleton-shimmer: color-mix(in srgb, var(--brand-brass-deep) 25%, var(--surface-night));
  // Layout max-widths (stylelint forbids raw large px inline on max-width)
  $page-max-width: 1280px;
  $state-max-width: 640px;

  .shared-character-page {
    max-width: $page-max-width;
    margin: 0 auto;
    padding: var(--space-6) var(--space-4);

    // ── Loading skeletons ───────────────────────────────────────────────────────

    &__loading {
      display: flex;
      flex-direction: column;
      gap: var(--space-6);
    }

    &__skeleton-hero {
      height: $skeleton-hero-height;
      border-radius: var(--radius-lg);
      background: linear-gradient(
        90deg,
        $skeleton-base 0%,
        $skeleton-shimmer 50%,
        $skeleton-base 100%
      );
      background-size: 200% 100%;
      animation: skeleton-shimmer $skeleton-dur ease-in-out infinite;
    }

    &__skeleton-body {
      height: $skeleton-body-height;
      border-radius: var(--radius-lg);
      background: linear-gradient(
        90deg,
        $skeleton-base 0%,
        $skeleton-shimmer 50%,
        $skeleton-base 100%
      );
      background-size: 200% 100%;
      animation: skeleton-shimmer $skeleton-dur ease-in-out $skeleton-stagger infinite;
    }

    @keyframes skeleton-shimmer {
      0% {
        background-position: 200% 0;
      }

      100% {
        background-position: -200% 0;
      }
    }

    @media (prefers-reduced-motion: reduce) {
      &__skeleton-hero,
      &__skeleton-body {
        animation: none;
        background: $skeleton-base;
      }
    }

    // ── State banners ───────────────────────────────────────────────────────────

    &__state-wrap {
      max-width: $state-max-width;
      margin: 0 auto;
      padding-top: var(--space-12);
    }
  }
</style>
