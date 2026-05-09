<script setup lang="ts">
  import { AppField, AppInput } from '@app/ui';
  import { computed } from 'vue';

  // ST3001 ch.2 — 11 character archetypes (амплуа). Mappings to key
  // attribute / key skills / reputation modifier are baked into the
  // server's RulesEngine; the UI mirrors the key-attr+skills hint here.
  type Concept =
    | 'artist'
    | 'networker'
    | 'fugitive'
    | 'negotiator'
    | 'operative'
    | 'pilot'
    | 'pioneer'
    | 'preacher'
    | 'scientist'
    | 'sailor'
    | 'soldier';

  type AttributeKey = 'strength' | 'agility' | 'wits' | 'empathy';

  interface ConceptInfo {
    keyAttribute: AttributeKey;
    keySkills: string[];
    reputationModifier: number;
  }

  const props = defineProps<Props>();

  const emit = defineEmits<{
    'update:name': [value: string];
    'update:concept': [value: Concept | null];
  }>();

  const CONCEPT_INFO: Record<Concept, ConceptInfo> = {
    artist: {
      keyAttribute: 'empathy',
      keySkills: ['manipulation', 'culture', 'dexterity', 'observation', 'infiltration'],
      reputationModifier: 1,
    },
    networker: {
      keyAttribute: 'wits',
      keySkills: ['dataDjinn', 'culture', 'manipulation', 'observation', 'infiltration'],
      reputationModifier: 0,
    },
    fugitive: {
      keyAttribute: 'empathy',
      keySkills: ['meleeCombat', 'infiltration', 'culture', 'mysticPowers', 'manipulation'],
      reputationModifier: -2,
    },
    negotiator: {
      keyAttribute: 'empathy',
      keySkills: ['manipulation', 'culture', 'observation', 'command', 'infiltration'],
      reputationModifier: 1,
    },
    operative: {
      keyAttribute: 'agility',
      keySkills: ['meleeCombat', 'rangedCombat', 'infiltration', 'observation', 'manipulation'],
      reputationModifier: 0,
    },
    pilot: {
      keyAttribute: 'agility',
      keySkills: ['pilot', 'rangedCombat', 'technology', 'observation', 'dataDjinn'],
      reputationModifier: 0,
    },
    pioneer: {
      keyAttribute: 'wits',
      keySkills: ['survival', 'observation', 'technology', 'infiltration', 'science'],
      reputationModifier: 0,
    },
    preacher: {
      keyAttribute: 'empathy',
      keySkills: ['culture', 'mysticPowers', 'manipulation', 'command', 'observation'],
      reputationModifier: 1,
    },
    scientist: {
      keyAttribute: 'wits',
      keySkills: ['science', 'culture', 'technology', 'medicurgy', 'dataDjinn'],
      reputationModifier: 1,
    },
    sailor: {
      keyAttribute: 'strength',
      keySkills: ['meleeCombat', 'force', 'technology', 'observation', 'pilot'],
      reputationModifier: -1,
    },
    soldier: {
      keyAttribute: 'agility',
      keySkills: ['rangedCombat', 'meleeCombat', 'force', 'command', 'observation'],
      reputationModifier: -1,
    },
  };

  const CONCEPT_ORDER: Concept[] = [
    'artist',
    'networker',
    'fugitive',
    'negotiator',
    'operative',
    'pilot',
    'pioneer',
    'preacher',
    'scientist',
    'sailor',
    'soldier',
  ];

  interface Props {
    name: string;
    concept: Concept | null;
  }

  const { t } = useI18n({ useScope: 'local' });

  const nameError = computed<string>(() => {
    if (!props.name.trim()) return t('nameRequired');
    if (props.name.trim().length > 80) return t('nameTooLong');
    return '';
  });

  const selectedInfo = computed<ConceptInfo | null>(() =>
    props.concept ? CONCEPT_INFO[props.concept] : null,
  );

  function pickConcept(c: Concept): void {
    emit('update:concept', props.concept === c ? null : c);
  }

  function repBadge(modifier: number): string {
    if (modifier > 0) return `+${String(modifier)}`;
    if (modifier < 0) return String(modifier);
    return '±0';
  }
