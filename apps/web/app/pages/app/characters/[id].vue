<script setup lang="ts">
  import { AppCard, AppButton, AppInput } from '@app/ui';
  import { ref, watch, onBeforeUnmount, computed } from 'vue';
  import { useCharactersApi } from '~/composables/useCharactersApi';
  import type { Character, Problem } from '~/composables/useCharactersApi';
  import { useDebounceFn } from '~/composables/useDebounceFn';

  const { t } = useI18n({ useScope: 'local' });
  const api = useCharactersApi();
  const route = useRoute();

  const characterId = computed<string>(() => route.params['id'] as string);

  type LoadState = 'loading' | 'loaded' | 'not-found' | 'error';

  const state = ref<LoadState>('loading');
  const character = ref<Character | null>(null);
  const errorMsg = ref('');

  // Editable fields — local copies; auto-save writes them back
  const nameValue = ref('');
  const conceptValue = ref('');

  // Save-state indicator
  type SaveState = 'idle' | 'saving' | 'saved' | 'error';
  const saveState = ref<SaveState>('idle');
  const saveError = ref('');

  // Delete confirmation dialog
  const deleteDialogOpen = ref(false);
  const deleteLoading = ref(false);

  // ── Load ─────────────────────────────────────────────────────────────────

  async function load(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      const data = await api.get(characterId.value);
      character.value = data;
      nameValue.value = data.name;
      conceptValue.value = data.concept ?? '';
      state.value = 'loaded';
    } catch (err) {
      const problem = err as Problem;
      if (problem?.status === 404 || problem?.status === 403) {
        state.value = 'not-found';
      } else {
        errorMsg.value = problem?.detail ?? t('errorLoad');
        state.value = 'error';
      }
    }
  }

  onMounted(() => {
    void load();
  });

  // ── Auto-save ─────────────────────────────────────────────────────────────

  async function persistChanges(): Promise<void> {
    if (!character.value) return;
    const trimmedName = nameValue.value.trim();
    if (!trimmedName) return; // Never save an empty name
    saveState.value = 'saving';
    saveError.value = '';
    try {
      const updated = await api.update(characterId.value, {
        name: trimmedName,
        concept: conceptValue.value.trim() || null,
      });
      character.value = updated;
      saveState.value = 'saved';
      // Clear "Saved" indicator after 1500ms
      setTimeout(() => {
        if (saveState.value === 'saved') saveState.value = 'idle';
      }, 1500);
    } catch (err) {
      const problem = err as Problem;
      saveError.value = problem?.detail ?? t('errorSave');
      saveState.value = 'error';
    }
  }

  const { debouncedFn: scheduleSave, cancel: cancelSave } = useDebounceFn(
    persistChanges,
    500,
  );

  watch(nameValue, () => {
    if (state.value !== 'loaded') return;
    saveState.value = 'idle';
    scheduleSave();
  });

  watch(conceptValue, () => {
    if (state.value !== 'loaded') return;
    saveState.value = 'idle';
    scheduleSave();
  });

  onBeforeUnmount(() => {
    cancelSave();
  });

  // ── Delete ────────────────────────────────────────────────────────────────

  function openDeleteDialog(): void {
    deleteDialogOpen.value = true;
  }

  function closeDeleteDialog(): void {
    deleteDialogOpen.value = false;
  }

  async function confirmDelete(): Promise<void> {
    deleteLoading.value = true;
    try {
      await api.delete(characterId.value);
      await navigateTo('/app/characters');
    } catch {
      deleteDialogOpen.value = false;
      saveError.value = t('errorDelete');
      saveState.value = 'error';
    } finally {
      deleteLoading.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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
    "pageTitle": "Character sheet",
    "namePlaceholder": "Character name",
    "conceptPlaceholder": "Concept — e.g. Veteran fringe pilot",
    "placeholderBody": "Full sheet arrives in Phase 2 — see Epic 5.",
    "deleteButton": "Delete character",
    "deleteConfirmHeading": "Delete this character?",
    "deleteConfirmBody": "This action is permanent and cannot be undone.",
    "deleteConfirmYes": "Delete",
    "deleteConfirmNo": "Cancel",
    "statusSaving": "Saving…",
    "statusSaved": "Saved",
    "statusError": "Save failed",
    "errorLoad": "Failed to load character.",
    "errorSave": "Auto-save failed. Your changes may not have been saved.",
    "errorDelete": "Failed to delete character. Please try again.",
    "notFoundHeading": "Character not found",
    "notFoundBody": "This character does not exist or you do not have access to it.",
    "notFoundBack": "Back to characters"
  },
  "ru": {
    "pageTitle": "Лист персонажа",
    "namePlaceholder": "Имя персонажа",
    "conceptPlaceholder": "Концепция — напр. Ветеран пограничья",
    "placeholderBody": "Полный лист появится во Фазе 2 — см. Epic 5.",
    "deleteButton": "Удалить персонажа",
    "deleteConfirmHeading": "Удалить этого персонажа?",
    "deleteConfirmBody": "Это действие необратимо.",
    "deleteConfirmYes": "Удалить",
    "deleteConfirmNo": "Отмена",
    "statusSaving": "Сохранение…",
    "statusSaved": "Сохранено",
    "statusError": "Ошибка сохранения",
    "errorLoad": "Не удалось загрузить персонажа.",
    "errorSave": "Автосохранение не удалось. Изменения могут быть потеряны.",
    "errorDelete": "Не удалось удалить персонажа. Попробуйте ещё раз.",
    "notFoundHeading": "Персонаж не найден",
    "notFoundBody": "Этот персонаж не существует или у вас нет доступа.",
    "notFoundBack": "К персонажам"
  },
  "uk": {
    "pageTitle": "[uk-todo] Character sheet",
    "namePlaceholder": "[uk-todo] Character name",
    "conceptPlaceholder": "[uk-todo] Concept",
    "placeholderBody": "[uk-todo] Full sheet in Phase 2",
    "deleteButton": "[uk-todo] Delete character",
    "deleteConfirmHeading": "[uk-todo] Delete this character?",
    "deleteConfirmBody": "[uk-todo] This action is permanent",
    "deleteConfirmYes": "[uk-todo] Delete",
    "deleteConfirmNo": "[uk-todo] Cancel",
    "statusSaving": "[uk-todo] Saving",
    "statusSaved": "[uk-todo] Saved",
    "statusError": "[uk-todo] Save failed",
    "errorLoad": "[uk-todo] Failed to load character",
    "errorSave": "[uk-todo] Auto-save failed",
    "errorDelete": "[uk-todo] Failed to delete character",
    "notFoundHeading": "[uk-todo] Character not found",
    "notFoundBody": "[uk-todo] Does not exist or no access",
    "notFoundBack": "[uk-todo] Back to characters"
  },
  "el": {
    "pageTitle": "[el-todo] Character sheet",
    "namePlaceholder": "[el-todo] Character name",
    "conceptPlaceholder": "[el-todo] Concept",
    "placeholderBody": "[el-todo] Full sheet in Phase 2",
    "deleteButton": "[el-todo] Delete character",
    "deleteConfirmHeading": "[el-todo] Delete this character?",
    "deleteConfirmBody": "[el-todo] This action is permanent",
    "deleteConfirmYes": "[el-todo] Delete",
    "deleteConfirmNo": "[el-todo] Cancel",
    "statusSaving": "[el-todo] Saving",
    "statusSaved": "[el-todo] Saved",
    "statusError": "[el-todo] Save failed",
    "errorLoad": "[el-todo] Failed to load character",
    "errorSave": "[el-todo] Auto-save failed",
    "errorDelete": "[el-todo] Failed to delete character",
    "notFoundHeading": "[el-todo] Character not found",
    "notFoundBody": "[el-todo] Does not exist or no access",
    "notFoundBack": "[el-todo] Back to characters"
  }
}
</i18n>

