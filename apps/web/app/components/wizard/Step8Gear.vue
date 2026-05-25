<script setup lang="ts">
  import { computed } from 'vue';
  import { findStarterKit, pickStarterKitItemName } from '@app/specs';
  import type { StarterKitChoice, StarterKitItem } from '@app/specs';
  import type { Concept, Role } from '@app/api-client-ts';

  interface Props {
    concept: Concept | null;
    role: Role | null;
    picks: Record<string, string | null>; // rowId → optionId | null
  }

  const props = defineProps<Props>();

  const emit = defineEmits<{
    'update:picks': [value: Record<string, string | null>];
  }>();

  const { t, locale } = useI18n({ useScope: 'local' });

  // Resolve the catalogue entry for the current concept+role pair.
  const kit = computed(() => {
    if (!props.concept || !props.role) return null;
    return findStarterKit(props.concept, props.role);
  });

  // Count how many rows have a pick.
  const pickedCount = computed<number>(() => {
    if (!kit.value) return 0;
    return kit.value.choices.filter((c) => props.picks[c.id] != null).length;
  });

  const totalRows = computed<number>(() => kit.value?.choices.length ?? 0);

  function itemName(item: StarterKitItem): string {
    // locale.value is 'en' | 'ru' — matches CatalogLocale.
    return pickStarterKitItemName(item, locale.value as 'en' | 'ru');
  }

  function kindLabel(kind: StarterKitItem['template']['kind']): string {
    return t(`kind.${kind.toLowerCase()}`);
  }

  function isPicked(choice: StarterKitChoice, option: StarterKitItem): boolean {
    return props.picks[choice.id] === option.id;
  }

  function togglePick(choice: StarterKitChoice, option: StarterKitItem): void {
    // Re-clicking the same option clears the row; clicking a new option flips.
    const newValue: string | null = isPicked(choice, option) ? null : option.id;
    emit('update:picks', { ...props.picks, [choice.id]: newValue });
  }

  function onKeydown(event: KeyboardEvent, choice: StarterKitChoice, option: StarterKitItem): void {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      togglePick(choice, option);
    }
  }
</script>

<i18n lang="json">
{
  "en": {
    "title": "Outfit the cycle ahead",
    "blurb": "Choose one item from each row. You can refine your kit later.",
    "placeholderNoConcept": "Pick a concept and role first; your starter kit follows from those.",
    "progress": "Picked {picked} of {total}",
    "kind": {
      "weapon": "Weapon",
      "armor": "Armor",
      "gear": "Gear",
      "cybernetic": "Implant",
      "other": "Other"
    }
  },
  "ru": {
    "title": "Снаряжение для нового цикла",
    "blurb": "Выбери по одному предмету в каждом ряду. Уточнить набор можно будет позже.",
    "placeholderNoConcept": "Сначала выбери амплуа и роль — стартовый набор зависит от них.",
    "progress": "Выбрано {picked} из {total}",
    "kind": {
      "weapon": "Оружие",
      "armor": "Броня",
      "gear": "Снаряжение",
      "cybernetic": "Имплант",
      "other": "Прочее"
    }
  }
}
</i18n>

<template>
  <section class="wizard-gear">
    <h2 class="wizard-gear__heading">
      {{ t('title') }}
    </h2>
    <p class="wizard-gear__blurb">
      {{ t('blurb') }}
    </p>

    <!-- Empty state when no concept+role chosen yet -->
    <p v-if="!kit" class="wizard-gear__placeholder">
      {{ t('placeholderNoConcept') }}
    </p>

    <template v-else>
      <!-- Choice rows -->
      <div v-for="choice in kit.choices" :key="choice.id" class="wizard-gear__row">
        <div class="wizard-gear__row-options">
          <button
            v-for="option in choice.options"
            :key="option.id"
            type="button"
            class="wizard-gear__card"
            :class="{ 'wizard-gear__card--is-picked': isPicked(choice, option) }"
            :aria-pressed="isPicked(choice, option)"
            @click="togglePick(choice, option)"
            @keydown="onKeydown($event, choice, option)"
          >
            <span class="wizard-gear__card-name">{{ itemName(option) }}</span>
            <span class="wizard-gear__card-kind">{{ kindLabel(option.template.kind) }}</span>
            <span v-if="isPicked(choice, option)" class="wizard-gear__card-check" aria-hidden="true"
              >✓</span
            >
          </button>
        </div>
      </div>

      <!-- Progress counter — computed from kit.choices.length for forward compat -->
      <p class="wizard-gear__progress">
        {{ t('progress', { picked: pickedCount, total: totalRows }) }}
      </p>
    </template>
  </section>
</template>

<style lang="scss" scoped>
  $gear-max-width: 760px;
  $card-min-height: 72px;

  .wizard-gear {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    max-width: $gear-max-width;
    margin: 0 auto;

    &__heading {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      font-weight: var(--type-display-sm-font-weight);
      color: var(--brand-brass-light);
      text-align: center;
    }

    &__blurb {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
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

    &__row {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__row-options {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: var(--space-3);

      @media (max-width: 479px) {
        grid-template-columns: 1fr;
      }
    }

    &__card {
      position: relative;
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
      min-height: $card-min-height;
      padding: var(--space-3) var(--space-4);
      font-family: var(--font-body);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      cursor: pointer;
      transition:
        border-color var(--motion-duration-fast) var(--motion-ease-standard),
        background-color var(--motion-duration-fast) var(--motion-ease-standard);
      text-align: left;

      &:hover {
        border-color: var(--brand-brass);
        background-color: var(--surface-dawn);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      &--is-picked {
        border-color: var(--brand-brass-deep);
        background-color: var(--surface-dawn);
      }
    }

    &__card-name {
      font-size: var(--type-body-md-font-size);
      font-weight: 500;
      color: var(--text-primary);
      line-height: 1.3;
    }

    &__card-kind {
      font-size: var(--type-body-xs-font-size);
      font-weight: 600;
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 0.06em;
    }

    &__card-check {
      position: absolute;
      top: var(--space-2);
      right: var(--space-3);
      font-size: var(--type-body-sm-font-size);
      color: var(--brand-brass);
    }

    &__progress {
      margin: 0;
      padding-top: var(--space-2);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      text-align: center;
      border-top: 1px solid var(--brand-brass-shadow);
    }
  }
</style>
