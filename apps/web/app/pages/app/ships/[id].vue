<script setup lang="ts">
  import { AppCard, AppBadge, AppButton, AppBanner } from '@app/ui';
  import { ref, onMounted } from 'vue';
  import { useRoute } from 'vue-router';
  import { useShipsApi } from '~/composables/useShipsApi';
  import type { Ship } from '~/composables/useShipsApi';
  import type { Problem } from '@app/api-client-ts';

  /**
   * Ship detail — STUB for Block 1 of T-2026-05-10-005.
   *
   * Resolves the ship by id so the create-flow redirect from /app/ships
   * and the list-page Open action do not 404. Renders a minimal header
   * (name, class, status badges) and a "Coming in Block 2 + 3 + 4" panel.
   *
   * Block 2 replaces this file with the real sheet: header actions
   * (rename, duplicate, delete), the full stat block, and the modules
   * list grouped by slot. Block 3 adds the module editor modal. Block 4
   * adds the crew roster assignment widget.
   */

  const { t } = useI18n({ useScope: 'local' });
  const route = useRoute();
  const shipsApi = useShipsApi();

  type LoadState = 'loading' | 'loaded' | 'error';

  const state = ref<LoadState>('loading');
  const ship = ref<Ship | null>(null);
  const errorMsg = ref('');

  function humaniseClass(cls: string): string {
    return cls
      .split('-')
      .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
      .join(' ');
  }

  async function load(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      const id = String(route.params.id);
      ship.value = await shipsApi.get(id);
      state.value = 'loaded';
    } catch (error) {
      const problem = error as Problem;
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
    "errorLoad": "Couldn't load ship.",
    "retry": "Try again",
    "backToList": "Back to ships",
    "comingSoonTitle": "Full sheet coming in Blocks 2–4",
    "comingSoonBody": "Block 2 adds the stat block and module list. Block 3 adds the module editor. Block 4 adds crew assignment.",
    "statusLabel": "Class"
  },
  "ru": {
    "errorLoad": "Не удалось загрузить корабль.",
    "retry": "Попробовать снова",
    "backToList": "К списку кораблей",
    "comingSoonTitle": "Полный лист появится в Блоках 2–4",
    "comingSoonBody": "Блок 2 добавит блок характеристик и список модулей. Блок 3 — редактор модулей. Блок 4 — назначение экипажа.",
    "statusLabel": "Класс"
  },
  "uk": {
    "errorLoad": "[uk-todo] Couldn't load ship",
    "retry": "[uk-todo] Try again",
    "backToList": "[uk-todo] Back to ships",
    "comingSoonTitle": "[uk-todo] Full sheet coming in Blocks 2–4",
    "comingSoonBody": "[uk-todo] Block 2 adds stat block and modules",
    "statusLabel": "[uk-todo] Class"
  },
  "el": {
    "errorLoad": "[el-todo] Couldn't load ship",
    "retry": "[el-todo] Try again",
    "backToList": "[el-todo] Back to ships",
    "comingSoonTitle": "[el-todo] Full sheet coming in Blocks 2–4",
    "comingSoonBody": "[el-todo] Block 2 adds stat block and modules",
    "statusLabel": "[el-todo] Class"
  }
}
</i18n>

<template>
  <section
    class="page-ship-stub"
    data-testid="page-ship-stub"
  >
    <AppButton
      variant="ghost"
      size="sm"
      class="page-ship-stub__back"
      @click="navigateTo('/app/ships')"
    >
      ← {{ t('backToList') }}
    </AppButton>

    <AppBanner
      v-if="state === 'error'"
      tone="danger"
      role="alert"
    >
      {{ errorMsg }}
      <AppButton
        variant="ghost"
        size="sm"
        @click="load"
      >
        {{ t('retry') }}
      </AppButton>
    </AppBanner>

    <div
      v-else-if="state === 'loading'"
      class="page-ship-stub__skeleton"
      aria-busy="true"
    />

    <template v-else-if="ship">
      <header class="page-ship-stub__header">
        <h1 class="page-ship-stub__name">
          {{ ship.name }}
        </h1>
        <div class="page-ship-stub__badges">
          <AppBadge
            variant="brass"
            size="md"
          >
            {{ t('statusLabel') }}: {{ humaniseClass(ship.class) }}
          </AppBadge>
        </div>
      </header>

      <AppCard class="page-ship-stub__coming-soon">
        <h2 class="page-ship-stub__coming-soon-title">
          {{ t('comingSoonTitle') }}
        </h2>
        <p class="page-ship-stub__coming-soon-body">
          {{ t('comingSoonBody') }}
        </p>
      </AppCard>
    </template>
  </section>
</template>

<style lang="scss" scoped>
  $skeleton-height: 120px;

  .page-ship-stub {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    padding: var(--space-6);
    max-width: 900px;
    margin: 0 auto;

    &__back {
      align-self: flex-start;
    }

    &__skeleton {
      height: $skeleton-height;
      border-radius: var(--radius-md);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      opacity: var(--opacity-disabled);
    }

    &__header {
      display: flex;
      align-items: flex-start;
      justify-content: space-between;
      gap: var(--space-4);
      flex-wrap: wrap;
    }

    &__name {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-md-font-size);
      letter-spacing: var(--type-display-md-letter-spacing);
      color: var(--brand-brass-light);
    }

    &__badges {
      display: inline-flex;
      gap: var(--space-2);
      flex-wrap: wrap;
    }

    &__coming-soon {
      padding: var(--space-6);
      border: 1px dashed var(--brand-brass-shadow);
    }

    &__coming-soon-title {
      margin: 0 0 var(--space-2);
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);
    }

    &__coming-soon-body {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
    }
  }
</style>