<template>
  <section class="page-sheet">
    <!-- Loading -->
    <div
      v-if="state === 'loading'"
      class="page-sheet__loading"
      aria-busy="true"
    >
      <div class="page-sheet__skeleton-header" aria-hidden="true" />
      <div class="page-sheet__skeleton-body" aria-hidden="true" />
    </div>

    <!-- Not found -->
    <div
      v-else-if="state === 'not-found'"
      class="page-sheet__not-found"
    >
      <AppCard>
        <div class="page-sheet__not-found-inner">
          <p class="page-sheet__not-found-heading">{{ t('notFoundHeading') }}</p>
          <p class="page-sheet__not-found-body">{{ t('notFoundBody') }}</p>
          <AppButton
            variant="ghost"
            size="md"
            @click="navigateTo('/app/characters')"
          >
            {{ t('notFoundBack') }}
          </AppButton>
        </div>
      </AppCard>
    </div>

    <!-- Error -->
    <div
      v-else-if="state === 'error'"
      class="page-sheet__error"
      role="alert"
    >
      <p class="page-sheet__error-text">{{ errorMsg }}</p>
    </div>

    <!-- Loaded -->
    <template v-else-if="state === 'loaded' && character">
      <!-- Header row -->
      <div class="page-sheet__header">
        <!-- Avatar (initials) -->
        <div class="page-sheet__avatar" aria-hidden="true">
          {{ initials(nameValue || character.name) }}
        </div>

        <!-- Editable name + concept -->
        <div class="page-sheet__identity">
          <AppInput
            v-model="nameValue"
            size="lg"
            :placeholder="t('namePlaceholder')"
            :aria-label="t('namePlaceholder')"
            autocomplete="off"
            class="page-sheet__name-input"
          />
          <AppInput
            v-model="conceptValue"
            size="md"
            :placeholder="t('conceptPlaceholder')"
            :aria-label="t('conceptPlaceholder')"
            autocomplete="off"
            class="page-sheet__concept-input"
          />
        </div>

        <!-- Save state indicator -->
        <div class="page-sheet__save-status" aria-live="polite" aria-atomic="true">
          <span
            v-if="saveState === 'saving'"
            class="page-sheet__save-label page-sheet__save-label--saving"
          >{{ t('statusSaving') }}</span>
          <span
            v-else-if="saveState === 'saved'"
            class="page-sheet__save-label page-sheet__save-label--saved"
          >{{ t('statusSaved') }}</span>
          <span
            v-else-if="saveState === 'error'"
            class="page-sheet__save-label page-sheet__save-label--error"
            role="alert"
          >{{ t('statusError') }}</span>
        </div>
      </div>

      <!-- Auto-save error detail -->
      <p
        v-if="saveError && saveState === 'error'"
        class="page-sheet__save-error"
        role="alert"
      >
        {{ saveError }}
      </p>

      <!-- Body placeholder -->
      <AppCard>
        <p class="page-sheet__placeholder-text">{{ t('placeholderBody') }}</p>
      </AppCard>

      <!-- Danger zone -->
      <div class="page-sheet__danger-zone">
        <AppButton
          variant="danger"
          size="sm"
          @click="openDeleteDialog"
        >
          {{ t('deleteButton') }}
        </AppButton>
      </div>
    </template>

    <!-- Delete confirmation dialog -->
    <dialog
      :open="deleteDialogOpen"
      class="page-sheet__dialog"
      :aria-label="t('deleteConfirmHeading')"
      @close="closeDeleteDialog"
    >
      <div class="page-sheet__dialog-inner">
        <p class="page-sheet__dialog-heading">{{ t('deleteConfirmHeading') }}</p>
        <p class="page-sheet__dialog-body">{{ t('deleteConfirmBody') }}</p>
        <div class="page-sheet__dialog-actions">
          <AppButton
            variant="ghost"
            size="md"
            :disabled="deleteLoading"
            @click="closeDeleteDialog"
          >
            {{ t('deleteConfirmNo') }}
          </AppButton>
          <AppButton
            variant="danger"
            size="md"
            :loading="deleteLoading"
            @click="confirmDelete"
          >
            {{ t('deleteConfirmYes') }}
          </AppButton>
        </div>
      </div>
    </dialog>
  </section>
