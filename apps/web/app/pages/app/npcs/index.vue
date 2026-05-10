<script setup lang="ts">
  definePageMeta({ layout: 'app' });

  import { AppCard, AppButton, AppInput, AppField, AppBadge, AppBanner, AppModal } from '@app/ui';
  import { ref, computed, onMounted, onUnmounted } from 'vue';
  import { useRoute, useRouter } from 'vue-router';
  import { useNpcsApi } from '~/composables/useNpcsApi';
  import type { Npc } from '~/composables/useNpcsApi';
  import type { Problem } from '@app/api-client-ts';

  /**
   * NPCs index — GM-owned NPC library. Phase 6 T-2026-05-10-008 Block 1.
   *
   * The OpenAPI list endpoint is cursor-paginated; for v1 we take the
   * first page (limit=20). A "Load more" affordance lands in a follow-up.
   * TODO: expose "Load more" using `nextCursor` when needed.
   */

  const { t } = useI18n({ useScope: 'local' });
  const route = useRoute();
  const router = useRouter();
  const npcsApi = useNpcsApi();

  type LoadState = 'loading' | 'loaded' | 'error';

  const state = ref<LoadState>('loading');
  const npcs = ref<Npc[]>([]);
  const errorMsg = ref('');

  // ── New-NPC form ─────────────────────────────────────────────────────────────
  const formOpen = ref(false);
  const newName = ref('');
  const newDescription = ref('');
  const creating = ref(false);
  const formError = ref('');

  const newNameTrimmed = computed(() => newName.value.trim());
  const formValid = computed(
    () => newNameTrimmed.value.length > 0 && newNameTrimmed.value.length <= 120,
  );

  async function load(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      const data = await npcsApi.list({ limit: 20 });
      npcs.value = [...data.items];
      state.value = 'loaded';
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorLoad');
      state.value = 'error';
    }
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
      const npc = await npcsApi.create({
        name: newNameTrimmed.value,
        description: newDescription.value.trim() || null,
      });
      // Navigate straight to the detail page so the GM can fill in the stat block.
      await navigateTo(`/app/npcs/${npc.id}`);
    } catch (error) {
      const problem = error as Problem;
      formError.value = problem.detail ?? t('errorCreate');
    } finally {
      creating.value = false;
    }
  }

  async function onDuplicate(npc: Npc): Promise<void> {
    try {
      const copy = await npcsApi.duplicate(npc.id);
      await navigateTo(`/app/npcs/${copy.id}?duplicatedFrom=${encodeURIComponent(npc.name)}`);
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorDuplicate');
    }
  }

  // ── Delete confirm ─────────────────────────────────────────────────────────

  const deleteConfirmOpen = ref(false);
  const deletingNpc = ref<Npc | null>(null);
  const deleting = ref(false);

  function openDeleteConfirm(npc: Npc): void {
    deletingNpc.value = npc;
    deleteConfirmOpen.value = true;
  }

  function closeDeleteConfirm(): void {
    deleteConfirmOpen.value = false;
    deletingNpc.value = null;
  }

  async function confirmDelete(): Promise<void> {
    if (!deletingNpc.value) return;
    deleting.value = true;
    try {
      await npcsApi.delete(deletingNpc.value.id);
      deleteConfirmOpen.value = false;
      deletingNpc.value = null;
      await load();
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorDelete');
      deleteConfirmOpen.value = false;
      deletingNpc.value = null;
    } finally {
      deleting.value = false;
    }
  }

  // ── Duplicate toast — "recently created" banner from redirect ─────────────

  const duplicatedFromName = ref('');
  const showDuplicatedToast = ref(false);
  let toastTimer: ReturnType<typeof setTimeout> | null = null;

  onMounted(() => {
    void load();
    const fromQuery = route.query.duplicatedFrom;
    if (typeof fromQuery === 'string' && fromQuery.length > 0) {
      duplicatedFromName.value = fromQuery;
      showDuplicatedToast.value = true;
      // Clear the query param so a refresh doesn't re-trigger.
      void router.replace({ query: {} });
      toastTimer = setTimeout(() => {
        showDuplicatedToast.value = false;
        duplicatedFromName.value = '';
      }, 4000);
    }
  });

  onUnmounted(() => {
    if (toastTimer !== null) clearTimeout(toastTimer);
  });
