<script setup lang="ts">
  import { useId } from 'vue';
  import RoleCardGrid from '~/components/RoleCardGrid.vue';
  import type { Concept, Role } from '@app/api-client-ts';

  interface Props {
    concept: Concept | null;
    role: Role | null;
  }

  const props = defineProps<Props>();

  const emit = defineEmits<{
    'update:role': [value: Role | null];
  }>();

  const { t } = useI18n({ useScope: 'local' });

  const id = useId();
</script>

<i18n lang="json">
{
  "en": {
    "headline": "Choose your role",
    "placeholderNoConcept": "Pick a concept first to see your role options."
  },
  "ru": {
    "headline": "Выберите роль",
    "placeholderNoConcept": "Сначала выберите амплуа, чтобы увидеть доступные роли."
  }
}
</i18n>

<template>
  <section class="step-role" :aria-labelledby="`role-label-${id}`">
    <h2 :id="`role-label-${id}`" class="step-role__heading">
      {{ t('headline') }}
    </h2>

    <p v-if="!concept" class="step-role__placeholder">
      {{ t('placeholderNoConcept') }}
    </p>

    <RoleCardGrid
      v-else
      :concept="concept"
      :role="props.role"
      @update:role="emit('update:role', $event)"
    />
  </section>
</template>

<style lang="scss" scoped>
  $role-max-width: 800px;

  .step-role {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    max-width: $role-max-width;
    margin: 0 auto;

    &__heading {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      font-weight: var(--type-display-sm-font-weight);
      color: var(--brand-brass-light);
      text-align: center;
    }

    &__placeholder {
      margin: 0;
      padding: var(--space-3) var(--space-4);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      font-style: italic;
      color: var(--text-secondary);
      background-color: var(--surface-night);
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      text-align: center;
    }
  }
</style>