</template>

<style lang="scss" scoped>
  // Skeleton stagger delay — intentionally a fixed offset, not a UI transition.
  // Named SCSS variable to satisfy the raw-ms Stylelint ban on animation-delay.
  $skeleton-stagger: 200ms;
  // Skeleton dimensions — layout constants, not part of the spacing scale.
  $skeleton-header-height: 100px;
  $skeleton-body-height: 200px;
  // Avatar size — 56px circle, fixed per design spec.
  $avatar-size: 56px;
  // Confirm dialog max width — layout cap, not a spacing token.
  $dialog-max-width: 400px;

  .page-sheet {
    display: flex;
    flex-direction: column;
    gap: var(--space-6);

    // ── Loading skeletons ─────────────────────────────────────────────────────

    &__loading {
      display: flex;
      flex-direction: column;
      gap: var(--space-5);
    }

    &__skeleton-header {
      height: $skeleton-header-height;
      border-radius: var(--radius-md);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      opacity: var(--opacity-disabled);
      animation: sheet-pulse var(--motion-duration-ceremony) ease-in-out infinite alternate;
    }

    &__skeleton-body {
      height: $skeleton-body-height;
      border-radius: var(--radius-md);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      opacity: var(--opacity-disabled);
      animation: sheet-pulse var(--motion-duration-ceremony) ease-in-out infinite alternate;
      animation-delay: $skeleton-stagger;
    }

    // ── Not found ────────────────────────────────────────────────────────────

    &__not-found {
      display: flex;
      justify-content: center;
      padding: var(--space-9) 0;
    }

    &__not-found-inner {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--space-4);
      text-align: center;
    }

    &__not-found-heading {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      color: var(--brand-brass-light);
    }

    &__not-found-body {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    // ── Error ─────────────────────────────────────────────────────────────────

    &__error {
      padding: var(--space-6) 0;
    }

    &__error-text {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--state-crimson-bright);
    }

    // ── Header row ───────────────────────────────────────────────────────────

    &__header {
      display: flex;
      align-items: flex-start;
      gap: var(--space-4);
      padding: var(--space-6);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-md);
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

    &__identity {
      flex: 1;
      min-width: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__name-input {
      font-family: var(--font-display);
    }

    &__concept-input {
      font-family: var(--font-body);
    }

    &__save-status {
      flex-shrink: 0;
      display: flex;
      align-items: center;
      min-width: var(--space-12);
      justify-content: flex-end;
    }

    &__save-label {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      letter-spacing: 0.04em;
      transition: opacity var(--motion-duration-fast) var(--motion-ease-standard);

      &--saving {
        color: var(--text-secondary);
      }

      &--saved {
        color: var(--state-success);
      }

      &--error {
        color: var(--state-crimson-bright);
      }
    }

    // ── Save error detail ─────────────────────────────────────────────────────

    &__save-error {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--state-crimson-bright);
      padding: 0 var(--space-2);
    }

    // ── Body placeholder ──────────────────────────────────────────────────────

    &__placeholder-text {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
      text-align: center;
      padding: var(--space-8) 0;
    }

    // ── Danger zone ───────────────────────────────────────────────────────────

    &__danger-zone {
      display: flex;
      justify-content: flex-end;
      padding-top: var(--space-4);
      border-top: 1px solid var(--brand-brass-shadow);
    }

    // ── Confirm dialog ────────────────────────────────────────────────────────

    &__dialog {
      position: fixed;
      inset: 0;
      margin: auto;
      padding: 0;
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
      background-color: var(--surface-night);
      color: var(--text-primary);
      max-width: $dialog-max-width;
      width: calc(100% - var(--space-8));

      &::backdrop {
        background-color: color-mix(in srgb, var(--surface-void) 80%, transparent);
      }

      &:not([open]) {
        display: none;
      }
    }

    &__dialog-inner {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
      padding: var(--space-6);
    }

    &__dialog-heading {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      line-height: var(--type-display-sm-line-height);
      color: var(--brand-brass-light);
    }

    &__dialog-body {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
    }

    &__dialog-actions {
      display: flex;
      justify-content: flex-end;
      gap: var(--space-3);
    }
  }

  @keyframes sheet-pulse {
    from {
      opacity: var(--opacity-disabled);
    }

    to {
      opacity: 0.18;
    }
  }
</style>