</script>

<i18n lang="json">
{
  "en": {
    "pageTitle": "NPCs",
    "newNpc": "New NPC",
    "emptyHeading": "Build your NPC library",
    "emptyBody": "Create your first NPC to populate the Third Horizon with crew, pirates, and powerful enemies. Use the form above to get started.",
    "errorLoad": "Couldn't load NPCs.",
    "errorCreate": "Couldn't create that NPC.",
    "errorDelete": "Couldn't delete that NPC.",
    "errorDuplicate": "Couldn't duplicate that NPC.",
    "deleteConfirmTitle": "Delete this NPC?",
    "deleteConfirmBody": "This will permanently delete the NPC and remove them from any active encounters. This cannot be undone.",
    "deleteConfirmYes": "Delete",
    "deleteConfirmNo": "Cancel",
    "duplicatedToast": "Duplicated \"{name}\" to a new NPC.",
    "errorNameRequired": "An NPC name is required (1–120 characters).",
    "formNameLabel": "NPC name",
    "formNameHint": "Short label, 1–120 characters.",
    "formNamePlaceholder": "e.g. Corsair Captain",
    "formDescriptionLabel": "Description",
    "formDescriptionHint": "Optional — brief role or notes (Markdown supported).",
    "formDescriptionPlaceholder": "e.g. Scarred veteran of the Rift Wars",
    "formCreateButton": "Create NPC",
    "formCancelButton": "Cancel",
    "open": "Open",
    "duplicate": "Duplicate",
    "delete": "Delete",
    "hpLabel": "HP",
    "mpLabel": "MP",
    "tagsLabel": "Tags",
    "retry": "Try again"
  },
  "ru": {
    "pageTitle": "НПС",
    "newNpc": "Новый НПС",
    "emptyHeading": "Наполните библиотеку НПС",
    "emptyBody": "Создайте первого НПС, чтобы заселить Третий Горизонт экипажами, пиратами и опасными врагами. Используйте форму выше, чтобы начать.",
    "errorLoad": "Не удалось загрузить НПС.",
    "errorCreate": "Не удалось создать НПС.",
    "errorDelete": "Не удалось удалить НПС.",
    "errorDuplicate": "Не удалось продублировать НПС.",
    "deleteConfirmTitle": "Удалить этого НПС?",
    "deleteConfirmBody": "Это безвозвратно удалит НПС и уберёт его из всех активных столкновений. Действие необратимо.",
    "deleteConfirmYes": "Удалить",
    "deleteConfirmNo": "Отмена",
    "duplicatedToast": "«{name}» скопирован в нового НПС.",
    "errorNameRequired": "Имя НПС обязательно (1–120 символов).",
    "formNameLabel": "Имя НПС",
    "formNameHint": "Короткое имя, 1–120 символов.",
    "formNamePlaceholder": "напр. «Капитан корсаров»",
    "formDescriptionLabel": "Описание",
    "formDescriptionHint": "По желанию — роль или заметки (поддерживается Markdown).",
    "formDescriptionPlaceholder": "напр. «Ветеран Рифтовых войн»",
    "formCreateButton": "Создать",
    "formCancelButton": "Отмена",
    "open": "Открыть",
    "duplicate": "Дублировать",
    "delete": "Удалить",
    "hpLabel": "ЗД",
    "mpLabel": "ОД",
    "tagsLabel": "Теги",
    "retry": "Попробовать снова"
  },
  "uk": {
    "pageTitle": "[uk-todo] NPCs",
    "newNpc": "[uk-todo] New NPC",
    "emptyHeading": "[uk-todo] Build your NPC library",
    "emptyBody": "[uk-todo] Create your first NPC.",
    "errorLoad": "[uk-todo] Couldn't load NPCs",
    "errorCreate": "[uk-todo] Couldn't create that NPC",
    "errorDelete": "[uk-todo] Couldn't delete that NPC",
    "errorDuplicate": "[uk-todo] Couldn't duplicate that NPC",
    "deleteConfirmTitle": "[uk-todo] Delete this NPC?",
    "deleteConfirmBody": "[uk-todo] This will permanently delete the NPC. This cannot be undone.",
    "deleteConfirmYes": "[uk-todo] Delete",
    "deleteConfirmNo": "[uk-todo] Cancel",
    "duplicatedToast": "[uk-todo] Duplicated \"{name}\" to a new NPC.",
    "errorNameRequired": "[uk-todo] Name required",
    "formNameLabel": "[uk-todo] NPC name",
    "formNameHint": "[uk-todo] 1-120 characters",
    "formNamePlaceholder": "[uk-todo] e.g. Corsair Captain",
    "formDescriptionLabel": "[uk-todo] Description",
    "formDescriptionHint": "[uk-todo] Optional notes",
    "formDescriptionPlaceholder": "[uk-todo] e.g. Scarred veteran",
    "formCreateButton": "[uk-todo] Create NPC",
    "formCancelButton": "[uk-todo] Cancel",
    "open": "[uk-todo] Open",
    "duplicate": "[uk-todo] Duplicate",
    "delete": "[uk-todo] Delete",
    "hpLabel": "[uk-todo] HP",
    "mpLabel": "[uk-todo] MP",
    "tagsLabel": "[uk-todo] Tags",
    "retry": "[uk-todo] Try again"
  },
  "el": {
    "pageTitle": "[el-todo] NPCs",
    "newNpc": "[el-todo] New NPC",
    "emptyHeading": "[el-todo] Build your NPC library",
    "emptyBody": "[el-todo] Create your first NPC.",
    "errorLoad": "[el-todo] Couldn't load NPCs",
    "errorCreate": "[el-todo] Couldn't create that NPC",
    "errorDelete": "[el-todo] Couldn't delete that NPC",
    "errorDuplicate": "[el-todo] Couldn't duplicate that NPC",
    "deleteConfirmTitle": "[el-todo] Delete this NPC?",
    "deleteConfirmBody": "[el-todo] This will permanently delete the NPC. This cannot be undone.",
    "deleteConfirmYes": "[el-todo] Delete",
    "deleteConfirmNo": "[el-todo] Cancel",
    "duplicatedToast": "[el-todo] Duplicated \"{name}\" to a new NPC.",
    "errorNameRequired": "[el-todo] Name required",
    "formNameLabel": "[el-todo] NPC name",
    "formNameHint": "[el-todo] 1-120 characters",
    "formNamePlaceholder": "[el-todo] e.g. Corsair Captain",
    "formDescriptionLabel": "[el-todo] Description",
    "formDescriptionHint": "[el-todo] Optional notes",
    "formDescriptionPlaceholder": "[el-todo] e.g. Scarred veteran",
    "formCreateButton": "[el-todo] Create NPC",
    "formCancelButton": "[el-todo] Cancel",
    "open": "[el-todo] Open",
    "duplicate": "[el-todo] Duplicate",
    "delete": "[el-todo] Delete",
    "hpLabel": "[el-todo] HP",
    "mpLabel": "[el-todo] MP",
    "tagsLabel": "[el-todo] Tags",
    "retry": "[el-todo] Try again"
  }
}
</i18n>

