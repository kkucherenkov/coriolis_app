<script setup lang="ts">
  import { AppCard, AppButton, AppField, AppInput } from '@app/ui';
  import { ref, computed } from 'vue';
  import { useCharactersApi } from '~/composables/useCharactersApi';
  import type { Problem } from '~/composables/useCharactersApi';

  const { t } = useI18n({ useScope: 'local' });
  const api = useCharactersApi();

  const name = ref('');
  const loading = ref(false);
  const errorMsg = ref('');

  const nameValid = computed(() => name.value.trim().length >= 1 && name.value.trim().length <= 80);
  const nameError = computed<string>(() => {
    if (errorMsg.value) return errorMsg.value;
    if (name.value.trim().length > 80) return t('errorNameTooLong');
    return '';
  });

  async function onSubmit(event: Event): Promise<void> {
    event.preventDefault();
    if (!nameValid.value) {
      errorMsg.value = t('errorNameRequired');
      return;
    }
    errorMsg.value = '';
    loading.value = true;
    try {
      const character = await api.create({ name: name.value.trim() });
      await navigateTo(`/app/characters/${character.id}`);
    } catch (err) {
      const problem = err as Problem;
      errorMsg.value = problem?.detail ?? t('errorGeneric');
    } finally {
      loading.value = false;
    }
  }
</script>

<i18n lang="json">
{
  "en": {
    "pageTitle": "New character",
    "nameLabel": "Character name",
    "namePlaceholder": "Enter a name for your character",
    "nameHelp": "1–80 characters. You can change this later.",
    "submitButton": "Create character",
    "cancelButton": "Cancel",
    "errorNameRequired": "Name is required.",
    "errorNameTooLong": "Name must be 80 characters or fewer.",
    "errorGeneric": "Something went wrong. Please try again."
  },
  "ru": {
    "pageTitle": "Новый персонаж",
    "nameLabel": "Имя персонажа",
    "namePlaceholder": "Введите имя персонажа",
    "nameHelp": "1–80 символов. Можно изменить позже.",
    "submitButton": "Создать персонажа",
    "cancelButton": "Отмена",
    "errorNameRequired": "Имя обязательно.",
    "errorNameTooLong": "Имя не должно превышать 80 символов.",
    "errorGeneric": "Что-то пошло не так. Попробуйте ещё раз."
  },
  "uk": {
    "pageTitle": "[uk-todo] New character",
    "nameLabel": "[uk-todo] Character name",
    "namePlaceholder": "[uk-todo] Enter a name",
    "nameHelp": "[uk-todo] 1–80 characters",
    "submitButton": "[uk-todo] Create character",
    "cancelButton": "[uk-todo] Cancel",
    "errorNameRequired": "[uk-todo] Name is required",
    "errorNameTooLong": "[uk-todo] Name too long",
    "errorGeneric": "[uk-todo] Something went wrong"
  },
  "el": {
    "pageTitle": "[el-todo] New character",
    "nameLabel": "[el-todo] Character name",
    "namePlaceholder": "[el-todo] Enter a name",
    "nameHelp": "[el-todo] 1–80 characters",
    "submitButton": "[el-todo] Create character",
    "cancelButton": "[el-todo] Cancel",
    "errorNameRequired": "[el-todo] Name is required",
    "errorNameTooLong": "[el-todo] Name too long",
    "errorGeneric": "[el-todo] Something went wrong"
  }
}
</i18n>

<template>
  <section class="page-new-character">
    <AppCard class="page-new-character__card">
      <template #header>
        <h1 class="page-new-character__title">{{ t('pageTitle') }}</h1>
      </template>

      <form
        class="page-new-character__form"
        novalidate
        @submit="onSubmit"
      >
        <AppField
          :label="t('nameLabel')"
          :help-text="nameError ? undefined : t('nameHelp')"
          :error="nameError || undefined"
          required
        >
          <template #default="slotAttrs">
            <AppInput
              v-bind="slotAttrs"
              v-model="name"
              :placeholder="t('namePlaceholder')"
              :invalid="!!nameError"
              :disabled="loading"
              autocomplete="off"
              size="md"
            />
          </template>
        </AppField>

        <div class="page-new-character__actions">
          <AppButton
            variant="ghost"
            size="md"
            type="button"
            :disabled="loading"
            @click="navigateTo('/app/characters')"
          >
            {{ t('cancelButton') }}
          </AppButton>
          <AppButton
            variant="primary"
            size="md"
            type="submit"
            :loading="loading"
            :disabled="!nameValid || loading"
          >
            {{ t('submitButton') }}
          </AppButton>
        </div>
      </form>
    </AppCard>
  </section>
</template>

<style lang="scss" scoped>
  $form-max-width: 480px;

  .page-new-character {
    display: flex;
    justify-content: center;
    padding: var(--space-9) var(--space-6);

    &__card {
      width: 100%;
      max-width: $form-max-width;
    }

    &__title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      line-height: var(--type-display-sm-line-height);
      font-weight: var(--type-display-sm-font-weight);
      letter-spacing: var(--type-display-sm-letter-spacing);
      color: var(--brand-brass-light);
    }

    &__form {
      display: flex;
      flex-direction: column;
      gap: var(--space-6);
    }

    &__actions {
      display: flex;
      justify-content: flex-end;
      gap: var(--space-3);
    }
  }
</style>