</script>

<i18n lang="json">
{
  "en": {
    "nameLabel": "Character name",
    "namePlaceholder": "Enter a name for your character",
    "nameHelp": "1–80 characters. You can change this later.",
    "nameRequired": "Name is required.",
    "nameTooLong": "Name must be 80 characters or fewer.",
    "conceptLabel": "Concept (Amplua)",
    "conceptHelp": "Pick the archetype that defines your character. Determines your key attribute (cap 5), your key skills (cap 3), and a reputation modifier.",
    "selectPrompt": "Select a concept to see your key attribute, key skills, and reputation modifier.",
    "concept": {
      "artist": "Artist",
      "networker": "Networker",
      "fugitive": "Fugitive",
      "negotiator": "Negotiator",
      "operative": "Operative",
      "pilot": "Pilot",
      "pioneer": "Pioneer",
      "preacher": "Preacher",
      "scientist": "Scientist",
      "sailor": "Sailor",
      "soldier": "Soldier"
    },
    "attribute": {
      "strength": "Strength",
      "agility": "Agility",
      "wits": "Wits",
      "empathy": "Empathy"
    },
    "skill": {
      "dexterity": "Dexterity",
      "force": "Force",
      "infiltration": "Infiltration",
      "manipulation": "Manipulation",
      "meleeCombat": "Melee Combat",
      "observation": "Observation",
      "rangedCombat": "Ranged Combat",
      "survival": "Survival",
      "command": "Command",
      "culture": "Culture",
      "dataDjinn": "Data Djinn",
      "medicurgy": "Medicurgy",
      "mysticPowers": "Mystic Powers",
      "pilot": "Pilot",
      "science": "Science",
      "technology": "Technology"
    },
    "hint": {
      "keyAttribute": "Key attribute",
      "keySkills": "Key skills",
      "reputation": "Reputation modifier"
    }
  },
  "ru": {
    "nameLabel": "Имя персонажа",
    "namePlaceholder": "Введите имя персонажа",
    "nameHelp": "1–80 символов. Можно изменить позже.",
    "nameRequired": "Имя обязательно.",
    "nameTooLong": "Имя не должно превышать 80 символов.",
    "conceptLabel": "Амплуа",
    "conceptHelp": "Выберите амплуа персонажа. Оно определяет ключевую характеристику (макс. 5), ключевые навыки (макс. 3) и модификатор репутации.",
    "selectPrompt": "Выберите амплуа, чтобы увидеть ключевую характеристику, ключевые навыки и модификатор репутации.",
    "concept": {
      "artist": "Артист",
      "networker": "Сетевой паук",
      "fugitive": "Беглец",
      "negotiator": "Негоциант",
      "operative": "Оперативник",
      "pilot": "Пилот",
      "pioneer": "Первопроходец",
      "preacher": "Проповедник",
      "scientist": "Учёный",
      "sailor": "Матрос",
      "soldier": "Солдат"
    },
    "attribute": {
      "strength": "Сила",
      "agility": "Ловкость",
      "wits": "Разум",
      "empathy": "Эмпатия"
    },
    "skill": {
      "dexterity": "Проворство",
      "force": "Сила",
      "infiltration": "Скрытность",
      "manipulation": "Влияние",
      "meleeCombat": "Ближний бой",
      "observation": "Наблюдательность",
      "rangedCombat": "Стрельба",
      "survival": "Выживание",
      "command": "Лидерство",
      "culture": "Мудрость",
      "dataDjinn": "Инфомантия",
      "medicurgy": "Медикургия",
      "mysticPowers": "Психомистицизм",
      "pilot": "Пилотирование",
      "science": "Наука",
      "technology": "Технология"
    },
    "hint": {
      "keyAttribute": "Ключевая характеристика",
      "keySkills": "Ключевые навыки",
      "reputation": "Модификатор репутации"
    }
  },
  "uk": {
    "nameLabel": "[uk-todo] Character name",
    "namePlaceholder": "[uk-todo] Enter a name",
    "nameHelp": "[uk-todo] 1–80 characters",
    "nameRequired": "[uk-todo] Name is required",
    "nameTooLong": "[uk-todo] Name too long",
    "conceptLabel": "[uk-todo] Concept",
    "conceptHelp": "[uk-todo] Pick an archetype",
    "selectPrompt": "[uk-todo] Select a concept",
    "concept": {
      "artist": "[uk-todo] Artist",
      "networker": "[uk-todo] Networker",
      "fugitive": "[uk-todo] Fugitive",
      "negotiator": "[uk-todo] Negotiator",
      "operative": "[uk-todo] Operative",
      "pilot": "[uk-todo] Pilot",
      "pioneer": "[uk-todo] Pioneer",
      "preacher": "[uk-todo] Preacher",
      "scientist": "[uk-todo] Scientist",
      "sailor": "[uk-todo] Sailor",
      "soldier": "[uk-todo] Soldier"
    },
    "attribute": {
      "strength": "[uk-todo] Strength",
      "agility": "[uk-todo] Agility",
      "wits": "[uk-todo] Wits",
      "empathy": "[uk-todo] Empathy"
    },
    "skill": {
      "dexterity": "[uk-todo] Dexterity",
      "force": "[uk-todo] Force",
      "infiltration": "[uk-todo] Infiltration",
      "manipulation": "[uk-todo] Manipulation",
      "meleeCombat": "[uk-todo] Melee Combat",
      "observation": "[uk-todo] Observation",
      "rangedCombat": "[uk-todo] Ranged Combat",
      "survival": "[uk-todo] Survival",
      "command": "[uk-todo] Command",
      "culture": "[uk-todo] Culture",
      "dataDjinn": "[uk-todo] Data Djinn",
      "medicurgy": "[uk-todo] Medicurgy",
      "mysticPowers": "[uk-todo] Mystic Powers",
      "pilot": "[uk-todo] Pilot",
      "science": "[uk-todo] Science",
      "technology": "[uk-todo] Technology"
    },
    "hint": {
      "keyAttribute": "[uk-todo] Key attribute",
      "keySkills": "[uk-todo] Key skills",
      "reputation": "[uk-todo] Reputation modifier"
    }
  },
  "el": {
    "nameLabel": "[el-todo] Character name",
    "namePlaceholder": "[el-todo] Enter a name",
    "nameHelp": "[el-todo] 1–80 characters",
    "nameRequired": "[el-todo] Name is required",
    "nameTooLong": "[el-todo] Name too long",
    "conceptLabel": "[el-todo] Concept",
    "conceptHelp": "[el-todo] Pick an archetype",
    "selectPrompt": "[el-todo] Select a concept",
    "concept": {
      "artist": "[el-todo] Artist",
      "networker": "[el-todo] Networker",
      "fugitive": "[el-todo] Fugitive",
      "negotiator": "[el-todo] Negotiator",
      "operative": "[el-todo] Operative",
      "pilot": "[el-todo] Pilot",
      "pioneer": "[el-todo] Pioneer",
      "preacher": "[el-todo] Preacher",
      "scientist": "[el-todo] Scientist",
      "sailor": "[el-todo] Sailor",
      "soldier": "[el-todo] Soldier"
    },
    "attribute": {
      "strength": "[el-todo] Strength",
      "agility": "[el-todo] Agility",
      "wits": "[el-todo] Wits",
      "empathy": "[el-todo] Empathy"
    },
    "skill": {
      "dexterity": "[el-todo] Dexterity",
      "force": "[el-todo] Force",
      "infiltration": "[el-todo] Infiltration",
      "manipulation": "[el-todo] Manipulation",
      "meleeCombat": "[el-todo] Melee Combat",
      "observation": "[el-todo] Observation",
      "rangedCombat": "[el-todo] Ranged Combat",
      "survival": "[el-todo] Survival",
      "command": "[el-todo] Command",
      "culture": "[el-todo] Culture",
      "dataDjinn": "[el-todo] Data Djinn",
      "medicurgy": "[el-todo] Medicurgy",
      "mysticPowers": "[el-todo] Mystic Powers",
      "pilot": "[el-todo] Pilot",
      "science": "[el-todo] Science",
      "technology": "[el-todo] Technology"
    },
    "hint": {
      "keyAttribute": "[el-todo] Key attribute",
      "keySkills": "[el-todo] Key skills",
      "reputation": "[el-todo] Reputation modifier"
    }
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

    <AppField :label="t('conceptLabel')" :help-text="t('conceptHelp')" required>
      <div class="step-concept__grid" role="radiogroup" :aria-label="t('conceptLabel')">
        <button
          v-for="c in CONCEPT_ORDER"
          :key="c"
          type="button"
          role="radio"
          :aria-checked="concept === c"
          class="step-concept__chip"
          :class="{ 'step-concept__chip--active': concept === c }"
          @click="pickConcept(c)"
        >
          {{ t(`concept.${c}`) }}
        </button>
      </div>
    </AppField>

    <div v-if="selectedInfo" class="step-concept__hint">
      <dl class="step-concept__hint-grid">
        <div class="step-concept__hint-row">
          <dt>{{ t('hint.keyAttribute') }}</dt>
          <dd>{{ t(`attribute.${selectedInfo.keyAttribute}`) }}</dd>
        </div>
        <div class="step-concept__hint-row">
          <dt>{{ t('hint.reputation') }}</dt>
          <dd>{{ repBadge(selectedInfo.reputationModifier) }}</dd>
        </div>
        <div class="step-concept__hint-row step-concept__hint-row--wide">
          <dt>{{ t('hint.keySkills') }}</dt>
          <dd>
            <span v-for="s in selectedInfo.keySkills" :key="s" class="step-concept__skill-pill">
              {{ t(`skill.${s}`) }}
            </span>
          </dd>
        </div>
      </dl>
    </div>
    <p v-else class="step-concept__select-prompt">
      {{ t('selectPrompt') }}
    </p>
  </div>
</template>

<style lang="scss" scoped>
  $step-form-max-width: 720px;
  $chip-min-width: 130px;

  .step-concept {
    display: flex;
    flex-direction: column;
    gap: var(--space-6);
    max-width: $step-form-max-width;
    margin: 0 auto;

    &__grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax($chip-min-width, 1fr));
      gap: var(--space-2);
    }

    &__chip {
      padding: var(--space-3) var(--space-4);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
      cursor: pointer;
      text-align: center;
      transition:
        border-color var(--motion-duration-fast) var(--motion-ease-standard),
        color var(--motion-duration-fast) var(--motion-ease-standard),
        background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        border-color: var(--brand-brass);
      }

      &--active {
        border-color: var(--brand-brass);
        background-color: var(--brand-brass-deep);
        color: var(--brand-brass-light);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    &__hint {
      padding: var(--space-4);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
    }

    &__hint-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: var(--space-3) var(--space-4);
      margin: 0;
    }

    &__hint-row {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);

      dt {
        font-family: var(--font-body);
        font-size: var(--type-body-xs-font-size);
        color: var(--brand-brass);
        text-transform: uppercase;
        letter-spacing: 0.14em;
      }

      dd {
        margin: 0;
        font-family: var(--font-mono);
        font-size: var(--type-body-md-font-size);
        font-weight: 700;
        color: var(--brand-brass-light);
      }

      &--wide {
        grid-column: 1 / -1;

        dd {
          display: flex;
          flex-wrap: wrap;
          gap: var(--space-2);
        }
      }
    }

    &__skill-pill {
      padding: var(--space-1) var(--space-3);
      background-color: var(--brand-brass-deep);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-pill);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      font-weight: 500;
      color: var(--brand-brass-light);
    }

    &__select-prompt {
      margin: 0;
      padding: var(--space-3) var(--space-4);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      font-style: italic;
      color: var(--text-secondary);
      background-color: var(--surface-night);
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-md);
    }
  }
</style>