<template>
  <section class="page-npcs" data-testid="page-npcs">
    <header class="page-npcs__header">
      <h1 class="page-npcs__title">
        {{ t('pageTitle') }}
      </h1>
      <AppButton v-if="!formOpen" variant="primary" size="md" @click="openForm">
        + {{ t('newNpc') }}
      </AppButton>
    </header>

    <!-- Create form card -->
    <AppCard v-if="formOpen" class="page-npcs__form-card">
      <form novalidate class="page-npcs__form" @submit.prevent="onCreate">
        <AppBanner v-if="formError" tone="danger" role="alert">
          {{ formError }}
        </AppBanner>

        <AppField :label="t('formNameLabel')" :help="t('formNameHint')" required>
          <template #default="slotAttrs">
            <AppInput
              v-bind="slotAttrs"
              v-model="newName"
              type="text"
              maxlength="120"
              :placeholder="t('formNamePlaceholder')"
            />
          </template>
        </AppField>

        <AppField :label="t('formDescriptionLabel')" :help="t('formDescriptionHint')">
          <template #default="slotAttrs">
            <AppInput
              v-bind="slotAttrs"
              v-model="newDescription"
              type="text"
              maxlength="2000"
              :placeholder="t('formDescriptionPlaceholder')"
            />
          </template>
        </AppField>

        <div class="page-npcs__form-actions">
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

    <!-- Error banner -->
    <AppBanner v-if="errorMsg && state === 'error'" tone="danger" role="alert">
      {{ errorMsg }}
      <AppButton variant="ghost" size="sm" @click="load">
        {{ t('retry') }}
      </AppButton>
    </AppBanner>

    <!-- Loading skeleton -->
    <div v-else-if="state === 'loading'" class="page-npcs__grid" aria-busy="true">
      <div v-for="n in 4" :key="n" class="page-npcs__skeleton" aria-hidden="true" />
    </div>

    <!-- Empty state -->
    <div v-else-if="npcs.length === 0" class="page-npcs__empty">
      <h2 class="page-npcs__empty-heading">
        {{ t('emptyHeading') }}
      </h2>
      <p class="page-npcs__empty-body">
        {{ t('emptyBody') }}
      </p>
    </div>

    <!-- NPCs grid -->
    <ul v-else class="page-npcs__grid" role="list">
      <li v-for="npc in npcs" :key="npc.id">
        <AppCard class="page-npcs__card">
          <div class="page-npcs__card-head">
            <h3 class="page-npcs__card-title">
              {{ npc.name }}
            </h3>
          </div>

          <div v-if="npc.description" class="page-npcs__card-description">
            {{ npc.description }}
          </div>

          <div class="page-npcs__card-stats">
            <span class="page-npcs__stat">
              <span class="page-npcs__stat-label">{{ t('hpLabel') }}</span>
              <span class="page-npcs__stat-value">{{ npc.hp.current }}/{{ npc.hp.max }}</span>
            </span>
            <span class="page-npcs__stat">
              <span class="page-npcs__stat-label">{{ t('mpLabel') }}</span>
              <span class="page-npcs__stat-value">{{ npc.mp.current }}/{{ npc.mp.max }}</span>
            </span>
          </div>

          <div v-if="npc.tags.length > 0" class="page-npcs__card-badges">
            <AppBadge v-for="tag in npc.tags" :key="tag" variant="darkness" size="sm">
              {{ tag }}
            </AppBadge>
          </div>

          <div class="page-npcs__card-actions">
            <AppButton variant="primary" size="sm" @click="navigateTo(`/app/npcs/${npc.id}`)">
              {{ t('open') }}
            </AppButton>
            <AppButton variant="ghost" size="sm" @click="onDuplicate(npc)">
              {{ t('duplicate') }}
            </AppButton>
            <AppButton variant="ghost" size="sm" @click="openDeleteConfirm(npc)">
              {{ t('delete') }}
            </AppButton>
          </div>
        </AppCard>
      </li>
    </ul>

    <!-- ── Duplicate toast ─────────────────────────────────────────────────── -->
    <AppBanner
      v-if="showDuplicatedToast"
      tone="success"
      role="status"
      class="page-npcs__toast"
      data-testid="duplicate-toast"
    >
      {{ t('duplicatedToast', { name: duplicatedFromName }) }}
    </AppBanner>

    <!-- ── Delete confirmation modal ─────────────────────────────────────── -->
    <AppModal
      :open="deleteConfirmOpen"
      :aria-label="t('deleteConfirmTitle')"
      size="sm"
      :close-on-backdrop="!deleting"
      :close-on-esc="!deleting"
      @update:open="
        (v) => {
          if (!v) closeDeleteConfirm();
        }
      "
    >
      <div class="page-npcs__delete-modal">
        <p class="page-npcs__delete-modal-heading">
          {{ t('deleteConfirmTitle') }}
        </p>
        <p class="page-npcs__delete-modal-body">
          {{ t('deleteConfirmBody') }}
        </p>
        <div class="page-npcs__delete-modal-actions">
          <AppButton variant="ghost" size="md" :disabled="deleting" @click="closeDeleteConfirm">
            {{ t('deleteConfirmNo') }}
          </AppButton>
          <AppButton variant="danger" size="md" :loading="deleting" @click="confirmDelete">
            {{ t('deleteConfirmYes') }}
          </AppButton>
        </div>
      </div>
    </AppModal>
  </section>
