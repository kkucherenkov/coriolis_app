<script setup lang="ts">
  import { AppBanner, AppButton } from '@app/ui';

  const { t } = useI18n({ useScope: 'local' });

  useHead({
    title: () => t('pageTitle'),
  });
</script>

<i18n lang="json">
{
  "en": {
    "pageTitle": "Ship — Coriolis Companion",
    "comingSoonTitle": "Ship sharing coming soon",
    "comingSoonBody": "Ship character sheets will be available to share in a future update. Check back soon!",
    "backToHome": "Go to home"
  },
  "ru": {
    "pageTitle": "Корабль — Coriolis Companion",
    "comingSoonTitle": "Обмен кораблями скоро появится",
    "comingSoonBody": "Листы кораблей можно будет открыть для общего доступа в будущем обновлении. Следите за новостями!",
    "backToHome": "На главную"
  },
  "uk": {
    "pageTitle": "[uk-todo] Ship — Coriolis Companion",
    "comingSoonTitle": "[uk-todo] Ship sharing coming soon",
    "comingSoonBody": "[uk-todo] Ship character sheets will be available to share in a future update.",
    "backToHome": "[uk-todo] Go to home"
  },
  "el": {
    "pageTitle": "[el-todo] Ship — Coriolis Companion",
    "comingSoonTitle": "[el-todo] Ship sharing coming soon",
    "comingSoonBody": "[el-todo] Ship character sheets will be available to share in a future update.",
    "backToHome": "[el-todo] Go to home"
  }
}
</i18n>

<template>
  <main class="shared-ship-page">
    <div class="shared-ship-page__wrap">
      <AppBanner tone="info" :title="t('comingSoonTitle')">
        {{ t('comingSoonBody') }}
        <template #actions>
          <AppButton variant="ghost" size="sm" @click="navigateTo('/')">
            {{ t('backToHome') }}
          </AppButton>
        </template>
      </AppBanner>
    </div>
  </main>
</template>

<style lang="scss" scoped>
  $page-max-width: 1280px;
  $state-max-width: 640px;

  .shared-ship-page {
    max-width: $page-max-width;
    margin: 0 auto;
    padding: var(--space-6) var(--space-4);

    &__wrap {
      max-width: $state-max-width;
      margin: 0 auto;
      padding-top: var(--space-12);
    }
  }
</style>
