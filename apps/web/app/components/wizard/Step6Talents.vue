<script setup lang="ts">
  import { computed, ref, watch } from 'vue';
  import {
    PERSONAL_TALENTS,
    STIGMA_TALENTS,
    getCrewTalentsByConcept,
    getIconGiftByIconId,
    getRecommendedPersonalTalents,
    type CatalogLocale,
  } from '@app/specs';
  import type { IconId, Concept, CrewConcept } from '@app/api-client-ts';

  // TODO(wizard-step-7-relationships): Relationships step deferred to v1.1+.

  interface Props {
    personalTalentId: string | null;
    crewTalentId: string | null;
    stigmaTalentId: string | null;
    iconId: IconId | null;
    concept: Concept | null;
    crewConcept: CrewConcept | null;
    mutant: boolean;
  }

  const props = defineProps<Props>();

  const emit = defineEmits<{
    'update:personalTalentId': [value: string | null];
    'update:crewTalentId': [value: string | null];
    'update:stigmaTalentId': [value: string | null];
  }>();

  const { t, locale } = useI18n({ useScope: 'local' });

  // Catalog ships en/ru with [uk-todo]/[el-todo] placeholders. Resolve the
  // localised string for the active i18n locale; if Nuxt boots into an unknown
  // locale (shouldn't happen), fall back to en.
  function l10n(field: { en: string; ru: string; uk: string; el: string }): string {
    const code = locale.value as CatalogLocale;
    // The catalog ships every supported locale, but the runtime locale list
    // could drift in the future — fall back to en defensively.
    return code in field ? field[code] : field.en;
  }

  // Crew talents available for the chosen amplua (or empty when none picked yet).
  const crewOptions = computed(() =>
    props.crewConcept ? getCrewTalentsByConcept(props.crewConcept) : [],
  );

  // Icon gift is auto-derived from the chosen Icon; characters never pick it.
  const iconGift = computed(() => (props.iconId ? getIconGiftByIconId(props.iconId) : null));

  // Personal-pool filtering — defaults to ON when an amplua is chosen so
  // the player sees the rulebook's 1–3 picks first; toggling off restores
  // the full 26-talent pool. The rulebook is suggestive rather than
  // prescriptive here, so we never *force* the filter — the toggle is
  // always visible.
  const showOnlyRecommendedForConcept = ref(true);

  const recommendedPersonalIds = computed<readonly string[]>(() =>
    props.concept ? getRecommendedPersonalTalents(props.concept).map((t) => t.id) : [],
  );

  const personalOptions = computed(() => {
    if (!props.concept || !showOnlyRecommendedForConcept.value) return PERSONAL_TALENTS;
    const ids = new Set(recommendedPersonalIds.value);
    return PERSONAL_TALENTS.filter((t) => ids.has(t.id));
  });

  // If the player had a recommended-only filter on but their already-picked
  // talent isn't in the recommended pool (e.g. they switched amplua after
  // picking), drop the filter rather than silently hiding their selection.
  watch(
    () => [props.concept, props.personalTalentId] as const,
    ([concept, picked]) => {
      if (!concept || !picked || !showOnlyRecommendedForConcept.value) return;
      const ids = new Set(getRecommendedPersonalTalents(concept).map((t) => t.id));
      if (!ids.has(picked)) showOnlyRecommendedForConcept.value = false;
    },
  );

  function isPersonalPicked(id: string): boolean {
    return props.personalTalentId === id;
  }

  function togglePersonal(id: string): void {
    emit('update:personalTalentId', isPersonalPicked(id) ? null : id);
  }

  function isCrewPicked(id: string): boolean {
    return props.crewTalentId === id;
  }

  function toggleCrew(id: string): void {
    emit('update:crewTalentId', isCrewPicked(id) ? null : id);
  }

  function isStigmaPicked(id: string): boolean {
    return props.stigmaTalentId === id;
  }

  function toggleStigma(id: string): void {
    emit('update:stigmaTalentId', isStigmaPicked(id) ? null : id);
  }
</script>

