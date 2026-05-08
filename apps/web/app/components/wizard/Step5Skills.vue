<script setup lang="ts">
  import { computed } from 'vue';
  import type { Skills } from '@app/api-client-ts';

  const props = defineProps<Props>();
  const emit = defineEmits<{
    'update:skills': [value: Skills];
  }>();
  const GENERAL_POOL = 8;
  const ADVANCED_POOL = 2;
  const MAX_RANK = 3;

  interface Props {
    skills: Skills;
  }

  const { t } = useI18n({ useScope: 'local' });

  type GeneralSkillKey =
    | 'force'
    | 'meleeCombat'
    | 'dexterity'
    | 'infiltration'
    | 'rangedCombat'
    | 'observation'
    | 'survival'
    | 'manipulation';

  type AdvancedSkillKey =
    | 'command'
    | 'culture'
    | 'dataDjinn'
    | 'medicurgy'
    | 'mysticPowers'
    | 'pilot'
    | 'science'
    | 'technology';

  const GENERAL_KEYS: GeneralSkillKey[] = [
    'force',
    'meleeCombat',
    'dexterity',
    'infiltration',
    'rangedCombat',
    'observation',
    'survival',
    'manipulation',
  ];

  const ADVANCED_KEYS: AdvancedSkillKey[] = [
    'command',
    'culture',
    'dataDjinn',
    'medicurgy',
    'mysticPowers',
    'pilot',
    'science',
    'technology',
  ];

  const SKILL_ATTR: Record<keyof Skills, string> = {
    force: 'STR',
    meleeCombat: 'STR',
    dexterity: 'AGI',
    infiltration: 'AGI',
    rangedCombat: 'AGI',
    pilot: 'AGI',
    observation: 'WIT',
    survival: 'WIT',
    dataDjinn: 'WIT',
    medicurgy: 'WIT',
    science: 'WIT',
    technology: 'WIT',
    manipulation: 'EMP',
    command: 'EMP',
    culture: 'EMP',
    mysticPowers: 'EMP',
  };

  const generalSpent = computed<number>(() =>
    GENERAL_KEYS.reduce((s, k) => s + props.skills[k], 0),
  );

  const advancedSpent = computed<number>(() =>
    ADVANCED_KEYS.reduce((s, k) => s + props.skills[k], 0),
  );

  const generalRemaining = computed<number>(() => GENERAL_POOL - generalSpent.value);
  const advancedRemaining = computed<number>(() => ADVANCED_POOL - advancedSpent.value);

  function canIncrement(key: keyof Skills, pool: 'general' | 'advanced'): boolean {
    const rem = pool === 'general' ? generalRemaining.value : advancedRemaining.value;
    return props.skills[key] < MAX_RANK && rem > 0;
  }

  function canDecrement(key: keyof Skills): boolean {
    return props.skills[key] > 0;
  }

  function setSkill(key: keyof Skills, delta: 1 | -1, pool: 'general' | 'advanced'): void {
    if (delta === 1 && !canIncrement(key, pool)) return;
    if (delta === -1 && !canDecrement(key)) return;
    emit('update:skills', { ...props.skills, [key]: props.skills[key] + delta });
  }

  function onDotClick(key: keyof Skills, dotIdx: number, pool: 'general' | 'advanced'): void {
    // dotIdx is 0-based; clicking a filled dot clears to that level, clicking empty sets to dotIdx+1
    const newVal = dotIdx + 1 === props.skills[key] ? dotIdx : dotIdx + 1;
    const delta = newVal - props.skills[key];
    if (delta > 0) {
      const rem = pool === 'general' ? generalRemaining.value : advancedRemaining.value;
      if (newVal > MAX_RANK || delta > rem) return;
    }
    emit('update:skills', { ...props.skills, [key]: newVal });
  }
</script>

