<script setup lang="ts">
  import { AppField, AppInput, AppTextarea } from '@app/ui';
  import { computed } from 'vue';

  interface Props {
    name: string;
    concept: string | null;
  }

  const props = defineProps<Props>();

  const emit = defineEmits<{
    'update:name': [value: string];
    'update:concept': [value: string | null];
  }>();

  const { t } = useI18n({ useScope: 'local' });

  const nameError = computed<string>(() => {
    if (!props.name.trim()) return t('nameRequired');
    if (props.name.trim().length > 80) return t('nameTooLong');
    return '';
  });

  const conceptError = computed<string>(() => {
    const val = props.concept ?? '';
    if (val.length > 120) return t('conceptTooLong');
    return '';
  });
</script>

<i18n lang="json">
{
  "en": {
    "nameLabel": "Character name",
    "namePlaceholder": "Enter a name for your character",
    "nameHelp": "1–80 characters. You can change this later.",
    "nameRequired": "Name is required.",
    "nameTooLong": "Name must be 80 characters or fewer.",
    "conceptLabel": "Concept",
    "conceptPlaceholder": "e.g. Veteran fringe pilot · navigator",
    "conceptHelp": "1–120 characters. The role you play at the table.",
    "conceptTooLong": "Concept must be 120 characters or fewer."
  },
  "ru": {
    "nameLabel": "Имя персонажа",
    "namePlaceholder": "Введите имя персонажа",
    "nameHelp": "1–80 символов. Можно изменить позже.",
    "nameRequired": "Имя обязательно.",
    "nameTooLong": "Имя не должно превышать 80 символов.",
    "conceptLabel": "Концепт",
    "conceptPlaceholder": "напр. Опытный пилот окраин · навигатор",
    "conceptHelp": "1–120 символов. Роль за столом.",
    "conceptTooLong": "Концепт не должен превышать 120 символов."
  },
  "uk": {
    "nameLabel": "[uk-todo] Character name",
    "namePlaceholder": "[uk-todo] Enter a name",
    "nameHelp": "[uk-todo] 1–80 characters",
    "nameRequired": "[uk-todo] Name is required",
    "nameTooLong": "[uk-todo] Name too long",
    "conceptLabel": "[uk-todo] Concept",
    "conceptPlaceholder": "[uk-todo] e.g. Veteran pilot",
    "conceptHelp": "[uk-todo] 1–120 characters",
    "conceptTooLong": "[uk-todo] Concept too long"
  },
  "el": {
    "nameLabel": "[el-todo] Character name",
    "namePlaceholder": "[el-todo] Enter a name",
    "nameHelp": "[el-todo] 1–80 characters",
    "nameRequired": "[el-todo] Name is required",
    "nameTooLong": "[el-todo] Name too long",
    "conceptLabel": "[el-todo] Concept",
    "conceptPlaceholder": "[el-todo] e.g. Veteran pilot",
    "conceptHelp": "[el-todo] 1–120 characters",
    "conceptTooLong": "[el-todo] Concept too long"
  }
}
</i18n>

<template>
  <div class="step-concept">
    <AppField
      :label="t('nameLabel')"
      :help-text="nameError ? undefined : t('nameHelp')"
      :error="nameError || undefined"
      required
    >
      <template #default="slotAttrs">
        <AppInput
          v-bind="slotAttrs"
          :model-value="name"
          :placeholder="t('namePlaceholder')"
          :invalid="!!nameError"
          autocomplete="off"
          size="md"
          @update:model-value="emit('update:name', String($event ?? ''))"
        />
      </template>
    </AppField>

    <AppField
      :label="t('conceptLabel')"
      :help-text="conceptError ? undefined : t('conceptHelp')"
      :error="conceptError || undefined"
    >
      <template #default="slotAttrs">
        <AppTextarea
          v-bind="slotAttrs"
          :model-value="concept ?? ''"
          :placeholder="t('conceptPlaceholder')"
          :invalid="!!conceptError"
          :rows="3"
          @update:model-value="emit('update:concept', $event || null)"
        />
      </template>
    </AppField>
  </div>
</template>

<style lang="scss" scoped>
  $step-form-max-width: 560px;

  .step-concept {
    display: flex;
    flex-direction: column;
    gap: var(--space-6);
    max-width: $step-form-max-width;
    margin: 0 auto;
  }
</style>