<i18n lang="json">
{
  "en": {
    "intro": "Each character begins with three talents — one personal, one shared by your crew, and one icon gift derived from your patron Icon.",
    "personal": {
      "title": "Personal talent",
      "help": "Pick one talent that fits your character.",
      "counter": "{count} / 1 selected",
      "filterRecommendedLabel": "Show only talents recommended for this amplua",
      "filterPoolMeta": "{shown} of {total}",
      "noConceptHint": "Pick an amplua on Step 1 to see the rulebook's recommended talents."
    },
    "crew": {
      "title": "Crew talent",
      "help": "Shared by your team. Pick one of the three talents from the {label} amplua.",
      "noCrew": "Pick a crew amplua on Step 2 first."
    },
    "iconGift": {
      "title": "Icon gift",
      "help": "Auto-derived from the Icon you chose on Step 3. The gift is added to your sheet automatically when you forge the character.",
      "noIcon": "Pick an Icon on Step 3 first."
    },
    "stigma": {
      "title": "Stigma (Pasynok)",
      "help": "Mutants carry one stigma in addition to the three regular talents. Pick the one that fits your lineage.",
      "counter": "{count} / 1 selected"
    },
    "pickedBadge": "Picked"
  },
  "ru": {
    "intro": "Каждый персонаж получает три таланта — одно личное достоинство, одно от амплуа команды и один дар Иконы.",
    "personal": {
      "title": "Личное достоинство",
      "help": "Выберите одно достоинство для своего персонажа.",
      "counter": "Выбрано {count} / 1",
      "filterRecommendedLabel": "Только достоинства, рекомендованные для амплуа",
      "filterPoolMeta": "{shown} из {total}",
      "noConceptHint": "Выберите амплуа на шаге 1, чтобы увидеть рекомендации книги правил."
    },
    "crew": {
      "title": "Достоинство команды",
      "help": "Общее на всю команду. Выберите одно из трёх достоинств амплуа «{label}».",
      "noCrew": "Сначала выберите амплуа команды на шаге 2."
    },
    "iconGift": {
      "title": "Дар Иконы",
      "help": "Выводится из Иконы, выбранной на шаге 3. Дар добавляется к листу персонажа автоматически при создании.",
      "noIcon": "Сначала выберите Икону на шаге 3."
    },
    "stigma": {
      "title": "Стигма (Пасынок)",
      "help": "Пасынки получают одну стигму вдобавок к трём обычным талантам. Выберите подходящую вашей родословной.",
      "counter": "Выбрано {count} / 1"
    },
    "pickedBadge": "Выбрано"
  },
  "uk": {
    "intro": "[uk-todo] Three starting talents.",
    "personal": {
      "title": "[uk-todo] Personal talent",
      "help": "[uk-todo] Pick one talent.",
      "counter": "[uk-todo] {count} / 1 selected",
      "filterRecommendedLabel": "[uk-todo] Only recommended for amplua",
      "filterPoolMeta": "[uk-todo] {shown} / {total}",
      "noConceptHint": "[uk-todo] Pick an amplua on Step 1."
    },
    "crew": {
      "title": "[uk-todo] Crew talent",
      "help": "[uk-todo] Shared by team. Pick one of three talents from {label}.",
      "noCrew": "[uk-todo] Pick crew on Step 2."
    },
    "iconGift": {
      "title": "[uk-todo] Icon gift",
      "help": "[uk-todo] Derived from chosen Icon.",
      "noIcon": "[uk-todo] Pick Icon on Step 3."
    },
    "stigma": {
      "title": "[uk-todo] Stigma",
      "help": "[uk-todo] Mutants pick one stigma.",
      "counter": "[uk-todo] {count} / 1 selected"
    },
    "pickedBadge": "[uk-todo] Picked"
  },
  "el": {
    "intro": "[el-todo] Three starting talents.",
    "personal": {
      "title": "[el-todo] Personal talent",
      "help": "[el-todo] Pick one talent.",
      "counter": "[el-todo] {count} / 1 selected",
      "filterRecommendedLabel": "[el-todo] Only recommended for amplua",
      "filterPoolMeta": "[el-todo] {shown} / {total}",
      "noConceptHint": "[el-todo] Pick an amplua on Step 1."
    },
    "crew": {
      "title": "[el-todo] Crew talent",
      "help": "[el-todo] Shared by team. Pick one of three talents from {label}.",
      "noCrew": "[el-todo] Pick crew on Step 2."
    },
    "iconGift": {
      "title": "[el-todo] Icon gift",
      "help": "[el-todo] Derived from chosen Icon.",
      "noIcon": "[el-todo] Pick Icon on Step 3."
    },
    "stigma": {
      "title": "[el-todo] Stigma",
      "help": "[el-todo] Mutants pick one stigma.",
      "counter": "[el-todo] {count} / 1 selected"
    },
    "pickedBadge": "[el-todo] Picked"
  }
}
</i18n>

