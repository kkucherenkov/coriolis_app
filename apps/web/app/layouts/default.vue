<script setup lang="ts">
  const { t } = useI18n({ useScope: 'local' });
</script>

<i18n lang="json">
{
  "en": {
    "wordmark": "Coriolis · Companion",
    "disclaimer": "A fan project · Not affiliated with the publisher of the Coriolis tabletop RPG."
  },
  "ru": {
    "wordmark": "Coriolis · Companion",
    "disclaimer": "Фан-проект · Не связан с издателем настольной ролевой игры Coriolis."
  }
}
</i18n>

<template>
  <div class="layout-default">
    <header class="layout-default__header">
      <span class="layout-default__wordmark">{{ t('wordmark') }}</span>
    </header>

    <main class="layout-default__main">
      <slot />
    </main>

    <footer class="layout-default__footer">
      <span class="layout-default__disclaimer">{{ t('disclaimer') }}</span>
    </footer>
  </div>
</template>

<style lang="scss" scoped>
  .layout-default {
    display: flex;
    flex-direction: column;
    min-height: 100dvh;
    background: var(--surface-void);
    color: var(--text-primary);
    font-family: var(--font-body);
    font-size: var(--type-body-md-font-size);
    line-height: var(--type-body-md-line-height);

    &__header {
      display: flex;
      align-items: center;
      justify-content: center;
      padding: var(--space-5) var(--space-7);
      border-bottom: 1px solid var(--brand-brass-shadow);

      @media (max-width: 768px) {
        padding: var(--space-4) var(--space-4);
      }
    }

    &__wordmark {
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      font-weight: var(--fw-regular);
      letter-spacing: 0.18em;
      text-transform: uppercase;
      color: var(--brand-brass-light);
    }

    &__main {
      flex: 1;
      display: flex;
      flex-direction: column;
      padding: var(--space-7) var(--space-8);

      @media (max-width: 768px) {
        padding: var(--space-5) var(--space-4);
      }

      @media (max-width: 420px) {
        padding: var(--space-4) var(--space-3);
      }
    }

    &__footer {
      padding: var(--space-6) var(--space-8);
      text-align: center;
      border-top: 1px solid var(--brand-brass-shadow);

      @media (max-width: 768px) {
        padding: var(--space-5) var(--space-4);
      }
    }

    &__disclaimer {
      font-size: var(--type-body-sm-font-size);
      letter-spacing: 0.06em;
      color: var(--text-secondary);
      opacity: var(--opacity-secondary);
    }
  }
</style>