</template>

<style lang="scss" scoped>
  $card-min-width: 300px;
  $skeleton-min-height: 160px;

  .page-npcs {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    padding: var(--space-6);
    max-width: 1200px;
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

    // ── Skeleton ───────────────────────────────────────────────────────────────

    &__skeleton {
      min-height: $skeleton-min-height;
      border-radius: var(--radius-md);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      opacity: var(--opacity-disabled);
      animation: npcs-pulse var(--motion-duration-ceremony) ease-in-out infinite alternate;
    }

    // ── Empty state ────────────────────────────────────────────────────────────

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
      max-width: 480px;
      margin-inline: auto;
    }

    // ── Grid ──────────────────────────────────────────────────────────────────

    &__grid {
      list-style: none;
      margin: 0;
      padding: 0;
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax($card-min-width, 1fr));
      gap: var(--space-4);
    }

    // ── Card ──────────────────────────────────────────────────────────────────

    &__card {
      padding: var(--space-4);
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
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

    &__card-description {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      overflow: hidden;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
    }

    &__card-stats {
      display: flex;
      gap: var(--space-4);
    }

    &__stat {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__stat-label {
      font-family: var(--font-mono);
      font-size: var(--type-body-xs-font-size);
      color: var(--text-tertiary);
      text-transform: uppercase;
      letter-spacing: 0.08em;
    }

    &__stat-value {
      font-family: var(--font-mono);
      font-size: var(--type-body-md-font-size);
      color: var(--text-primary);
    }

    &__card-badges {
      display: inline-flex;
      gap: var(--space-1);
      flex-wrap: wrap;
    }

    &__card-actions {
      margin-top: var(--space-1);
      display: flex;
      gap: var(--space-2);
    }

    // ── Duplicate toast ────────────────────────────────────────────────────────

    $toast-min-width: 320px;
    $toast-max-width: 560px;

    &__toast {
      position: fixed;
      bottom: var(--space-6);
      left: 50%;
      transform: translateX(-50%);
      z-index: var(--z-toast);
      min-width: $toast-min-width;
      max-width: $toast-max-width;
    }

    // ── Delete confirmation modal ──────────────────────────────────────────────

    &__delete-modal {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
      padding: var(--space-5);
    }

    &__delete-modal-heading {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);
    }

    &__delete-modal-body {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
    }

    &__delete-modal-actions {
      display: flex;
      justify-content: flex-end;
      gap: var(--space-3);
    }
  }

  @keyframes npcs-pulse {
    from {
      opacity: var(--opacity-disabled);
    }

    to {
      opacity: 0.18;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .page-npcs__skeleton {
      animation: none;
    }
  }
</style>