<template>
  <div class="step-talents">
    <p class="step-talents__intro">
      {{ t('intro') }}
    </p>

    <section class="step-talents__section">
      <header class="step-talents__section-head">
        <h3 class="step-talents__section-title">
          {{ t('personal.title') }}
        </h3>
        <span class="step-talents__counter">
          {{ t('personal.counter', { count: personalTalentId ? 1 : 0 }) }}
        </span>
      </header>
      <p class="step-talents__section-help">
        {{ t('personal.help') }}
      </p>

      <div v-if="concept" class="step-talents__filter">
        <label class="step-talents__filter-toggle">
          <input
            v-model="showOnlyRecommendedForConcept"
            type="checkbox"
            class="step-talents__filter-checkbox"
          />
          <span class="step-talents__filter-text">
            {{ t('personal.filterRecommendedLabel') }}
          </span>
        </label>
        <span class="step-talents__filter-meta">
          {{
            t('personal.filterPoolMeta', {
              shown: personalOptions.length,
              total: PERSONAL_TALENTS.length,
            })
          }}
        </span>
      </div>
      <p v-else class="step-talents__section-help step-talents__section-help--hint">
        {{ t('personal.noConceptHint') }}
      </p>

      <div class="step-talents__grid">
        <div
          v-for="talent in personalOptions"
          :key="talent.id"
          class="step-talents__card"
          :class="{
            'step-talents__card--picked': isPersonalPicked(talent.id),
          }"
          role="checkbox"
          :aria-checked="isPersonalPicked(talent.id)"
          tabindex="0"
          @click="togglePersonal(talent.id)"
          @keydown.enter.space.prevent="togglePersonal(talent.id)"
        >
          <div class="step-talents__card-head">
            <span class="step-talents__talent-name">{{ l10n(talent.name) }}</span>
            <span v-if="isPersonalPicked(talent.id)" class="step-talents__badge">
              {{ t('pickedBadge') }}
            </span>
          </div>
          <p class="step-talents__desc">
            {{ l10n(talent.description) }}
          </p>
        </div>
      </div>
    </section>

    <section class="step-talents__section">
      <header class="step-talents__section-head">
        <h3 class="step-talents__section-title">
          {{ t('crew.title') }}
        </h3>
      </header>
      <template v-if="crewConcept && crewOptions.length > 0">
        <p class="step-talents__section-help">
          {{ t('crew.help', { label: crewConcept }) }}
        </p>
        <div class="step-talents__grid">
          <div
            v-for="talent in crewOptions"
            :key="talent.id"
            class="step-talents__card"
            :class="{
              'step-talents__card--picked': isCrewPicked(talent.id),
            }"
            role="checkbox"
            :aria-checked="isCrewPicked(talent.id)"
            tabindex="0"
            @click="toggleCrew(talent.id)"
            @keydown.enter.space.prevent="toggleCrew(talent.id)"
          >
            <div class="step-talents__card-head">
              <span class="step-talents__talent-name">{{ l10n(talent.name) }}</span>
              <span v-if="isCrewPicked(talent.id)" class="step-talents__badge">
                {{ t('pickedBadge') }}
              </span>
            </div>
            <p class="step-talents__desc">
              {{ l10n(talent.description) }}
            </p>
          </div>
        </div>
      </template>
      <div v-else class="step-talents__slot step-talents__slot--empty">
        {{ t('crew.noCrew') }}
      </div>
    </section>

    <section class="step-talents__section">
      <header class="step-talents__section-head">
        <h3 class="step-talents__section-title">
          {{ t('iconGift.title') }}
        </h3>
      </header>
      <div v-if="iconGift" class="step-talents__slot step-talents__slot--filled">
        <span class="step-talents__slot-label">{{ l10n(iconGift.name) }}</span>
        <span class="step-talents__slot-help">{{ l10n(iconGift.description) }}</span>
        <span class="step-talents__slot-meta">{{ t('iconGift.help') }}</span>
      </div>
      <div v-else class="step-talents__slot step-talents__slot--empty">
        {{ t('iconGift.noIcon') }}
      </div>
    </section>

    <section v-if="mutant" class="step-talents__section">
      <header class="step-talents__section-head">
        <h3 class="step-talents__section-title">
          {{ t('stigma.title') }}
        </h3>
        <span class="step-talents__counter">
          {{ t('stigma.counter', { count: stigmaTalentId ? 1 : 0 }) }}
        </span>
      </header>
      <p class="step-talents__section-help">
        {{ t('stigma.help') }}
      </p>
      <div class="step-talents__grid">
        <div
          v-for="talent in STIGMA_TALENTS"
          :key="talent.id"
          class="step-talents__card"
          :class="{
            'step-talents__card--picked': isStigmaPicked(talent.id),
          }"
          role="checkbox"
          :aria-checked="isStigmaPicked(talent.id)"
          tabindex="0"
          @click="toggleStigma(talent.id)"
          @keydown.enter.space.prevent="toggleStigma(talent.id)"
        >
          <div class="step-talents__card-head">
            <span class="step-talents__talent-name">{{ l10n(talent.name) }}</span>
            <span v-if="isStigmaPicked(talent.id)" class="step-talents__badge">
              {{ t('pickedBadge') }}
            </span>
          </div>
          <p class="step-talents__desc">
            {{ l10n(talent.description) }}
          </p>
        </div>
      </div>
    </section>
  </div>
