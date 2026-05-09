<script setup lang="ts">
  import { AppSegControl, AppField, AppInput } from '@app/ui';
  import { computed } from 'vue';

  interface Props {
    origin: string | null;
    upbringing: string | null;
    age: number | null;
  }

  const props = defineProps<Props>();

  const emit = defineEmits<{
    'update:origin': [value: string | null];
    'update:upbringing': [value: string | null];
    'update:age': [value: number | null];
  }>();

  const { t } = useI18n({ useScope: 'local' });

  const upbringingOptions = computed(() => [
    { value: 'stationary', label: t('upbringing.stationary') },
    { value: 'zenithian', label: t('upbringing.zenithian') },
    { value: 'firstcome', label: t('upbringing.firstcome') },
    { value: 'nomad', label: t('upbringing.nomad') },
  ]);

  const ageStr = computed<string>(() => (props.age !== null ? String(props.age) : ''));

  function onOriginInput(val: string | number | null): void {
    const s = val !== null && val !== '' ? String(val) : null;
    emit('update:origin', s);
  }

  function onAgeInput(val: string | number | null): void {
    const raw = typeof val === 'number' ? val : Number.parseInt(val ?? '', 10);
    emit('update:age', Number.isFinite(raw) ? raw : null);
  }
</script>

<i18n lang="json">
{
  "en": {
    "originLabel": "Origin",
    "originPlaceholder": "Where do you come from?",
    "originHelp": "Free text — home station, planet, or region of the Third Horizon.",
    "upbringingLabel": "Upbringing",
    "upbringing": {
      "stationary": "Stationary",
      "zenithian": "Zenithian",
      "firstcome": "Firstcome",
      "nomad": "Nomad"
    },
    "ageLabel": "Age",
    "agePlaceholder": "e.g. 28",
    "ageHelp": "Optional. Any positive integer."
  },
  "ru": {
    "originLabel": "Происхождение",
    "originPlaceholder": "Откуда вы родом?",
    "originHelp": "Свободный текст — станция, планета или регион Третьего горизонта.",
    "upbringingLabel": "Воспитание",
    "upbringing": {
      "stationary": "Осёдлые",
      "zenithian": "Зенитяне",
      "firstcome": "Первопришедшие",
      "nomad": "Номады"
    },
    "ageLabel": "Возраст",
    "agePlaceholder": "напр. 28",
    "ageHelp": "Необязательно. Любое положительное число."
  },
  "uk": {
    "originLabel": "[uk-todo] Origin",
    "originPlaceholder": "[uk-todo] Where do you come from?",
    "originHelp": "[uk-todo] Home station or planet.",
    "upbringingLabel": "[uk-todo] Upbringing",
    "upbringing": {
      "stationary": "[uk-todo] Stationary",
      "zenithian": "[uk-todo] Zenithian",
      "firstcome": "[uk-todo] Firstcome",
      "nomad": "[uk-todo] Nomad"
    },
    "ageLabel": "[uk-todo] Age",
    "agePlaceholder": "[uk-todo] e.g. 28",
    "ageHelp": "[uk-todo] Optional."
  },
  "el": {
    "originLabel": "[el-todo] Origin",
    "originPlaceholder": "[el-todo] Where do you come from?",
    "originHelp": "[el-todo] Home station or planet.",
    "upbringingLabel": "[el-todo] Upbringing",
    "upbringing": {
      "stationary": "[el-todo] Stationary",
      "zenithian": "[el-todo] Zenithian",
      "firstcome": "[el-todo] Firstcome",
      "nomad": "[el-todo] Nomad"
    },
    "ageLabel": "[el-todo] Age",
    "agePlaceholder": "[el-todo] e.g. 28",
    "ageHelp": "[el-todo] Optional."
  }
}
</i18n>

<template>
  <div class="step-background">
    <AppField
      :label="t('originLabel')"
      :help-text="t('originHelp')"
    >
      <template #default="slotAttrs">
        <AppInput
          v-bind="slotAttrs"
          :model-value="origin ?? ''"
          :placeholder="t('originPlaceholder')"
          autocomplete="off"
          size="md"
          @update:model-value="onOriginInput($event)"
        />
      </template>
    </AppField>

    <AppField :label="t('upbringingLabel')">
      <AppSegControl
        :model-value="upbringing ?? null"
        :options="upbringingOptions"
        size="md"
        @update:model-value="emit('update:upbringing', String($event))"
      />
    </AppField>

    <AppField
      :label="t('ageLabel')"
      :help-text="t('ageHelp')"
    >
      <template #default="slotAttrs">
        <AppInput
          v-bind="slotAttrs"
          :model-value="ageStr"
          :placeholder="t('agePlaceholder')"
          type="number"
          inputmode="numeric"
          min="1"
          max="999"
          autocomplete="off"
          size="md"
          @update:model-value="onAgeInput($event)"
        />
      </template>
    </AppField>
  </div>
</template>

<style lang="scss" scoped>
  $step-form-max-width: 560px;

  .step-background {
    display: flex;
    flex-direction: column;
    gap: var(--space-6);
    max-width: $step-form-max-width;
    margin: 0 auto;
  }
</style>