<i18n lang="json">
{
  "en": {
    "generalTitle": "General Skills",
    "advancedTitle": "Advanced Skills",
    "pointsLeft": "Points left",
    "hint": "General: {genPool} pts · Advanced: {advPool} pts · Max rank {max} each.",
    "skill": {
      "force": "Force",
      "meleeCombat": "Melee Combat",
      "dexterity": "Dexterity",
      "infiltration": "Infiltration",
      "rangedCombat": "Ranged Combat",
      "observation": "Observation",
      "survival": "Survival",
      "manipulation": "Manipulation",
      "command": "Command",
      "culture": "Culture",
      "dataDjinn": "Data Djinn",
      "medicurgy": "Medicurgy",
      "mysticPowers": "Mystic Powers",
      "pilot": "Pilot",
      "science": "Science!",
      "technology": "Technology"
    },
    "decrementAria": "Decrease {skill}",
    "incrementAria": "Increase {skill}"
  },
  "ru": {
    "generalTitle": "Общие навыки",
    "advancedTitle": "Продвинутые навыки",
    "pointsLeft": "Осталось",
    "hint": "Общие: {genPool} оч. · Продвинутые: {advPool} оч. · Макс. ранг {max}.",
    "skill": {
      "force": "Сила",
      "meleeCombat": "Рукопашный бой",
      "dexterity": "Ловкость",
      "infiltration": "Инфильтрация",
      "rangedCombat": "Дальний бой",
      "observation": "Наблюдение",
      "survival": "Выживание",
      "manipulation": "Манипуляция",
      "command": "Командование",
      "culture": "Культура",
      "dataDjinn": "Дата-джинн",
      "medicurgy": "Медицинские технологии",
      "mysticPowers": "Мистические силы",
      "pilot": "Пилот",
      "science": "Наука!",
      "technology": "Технология"
    },
    "decrementAria": "Уменьшить {skill}",
    "incrementAria": "Увеличить {skill}"
  },
  "uk": {
    "generalTitle": "[uk-todo] General Skills",
    "advancedTitle": "[uk-todo] Advanced Skills",
    "pointsLeft": "[uk-todo] Points left",
    "hint": "[uk-todo] General: {genPool} pts · Advanced: {advPool} pts · Max {max}.",
    "skill": {
      "force": "[uk-todo] Force",
      "meleeCombat": "[uk-todo] Melee Combat",
      "dexterity": "[uk-todo] Dexterity",
      "infiltration": "[uk-todo] Infiltration",
      "rangedCombat": "[uk-todo] Ranged Combat",
      "observation": "[uk-todo] Observation",
      "survival": "[uk-todo] Survival",
      "manipulation": "[uk-todo] Manipulation",
      "command": "[uk-todo] Command",
      "culture": "[uk-todo] Culture",
      "dataDjinn": "[uk-todo] Data Djinn",
      "medicurgy": "[uk-todo] Medicurgy",
      "mysticPowers": "[uk-todo] Mystic Powers",
      "pilot": "[uk-todo] Pilot",
      "science": "[uk-todo] Science!",
      "technology": "[uk-todo] Technology"
    },
    "decrementAria": "[uk-todo] Decrease {skill}",
    "incrementAria": "[uk-todo] Increase {skill}"
  },
  "el": {
    "generalTitle": "[el-todo] General Skills",
    "advancedTitle": "[el-todo] Advanced Skills",
    "pointsLeft": "[el-todo] Points left",
    "hint": "[el-todo] General: {genPool} pts · Advanced: {advPool} pts · Max {max}.",
    "skill": {
      "force": "[el-todo] Force",
      "meleeCombat": "[el-todo] Melee Combat",
      "dexterity": "[el-todo] Dexterity",
      "infiltration": "[el-todo] Infiltration",
      "rangedCombat": "[el-todo] Ranged Combat",
      "observation": "[el-todo] Observation",
      "survival": "[el-todo] Survival",
      "manipulation": "[el-todo] Manipulation",
      "command": "[el-todo] Command",
      "culture": "[el-todo] Culture",
      "dataDjinn": "[el-todo] Data Djinn",
      "medicurgy": "[el-todo] Medicurgy",
      "mysticPowers": "[el-todo] Mystic Powers",
      "pilot": "[el-todo] Pilot",
      "science": "[el-todo] Science!",
      "technology": "[el-todo] Technology"
    },
    "decrementAria": "[el-todo] Decrease {skill}",
    "incrementAria": "[el-todo] Increase {skill}"
  }
}
</i18n>

