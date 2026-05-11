<script setup lang="ts">
  definePageMeta({ layout: 'app' });

  import { AppCard, AppButton, AppInput, AppField, AppBadge, AppBanner } from '@app/ui';
  import { ref, computed, onMounted } from 'vue';
  import { useGameSessionsApi } from '~/composables/useGameSessionsApi';
  import type { GameSession, GameSessionStatus } from '~/composables/useGameSessionsApi';
  import type { Problem } from '@app/api-client-ts';

  /**
   * GM index — game sessions owned by the authenticated user. Phase 4
   * Feature 7.2 list view: tabbed (active / archived), with an inline
   * "new session" form pinned at the top of the active tab. Detail page
   * is `/app/sessions/[id]` (Block 4).
   *
   * The OpenAPI list endpoint is cursor-paginated; for v1 we just take
   * the first page (limit=20) — pagination UI lands in a follow-up if
   * the corpus grows past that. Drop the `nextCursor` for now.
   */

  const { t } = useI18n({ useScope: 'local' });
  const sessionsApi = useGameSessionsApi();

  type Tab = 'active' | 'archived';
  type LoadState = 'loading' | 'loaded' | 'error';

  const tab = ref<Tab>('active');
  const state = ref<LoadState>('loading');
  const sessions = ref<GameSession[]>([]);
  const errorMsg = ref('');

  // ── New-session form ────────────────────────────────────────────────────────
  const formOpen = ref(false);
  const newName = ref('');
  const newDescription = ref('');
  const creating = ref(false);
  const formError = ref('');

  const newNameTrimmed = computed(() => newName.value.trim());
  const formValid = computed(
    () => newNameTrimmed.value.length > 0 && newNameTrimmed.value.length <= 80,
  );

  async function load(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      const status: GameSessionStatus = tab.value;
      const data = await sessionsApi.listSessions({ status, limit: 20 });
      sessions.value = [...data.items];
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

  function setTab(next: Tab): void {
    if (tab.value === next) return;
    tab.value = next;
    void load();
  }

  function openForm(): void {
    formOpen.value = true;
    newName.value = '';
    newDescription.value = '';
    formError.value = '';
  }

  function closeForm(): void {
    formOpen.value = false;
  }

  async function onCreate(): Promise<void> {
    formError.value = '';
    if (!formValid.value) {
      formError.value = t('errorNameRequired');
      return;
    }
    creating.value = true;
    try {
      const session = await sessionsApi.createSession({
        name: newNameTrimmed.value,
        description: newDescription.value.trim() || null,
      });
      // Take the user straight to the detail page rather than back to
      // the list — the GM is here to set up a session, the next thing
      // they want is to assign characters.
      await navigateTo(`/app/sessions/${session.id}`);
    } catch (error) {
      const problem = error as Problem;
      formError.value = problem.detail ?? t('errorCreate');
    } finally {
      creating.value = false;
    }
  }

  async function onArchive(session: GameSession): Promise<void> {
    try {
      await sessionsApi.updateSession(session.id, { status: 'archived' });
      await load();
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorArchive');
    }
  }

  async function onUnarchive(session: GameSession): Promise<void> {
    try {
      await sessionsApi.updateSession(session.id, { status: 'active' });
      await load();
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorArchive');
    }
  }

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
</script>

<i18n lang="json">
{
  "en": {
    "pageTitle": "Game Sessions",
    "newSession": "New session",
    "tabActive": "Active",
    "tabArchived": "Archived",
    "emptyActiveHeading": "No active sessions yet",
    "emptyActiveBody": "Spin one up to start tracking Darkness Points and assigning characters.",
    "emptyArchivedHeading": "No archived sessions",
    "emptyArchivedBody": "Sessions archived from the active tab land here.",
    "errorLoad": "Couldn't load sessions.",
    "errorCreate": "Couldn't create that session.",
    "errorArchive": "Couldn't update that session.",
    "errorNameRequired": "A session name is required (1–80 characters).",
    "formNameLabel": "Session name",
    "formNameHint": "Short label, 1–80 characters.",
    "formNamePlaceholder": "e.g. Crimson Run",
    "formDescriptionLabel": "Description",
    "formDescriptionHint": "Optional context — campaign arc, mission objective, etc.",
    "formCreateButton": "Create session",
    "formCancelButton": "Cancel",
    "open": "Open",
    "archive": "Archive",
    "unarchive": "Unarchive",
    "dpCount": "{n} DP",
    "characterCount": "{n} character | {n} characters",
    "createdLabel": "Created"
  },
  "ru": {
    "pageTitle": "Игровые сессии",
    "newSession": "Новая сессия",
    "tabActive": "Активные",
    "tabArchived": "Архив",
    "emptyActiveHeading": "Активных сессий пока нет",
    "emptyActiveBody": "Создайте сессию, чтобы отслеживать пункты тьмы и подключать персонажей.",
    "emptyArchivedHeading": "В архиве пусто",
    "emptyArchivedBody": "Архивированные сессии появятся здесь.",
    "errorLoad": "Не удалось загрузить сессии.",
    "errorCreate": "Не удалось создать сессию.",
    "errorArchive": "Не удалось обновить сессию.",
    "errorNameRequired": "Название сессии обязательно (1–80 символов).",
    "formNameLabel": "Название",
    "formNameHint": "Короткое имя, 1–80 символов.",
    "formNamePlaceholder": "напр. «Алые рейсы»",
    "formDescriptionLabel": "Описание",
    "formDescriptionHint": "По желанию — арка кампании, цель миссии и т.д.",
    "formCreateButton": "Создать",
    "formCancelButton": "Отмена",
    "open": "Открыть",
    "archive": "В архив",
    "unarchive": "Из архива",
    "dpCount": "{n} ПТ",
    "characterCount": "{n} персонаж | {n} персонажа | {n} персонажей",
    "createdLabel": "Создана"
  },
  "uk": {
    "pageTitle": "[uk-todo] Game Sessions",
    "newSession": "[uk-todo] New session",
    "tabActive": "[uk-todo] Active",
    "tabArchived": "[uk-todo] Archived",
    "emptyActiveHeading": "[uk-todo] No active sessions",
    "emptyActiveBody": "[uk-todo] Spin one up",
    "emptyArchivedHeading": "[uk-todo] No archived",
    "emptyArchivedBody": "[uk-todo] Archived land here",
    "errorLoad": "[uk-todo] Couldn't load sessions",
    "errorCreate": "[uk-todo] Couldn't create",
    "errorArchive": "[uk-todo] Couldn't update",
    "errorNameRequired": "[uk-todo] Name required",
    "formNameLabel": "[uk-todo] Session name",
    "formNameHint": "[uk-todo] 1-80 characters",
    "formNamePlaceholder": "[uk-todo] e.g. Crimson Run",
    "formDescriptionLabel": "[uk-todo] Description",
    "formDescriptionHint": "[uk-todo] Optional context",
    "formCreateButton": "[uk-todo] Create session",
    "formCancelButton": "[uk-todo] Cancel",
    "open": "[uk-todo] Open",
    "archive": "[uk-todo] Archive",
    "unarchive": "[uk-todo] Unarchive",
    "dpCount": "[uk-todo] {n} DP",
    "characterCount": "[uk-todo] {n} characters",
    "createdLabel": "[uk-todo] Created"
  },
  "el": {
    "pageTitle": "[el-todo] Game Sessions",
    "newSession": "[el-todo] New session",
    "tabActive": "[el-todo] Active",
    "tabArchived": "[el-todo] Archived",
    "emptyActiveHeading": "[el-todo] No active sessions",
    "emptyActiveBody": "[el-todo] Spin one up",
    "emptyArchivedHeading": "[el-todo] No archived",
    "emptyArchivedBody": "[el-todo] Archived land here",
    "errorLoad": "[el-todo] Couldn't load sessions",
    "errorCreate": "[el-todo] Couldn't create",
    "errorArchive": "[el-todo] Couldn't update",
    "errorNameRequired": "[el-todo] Name required",
    "formNameLabel": "[el-todo] Session name",
    "formNameHint": "[el-todo] 1-80 characters",
    "formNamePlaceholder": "[el-todo] e.g. Crimson Run",
    "formDescriptionLabel": "[el-todo] Description",
    "formDescriptionHint": "[el-todo] Optional context",
    "formCreateButton": "[el-todo] Create session",
    "formCancelButton": "[el-todo] Cancel",
    "open": "[el-todo] Open",
    "archive": "[el-todo] Archive",
    "unarchive": "[el-todo] Unarchive",
    "dpCount": "[el-todo] {n} DP",
    "characterCount": "[el-todo] {n} characters",
    "createdLabel": "[el-todo] Created"
  }
}
</i18n>

<template>
  <section class="page-sessions" data-testid="page-sessions">
    <header class="page-sessions__header">
      <h1 class="page-sessions__title">
        {{ t('pageTitle') }}
      </h1>
      <AppButton v-if="tab === 'active' && !formOpen" variant="primary" size="md" @click="openForm">
        + {{ t('newSession') }}
      </AppButton>
    </header>

    <div class="page-sessions__tabs" role="tablist">
      <button
        type="button"
        role="tab"
        :aria-selected="tab === 'active'"
        class="page-sessions__tab"
        :class="{ 'page-sessions__tab--active': tab === 'active' }"
        @click="setTab('active')"
      >
        {{ t('tabActive') }}
      </button>
      <button
        type="button"
        role="tab"
        :aria-selected="tab === 'archived'"
        class="page-sessions__tab"
        :class="{ 'page-sessions__tab--active': tab === 'archived' }"
        @click="setTab('archived')"
      >
        {{ t('tabArchived') }}
      </button>
    </div>

    <AppCard v-if="formOpen" class="page-sessions__form-card">
      <form novalidate class="page-sessions__form" @submit.prevent="onCreate">
        <AppBanner v-if="formError" tone="danger" role="alert">
          {{ formError }}
        </AppBanner>
        <AppField :label="t('formNameLabel')" :help="t('formNameHint')" required>
          <template #default="slotAttrs">
            <AppInput
              v-bind="slotAttrs"
              v-model="newName"
              type="text"
              maxlength="80"
              :placeholder="t('formNamePlaceholder')"
            />
          </template>
        </AppField>
        <AppField :label="t('formDescriptionLabel')" :help="t('formDescriptionHint')">
          <template #default="slotAttrs">
            <AppInput v-bind="slotAttrs" v-model="newDescription" type="text" maxlength="500" />
          </template>
        </AppField>
        <div class="page-sessions__form-actions">
          <AppButton
            type="button"
            variant="ghost"
            size="sm"
            :disabled="creating"
            @click="closeForm"
          >
            {{ t('formCancelButton') }}
          </AppButton>
          <AppButton
            type="submit"
            variant="primary"
            size="sm"
            :loading="creating"
            :disabled="!formValid || creating"
          >
            {{ t('formCreateButton') }}
          </AppButton>
        </div>
      </form>
    </AppCard>

    <AppBanner v-if="errorMsg && state === 'error'" tone="danger" role="alert">
      {{ errorMsg }}
    </AppBanner>

    <p v-else-if="state === 'loading'" class="page-sessions__placeholder">…</p>

    <div v-else-if="sessions.length === 0" class="page-sessions__empty">
      <h2 class="page-sessions__empty-heading">
        {{ tab === 'active' ? t('emptyActiveHeading') : t('emptyArchivedHeading') }}
      </h2>
      <p class="page-sessions__empty-body">
        {{ tab === 'active' ? t('emptyActiveBody') : t('emptyArchivedBody') }}
      </p>
    </div>

    <ul v-else class="page-sessions__grid" role="list">
      <li v-for="session in sessions" :key="session.id">
        <AppCard class="page-sessions__card">
          <div class="page-sessions__card-head">
            <h3 class="page-sessions__card-title">
              {{ session.name }}
            </h3>
            <div class="page-sessions__card-badges">
              <AppBadge variant="darkness" size="sm">
                {{ t('dpCount', { n: session.dpCount }) }}
              </AppBadge>
              <AppBadge variant="brass" size="sm">
                {{ t('characterCount', { n: session.characterIds.length }) }}
              </AppBadge>
            </div>
          </div>
          <p v-if="session.description" class="page-sessions__card-desc">
            {{ session.description }}
          </p>
          <p class="page-sessions__card-meta">
            {{ t('createdLabel') }}: {{ formatDate(session.createdAt) }}
          </p>
          <div class="page-sessions__card-actions">
            <AppButton
              variant="primary"
              size="sm"
              @click="navigateTo(`/app/sessions/${session.id}`)"
            >
              {{ t('open') }}
            </AppButton>
            <AppButton
              v-if="session.status === 'active'"
              variant="ghost"
              size="sm"
              @click="onArchive(session)"
            >
              {{ t('archive') }}
            </AppButton>
            <AppButton v-else variant="ghost" size="sm" @click="onUnarchive(session)">
              {{ t('unarchive') }}
            </AppButton>
          </div>
        </AppCard>
      </li>
    </ul>
  </section>
</template>

<style lang="scss" scoped>
  $card-min-width: 280px;
  $page-max-width: 1200px;
  $empty-body-max-width: 480px;

  .page-sessions {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    padding: var(--space-6);
    max-width: $page-max-width;
    margin: 0 auto;

    &__header {
      display: flex;
      justify-content: space-between;
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

    &__tabs {
      display: inline-flex;
      gap: var(--space-1);
      border-bottom: 1px solid var(--brand-brass-shadow);
    }

    &__tab {
      padding: var(--space-2) var(--space-4);
      background: transparent;
      border: none;
      border-bottom: 2px solid transparent;
      cursor: pointer;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
      transition:
        color var(--motion-duration-fast) var(--motion-ease-standard),
        border-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        color: var(--brand-brass-light);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      &--active {
        color: var(--brand-brass-light);
        border-bottom-color: var(--brand-brass);
      }
    }

    &__form-card {
      padding: var(--space-4);
    }

    &__form {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__form-actions {
      display: flex;
      justify-content: flex-end;
      gap: var(--space-2);
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
      background: color-mix(in srgb, var(--brand-brass-shadow) 15%, transparent);
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
      max-width: $empty-body-max-width;
      margin-inline: auto;
    }

    &__grid {
      list-style: none;
      margin: 0;
      padding: 0;
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax($card-min-width, 1fr));
      gap: var(--space-4);
    }

    &__card {
      padding: var(--space-4);
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__card-head {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: var(--space-2);
      flex-wrap: wrap;
    }

    &__card-title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);
    }

    &__card-badges {
      display: inline-flex;
      gap: var(--space-1);
      flex-wrap: wrap;
    }

    &__card-desc {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      // Clamp to two lines so card heights stay rough.
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    &__card-meta {
      margin: 0;
      font-family: var(--font-mono);
      font-size: var(--type-body-xs-font-size);
      color: var(--text-tertiary);
    }

    &__card-actions {
      margin-top: var(--space-2);
      display: flex;
      gap: var(--space-2);
    }
  }
</style>