</template>

<style lang="scss" scoped>
  $talents-max-width: 1000px;

  .step-talents {
    max-width: $talents-max-width;
    margin: 0 auto;
    display: flex;
    flex-direction: column;
    gap: var(--space-6);

    &__intro {
      margin: 0;
      text-align: center;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__section {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__section-head {
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      gap: var(--space-3);
    }

    &__section-title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }

    &__section-help {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);

      &--hint {
        font-style: italic;
        color: var(--text-tertiary);
      }
    }

    &__counter {
      font-family: var(--font-mono);
      font-size: var(--type-body-sm-font-size);
      color: var(--brand-brass-light);
    }

    &__filter {
      display: flex;
      flex-wrap: wrap;
      gap: var(--space-3);
      align-items: center;
      justify-content: space-between;
      padding: var(--space-2) var(--space-3);
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-sm);
      background-color: color-mix(in srgb, var(--brand-brass-shadow) 25%, transparent);
    }

    &__filter-toggle {
      display: inline-flex;
      align-items: center;
      gap: var(--space-2);
      cursor: pointer;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
    }

    &__filter-checkbox {
      width: 16px;
      height: 16px;
      accent-color: var(--brand-brass);
      cursor: pointer;
    }

    &__filter-text {
      user-select: none;
    }

    &__filter-meta {
      font-family: var(--font-mono);
      font-size: var(--type-body-xs-font-size);
      color: var(--text-tertiary);
    }

    &__grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: var(--space-3);

      @media (max-width: 640px) {
        grid-template-columns: 1fr;
      }
    }

    &__card {
      padding: var(--space-4);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      cursor: pointer;
      transition:
        border-color var(--motion-duration-fast) var(--motion-ease-standard),
        background-color var(--motion-duration-fast) var(--motion-ease-standard);
      outline: none;

      &:hover:not(.step-talents__card--picked) {
        border-color: var(--brand-brass-deep);
        background-color: var(--surface-dawn);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      &--picked {
        border-color: var(--brand-brass);
        background-color: var(--surface-dawn);
      }
    }

    &__card-head {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: var(--space-2);
      margin-bottom: var(--space-2);
    }

    &__talent-name {
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }

    &__badge {
      display: inline-block;
      padding: var(--space-1) var(--space-2);
      background-color: color-mix(in srgb, var(--state-mystic-teal) 15%, transparent);
      border: 1px solid var(--state-mystic-teal);
      border-radius: var(--radius-sm);
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--state-mystic-teal);
      text-transform: uppercase;
      letter-spacing: 0.1em;
      flex-shrink: 0;
    }

    &__desc {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      line-height: 1.5;
    }

    &__slot {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
      padding: var(--space-3) var(--space-4);
      border-radius: var(--radius-md);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);

      &--filled {
        background-color: var(--surface-dawn);
        border: 1px solid var(--brand-brass);
      }

      &--empty {
        background-color: var(--surface-night);
        border: 1px dashed var(--brand-brass-shadow);
        color: var(--text-secondary);
        font-style: italic;
      }
    }

    &__slot-label {
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }

    &__slot-help {
      color: var(--text-primary);
      font-style: normal;
    }

    &__slot-meta {
      color: var(--text-secondary);
      font-style: italic;
      font-size: var(--type-body-xs-font-size);
    }
  }
</style>