<template>
  <div class="step-skills">
    <p class="step-skills__hint">
      {{ t('hint', { genPool: GENERAL_POOL, advPool: ADVANCED_POOL, max: MAX_RANK }) }}
    </p>

    <div class="step-skills__cols">
      <!-- General skills -->
      <div class="step-skills__panel">
        <div class="step-skills__panel-header">
          <span class="step-skills__panel-title">{{ t('generalTitle') }}</span>
          <span
            class="step-skills__pool"
            :class="{ 'step-skills__pool--done': generalRemaining === 0 }"
          >
            {{ t('pointsLeft') }}: {{ generalRemaining }}
          </span>
        </div>

        <div v-for="key in GENERAL_KEYS" :key="key" class="step-skills__row">
          <span class="step-skills__name">{{ t(`skill.${key}`) }}</span>
          <span class="step-skills__attr">{{ SKILL_ATTR[key] }}</span>
          <div class="step-skills__dots" role="group" :aria-label="t(`skill.${key}`)">
            <span
              v-for="i in MAX_RANK"
              :key="i"
              class="step-skills__dot"
              :class="{ 'step-skills__dot--filled': i - 1 < skills[key] }"
              role="button"
              tabindex="0"
              :aria-pressed="i - 1 < skills[key]"
              @click="onDotClick(key, i - 1, 'general')"
              @keydown.enter.space.prevent="onDotClick(key, i - 1, 'general')"
            />
          </div>
          <span class="step-skills__val">{{ skills[key] }}</span>
          <div class="step-skills__btns">
            <button
              class="step-skills__btn"
              type="button"
              :disabled="!canDecrement(key)"
              :aria-label="t('decrementAria', { skill: t(`skill.${key}`) })"
              @click="setSkill(key, -1, 'general')"
            >
              &minus;
            </button>
            <button
              class="step-skills__btn"
              type="button"
              :disabled="!canIncrement(key, 'general')"
              :aria-label="t('incrementAria', { skill: t(`skill.${key}`) })"
              @click="setSkill(key, 1, 'general')"
            >
              &plus;
            </button>
          </div>
        </div>
      </div>

      <!-- Advanced skills -->
      <div class="step-skills__panel">
        <div class="step-skills__panel-header">
          <span class="step-skills__panel-title">{{ t('advancedTitle') }}</span>
          <span
            class="step-skills__pool"
            :class="{ 'step-skills__pool--done': advancedRemaining === 0 }"
          >
            {{ t('pointsLeft') }}: {{ advancedRemaining }}
          </span>
        </div>

        <div v-for="key in ADVANCED_KEYS" :key="key" class="step-skills__row">
          <span class="step-skills__name">{{ t(`skill.${key}`) }}</span>
          <span class="step-skills__attr">{{ SKILL_ATTR[key] }}</span>
          <div class="step-skills__dots" role="group" :aria-label="t(`skill.${key}`)">
            <span
              v-for="i in MAX_RANK"
              :key="i"
              class="step-skills__dot"
              :class="{ 'step-skills__dot--filled': i - 1 < skills[key] }"
              role="button"
              tabindex="0"
              :aria-pressed="i - 1 < skills[key]"
              @click="onDotClick(key, i - 1, 'advanced')"
              @keydown.enter.space.prevent="onDotClick(key, i - 1, 'advanced')"
            />
          </div>
          <span class="step-skills__val">{{ skills[key] }}</span>
          <div class="step-skills__btns">
            <button
              class="step-skills__btn"
              type="button"
              :disabled="!canDecrement(key)"
              :aria-label="t('decrementAria', { skill: t(`skill.${key}`) })"
              @click="setSkill(key, -1, 'advanced')"
            >
              &minus;
            </button>
            <button
              class="step-skills__btn"
              type="button"
              :disabled="!canIncrement(key, 'advanced')"
              :aria-label="t('incrementAria', { skill: t(`skill.${key}`) })"
              @click="setSkill(key, 1, 'advanced')"
            >
              &plus;
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  // Named SCSS layout variables — permitted escape hatch for pixel dimensions.
  $dot-size: 12px;
  $skills-max-width: 1080px;
  $skill-col-attr: 36px;
  $skill-col-val: 28px;
  $skill-col-ctrl: 72px;
  $btn-size: 28px;

  .step-skills {
    &__hint {
      margin: 0 0 var(--space-6);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
      text-align: center;
    }

    &__cols {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: var(--space-5);
      max-width: $skills-max-width;
      margin: 0 auto;

      @media (max-width: 768px) {
        grid-template-columns: 1fr;
      }
    }

    &__panel {
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      padding: var(--space-5);
    }

    &__panel-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: var(--space-4);
      padding-bottom: var(--space-3);
      border-bottom: 1px solid var(--brand-brass-shadow);
    }

    &__panel-title {
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      font-weight: var(--type-display-sm-font-weight);
      color: var(--brand-brass-light);
      text-transform: uppercase;
      letter-spacing: 0.1em;
    }

    &__pool {
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--brand-brass);
      text-transform: uppercase;
      letter-spacing: 0.12em;

      &--done {
        color: var(--state-success);
      }
    }

    &__row {
      display: grid;
      grid-template-columns: 1fr $skill-col-attr auto $skill-col-val $skill-col-ctrl;
      align-items: center;
      gap: var(--space-2);
      padding: var(--space-2) 0;
      border-bottom: 1px solid color-mix(in srgb, var(--brand-brass) 20%, transparent);

      &:last-child {
        border-bottom: none;
      }
    }

    &__name {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
    }

    &__attr {
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--brand-brass);
      text-transform: uppercase;
      letter-spacing: 0.12em;
      text-align: center;
    }

    &__dots {
      display: flex;
      gap: var(--space-1);
      align-items: center;
    }

    &__dot {
      width: $dot-size;
      height: $dot-size;
      border-radius: var(--radius-pill);
      border: 1px solid var(--brand-brass-shadow);
      background-color: transparent;
      cursor: pointer;
      flex-shrink: 0;
      transition: background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &--filled {
        background-color: var(--brand-brass);
        border-color: var(--brand-brass);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    &__val {
      font-family: var(--font-mono);
      font-size: var(--type-body-md-font-size);
      color: var(--text-primary);
      text-align: center;
    }

    &__btns {
      display: flex;
      gap: var(--space-1);
      justify-content: flex-end;
    }

    &__btn {
      width: $btn-size;
      height: $btn-size;
      display: flex;
      align-items: center;
      justify-content: center;
      background: transparent;
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-sm);
      color: var(--brand-brass);
      font-size: var(--type-body-md-font-size);
      cursor: pointer;
      transition:
        border-color var(--motion-duration-fast) var(--motion-ease-standard),
        color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover:not(:disabled) {
        border-color: var(--brand-brass);
        color: var(--brand-brass-light);
      }

      &:disabled {
        opacity: 0.3;
        cursor: not-allowed;
      }
    }
  }
</style>
